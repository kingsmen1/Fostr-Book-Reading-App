import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/pages/rooms/RoomInfo.dart';
import 'package:fostr/pages/rooms/ThemePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/FeedProvider.dart';
import 'package:fostr/services/RecordingService.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'RoomRecordings.dart';

class UserTheatres extends StatelessWidget {
  const UserTheatres(this.ind, this.userid);
  final int ind;
  final String userid;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .where("id", isEqualTo: userid)
            // .where("isActive", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Text(
                    // "No active rooms",
                    "",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          List l = [];

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: AppLoading(
                height: 70,
                width: 70,
              ));

            default:
              return snapshot.data!.docs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "No active theatre",
                            // "",
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length + 1,
                      itemBuilder: (context, index) {
                        snapshot.data!.docs.forEach((element) {
                          print(element.data());
                        });
                        if (index == snapshot.data!.docs.length) {
                          return Container(
                            height: 200,
                          );
                        }
                        l.add(snapshot.data!.docs[index].id);
                        return LiveUserTheatreCards(
                            snapshot.data!.docs[index].id, ind, userid);
                      },
                    );
          }
        },
      ),
    );
  }
}

class LiveUserTheatreCards extends StatelessWidget {
  const LiveUserTheatreCards(this.id, this.ind, this.userid);
  final String id;
  final int ind;
  final String userid;
  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthProvider>(context);
    print(id);
    print(userid);
    return StreamBuilder<QuerySnapshot>(
      stream: //ind == 1?
          FirebaseFirestore.instance
              .collection('rooms')
              .doc(id)
              .collection("amphitheatre")
              .where("isUpcoming", isEqualTo: false)
              .where("isDeleted", isEqualTo: false)
              .orderBy('scheduledOn', descending: true)
              .snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 0,
            width: 0,
          );
        }
        List rev = [];

        return Column(
          children: [
            SizedBox(
              height: 10,
            ),
            snapshot.data!.docs.length == 0
                ? Text(
                    "No active theatre",
                  )
                : ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      rev.add(snapshot.data!.docs[index].data());
                      // print(rev);
                      // rev.sort();
                      var room = snapshot.data!.docs[index].data();
                      print("----------");
                      print(room);
                      // rev.sort((a, b) =>
                      //     DateTime.parse(b.dateTime).compareTo(DateTime.parse(a.dateTime)));
                      // print("--------------room---------------$room");
                      return LiveUserTheatreCardSingle(
                          snapshot.data!.docs[index].data(),
                          Theatre.fromJson(room, ""),
                          "room");
                    },
                  ),
            SizedBox(
              height: 100,
            )
          ],
        );
      },
    );
  }
}

class LiveUserTheatreCardSingle extends StatefulWidget {
  const LiveUserTheatreCardSingle(this.data, this.room, this.type);
  final Map<String, dynamic> data;
  final String type; // random string, only required for All tab in hallway
  final Theatre room;

  @override
  State<LiveUserTheatreCardSingle> createState() =>
      _LiveUserTheatreCardSingleState();
}

class _LiveUserTheatreCardSingleState extends State<LiveUserTheatreCardSingle> {
  bool active = true;

  final RecordingService _recordingService = GetIt.I<RecordingService>();

  bool isRecordingAvaialble = false;
  late StreamSubscription recordingChecker;

  Future<void> checkIfRecordingAvaiavle() async {
    recordingChecker = FirebaseFirestore.instance
        .collection("recordings")
        .where("roomId", isEqualTo: widget.room.theatreId)
        .where("isActive", isEqualTo: true)
        .snapshots()
        .listen((value) {
      if (value.docs.length > 0) {
        if (mounted) {
          setState(() {
            isRecordingAvaialble = true;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfRecordingAvaiavle();
    print("objectsss");
  }

  @override
  void dispose() {
    recordingChecker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final user = auth.user!;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rooms")
            .doc(widget.room.createdBy)
            .collection("amphitheatre")
            .doc(widget.room.theatreId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return SizedBox.shrink();

            default:
              return !snapshot.data?.get("isDeleted")
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
                                    child: Text(widget.data['genre'],
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
                                      "by " +
                                          ((widget.data['creatorUsername']
                                                      .toString() ==
                                                  'null')
                                              ? ""
                                              : widget.data[
                                                      'creatorUsername'] ??
                                                  ""),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: "drawerbody"),
                                    ),
                                    Spacer(),
                                    (isRecordingAvaialble)
                                        ? IconButton(
                                            icon: Icon(Icons.podcasts),
                                            color: Colors.white,
                                            iconSize: 28,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RoomRecorings(
                                                    id: widget.room.createdBy!,
                                                    roomId:
                                                        widget.room.theatreId!,
                                                    type: RecordingType
                                                        .AMPHITHEATRE,
                                                  ),
                                                ),
                                              );
                                            })
                                        : SizedBox.shrink(),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      RoomInfo(
                                                        data: widget.data,
                                                        type: "activity",
                                                        insideRoom: false,
                                                      )));
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
                                        .doc(widget.data['createdBy'])
                                        .collection("amphitheatre")
                                        .doc(widget.data['theatreId'])
                                        .collection("users")
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
                                        user.id == widget.data['createdBy']
                                            ? IconButton(
                                                onPressed: () async {
                                                  // _roomService.updateIsActive(room);
                                                  QuerySnapshot _myDoc =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("rooms")
                                                          .doc(widget.data[
                                                              'createdBy'])
                                                          .collection(
                                                              "amphitheatre")
                                                          .doc(widget.data[
                                                              'theatreId'])
                                                          .collection("users")
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
                                                    await TheatreService()
                                                        .updateIsDelete(
                                                            widget.room);
                                                    await _recordingService
                                                        .deleteRecordingInfo(
                                                      widget.room.theatreId!,
                                                      widget.room.createdBy!,
                                                    );
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
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 5),
                  //   child: Container(
                  //     margin: EdgeInsets.symmetric(
                  //         horizontal: MediaQuery
                  //             .of(context)
                  //             .size
                  //             .width * 0.05),
                  //     decoration: BoxDecoration(
                  //         image: DecorationImage(
                  //             fit: BoxFit.cover,
                  //             image: widget.data["image"] == ''
                  //                 ? Image
                  //                 .asset(IMAGES + "logo_white.png")
                  //                 .image
                  //                 : NetworkImage(
                  //               widget.data['image']
                  //               ,
                  //             )),
                  //         gradient: LinearGradient(
                  //           begin: Alignment.topLeft,
                  //           end: Alignment.bottomRight,
                  //           colors: [
                  //             gradientBottom,
                  //             gradientTop,
                  //           ],
                  //         ),
                  //         borderRadius: BorderRadius.circular(10)),
                  //     child: Container(
                  //       padding: const EdgeInsets.all(16),
                  //       decoration: BoxDecoration(
                  //         gradient: LinearGradient(colors: [
                  //           Colors.black.withOpacity(0.2),
                  //           Colors.black.withOpacity(0.9)
                  //         ], begin: Alignment.centerRight, end: Alignment.centerLeft),
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           //title and genre
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Flexible(
                  //                 fit: FlexFit.loose,
                  //                 child: Text(
                  //                   widget.data['title'],
                  //                   overflow: TextOverflow.fade,
                  //                   maxLines: 2,
                  //                   softWrap: false,
                  //                   style: TextStyle(
                  //                       color: Colors.white,
                  //                       fontSize: 20,
                  //                       fontWeight: FontWeight.bold,
                  //                       fontFamily: "drawerhead"),
                  //                 ),
                  //               ),
                  //               SizedBox(
                  //                 width: 10,
                  //               ),
                  //               Container(
                  //                 padding: const EdgeInsets.all(8),
                  //                 decoration: BoxDecoration(
                  //                     color: Colors.black45,
                  //                     border: Border.all(width: 1, color: Colors.black),
                  //                     borderRadius: BorderRadius.circular(24)),
                  //                 child: Text(widget.data['genre'],
                  //                     style: TextStyle(
                  //                         color: Colors.white,
                  //                         fontWeight: FontWeight.bold,
                  //                         fontFamily: "drawerbody")),
                  //               ),
                  //             ],
                  //           ),
                  //
                  //           //author name
                  //           Text(
                  //             "by " + widget.data['roomCreator'],
                  //             overflow: TextOverflow.ellipsis,
                  //             style: TextStyle(
                  //                 color: Colors.white,
                  //                 fontSize: 12,
                  //                 fontFamily: "drawerbody"),
                  //           ),
                  //           const SizedBox(
                  //             height: 10,
                  //           ),
                  //
                  //           //speaker count
                  //           Row(
                  //             children: [
                  //               Text(
                  //                 "speaker count : ",
                  //                 style: TextStyle(
                  //                     color: Colors.white,
                  //                     fontFamily: "drawerbody",
                  //                     fontStyle: FontStyle.italic,
                  //                     fontSize: 10),
                  //               ),
                  //               StreamBuilder<DocumentSnapshot>(
                  //                 stream: roomCollection
                  //                     .doc(widget.data['id'])
                  //                     .collection("rooms")
                  //                     .doc(widget.data['roomID'])
                  //                     .snapshots(),
                  //                 builder: (BuildContext context, snapshot) {
                  //                   if (snapshot.hasData) {
                  //                     print(
                  //                         "--------------speakersCount : ${snapshot
                  //                             .data!
                  //                             .get("speakersCount")
                  //                             .toString()}----------------");
                  //                     return Text(
                  //                       snapshot.data!.get("speakersCount").toString(),
                  //                       style: TextStyle(
                  //                           color: Colors.white,
                  //                           fontFamily: "drawerbody",
                  //                           fontStyle: FontStyle.italic,
                  //                           fontSize: 10),
                  //                     );
                  //                   } else {
                  //                     return Container(
                  //                       width: 0.0,
                  //                       height: 0.0,
                  //                     );
                  //                   }
                  //                 },
                  //               ),
                  //             ],
                  //           ),
                  //           const SizedBox(
                  //             height: 8,
                  //           ),
                  //
                  //           //summary
                  //           RoomSummary(
                  //             data: widget.data,
                  //           ),
                  //
                  //           //chips and delete
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Row(
                  //                 children: [
                  //                   if (widget.data['followersOnly'] == true ||
                  //                       widget.data['inviteOnly'] == true) ...[
                  //                     Chip(
                  //                       label: Text(widget.data['inviteOnly'] == true
                  //                           ? 'Invite Only'
                  //                           : 'Followers Only'),
                  //                       backgroundColor:
                  //                       Colors.grey[300]!.withOpacity(.5),
                  //                       elevation: 0,
                  //                       shadowColor: Colors.transparent,
                  //                     ),
                  //                   ]
                  //                 ],
                  //               ),
                  //               Align(
                  //                 alignment: Alignment.bottomRight,
                  //                 child: Row(
                  //                   children: [
                  //                     widget.data["isBookClub"] == true
                  //                         ? Icon(Icons.menu_book_outlined,
                  //                         size: 30, color: Colors.white)
                  //                         : Container(),
                  //                     widget.data["button toggle"] == 'true'
                  //                         ? Icon(Icons.face,
                  //                         size: 30, color: Colors.white)
                  //                         : Container(),
                  //                     user.id == widget.data['id']
                  //                         ? IconButton(
                  //                         onPressed: () async {
                  //                           // _roomService.updateIsActive(room);
                  //                           QuerySnapshot _myDoc =
                  //                           await FirebaseFirestore.instance
                  //                               .collection("rooms")
                  //                               .doc(widget.data['id'])
                  //                               .collection("rooms")
                  //                               .doc(widget.data['roomID'])
                  //                               .collection("speakers")
                  //                               .where("isActiveInRoom",
                  //                               isEqualTo: true)
                  //                               .get();
                  //                           List<DocumentSnapshot> _myDocCount =
                  //                               _myDoc.docs;
                  //                           print(_myDocCount.length);
                  //                           if (_myDocCount.length > 0) {
                  //                             confirmDialog(
                  //                                 context,
                  //                                 const TextStyle(
                  //                                     fontSize: 16,
                  //                                     color: Color(0xff000000),
                  //                                     fontFamily: "drawerbody"));
                  //                           } else {
                  //                             _roomService
                  //                                 .updateIsActive(widget.room);
                  //                             // setState(() {
                  //                             //   active = false;
                  //                             // });
                  //                           }
                  //                         },
                  //                         icon: Icon(
                  //                           Icons.delete_outline_outlined,
                  //                           color: Colors.white,
                  //                           size: 30,
                  //                         ))
                  //                         : SizedBox.shrink(),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // )
                  : SizedBox.shrink();
          }
        });
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

class RoomSummary extends StatefulWidget {
  final Map<String, dynamic> data;
  const RoomSummary({Key? key, required this.data}) : super(key: key);

  @override
  _RoomSummaryState createState() => _RoomSummaryState();
}

class _RoomSummaryState extends State<RoomSummary> {
  bool ellipsis = true;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: roomCollection
            .doc(widget.data['id'])
            .collection("rooms")
            .doc(widget.data['roomID'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.get("summary") != "") {
            return GestureDetector(
              onTap: () {
                setState(() {
                  ellipsis = !ellipsis;
                });
              },
              child: ellipsis
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          snapshot.data!.get("summary"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "drawerbody",
                              fontStyle: FontStyle.italic,
                              fontSize: 12),
                        ),
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          snapshot.data!.get("summary"),
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "drawerbody",
                              fontStyle: FontStyle.italic,
                              fontSize: 12),
                        ),
                      ),
                    ),
            );
          } else {
            return Container(
              width: 0.0,
              height: 0.0,
            );
          }
        });
  }
}
