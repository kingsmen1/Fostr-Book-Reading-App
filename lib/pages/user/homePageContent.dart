import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/AllPosts.dart';
import 'package:fostr/pages/user/AllLandingPage.dart';
import 'package:fostr/pages/user/AllRooms.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/RoomProvider.dart';
import 'package:fostr/reviews/AllReviews.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/theatre/TheatreHomePage.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';

class HomePageContent extends StatefulWidget {
  final String tab;
  final bool? refresh;
  HomePageContent({Key? key, required this.tab, this.refresh})
      : super(key: key);
  static const headStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String name = "";
  String userid = "";
  String bodyName = "";
  String topLine = "";

  bool all = true;
  bool bits = false;
  bool rooms = false;
  bool theatre = false;
  bool readings = false;
  ScrollController _controller = ScrollController();
  List newUsers = [];


  void getNewUsers() async {

    dynamic list = await UserService().getRecentUser();
    list.forEach((element) {
      setState(() {
        newUsers.add(element);
      });
    });

    // await FirebaseFirestore.instance
    //     .collection("users")
    //     .orderBy("createdOn", descending: true)
    //     .where("createdOn", isGreaterThan: DateTime.now().subtract(Duration(days: 10)).toIso8601String())
    //     .get()
    //     .then((value){
    //       value.docs.forEach((element) {
    //         setState(() {
    //           newUsers.add(element.id);
    //         });
    //       });
    // });
  }

  @override
  void initState() {
    getNewUsers();
    setState(() {
      bodyName = widget.tab;
      all = widget.tab == "all" ? true : false;
      bits = widget.tab == "bits" ? true : false;
      rooms = widget.tab == "rooms" ? true : false;
      theatre = widget.tab == "theaters" ? true : false;
      readings = widget.tab == "readings" ? true : false;

      topLine = widget.tab == "all"
          ? "Bond over books!"
          : widget.tab == "bits"
              ? "When reader speaks!"
              : widget.tab == "rooms"
                  ? "Knock knock!"
                  : widget.tab == "theaters"
                      ? "Knock knock!"
                      : widget.tab == "readings"
                          ? "From the community!"
                          : "";
    });
    checkForUpdate();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.tab == "theaters") {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
      final auth = Provider.of<AuthProvider>(context, listen: false);
      FirebaseMessaging.instance.getToken().then((token) {
        if (token != null) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(auth.user!.id)
              .update({"deviceToken": token, "notificationToken": token});
        }
      });
    });
    super.initState();
    // fetchQuotes();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      name = auth.user!.name;
      userid = auth.user!.id;
      print("name ----- $userid");
    });

    InAppUpdate.checkForUpdate().then((info) {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate().catchError((e) {});
      }
    }).catchError((e) {});
  }

  final genres = [
    'Recent rooms',
    'My rooms',
  ];

  int selectedIndex = 0;

  bool enabled = false;
  bool feedTab = true;

  Widget returnBody() {
    Widget bodyWidget = AllLandingPage(
      refresh: widget.refresh,
      newUsers: newUsers,
    );
    switch (bodyName) {
      case "all":
        bodyWidget = AllLandingPage(
          refresh: widget.refresh,
          newUsers: newUsers,
        );
        break;
      case "bits":
        bodyWidget = AllReviews(
          page: 'home',
          postsOfUserId: '',
          refresh: widget.refresh,
        );
        break;
      case "rooms":
        bodyWidget = AllRooms();
        break;
      case "theaters":
        bodyWidget = TheatreHomePage(
          page: "home",
          authId: userid,
        );
        break;
      case "readings":
        bodyWidget = AllPosts(
          page: "home",
          refresh: widget.refresh,
        );
        break;
    }
    return bodyWidget;
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerData = Provider.of<RoomProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.backgroundColor,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // SizedBox(
            //   width: 20,
            // ),
            SizedBox(
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    topLine,
                    style: TextStyle(
                      fontFamily: "drawerhead",
                      fontSize: 27,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     controller: _controller,
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 20),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           GestureDetector(
            //             onTap: () {
            //               audioPlayerData.showPlayer();
            //               setState(() {
            //                 all = true;
            //                 bits = false;
            //                 rooms = false;
            //                 theatre = false;
            //                 readings = false;
            //                 bodyName = "all";
            //                 topLine = "Bond over books!";
            //               });
            //             },
            //             child: Container(
            //               height: 30,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(15),
            //                 color: all
            //                     ? theme.colorScheme.secondary
            //                     : theme.chipTheme.backgroundColor,
            //               ),
            //               child: Center(
            //                 child: Padding(
            //                   padding:
            //                       const EdgeInsets.symmetric(horizontal: 15),
            //                   child: Text(
            //                     "   All   ",
            //                     style: TextStyle(
            //                         color: all
            //                             ? Colors.white
            //                             : theme.colorScheme.secondary,
            //                         fontFamily: "drawerbody"),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SizedBox(
            //             width: 10,
            //           ),

            //           //bits
            //           GestureDetector(
            //             onTap: () {
            //               audioPlayerData.hidePlayer();
            //               setState(() {
            //                 all = false;
            //                 bits = true;
            //                 rooms = false;
            //                 theatre = false;
            //                 readings = false;
            //                 bodyName = "bits";
            //                 topLine = "When reader speaks!";
            //               });
            //             },
            //             child: Container(
            //               height: 30,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(15),
            //                 color: bits
            //                     ? theme.colorScheme.secondary
            //                     : theme.chipTheme.backgroundColor,
            //               ),
            //               child: Center(
            //                 child: Padding(
            //                   padding:
            //                       const EdgeInsets.symmetric(horizontal: 15),
            //                   child: Text(
            //                     "   Bits   ",
            //                     style: TextStyle(
            //                         color: bits
            //                             ? Colors.white
            //                             : theme.colorScheme.secondary,
            //                         fontFamily: "drawerbody"),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SizedBox(
            //             width: 10,
            //           ),

            //           //readings
            //           GestureDetector(
            //             onTap: () {
            //               audioPlayerData.showPlayer();
            //               setState(() {
            //                 all = false;
            //                 bits = false;
            //                 rooms = false;
            //                 theatre = false;
            //                 readings = true;
            //                 bodyName = "readings";
            //                 topLine = "From the community!";
            //               });
            //             },
            //             child: Container(
            //               height: 30,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(15),
            //                 color: readings
            //                     ? theme.colorScheme.secondary
            //                     : theme.chipTheme.backgroundColor,
            //               ),
            //               child: Center(
            //                 child: Padding(
            //                   padding:
            //                       const EdgeInsets.symmetric(horizontal: 15),
            //                   child: Text(
            //                     "Readings",
            //                     style: TextStyle(
            //                         color: readings
            //                             ? Colors.white
            //                             : theme.colorScheme.secondary,
            //                         fontFamily: "drawerbody"),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SizedBox(
            //             width: 10,
            //           ),

            //           //rooms
            //           GestureDetector(
            //             onTap: () {
            //               audioPlayerData.showPlayer();
            //               setState(() {
            //                 all = false;
            //                 bits = false;
            //                 rooms = true;
            //                 theatre = false;
            //                 readings = false;
            //                 bodyName = "rooms";
            //                 topLine = "Knock knock!";
            //               });
            //             },
            //             child: Container(
            //               height: 30,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(15),
            //                 color: rooms
            //                     ? theme.colorScheme.secondary
            //                     : theme.chipTheme.backgroundColor,
            //               ),
            //               child: Center(
            //                 child: Padding(
            //                   padding:
            //                       const EdgeInsets.symmetric(horizontal: 15),
            //                   child: Text(
            //                     " Rooms ",
            //                     style: TextStyle(
            //                         color: rooms
            //                             ? Colors.white
            //                             : theme.colorScheme.secondary,
            //                         fontFamily: "drawerbody"),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SizedBox(
            //             width: 10,
            //           ),
            //           // theatre
            //           GestureDetector(
            //             onTap: () {
            //               audioPlayerData.showPlayer();
            //               setState(() {
            //                 all = false;
            //                 bits = false;
            //                 rooms = false;
            //                 theatre = true;
            //                 readings = false;
            //                 bodyName = "theaters";
            //                 topLine = "Knock knock!";
            //               });
            //             },
            //             child: Container(
            //               height: 30,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(15),
            //                 color: theatre
            //                     ? theme.colorScheme.secondary
            //                     : theme.chipTheme.backgroundColor,
            //               ),
            //               child: Center(
            //                 child: Padding(
            //                   padding:
            //                       const EdgeInsets.symmetric(horizontal: 15),
            //                   child: Text(
            //                     "Theatre",
            //                     style: TextStyle(
            //                         color: theatre
            //                             ? Colors.white
            //                             : theme.colorScheme.secondary,
            //                         fontFamily: "drawerbody"),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           // SizedBox(width: 20,),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: returnBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
