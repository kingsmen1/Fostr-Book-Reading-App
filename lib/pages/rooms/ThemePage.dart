import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/pages/rooms/SelectTheme.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:provider/provider.dart';

class ThemePage extends StatefulWidget with FostrTheme {
  final Room room;
  ThemePage({Key? key, required this.room}) : super(key: key);

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  late Future<QuerySnapshot<Map<String, dynamic>>>? roomSpeakers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
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
              final x = snapshot.data!.get("dateTime").toDate().toUtc().isAfter(
                  DateTime.now().toUtc().subtract(Duration(minutes: 90)));
              final y = snapshot.data!
                  .get("dateTime")
                  .toDate()
                  .toUtc()
                  .isBefore(DateTime.now().toUtc().add(Duration(minutes: 10)));

              return
                // snapshot.data!.get("isActive") && x && y
                //   ?
              Material(
                      child: Container(
                        padding: const EdgeInsets.only(top: 30),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          image: DecorationImage(
                            alignment: Alignment(0, -0.85),
                            fit: BoxFit.contain,
                            image: widget.room.imageUrl == ''
                                ? Image.asset(
                                    "assets/images/logo.png",
                                    height: 100,
                                    width: 100,
                                    scale: 1.5,
                                  ).image
                                : FosterImageProvider(
                                    cachedKey: widget.room.imageUrl,
                                    imageUrl: widget.room.imageUrl!,
                                  ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                  shape: BoxShape.circle
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            SelectTheme(room: widget.room),
                          ],
                        ),
                      ),
                    )
              //     : Scaffold(
              //   backgroundColor: theme.colorScheme.primary,
              //   body: SafeArea(
              //     child: Container(
              //       width: MediaQuery.of(context).size.width,
              //       height: MediaQuery.of(context).size.height,
              //       color: Colors.transparent,
              //       child: Column(
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 20),
              //             child: Container(
              //               width: MediaQuery.of(context).size.width,
              //               height: 30,
              //               child: Row(
              //                 children: [
              //                   IconButton(
              //                       onPressed: () {
              //                         Navigator.of(context).pop();
              //                       },
              //                       icon: Icon(
              //                         Icons.arrow_back_ios,
              //                         color: theme.colorScheme.inversePrimary,
              //                       )),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           SizedBox(height: 100,),
              //
              //           Container(
              //             width: 150,
              //             height: 150,
              //             decoration: BoxDecoration(
              //                 color: Colors.transparent,
              //                 border: Border.all(color: theme.colorScheme.secondary, width: 1),
              //                 shape: BoxShape.circle
              //             ),
              //             child: Center(
              //               child: Image.asset("assets/images/logo.png", width: 100, height: 100,),
              //             ),
              //           ),
              //
              //           SizedBox(height: 100,),
              //
              //           Text("This room is inactive",
              //             style: TextStyle(
              //                 color: Colors.grey,
              //                 fontSize: 14,
              //                 fontFamily: "drawerbody",
              //                 fontStyle: FontStyle.italic),
              //           ),
              //
              //         ],
              //       ),
              //     ),
              //   ),
              // )
              // Scaffold(
              //         appBar: AppBar(
              //           automaticallyImplyLeading: false,
              //           backgroundColor: theme.colorScheme.primary,
              //           centerTitle: true,
              //           elevation: 0,
              //           leading: GestureDetector(
              //               onTap: Navigator.of(context).pop,
              //               child: Icon(
              //                 Icons.arrow_back_ios,
              //               )),
              //           title: Text(
              //             widget.room.title ?? "",
              //             style: TextStyle(fontFamily: "drawerhead", fontSize: 18),
              //           ),
              //           actions: [
              //             Image.asset(
              //               'assets/images/logo.png',
              //               fit: BoxFit.cover,
              //               width: 40,
              //               height: 40,
              //             )
              //           ],
              //         ),
              //         backgroundColor: theme.colorScheme.primary,
              //         body: Container(
              //           width: MediaQuery.of(context).size.width,
              //           height: 60,
              //           child: Center(
              //             child: Text(
              //               "This room is inactive.",
              //               style: TextStyle(
              //                   color: Colors.grey,
              //                   fontStyle: FontStyle.italic),
              //             ),
              //           ),
              //         ),
              //       )
              ;
          }
          // return Container(
          //   padding: EdgeInsets.symmetric(
          //       horizontal: MediaQuery.of(context).size.width * 0.03),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadiusDirectional.only(
          //       topStart: Radius.circular(32),
          //       topEnd: Radius.circular(32),
          //     ),
          //     color: Colors.white,
          //   ),
          //   child: Padding(
          //     padding: const EdgeInsets.all(10),
          //     child: SingleChildScrollView(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         children: [
          //           SizedBox(
          //             height: 15,
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Align(
          //               alignment: Alignment.centerLeft,
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Center(
          //                         child: Text(
          //                           "${widget.room.title}",
          //                           style: h1.apply(),
          //                           // style: h1.apply(color: Colors.black87),
          //                         ),
          //                       ),
          //                       Center(
          //                         child: Text(
          //                           "${widget.room.roomCreator}",
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                   Padding(
          //                     padding: const EdgeInsets.only(top: 55.0),
          //                     child: StreamBuilder(
          //                       stream: roomCollection
          //                           .doc(widget.room.id)
          //                           .collection("rooms")
          //                           .doc(widget.room.roomID)
          //                           .collection("speakers")
          //                           .where("isActiveInRoom", isEqualTo: true)
          //                           .snapshots(),
          //                       builder: (BuildContext context,
          //                           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
          //                               snapshot) {
          //                         if (snapshot.hasData) {
          //                           return Center(
          //                             child: Padding(
          //                               padding: const EdgeInsets.only(top: 8.0),
          //                               child: Text(
          //                                 "Participants  ${snapshot.data!.docs.length}",
          //                                 style: TextStyle(
          //                                     color: Colors.black87,
          //                                     fontWeight: FontWeight.normal,
          //                                     fontSize: 20),
          //                               ),
          //                             ),
          //                           );
          //                         } else {
          //                           return Container(
          //                             width: 0.0,
          //                             height: 0.0,
          //                           );
          //                         }
          //                       },
          //                     ),
          //                   ),
          //                   widget.room.authorName!.isNotEmpty
          //                       ? Center(
          //                           child: Padding(
          //                             padding: const EdgeInsets.only(top: 8.0),
          //                             child: Text(
          //                               "Author name ${widget.room.authorName}",
          //                               style: TextStyle(
          //                                   color: Colors.black87,
          //                                   fontWeight: FontWeight.normal,
          //                                   fontSize: 20),
          //                             ),
          //                           ),
          //                         )
          //                       : SizedBox.shrink(),
          //                   // Center(
          //                   //   child: Padding(
          //                   //     padding: const EdgeInsets.only(top:8.0),
          //                   //     child: Text(
          //                   //       "Created by ${widget.room.roomCreator}",
          //                   //       style: TextStyle(
          //                   //           color: Colors.black87,
          //                   //           fontWeight: FontWeight.normal,
          //                   //           fontSize: 20
          //                   //       ),
          //                   //     ),
          //                   //   ),
          //                   // )
          //                 ],
          //               ),
          //             ),
          //           ),
          //           SizedBox(
          //             height: 20,
          //           ),
          //           if (!widget.room.isFollowersOnly)
          //             _InviteOnlyBuilder(
          //               room: widget.room,
          //             ),
          //           Divider(
          //             color: GlobalColors.signUpSignInButton,
          //           ),
          //           isLoading
          //               ? CircularProgressIndicator(
          //                   color: GlobalColors.signUpSignInButton)
          //               : StreamBuilder(
          //                   stream: roomCollection
          //                       .doc(widget.room.id)
          //                       .collection("rooms")
          //                       .doc(widget.room.roomID)
          //                       .collection("speakers")
          //                       .where("isActiveInRoom", isEqualTo: true)
          //                       .snapshots(),
          //                   builder: (BuildContext context,
          //                       AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
          //                           snapshot) {
          //                     if (snapshot.hasData) {
          //                       if (snapshot.data!.docs.length > 14) {
          //                         return ElevatedButton(
          //                           child: Text(
          //                             'Room Full',
          //                             style: TextStyle(
          //                                 color: Colors.black,
          //                                 fontFamily: "drawerbody"),
          //                           ),
          //                           onPressed: () async {},
          //                           style: ButtonStyle(
          //                             backgroundColor:
          //                                 MaterialStateProperty.all(Colors.redAccent),
          //                             shape:
          //                                 MaterialStateProperty.all<OutlinedBorder>(
          //                               RoundedRectangleBorder(
          //                                 borderRadius: BorderRadius.circular(30),
          //                               ),
          //                             ),
          //                           ),
          //                         );
          //                       }
          //                       var joinButton = ElevatedButton(
          //                         child: Text('Join Room'),
          //                         onPressed: () async {
          //                           var result = await updateRoom(user, context);
          //                           if (result == true) {
          //                             navigateToRoom();
          //                           }
          //                           // bool checkBan = await isUserBanned();
          //                           // if(checkBan){
          //                           //   var result = await updateRoom(user, context);
          //                           //   if (result == true) {
          //                           //     navigateToRoom();
          //                           //   }
          //                           // }
          //                         },
          //                         style: ButtonStyle(
          //                           backgroundColor: MaterialStateProperty.all(
          //                               GlobalColors.signUpSignInButton),
          //                           shape: MaterialStateProperty.all<OutlinedBorder>(
          //                             RoundedRectangleBorder(
          //                               borderRadius: BorderRadius.circular(10),
          //                             ),
          //                           ),
          //                         ),
          //                       );
          //                       if (widget.room.isFollowersOnly &&
          //                           fa.FirebaseAuth.instance.currentUser!.uid !=
          //                               widget.room.id) {
          //                         return FollowersOnlyJoinButton(
          //                           joinButton: joinButton,
          //                           room: widget.room,
          //                         );
          //                       } else {
          //                         return joinButton;
          //                       }
          //                     } else {
          //                       return Container(
          //                         width: 0.0,
          //                         height: 0.0,
          //                       );
          //                     }
          //                   },
          //                 ),
          //           SizedBox(
          //             height: 20,
          //           ),
          //           Container(
          //             width: MediaQuery.of(context).size.width,
          //             // color: Colors.grey,
          //             child: Text(
          //               "Maximum of 15 participants are allowed.",
          //               style: TextStyle(
          //                 color: GlobalColors.signUpSignInButton,
          //               ),
          //               textAlign: TextAlign.center,
          //             ),
          //           ),
          //           Container(
          //             height: MediaQuery.of(context).size.height * 0.4,
          //             child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          //                 stream: roomCollection
          //                     .doc(widget.room.id)
          //                     .collection("rooms")
          //                     .doc(widget.room.roomID)
          //                     .collection('speakers')
          //                     .where("isActiveInRoom", isEqualTo: true)
          //                     .snapshots(),
          //                 builder: (BuildContext context,
          //                     AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
          //                         snapshot) {
          //                   if (snapshot.hasData && snapshot.data!.docs.length == 0) {
          //                     return Align(
          //                       child: Text("No speakers yet!"),
          //                       alignment: Alignment.topCenter,
          //                     );
          //                   } else if (snapshot.hasData) {
          //                     List<QueryDocumentSnapshot<Map<String, dynamic>>> map =
          //                         snapshot.data!.docs;
          //                     return Padding(
          //                       padding: const EdgeInsets.only(top: 25),
          //                       child: GridView.builder(
          //                         gridDelegate:
          //                             SliverGridDelegateWithFixedCrossAxisCount(
          //                                 crossAxisCount: 3),
          //                         itemCount: map.length,
          //                         padding: EdgeInsets.all(2.0),
          //                         itemBuilder: (BuildContext context, int index) {
          //                           return Profile(
          //                               user: User.fromJson(map[index].data()),
          //                               size: 60,
          //                               isMute: false,
          //                               volume: 0,
          //                               myVolume: 0);
          //                         },
          //                       ),
          //                     );
          //                   } else {
          //                     return SizedBox.shrink();
          //                   }
          //                 }),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // );
        });
  }
}
