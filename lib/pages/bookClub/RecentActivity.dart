import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/pages/rooms/RoomInfo.dart';
import 'package:fostr/pages/rooms/ThemePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class RecentActivity extends StatefulWidget {
  final BookClubModel bookClubModel;
  const RecentActivity({Key? key, required this.bookClubModel})
      : super(key: key);

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  Future<QuerySnapshot<Map<String, dynamic>>> getRecentActivity() async {
    return await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.bookClubModel.createdBy)
        .collection("rooms")
        .where("bookClubId", isEqualTo: widget.bookClubModel.id)
        .orderBy("dateTime", descending: true)
        .limit(1)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          "Recent Activity",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: getRecentActivity(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                child: Text("Error"),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data?.docs.length == 0) {
              return Center(
                child: Text("No Activities"),
              );
            }

            final rawRoom = snapshot.data?.docs.first.data();
            return BookClubRoomCardSingle(
              rawRoom!,
              Room.fromJson(rawRoom, ""),
              auth.subscribedBookClubs.contains(widget.bookClubModel.id),
            );
          },
        ),
      ),
    );
  }
}

class BookClubRoomCardSingle extends StatefulWidget {
  const BookClubRoomCardSingle(this.data, this.room, this.isSubscribed);
  final Map<String, dynamic> data;
  final Room room;
  final bool isSubscribed;

  @override
  State<BookClubRoomCardSingle> createState() => _BookClubRoomCardSingleState();
}

class _BookClubRoomCardSingleState extends State<BookClubRoomCardSingle> {
  bool isMember = false;

  final RoomService _roomService = GetIt.I<RoomService>();
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    isMember = widget.isSubscribed;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      constraints: BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: widget.data["image"] == ''
                  ? Image.asset(IMAGES + "logo_white.png").image
                  : FosterImageProvider(
                      imageUrl: widget.data['image'],
                      cachedKey: widget.data["image"])),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientBottom,
              gradientTop,
            ],
          ),
          borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.9)
          ], begin: Alignment.centerRight, end: Alignment.centerLeft),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    widget.data['title'],
                    overflow: TextOverflow.fade,
                    maxLines: 2,
                    softWrap: false,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(24)),
                  child: Text(widget.data['genre'],
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "by " + widget.data['roomCreator'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: "Lato",
                  ),
                ),
                (widget.room.isActive == true)
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => RoomInfo(
                                data: widget.data,
                                insideRoom: false,
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                        ))
                    : SizedBox.shrink()
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                // CircleAvatar(
                //   backgroundImage: NetworkImage(
                //       'https://www.pngarts.com/files/6/User-Avatar-in-Suit-PNG.png'),
                // ),
                FutureBuilder(
                  future: roomCollection
                      .doc(widget.data['id'])
                      .collection("rooms")
                      .doc(widget.data['roomID'])
                      .collection("speakers")
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasData) {
                      return CircleAvatar(
                        backgroundColor: Colors.black26,
                        child: Text(snapshot.data!.docs.length.toString()),
                      );
                    } else {
                      return Container(
                        width: 0.0,
                        height: 0.0,
                      );
                    }
                  },
                ),
                // CircleAvatar(
                //   backgroundColor: Colors.black26,
                //   child: Text("${data["participantsCount"]+ data["speakersCount"]}"),
                // ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (widget.room.isActive == true)
                    ? PeekInButton(
                        room: widget.room,
                        isMember: isMember,
                        membersOnly: widget.data["membersOnly"],
                        data: widget.data,
                      )
                    : SizedBox.shrink(),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width*0.4,
                // ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [
                      widget.data["isBookClub"] == true
                          ? Icon(Icons.menu_book_outlined,
                              size: 30, color: Colors.white)
                          : Container(),
                      widget.data["button toggle"] == 'true'
                          ? Icon(Icons.face, size: 30, color: Colors.white)
                          : Container(),
                      user.id == widget.data['id']
                          ? IconButton(
                              onPressed: () async {
                                // _roomService.updateIsActive(room);
                                QuerySnapshot _myDoc = await FirebaseFirestore
                                    .instance
                                    .collection("rooms")
                                    .doc(widget.data['id'])
                                    .collection("rooms")
                                    .doc(widget.data['roomID'])
                                    .collection("speakers")
                                    .where("isActiveInRoom", isEqualTo: true)
                                    .get();
                                List<DocumentSnapshot> _myDocCount =
                                    _myDoc.docs;
                                print(_myDocCount.length);
                                if (_myDocCount.length > 0) {
                                  confirmDialog(
                                      context,
                                      const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff000000),
                                        fontFamily: "Lato",
                                      ));
                                } else {
                                  _roomService.updateIsActive(widget.room);
                                }
                              },
                              icon: Icon(
                                Icons.delete_outline_outlined,
                                color: Colors.white,
                                size: 30,
                              ))
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> confirmDialog(BuildContext context, TextStyle h2) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Container(
          height: size.height,
          width: size.width,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Align(
              alignment: Alignment(0, 0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: size.width * 0.9,
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cannot delete the room with speakers inside the room.',
                        style: h2.copyWith(
                          fontSize: 15.sp,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  GlobalColors.signUpSignInButton),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              "Ok",
                              style: h2.copyWith(
                                fontSize: 17.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PeekInButton extends StatelessWidget {
  final Room room;
  final Map<String, dynamic> data;
  final bool isMember;
  final bool membersOnly;
  const PeekInButton({
    Key? key,
    required this.room,
    required this.isMember,
    required this.membersOnly,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (membersOnly && auth.user!.id != room.id && !isMember) {
      return MaterialButton(
        onPressed: null,
        child: Text(
          'Members Only Room',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        color: Color(0xff2A9D8F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );
    }
    return MaterialButton(
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => ThemePage(
              room: Room.fromJson(data, ""),
            ),
          ),
        );
      },
      child: Text(
        'Peek in',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
      color: Color(0xff2A9D8F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
