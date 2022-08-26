import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/rooms/RoomInfo.dart';
import 'package:fostr/pages/user/BookClubRooms.dart';
import 'package:fostr/screen/ReportContent.dart';
import 'package:fostr/services/RecordingService.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/pages/rooms/ThemePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/RoomService.dart';

import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../providers/FeedProvider.dart';
import '../../providers/RoomsMetaProvider.dart';

class LiveRooms extends StatefulWidget {
  const LiveRooms(this.ind, this.userid);
  final int ind;
  final String userid;

  @override
  State<LiveRooms> createState() => _LiveRoomsState();
}

class _LiveRoomsState extends State<LiveRooms> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    print(auth.subscribedBookClubs);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collectionGroup('rooms')
            .where("isActive", isEqualTo: true)
            .where("dateTime",
                isGreaterThanOrEqualTo:
                    DateTime.now().toUtc().subtract(Duration(minutes: 90)))
            .where("dateTime",
                isLessThanOrEqualTo:
                    DateTime.now().toUtc().add(Duration(minutes: 10)))
            .where("isUpcoming", isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: AppLoading(
                height: 150,
                width: 150,
              ));
            default:
              if (snapshot.data?.size == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: const Text(
                        "No Active Rooms",
                      ),
                    ),
                  ),
                );
              }
              if (widget.ind == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final room = snapshot.data!.docs[index].data();

                      if (room["isBookClub"]) {
                        bool isMember = auth.subscribedBookClubs
                            .contains(room["bookClubId"]);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: BookClubRoomCardSingle(
                              room, Room.fromJson(room, ""), isMember),
                        );
                      }

                      return LiveRoomCardSingle(
                          room, Room.fromJson(room, ""), "room",auth.user!.id);
                    },
                  ),
                );
              } else {
                final myRooms = snapshot.data!.docs
                    .where((element) => element.data()['id'] == widget.userid)
                    .toList();
                if (myRooms.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: const Text(
                          "No Active Rooms",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: myRooms.length,
                    itemBuilder: (context, index) {
                      final room = snapshot.data!.docs[index].data();
                      print(
                          "element id = ${snapshot.data!.docs[index].data()['id']}");
                      if (room["isBookClub"]) {
                        bool isMember = auth.subscribedBookClubs
                            .contains(room["bookClubId"]);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: BookClubRoomCardSingle(
                              room, Room.fromJson(room, ""), isMember),
                        );
                      }
                      return LiveRoomCardSingle(
                          room, Room.fromJson(room, ""), "room",auth.user!.id);
                    },
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

// class LiveRoomCards extends StatefulWidget {
//   const LiveRoomCards(this.id, this.ind, this.userid);
//   final String id;
//   final int ind;
//   final String userid;

//   @override
//   State<LiveRoomCards> createState() => _LiveRoomCardsState();
// }

// class _LiveRoomCardsState extends State<LiveRoomCards> {
//   @override
//   void initState() {
//     super.initState();
//     // setState(() {
//     //   Empty.count = 0;
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final roomsMeta = Provider.of<RoomsMetaProvider>(context);

//     return StreamBuilder<QuerySnapshot>(
//       stream: widget.ind == 1
//           ? FirebaseFirestore.instance
//               .collection('rooms/${widget.id}/rooms')
//               .orderBy('dateTime', descending: true)
//               .where("id", isEqualTo: widget.userid)
//               .where("isUpcoming", isEqualTo: false)
//               .where("isActive", isEqualTo: true)
//               .snapshots()
//           : FirebaseFirestore.instance
//               .collection('rooms/${widget.id}/rooms')
//               .where("isUpcoming", isEqualTo: false)
//               .where("isActive", isEqualTo: true)
//               .orderBy('dateTime', descending: true)
//               .limit(8)
//               .snapshots(),
//       builder: (context, AsyncSnapshot snapshot) {
//         // print("--------------------------------");
//         // print(snapshot.data);
//         // print("--------------------------------");

//         if (!snapshot.hasData) {
//           print("nodata");
//           return SizedBox.shrink();
//         }
//         List rev = [];

//         return snapshot.data!.docs.length == 0
//             ? Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   children: [
//                     const Text(
//                       //  "No active rooms",
//                       "",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               )
//             : ListView.builder(
//                 physics: ClampingScrollPhysics(),
//                 shrinkWrap: true,
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   rev.add(snapshot.data!.docs[index].data());
//                   var room = snapshot.data!.docs[index].data();
//                   final roomModel = Room.fromJson(room, "");

//                   final x = roomModel.dateTime!.toUtc().isAfter(
//                       DateTime.now().toUtc().subtract(Duration(minutes: 90)));
//                   final y = roomModel.dateTime!.toUtc().isBefore(
//                       DateTime.now().toUtc().add(Duration(minutes: 10)));

//                   if (x && y) {
//                     if (snapshot.data!.docs[index]
//                         .data()
//                         .toString()
//                         .isNotEmpty) {
//                       return LiveRoomCardSingle(
//                           snapshot.data!.docs[index].data(),
//                           Room.fromJson(room, ""),
//                           "room");
//                     } else {
//                       return Container(
//                         child: Text(
//                           // "No active rooms",
//                           "",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       );
//                     }
//                   } else {
//                     return SizedBox.shrink();
//                   }
//                 },
//               );
//       },
//     );
//   }
// }

class LiveRoomCardSingle extends StatefulWidget {
  const LiveRoomCardSingle(this.data, this.room, this.type, this.authID);
  final Map<String, dynamic> data;
  final String type;
  final String authID; // random string, only required for All tab in hallway
  final Room room;

  @override
  State<LiveRoomCardSingle> createState() => _LiveRoomCardSingleState();
}

class _LiveRoomCardSingleState extends State<LiveRoomCardSingle> {
  bool active = true;
  bool authorActive = true;
  bool isBlocked = false;

  RecordingService _recordingService = GetIt.I<RecordingService>();

  @override
  void initState() {
    super.initState();
    checkIfUserIsInactive();
    checkIfUserIsBlocked(widget.authID);
  }

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: widget.data["id"])
        .where('accDeleted', isEqualTo: true)
        .limit(1)
        .get()
        .then((value){
      if(value.docs.length == 1){
        if(value.docs.first['accDeleted']){
          setState(() {
            authorActive = false;
          });
        }
      }
    });
  }

  void checkIfUserIsBlocked(String authId) async {
    await FirebaseFirestore.instance
        .collection("block tracking")
        .doc(authId)
        .collection('block_list')
        .where('blockedId', isEqualTo: widget.data["id"])
        .limit(1)
        .get()
        .then((value){
      if(value.docs.length == 1){
        if(value.docs.first['isBlocked']){
          setState(() {
            isBlocked = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final RoomService _roomService = GetIt.I<RoomService>();
    final user = auth.user!;

    return authorActive && !isBlocked ?
    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("rooms")
            .doc(widget.room.id)
            .collection("rooms")
            .doc(widget.room.roomID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return SizedBox.shrink();
            default:
              return snapshot.data?.data()?["isActive"] ?? false
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 18),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: widget.data["image"] == ''
                                    ? Image.asset(IMAGES + "logo_white.png")
                                        .image
                                    : NetworkImage(
                                        widget.data['image']
                                        // .toString().replaceAll(
                                        // "https://firebasestorage.googleapis.com",
                                        // "https://ik.imagekit.io/fostrreads"
                                        // )
                                        ,
                                      )),
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
                            gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.9)
                                ],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //title
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "drawerhead"),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.black45,
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    child: Text(widget.data['genre'] ?? "",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "drawerbody")),
                                  ),
                                ],
                              ),

                              //author and info
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      "by " + widget.data['roomCreator'],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: "drawerbody"),
                                    ),
                                    Expanded(child: Container()),
                                    GestureDetector(
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
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 24,
                              ),

                              //count of participants
                              Row(
                                children: [
                                  // CircleAvatar(
                                  //   backgroundImage: NetworkImage(
                                  //       'https://www.pngarts.com/files/6/User-Avatar-in-Suit-PNG.png'),
                                  // ),
                                  StreamBuilder(
                                    stream: roomCollection
                                        .doc(widget.data['id'])
                                        .collection("rooms")
                                        .doc(widget.data['roomID'])
                                        .collection("speakers")
                                        .where("isActiveInRoom",
                                            isEqualTo: true)
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        return CircleAvatar(
                                          backgroundColor: Colors.black26,
                                          child: Text(snapshot.data!.docs.length
                                              .toString()),
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

                              //peek in
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (widget.room.id ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid ||
                                          widget.data['inviteOnly'] != true)
                                        MaterialButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ThemePage(
                                                  room: Room.fromJson(
                                                      widget.data,
                                                      widget.type == "all"
                                                          ? "change"
                                                          : ""),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Peek In',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontFamily: "drawerbody"),
                                          ),
                                          color: theme.colorScheme.secondary,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      // SizedBox(
                                      //   width: MediaQuery.of(context).size.width*0.4,
                                      // ),
                                      if (widget.data['followersOnly'] ==
                                              true ||
                                          widget.data['inviteOnly'] ==
                                              true) ...[
                                        Chip(
                                          label: Text(
                                              widget.data['inviteOnly'] == true
                                                  ? 'Invite Only'
                                                  : 'Followers Only'),
                                          backgroundColor:
                                              Colors.grey[300]!.withOpacity(.5),
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                        ),
                                      ]
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      children: [
                                        widget.data["isBookClub"] == true
                                            ? Icon(Icons.menu_book_outlined,
                                                size: 30, color: Colors.white)
                                            : Container(),
                                        widget.data["button toggle"] == 'true'
                                            ? Icon(Icons.face,
                                                size: 30, color: Colors.white)
                                            : Container(),

                                        //delete
                                        user.id == widget.data['id']
                                            ? IconButton(
                                                onPressed: () async {
                                                  // _roomService.updateIsActive(room);
                                                  QuerySnapshot _myDoc =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("rooms")
                                                          .doc(
                                                              widget.data['id'])
                                                          .collection("rooms")
                                                          .doc(widget
                                                              .data['roomID'])
                                                          .collection(
                                                              "speakers")
                                                          .where(
                                                              "isActiveInRoom",
                                                              isEqualTo: true)
                                                          .get();
                                                  List<DocumentSnapshot>
                                                      _myDocCount = _myDoc.docs;

                                                  if (_myDocCount.length > 0) {
                                                    confirmDialog(
                                                        context,
                                                        const TextStyle(
                                                            fontSize: 16,
                                                            color: Color(
                                                                0xff000000),
                                                            fontFamily:
                                                                "drawerbody"));
                                                  } else {
                                                    await _roomService
                                                        .updateIsActive(
                                                            widget.room);
                                                    _recordingService
                                                        .deleteRecordingInfo(
                                                            widget.room.roomID!,
                                                            widget.room.id!);
                                                    final feedProvider =
                                                        Provider.of<
                                                                FeedProvider>(
                                                            context,
                                                            listen: false);
                                                    feedProvider
                                                        .refreshFeed(true);
                                                    // setState(() {
                                                    //   active = false;
                                                    // });
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.delete_outline_outlined,
                                                  color: Colors.white,
                                                  size: 30,
                                                ))
                                            : SizedBox.shrink(),

                                        //share
                                        user.id == widget.data['id']
                                            ? IconButton(
                                            onPressed: () async {

                                              Share.share(await DynamicLinksApi.inviteOnlyRoomLink(
                                                widget.room.roomID!,
                                                widget.room.id!,
                                                roomName: widget.room.title!,
                                                imageUrl: widget.room.imageUrl,
                                                creatorName: widget.room.roomCreator ?? "",
                                              ));

                                            },
                                            icon: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                                            // Icon(
                                            //   Icons.share,
                                            //   color: Colors.white,
                                            //   size: 30,
                                            // )
                                        )
                                            : SizedBox.shrink(),

                                        //report
                                        user.id != widget.data['id']
                                            ? IconButton(
                                            onPressed: () async {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportContent(
                                                            contentId: widget.room.roomID!,
                                                            contentType: 'Room',
                                                            contentOwnerId: widget.room.id!,
                                                          )
                                                  ));
                                            },
                                            icon: Icon(
                                              Icons.flag,
                                              color: Colors.red,
                                              size: 20,
                                            ))
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink();
          }
        }) :
    SizedBox.shrink();
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
