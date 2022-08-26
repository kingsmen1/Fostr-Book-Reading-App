import 'dart:math';

import 'package:fostr/models/BookClubModel/PendingRequests.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/screen/Eula.dart';
import 'package:fostr/services/BookClubServices.dart';
import 'package:fostr/services/InAppNotificationService.dart';
import 'package:fostr/theatre/TheatrePeekInPage.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/PageSinglePost.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/rooms/ThemePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/PageSingleReview.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../widgets/AppLoading.dart';
import 'package:sizer/sizer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List tileType = [
    "roomRN",
    "followed",
    "event",
    "bookmarked",
    "commented",
    "reviewed",
    "rated"
  ];
  User user = User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  final UserService userService = GetIt.I<UserService>();

  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  List colors = [
    Colors.pink.shade300,
    Colors.deepPurple.shade400,
    Colors.deepOrange.shade300,
    Colors.indigo,
    Colors.blueAccent,
    Colors.teal,
    Colors.green.shade700,
    Colors.orangeAccent,
    Colors.pinkAccent.shade700
  ];
  final _random = new Random();
  Color color = Colors.grey;

  @override
  void initState() {
    super.initState();
    getColor();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      FirebaseFirestore.instance
          .collection('users')
          .doc(auth.user!.id)
          .update({'unreadNotifications': false});
      checkIfUserAlreadyAgreed(auth.user!.id);
    });


  }

  void getColor() async {
    setState(() {
      color = colors[_random.nextInt(colors.length)];
    });
  }

  String? getProfileImage(String? userid) {
    String? image = "";
    FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .get()
        .then((value) {
      image = value.get("userProfile.profileImage");
    });
    return image;
  }

  bool showEULACard = true;

  void checkIfUserAlreadyAgreed(String userid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('eulaAgreed')
        .where('id', isEqualTo: userid)
        .limit(1)
        .get()
        .then((value){
      if(value.docs.length == 1){
        if(value.docs.first['eulaAgreed']){
          setState(() {
            showEULACard = false;
          });
        } else {
          setState(() {
            showEULACard = true;
          });
        }
      } else {
        setState(() {
          showEULACard = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    String userid = auth.user!.id;
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 70),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                dark_blue,
                theme.colorScheme.primary
                //Color(0xFF2E3170)
              ],
              begin : Alignment.topCenter,
              end : Alignment(0,0.8),
              // stops: [0,1]
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment(-0.9,0.6),
                child: Container(
                  height: 50,
                  width: 20,
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios,color: Colors.black,),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0,0.6),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      "Notifications",
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 26,
                          fontFamily: 'drawerhead',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.9,0.6),
                child: Container(
                  height: 50,
                  width: 50,
                  child: Center(
                      child: Image.asset("assets/images/logo.png", width: 40, height: 40,)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // AppBar(
      //   elevation: 0,
      //   backgroundColor: theme.colorScheme.primary,
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: Text("Notifications",
      //       style: TextStyle(fontFamily: "drawerhead", fontSize: 28)),
      //   leading: GestureDetector(
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //       child: Icon(
      //         Icons.arrow_back_ios,
      //       )),
      //   actions: [
      //     Image.asset(
      //       'assets/images/logo.png',
      //       fit: BoxFit.contain,
      //       width: 40,
      //       height: 40,
      //     )
      //   ],
      // ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [

                showEULACard ?
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: GestureDetector(
                        
                        onTap: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  EULA(userid: auth.user!.id,isOnboarding: false,)
                              )
                          );
                        },
                        
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 70,
                          decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              border: Border.all(
                                  color: theme.colorScheme.secondary, width: 0.5),
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 250,
                                      child: Text("Please make sure you agree to the EULA guidelines.",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.inversePrimary
                                      ),)
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.secondary,)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ) :
                    SizedBox(),

                // StreamBuilder<DocumentSnapshot>(
                //     stream: FirebaseFirestore.instance
                //         .collection("users")
                //         .doc(userid)
                //         .snapshots(),
                //     builder: (context, snapshot){
                //       if (snapshot.hasError) {
                //         print(snapshot.error);
                //         return Text("Error");
                //       }
                //       switch (snapshot.connectionState) {
                //         case ConnectionState.waiting:
                //           return SizedBox.shrink();
                //
                //         default:
                //           return snapshot.data!['eulaAgreed'] != null && !snapshot.data!['eulaAgreed']
                //               ? Container(
                //             width: 100,
                //             height: 50,
                //             color: Colors.pink,
                //           )
                //               : SizedBox.shrink();
                //       }
                //     }
                // ),

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(userid)
                        .collection("notifications")
                        .orderBy("dateTime", descending: true)
                        .where('read', isEqualTo: false)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return SizedBox.shrink();

                        default:
                          return snapshot.data!.docs.length != 0
                              ? Container(
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        var commentTimestamp = snapshot
                                            .data!.docs[index]
                                            .get("dateTime");
                                        var dateObject =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                commentTimestamp
                                                    .millisecondsSinceEpoch);
                                        String dateString;
                                        var dateDiff = DateTime.now()
                                            .difference(dateObject);
                                        if (dateDiff.inDays >= 1) {
                                          dateString = DateFormat.yMMMd()
                                              .addPattern(" | ")
                                              .add_jm()
                                              .format(dateObject)
                                              .toString();
                                        } else {
                                          dateString =
                                              timeago.format(dateObject);
                                        }

                                        ///room invite
                                        if (snapshot.data!.docs[index]
                                                    .get("type") ==
                                                NotificationType.Invite.name &&
                                            snapshot.data!.docs[index]
                                                    .get("read") !=
                                                true) {
                                          return
                                            // snapshot.data!.docs[index]
                                              //         .get("dateTime")
                                              //         .toDate()
                                              //         .toUtc()
                                              //         .add(
                                              //             Duration(minutes: 90))
                                              //         .millisecondsSinceEpoch >
                                              //     DateTime.now()
                                              //         .toUtc()
                                              //         .millisecondsSinceEpoch
                                              // ?
                                          InviteCard(
                                                  type: snapshot
                                                              .data?.docs[index]
                                                              .data()["payload"]
                                                          ?["type"] ??
                                                      "Room",
                                                  title: snapshot
                                                      .data!.docs[index]
                                                      .get("title"),
                                                  authorID: snapshot
                                                      .data?.docs[index]
                                                      .data()["payload"]
                                                  ?["creatorId"],
                                                  roomID: snapshot
                                                      .data!.docs[index]
                                                      .get("payload.roomId"),
                                                  userid: userid,
                                                  docid: snapshot
                                                      .data!.docs[index].id,
                                                );
                                              // : SizedBox.shrink();
                                        } else {
                                          return SizedBox.shrink();
                                        }
                                      }),
                                )
                              : SizedBox.shrink();
                      }
                    }),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(userid)
                        .collection("notifications")
                        .orderBy("dateTime", descending: true)
                        .where("read", isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Text("Error");
                      }
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: AppLoading(
                              height: 70,
                              width: 70,
                            )),
                          );

                        default:
                          final docs = snapshot.data!.docs;

                          Set<String> dates =
                              List.generate(docs.length, (index) {
                            return DateFormat("yyyy-MM-dd")
                                .format(docs[index].get("dateTime").toDate());
                          }).toSet();

                          return Container(
                            height: MediaQuery.of(context).size.height,
                            child: ListView.builder(
                              itemCount: dates.length,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 20, right: 20),
                                          child: Text(
                                            dates.elementAt(index),
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ] +
                                      (docs.map((doc) {
                                        var commentTimestamp =
                                            doc.get("dateTime");
                                        final currentDate =
                                            DateFormat("yyyy-MM-dd").format(
                                                commentTimestamp.toDate());
                                        if (currentDate !=
                                            dates.elementAt(index)) {
                                          return SizedBox.shrink();
                                        }

                                        var dateObject =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                commentTimestamp
                                                    .millisecondsSinceEpoch);
                                        String dateString;
                                        var dateDiff = DateTime.now()
                                            .difference(dateObject);
                                        if (dateDiff.inDays >= 1) {
                                          dateString = DateFormat.yMMMd()
                                              .addPattern(" | ")
                                              .add_jm()
                                              .format(dateObject)
                                              .toString();
                                        } else {
                                          dateString =
                                              timeago.format(dateObject);
                                        }

                                        ///followed
                                        if (doc.get("type") ==
                                            NotificationType.Follow.name) {
                                          String image = "";
                                          userService
                                              .getUserById(
                                                  doc.get("senderUserId"))
                                              .then((value) => {
                                                    if (value != null)
                                                      user = value,
                                                    image = value!.userProfile!
                                                            .profileImage ??
                                                        ""
                                                  });
                                          return StreamBuilder<
                                                  DocumentSnapshot<
                                                      Map<String, dynamic>>>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(doc.get("senderUserId"))
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return SizedBox.shrink();
                                                }
                                                switch (
                                                    snapshot.connectionState) {
                                                  case ConnectionState.waiting:
                                                    return SizedBox.shrink();
                                                }
                                                return Padding(
                                                  padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10) +
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: GestureDetector(
                                                    onTap: () => Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                        builder: (context) {
                                                          return ExternalProfilePage(
                                                            user: User.fromJson(
                                                                snapshot.data!
                                                                    .data()!),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      // height: 70,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 10),
                                                            child: Container(
                                                              width: 60,
                                                              height: 60,
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: theme
                                                                      .colorScheme
                                                                      .secondary),
                                                              child: Center(
                                                                child: StreamBuilder<
                                                                        DocumentSnapshot<
                                                                            Map<String,
                                                                                dynamic>>>(
                                                                    stream: FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "users")
                                                                        .doc(doc.get(
                                                                            "senderUserId"))
                                                                        .snapshots(),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (!snapshot
                                                                          .hasData) {
                                                                        return SizedBox
                                                                            .shrink();
                                                                      }
                                                                      switch (snapshot
                                                                          .connectionState) {
                                                                        case ConnectionState
                                                                            .waiting:
                                                                          return SizedBox
                                                                              .shrink();
                                                                      }
                                                                      return (snapshot.data?.data()?["userProfile"]?["profileImage"] == null ||
                                                                          snapshot.data?.data()?["userProfile"]?["profileImage"] == "" ||
                                                                          snapshot.data?.data()?["userProfile"]?["profileImage"] == "null") ?

                                                                      Container(
                                                                        width: 60,
                                                                        height: 60,
                                                                        decoration: BoxDecoration(
                                                                            color: color,
                                                                            shape: BoxShape.circle
                                                                        ),
                                                                        child: Center(
                                                                          child: Text(snapshot.data!.data()!["userName"].toString().characters.first.toUpperCase(),
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 40,
                                                                                fontFamily: "drawerbody"
                                                                            ),),
                                                                        ),
                                                                      ) :
                                                                      RoundedImage(
                                                                          width:
                                                                              60,
                                                                          height:
                                                                              60,
                                                                          borderRadius:
                                                                              35,
                                                                          margin: EdgeInsets
                                                                              .zero,
                                                                          url: snapshot
                                                                              .data
                                                                              ?.data()?["userProfile"]?["profileImage"]);
                                                                    })
                                                                // Icon(
                                                                //     Icons.person,
                                                                //     color: Colors
                                                                //         .white)
                                                                ,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                90,
                                                            // height: 60,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      90,
                                                                  child: Text(
                                                                    doc.get(
                                                                        "title"),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            "drawerbody"),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      dateString,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              "drawerbody",
                                                                          fontSize:
                                                                              10,
                                                                          fontStyle:
                                                                              FontStyle.italic),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        }

                                        ///event
                                        else if (doc.get("type") ==
                                            NotificationType.Event.name) {
                                          String body = doc.get("body");
                                          String datetime = DateFormat.yMMMd()
                                              .addPattern(" | ")
                                              .add_jm()
                                              .format(
                                                  doc.get("dateTime").toDate())
                                              .toString();
                                          // String image = "";
                                          // FirebaseFirestore.instance
                                          //     .collection("users")
                                          //     .doc(userid)
                                          //     .get()
                                          //     .then((value){
                                          //   image = value.get("userProfile.profileImage");
                                          // });
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                    horizontal: 10) +
                                                const EdgeInsets.only(top: 20),
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (doc.get("payload.type") ==
                                                    "Room") {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("rooms")
                                                      .doc(doc
                                                          .get("senderUserId"))
                                                      .collection("rooms")
                                                      .doc(doc.get(
                                                          "payload.roomId"))
                                                      .get()
                                                      .then((value) {

                                                        if(value['inviteOnly']) {
                                                          ToastMessege("This is an invite only room.", context: context);
                                                        }
                                                        else {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                              builder: (BuildContext
                                                              context) =>
                                                                  ThemePage(
                                                                    room: Room.fromJson(
                                                                        value.data(), ""),
                                                                  ),
                                                            ),
                                                          );
                                                        }

                                                  });
                                                }

                                                if (doc.get("payload.type") ==
                                                    "Review") {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("reviews")
                                                      .doc(doc.get(
                                                          "payload.reviewId"))
                                                      .get()
                                                      .then((value) async {
                                                    if (!value
                                                        .data()?["isActive"]) {
                                                      Navigator.of(context)
                                                          .push(
                                                        CupertinoPageRoute(
                                                          builder: (context) =>
                                                              DeletedMediaPage(
                                                                  title:
                                                                      "The Bit is deleted by the User"),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    String finalDateTime = "";

                                                    var dateDiff =
                                                        DateTime.now()
                                                            .difference(value
                                                                .get("dateTime")
                                                                .toDate());
                                                    if (dateDiff.inDays >= 1) {
                                                      finalDateTime = DateFormat
                                                              .yMMMd()
                                                          .addPattern(" | ")
                                                          .add_jm()
                                                          .format(value
                                                              .get("dateTime")
                                                              .toDate())
                                                          .toString();
                                                    } else {
                                                      finalDateTime =
                                                          timeago.format(value
                                                              .get("dateTime")
                                                              .toDate());
                                                    }

                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(value
                                                            .get("editorId"))
                                                        .get()
                                                        .then((user) {
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (context) =>
                                                              PageSingleReview(
                                                            url: value
                                                                .get("url"),
                                                            profile: user.get(
                                                                "userProfile.profileImage"),
                                                            username: user.get(
                                                                "userName"),
                                                            bookName: value.get(
                                                                "bookName"),
                                                            bookAuthor: value.get(
                                                                "bookAuthor"),
                                                            bookBio: value.get(
                                                                "bookNote"),
                                                            dateTime:
                                                                finalDateTime,
                                                            id: value.get("id"),
                                                            uid: value.get(
                                                                "editorId"),
                                                            imageUrl:
                                                                value.data()?[
                                                                    "imageUrl"],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                  });
                                                }

                                                if (doc.get("payload.type") ==
                                                    "Post") {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("posts")
                                                      .doc(doc.get(
                                                          "payload.postId"))
                                                      .get()
                                                      .then((value) {
                                                    if (!value
                                                        .data()?["isActive"]) {
                                                      Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                            builder: (context) =>
                                                                DeletedMediaPage(
                                                                    title:
                                                                        "The post is deleted by the User"),
                                                          ));
                                                      return;
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (context) =>
                                                              PageSinglePost(
                                                            postId: doc.get(
                                                                "payload.postId"),
                                                            dateTime: value.get(
                                                                "dateTime"),
                                                            userid: value
                                                                .get("userid"),
                                                            userProfile: value.get(
                                                                "userProfile"),
                                                            username: value.get(
                                                                "username"),
                                                            image: value
                                                                .get("image"),
                                                            caption: value
                                                                .get("caption"),
                                                            likes: value
                                                                .get("likes")
                                                                .toString(),
                                                            comments: value
                                                                .get("comments")
                                                                .toString(),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  });
                                                }
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                // height: 70,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: theme
                                                                    .colorScheme
                                                                    .secondary),
                                                        child: Center(
                                                            child: StreamBuilder<
                                                                    DocumentSnapshot<
                                                                        Map<String,
                                                                            dynamic>>>(
                                                                stream: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(doc.get(
                                                                        "senderUserId"))
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return SizedBox
                                                                        .shrink();
                                                                  }
                                                                  switch (snapshot
                                                                      .connectionState) {
                                                                    case ConnectionState
                                                                        .waiting:
                                                                      return SizedBox
                                                                          .shrink();
                                                                  }
                                                                  return (snapshot.data?.data()?["userProfile"]?["profileImage"] == null ||
                                                                      snapshot.data?.data()?["userProfile"]?["profileImage"] == "" ||
                                                                      snapshot.data?.data()?["userProfile"]?["profileImage"] == "null") ?

                                                                  Container(
                                                                    width: 60,
                                                                    height: 60,
                                                                    decoration: BoxDecoration(
                                                                        color: color,
                                                                        shape: BoxShape.circle
                                                                    ),
                                                                    child: Center(
                                                                      child: Text(snapshot.data?.data()?["userName"]?.characters.first.toUpperCase(),
                                                                        style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize: 40,
                                                                            fontFamily: "drawerbody"
                                                                        ),),
                                                                    ),
                                                                  ) :
                                                                  RoundedImage(
                                                                    width: 60,
                                                                    height: 60,
                                                                    borderRadius:
                                                                        35,
                                                                    margin:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    url: snapshot
                                                                            .data
                                                                            ?.data()?["userProfile"]
                                                                        ?[
                                                                        "profileImage"],
                                                                  );
                                                                })
                                                            // Icon(
                                                            //     (doc.get(
                                                            //                 "payload.type") ==
                                                            //             "Post")
                                                            //         ? Icons
                                                            //             .post_add
                                                            //         : (doc.get("payload.type") ==
                                                            //                 "Review")
                                                            //             ? Icons
                                                            //                 .audiotrack
                                                            //             : Icons
                                                            //                 .mic,
                                                            //     color: Colors
                                                            //         .white)
                                                            ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              90,
                                                      // height: 60,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                90,
                                                            child: Text(
                                                              "New event - ${body} at ${datetime}",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "drawerbody"),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                dateString,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "drawerbody",
                                                                    fontSize:
                                                                        10,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        ///bookmarked
                                        else if (doc.get("type") ==
                                            NotificationType.Bookmarked.name) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                    horizontal: 10) +
                                                const EdgeInsets.only(top: 20),
                                            child: GestureDetector(
                                              onTap: () async {
                                                await FirebaseFirestore.instance
                                                    .collection("posts")
                                                    .doc(doc
                                                        .get("payload.postId"))
                                                    .get()
                                                    .then((value) {
                                                  if (!value
                                                      .data()?["isActive"]) {
                                                    Navigator.of(context).push(
                                                      CupertinoPageRoute(
                                                        builder: (context) =>
                                                            DeletedMediaPage(
                                                          title:
                                                              "This Reading has been deleted",
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder: (context) => PageSinglePost(
                                                              postId: doc.get(
                                                                  "payload.postId"),
                                                              dateTime: value.get(
                                                                  "dateTime"),
                                                              userid: value.get(
                                                                  "userid"),
                                                              userProfile:
                                                                  value.get(
                                                                      "userProfile"),
                                                              username: value.get(
                                                                  "username"),
                                                              image: value
                                                                  .get("image"),
                                                              caption: value.get(
                                                                  "caption"),
                                                              likes: value
                                                                  .get("likes")
                                                                  .toString(),
                                                              comments: value
                                                                  .get("comments")
                                                                  .toString())));
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                // height: 70,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: theme
                                                                    .colorScheme
                                                                    .secondary),
                                                        child: Center(
                                                          child: StreamBuilder<
                                                                  DocumentSnapshot<
                                                                      Map<String,
                                                                          dynamic>>>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "users")
                                                                  .doc(doc.get(
                                                                      "senderUserId"))
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return SizedBox
                                                                      .shrink();
                                                                }
                                                                switch (snapshot
                                                                    .connectionState) {
                                                                  case ConnectionState
                                                                      .waiting:
                                                                    return SizedBox
                                                                        .shrink();
                                                                }
                                                                return (snapshot.data?.data()?["userProfile"]?["profileImage"] == null ||
                                                                    snapshot.data?.data()?["userProfile"]?["profileImage"] == "" ||
                                                                    snapshot.data?.data()?["userProfile"]?["profileImage"] == "null") ?

                                                                Container(
                                                                  width: 60,
                                                                  height: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: color,
                                                                      shape: BoxShape.circle
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(snapshot.data?.data()?["userName"]?.characters.first.toUpperCase(),
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 40,
                                                                          fontFamily: "drawerbody"
                                                                      ),),
                                                                  ),
                                                                ) :
                                                                RoundedImage(
                                                                  width: 60,
                                                                  height: 60,
                                                                  borderRadius:
                                                                      35,
                                                                  margin:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  url: snapshot
                                                                          .data
                                                                          ?.data()?["userProfile"]
                                                                      ?[
                                                                      "profileImage"],
                                                                );
                                                              })
                                                          // Icon(
                                                          //     Icons.bookmark,
                                                          //     color: Colors
                                                          //         .white)
                                                          ,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              90,
                                                      // height: 60,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                90,
                                                            child: Text(
                                                              doc.get("title"),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "drawerbody"),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                dateString,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "drawerbody",
                                                                    fontSize:
                                                                        10,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        ///commented
                                        else if (doc.get("type") ==
                                            NotificationType.Comment.name) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                    horizontal: 10) +
                                                const EdgeInsets.only(top: 20),
                                            child: GestureDetector(
                                              onTap: () async {
                                                await FirebaseFirestore.instance
                                                    .collection("posts")
                                                    .doc(doc
                                                        .get("payload.postId"))
                                                    .get()
                                                    .then((value) {
                                                  if (!value
                                                      .data()?["isActive"]) {
                                                    Navigator.of(context).push(
                                                      CupertinoPageRoute(
                                                        builder: (context) =>
                                                            DeletedMediaPage(
                                                          title:
                                                              "This Reading has been deleted",
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder: (context) => PageSinglePost(
                                                              postId: doc.get(
                                                                  "payload.postId"),
                                                              dateTime: value.get(
                                                                  "dateTime"),
                                                              userid: value.get(
                                                                  "userid"),
                                                              userProfile:
                                                                  value.get(
                                                                      "userProfile"),
                                                              username: value.get(
                                                                  "username"),
                                                              image: value
                                                                  .get("image"),
                                                              caption: value.get(
                                                                  "caption"),
                                                              likes: value
                                                                  .get("likes")
                                                                  .toString(),
                                                              comments: value
                                                                  .get("comments")
                                                                  .toString())));
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                // height: 70,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: theme
                                                                    .colorScheme
                                                                    .secondary),
                                                        child: Center(
                                                          child: StreamBuilder<
                                                                  DocumentSnapshot<
                                                                      Map<String,
                                                                          dynamic>>>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "users")
                                                                  .doc(doc.get(
                                                                      "senderUserId"))
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return SizedBox
                                                                      .shrink();
                                                                }
                                                                switch (snapshot
                                                                    .connectionState) {
                                                                  case ConnectionState
                                                                      .waiting:
                                                                    return SizedBox
                                                                        .shrink();
                                                                }
                                                                return (snapshot.data?.data()?["userProfile"]?["profileImage"] == null ||
                                                                    snapshot.data?.data()?["userProfile"]?["profileImage"] == "" ||
                                                                    snapshot.data?.data()?["userProfile"]?["profileImage"] == "null") ?

                                                                Container(
                                                                  width: 60,
                                                                  height: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: color,
                                                                      shape: BoxShape.circle
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(snapshot.data?.data()?["userName"]?.characters.first.toUpperCase(),
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 40,
                                                                          fontFamily: "drawerbody"
                                                                      ),),
                                                                  ),
                                                                ) :
                                                                RoundedImage(
                                                                  width: 60,
                                                                  height: 60,
                                                                  borderRadius:
                                                                      35,
                                                                  margin:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  url: snapshot
                                                                          .data
                                                                          ?.data()?["userProfile"]
                                                                      ?[
                                                                      "profileImage"],
                                                                );
                                                              })
                                                          // Icon(
                                                          //     Icons.comment,
                                                          //     color: Colors
                                                          //         .white)
                                                          ,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              90,
                                                      // height: 60,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                90,
                                                            child: Text(
                                                              doc.get("title"),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "drawerbody"),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                dateString,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "drawerbody",
                                                                    fontSize:
                                                                        10,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        ///created review
                                        else if (doc.get("type") ==
                                            NotificationType.Review.name) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                    horizontal: 10) +
                                                const EdgeInsets.only(top: 20),
                                            child: GestureDetector(
                                              onTap: () async {
                                                await FirebaseFirestore.instance
                                                    .collection("reviews")
                                                    .doc(doc
                                                        .get("payload.bitsId"))
                                                    .get()
                                                    .then((value) async {
                                                  if (!value
                                                      .data()?["isActive"]) {
                                                    Navigator.of(context).push(
                                                      CupertinoPageRoute(
                                                        builder: (context) =>
                                                            DeletedMediaPage(
                                                          title:
                                                              "This Bit has been deleted",
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  setState(() {});
                                                  String finalDateTime = "";

                                                  var dateDiff = DateTime.now()
                                                      .difference(value
                                                          .get("dateTime")
                                                          .toDate());
                                                  if (dateDiff.inDays >= 1) {
                                                    finalDateTime =
                                                        DateFormat.yMMMd()
                                                            .addPattern(" | ")
                                                            .add_jm()
                                                            .format(value
                                                                .get("dateTime")
                                                                .toDate())
                                                            .toString();
                                                  } else {
                                                    finalDateTime =
                                                        timeago.format(value
                                                            .get("dateTime")
                                                            .toDate());
                                                  }

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("users")
                                                      .doc(
                                                          value.get("editorId"))
                                                      .get()
                                                      .then((user) {
                                                    Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                        builder: (context) =>
                                                            PageSingleReview(
                                                          url: value.get("url"),
                                                          profile: user.get(
                                                                  "userProfile.profileImage") ??
                                                              "",
                                                          username: user
                                                              .get("userName"),
                                                          bookName: value
                                                              .get("bookName"),
                                                          bookAuthor: value.get(
                                                              "bookAuthor"),
                                                          bookBio: value
                                                              .get("bookNote"),
                                                          dateTime:
                                                              finalDateTime,
                                                          id: value.get("id"),
                                                          uid: value
                                                              .get("editorId"),
                                                          imageUrl:
                                                              value.data()?[
                                                                  "imageUrl"],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                // height: 70,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: theme
                                                                    .colorScheme
                                                                    .secondary),
                                                        child: Center(
                                                          child: StreamBuilder<
                                                                  DocumentSnapshot<
                                                                      Map<String,
                                                                          dynamic>>>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "users")
                                                                  .doc(doc.get(
                                                                      "senderUserId"))
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return SizedBox
                                                                      .shrink();
                                                                }
                                                                switch (snapshot
                                                                    .connectionState) {
                                                                  case ConnectionState
                                                                      .waiting:
                                                                    return SizedBox
                                                                        .shrink();
                                                                }
                                                                return (snapshot.data?.data()?["userProfile"]?["profileImage"] == null ||
                                                                    snapshot.data?.data()?["userProfile"]?["profileImage"] == "" ||
                                                                    snapshot.data?.data()?["userProfile"]?["profileImage"] == "null") ?

                                                                Container(
                                                                  width: 60,
                                                                  height: 60,
                                                                  decoration: BoxDecoration(
                                                                      color: color,
                                                                      shape: BoxShape.circle
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(snapshot.data?.data()?["userName"]?.characters.first.toUpperCase(),
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 40,
                                                                          fontFamily: "drawerbody"
                                                                      ),),
                                                                  ),
                                                                ) :
                                                                RoundedImage(
                                                                  width: 60,
                                                                  height: 60,
                                                                  borderRadius:
                                                                      35,
                                                                  margin:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  url: snapshot
                                                                          .data
                                                                          ?.data()?["userProfile"]
                                                                      ?[
                                                                      "profileImage"],
                                                                );
                                                              })
                                                          // Icon(
                                                          //     Icons.comment,
                                                          //     color: Colors
                                                          //         .white)
                                                          ,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              90,
                                                      // height: 60,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                90,
                                                            child: Text(
                                                              doc.get("title"),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "drawerbody"),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                dateString,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "drawerbody",
                                                                    fontSize:
                                                                        10,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        ///reviewed
                                        else if (doc.get("type") ==
                                            NotificationType.Review.name) {
                                          return ReviewCard(
                                            data: doc.data(),
                                            dateString: dateString,
                                          );
                                        }

                                        ///rated
                                        else if (doc.get("type") ==
                                            NotificationType.Rating.name) {
                                          return RatingCard(
                                            data: doc.data(),
                                            dateString: dateString,
                                          );
                                        } else if (doc.get("type") ==
                                            NotificationType
                                                .BookclubInvitationRequest
                                                .name) {
                                          return BookclubInvitationRequestCard(
                                            data: {
                                              ...doc.data(),
                                              "id": doc.id,
                                            },
                                            dateString: dateString,
                                          );
                                        } else if (doc.get("type") ==
                                            NotificationType
                                                .BookclubInvitationAccepted
                                                .name) {
                                          return BookclubInvitationAcceptedCard(
                                            data: {
                                              ...doc.data(),
                                              "id": doc.id,
                                            },
                                            dateString: dateString,
                                          );
                                        } else {
                                          return SizedBox.shrink();
                                        }
                                      })).toList(),
                                );
                              },
                            ),
                          );
                      }
                    }),
              ],
            ),
          )),
    );
  }
}

class ReviewCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String dateString;
  const ReviewCard({Key? key, required this.data, required this.dateString})
      : super(key: key);

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  List colors = [
    Colors.pink.shade300,
    Colors.deepPurple.shade400,
    Colors.deepOrange.shade300,
    Colors.indigo,
    Colors.blueAccent,
    Colors.teal,
    Colors.green.shade700,
    Colors.orangeAccent,
    Colors.pinkAccent.shade700
  ];
  final _random = new Random();
  Color color = Colors.grey;

  @override
  void initState() {
    super.initState();
    getColor();
  }

  void getColor() async {
    setState(() {
      color = colors[_random.nextInt(colors.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10) +
          const EdgeInsets.only(top: 20),
      child: GestureDetector(
        onTap: () async {
          await FirebaseFirestore.instance
              .collection("reviews")
              .doc(widget.data["payload"]["bitsId"])
              .get()
              .then((value) async {
            String finalDateTime = "";

            var dateDiff =
                DateTime.now().difference(value.get("dateTime").toDate());
            if (dateDiff.inDays >= 1) {
              finalDateTime = DateFormat.yMMMd()
                  .addPattern(" | ")
                  .add_jm()
                  .format(value.get("dateTime").toDate())
                  .toString();
            } else {
              finalDateTime = timeago.format(value.get("dateTime").toDate());
            }

            await FirebaseFirestore.instance
                .collection("users")
                .doc(value.get("editorId"))
                .get()
                .then((user) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PageSingleReview(
                    url: value.get("url"),
                    profile: user.get("userProfile.profileImage"),
                    username: user.get("userName"),
                    bookName: value.get("bookName"),
                    bookAuthor: value.get("bookAuthor"),
                    bookBio: value.get("bookNote"),
                    dateTime: finalDateTime,
                    id: value.get("id"),
                    uid: value.get("editorId"),
                    imageUrl: value.data()?["imageUrl"],
                  ),
                ),
              );
            });
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          // height: 70,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.secondary),
                  child: Center(
                    child:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.data["senderUserId"])
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return SizedBox.shrink();
                              }
                              return (snapshot.data?.data()?["userProfile"]?["profileImage"] == null ||
                                  snapshot.data?.data()?["userProfile"]?["profileImage"] == "" ||
                                  snapshot.data?.data()?["userProfile"]?["profileImage"] == "null") ?

                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle
                                ),
                                child: Center(
                                  child: Text(snapshot.data?.data()?["userName"]?.characters.first.toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontFamily: "drawerbody"
                                    ),),
                                ),
                              ) :
                              RoundedImage(
                                width: 60,
                                height: 60,
                                borderRadius: 35,
                                margin: EdgeInsets.zero,
                                url: snapshot.data?.data()?["userProfile"]
                                    ?["profileImage"],
                              );
                            })
                    // Icon(
                    //     Icons.comment,
                    //     color: Colors
                    //         .white)
                    ,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width - 90,
                // height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 90,
                      child: Text(
                        widget.data["title"],
                        style:
                            TextStyle(fontSize: 12, fontFamily: "drawerbody"),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.dateString,
                          style: TextStyle(
                              fontFamily: "drawerbody",
                              fontSize: 10,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RatingCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String dateString;
  const RatingCard({Key? key, required this.data, required this.dateString})
      : super(key: key);

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  List colors = [
    Colors.pink.shade300,
    Colors.deepPurple.shade400,
    Colors.deepOrange.shade300,
    Colors.indigo,
    Colors.blueAccent,
    Colors.teal,
    Colors.green.shade700,
    Colors.orangeAccent,
    Colors.pinkAccent.shade700
  ];
  final _random = new Random();
  Color color = Colors.grey;

  @override
  void initState() {
    super.initState();
    getColor();
  }

  void getColor() async {
    setState(() {
      color = colors[_random.nextInt(colors.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10) +
          const EdgeInsets.only(top: 20),
      child: GestureDetector(
        onTap: () async {
          await FirebaseFirestore.instance
              .collection("reviews")
              .doc(widget.data["payload"]["bitsId"])
              .get()
              .then((value) async {
            if (!value.data()?["isActive"]) {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => DeletedMediaPage(
                    title: "This Bit has been deleted",
                  ),
                ),
              );
              return;
            }

            String finalDateTime = "";

            var dateDiff =
                DateTime.now().difference(value.get("dateTime").toDate());
            if (dateDiff.inDays >= 1) {
              finalDateTime = DateFormat.yMMMd()
                  .addPattern(" | ")
                  .add_jm()
                  .format(value.get("dateTime").toDate())
                  .toString();
            } else {
              finalDateTime = timeago.format(value.get("dateTime").toDate());
            }

            await FirebaseFirestore.instance
                .collection("users")
                .doc(value.get("editorId"))
                .get()
                .then((user) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PageSingleReview(
                    url: value.get("url"),
                    profile: user.get("userProfile.profileImage") ?? "",
                    username: user.get("userName"),
                    bookName: value.get("bookName"),
                    bookAuthor: value.get("bookAuthor"),
                    bookBio: value.get("bookNote"),
                    dateTime: finalDateTime,
                    id: value.get("id"),
                    uid: value.get("editorId"),
                    imageUrl: value.data()?["imageUrl"],
                  ),
                ),
              );
            });
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          // height: 70,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.secondary),
                  child: Center(
                    child:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.data["senderUserId"])
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return SizedBox.shrink();
                              }
                              return (snapshot.data?.data()?["userProfile"]?["profileImage"] == null ||
                                  snapshot.data?.data()?["userProfile"]?["profileImage"] == "" ||
                                  snapshot.data?.data()?["userProfile"]?["profileImage"] == "null") ?

                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle
                                ),
                                child: Center(
                                  child: Text(snapshot.data?.data()?["userName"]?.characters.first.toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontFamily: "drawerbody"
                                    ),),
                                ),
                              ) :
                              RoundedImage(
                                width: 60,
                                height: 60,
                                borderRadius: 35,
                                margin: EdgeInsets.zero,
                                url: snapshot.data?.data()?["userProfile"]
                                    ?["profileImage"],
                              );
                            })
                    // Icon(
                    //     Icons.star,
                    //     color: Colors
                    //         .white)
                    ,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width - 90,
                // height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 90,
                      child: Text(
                        widget.data["title"],
                        style:
                            TextStyle(fontSize: 12, fontFamily: "drawerbody"),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.dateString,
                          style: TextStyle(
                              fontFamily: "drawerbody",
                              fontSize: 10,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BookclubInvitationRequestCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String dateString;
  const BookclubInvitationRequestCard(
      {Key? key, required this.data, required this.dateString})
      : super(key: key);

  @override
  State<BookclubInvitationRequestCard> createState() =>
      _BookclubInvitationRequestCardState();
}

class _BookclubInvitationRequestCardState
    extends State<BookclubInvitationRequestCard> with FostrTheme {
  final UserService userService = GetIt.I<UserService>();
  final BookClubServices _bookClubServices = GetIt.I<BookClubServices>();
  final InAppNotificationService _inAppNotificationService =
      GetIt.I<InAppNotificationService>();

  Future<User?> getUser() {
    return userService.getUserById(widget.data["senderUserId"]);
  }

  Future<void> sendAcceptedOrRejectedNotification(String title) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = await _inAppNotificationService
        .getNotificationToken(widget.data["senderUserId"]);
    if (token == null) return;

    _inAppNotificationService.sendNotification(NotificationPayload(
      type: NotificationType.BookclubInvitationAccepted,
      tokens: [token],
      data: {
        "title": title,
        "senderUserId": auth.user!.id,
        "senderUserName": auth.user!.name,
        "recipientUserId": widget.data["senderUserId"],
        "payload": {
          "senderUserId": auth.user!.id,
          "senderUserName": auth.user!.name,
          "recipientUserId": widget.data["senderUserId"],
          "body": title,
        }
      },
    ));
  }

  Future<void> removeFromPending() async {
    await FirebaseFirestore.instance
        .collection("bookclubs")
        .doc(widget.data["payload"]["bookclubId"])
        .update({
      "pendingMembers": FieldValue.arrayRemove([widget.data["senderUserId"]])
    });
    markAsRead();
  }

  Future<void> markAsRead() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.data["payload"]["recipientUserId"])
        .collection("notifications")
        .doc(widget.data["id"])
        .update({"read": true});
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return FutureBuilder<User?>(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Container();
          }

          if (!snapshot.hasData) {
            return AppLoading();
          }

          if (snapshot.data == null) {
            return Container();
          }
          final user = snapshot.data!;
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) {
                  return ExternalProfilePage(
                    user: user,
                  );
                },
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              // height: 65,

              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 15.w,
                        width: 15.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: (user.userProfile != null)
                                  ? (user.userProfile?.profileImage != null)
                                      ? FosterImageProvider(
                                          imageUrl:
                                              user.userProfile!.profileImage!,
                                        )
                                      : Image.asset(IMAGES + "profile.png")
                                          .image
                                  : Image.asset(IMAGES + "profile.png").image),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          widget.data['title'],
                          style:
                              TextStyle(fontSize: 12, fontFamily: "drawerbody"),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              try {
                                sendAcceptedOrRejectedNotification(
                                  "${auth.user!.userName} has accepted your invitation to join ${widget.data['payload']['bookclubName']}",
                                );
                                final tokenID =
                                    await auth.firebaseUser!.getIdToken();
                                _bookClubServices.subscribeBookClub(
                                    widget.data["payload"]["bookclubId"],
                                    widget.data["senderUserId"],
                                    tokenID);
                                await removeFromPending();
                                await FirebaseFirestore.instance
                                    .collection("subscribedBookClubs")
                                    .doc(widget.data["senderUserId"])
                                    .set({
                                  "subscribedBookClubs": FieldValue.arrayUnion(
                                      [widget.data["payload"]["bookclubId"]])
                                }, SetOptions(merge: true));

                                ToastMessege("Request Accepted",
                                    context: context);
                              } catch (e) {}
                            },
                            icon: Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              try {
                                sendAcceptedOrRejectedNotification(
                                  "${auth.user!.userName} has rejected your invitation to join ${widget.data['payload']['bookclubName']}",
                                );
                                removeFromPending();

                                ToastMessege("Request Rejected",
                                    context: context);
                              } catch (e) {}
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.dateString,
                        style: TextStyle(
                            fontFamily: "drawerbody",
                            fontSize: 10,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class BookclubInvitationAcceptedCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String dateString;
  const BookclubInvitationAcceptedCard(
      {Key? key, required this.data, required this.dateString})
      : super(key: key);

  @override
  State<BookclubInvitationAcceptedCard> createState() =>
      _BookclubInvitationAcceptedCardState();
}

class _BookclubInvitationAcceptedCardState
    extends State<BookclubInvitationAcceptedCard> with FostrTheme {
  final UserService userService = GetIt.I<UserService>();

  Future<User?> getUser() {
    return userService.getUserById(widget.data["senderUserId"]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return FutureBuilder<User?>(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Container();
          }

          if (!snapshot.hasData) {
            return AppLoading();
          }

          if (snapshot.data == null) {
            return Container();
          }
          final user = snapshot.data!;
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) {
                  return ExternalProfilePage(
                    user: user,
                  );
                },
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              // height: 65,

              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 15.w,
                        width: 15.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: (user.userProfile != null)
                                  ? (user.userProfile?.profileImage != null)
                                      ? FosterImageProvider(
                                          imageUrl:
                                              user.userProfile!.profileImage!,
                                        )
                                      : Image.asset(IMAGES + "profile.png")
                                          .image
                                  : Image.asset(IMAGES + "profile.png").image),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          widget.data['title'],
                          style:
                              TextStyle(fontSize: 12, fontFamily: "drawerbody"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.dateString,
                        style: TextStyle(
                            fontFamily: "drawerbody",
                            fontSize: 10,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class InviteCard extends StatefulWidget {
  final String title;
  final String authorID;
  final String roomID;
  final String userid;
  final String docid;
  final String? type;
  const InviteCard(
      {Key? key,
      required this.title,
      required this.authorID,
      required this.roomID,
      required this.docid,
      required this.userid,
      this.type = "Room"})
      : super(key: key);

  @override
  State<InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<InviteCard> {
  bool notNow = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return notNow
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 151,
              decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  border: Border.all(
                      color: theme.colorScheme.secondary, width: 0.5),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  ///messege
                  Container(
                    height: 109.5,
                    width: MediaQuery.of(context).size.width - 40,
                    child: Center(
                      child: Text(
                        widget.title,
                        style:
                            TextStyle(fontSize: 16, fontFamily: "drawerbody"),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Container(
                    height: 0.5,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white54,
                  ),

                  //buttons
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: Row(children: [
                      //not now
                      GestureDetector(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(widget.userid)
                              .collection("notifications")
                              .doc(widget.docid)
                              .get()
                              .then((value) async {
                            if (value.get("payload.roomId").toString() ==
                                widget.roomID) {
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(widget.userid)
                                  .collection("notifications")
                                  .doc(widget.docid)
                                  .update({"read": true});
                            }
                          });
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: theme.colorScheme.secondary,
                                  width: 0.5),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15))),
                          width: MediaQuery.of(context).size.width -
                              (MediaQuery.of(context).size.width / 2) -
                              1,
                          child: Center(
                            child: Text(
                              "Not now",
                              style: TextStyle(
                                  fontFamily: "drawerbody",
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ),

                      //Peek in
                      GestureDetector(
                        onTap: () async {
                          if (widget.type == "Room") {
                            await FirebaseFirestore.instance
                                .collection("rooms")
                                .doc(widget.authorID)
                                .collection("rooms")
                                .doc(widget.roomID)
                                .get()
                                .then((value) {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (BuildContext context) => ThemePage(
                                    room: Room.fromJson(value.data(), ""),
                                  ),
                                ),
                              );
                            });
                          } else {
                            final userDoc = await FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.authorID)
                                .get();

                            String name;
                            String profileImage = "";
                            if (userDoc.data()!["userProfile"] != null) {
                              if (userDoc.data()!["userProfile"]
                                      ["profileImage"] !=
                                  null) {
                                profileImage = userDoc.data()?["userProfile"]
                                    ["profileImage"];
                              }
                            }
                            name = userDoc.data()!["name"];
                            await FirebaseFirestore.instance
                                .collection("rooms")
                                .doc(widget.authorID)
                                .collection("amphitheatre")
                                .doc(widget.roomID)
                                .get()
                                .then((value) {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (BuildContext context) =>
                                      TheatrePeekInPage(
                                    theatre: Theatre.fromJson(value.data(), ""),
                                    imageUrl: profileImage,
                                    name: name,
                                  ),
                                ),
                              );
                            });
                          }

                          Future.delayed(Duration(minutes: 10), () async {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.userid)
                                .collection("notifications")
                                .doc(widget.docid)
                                .update({"read": true});
                          });

                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(15))),
                          width: MediaQuery.of(context).size.width -
                              (MediaQuery.of(context).size.width / 2) -
                              1,
                          child: Center(
                            child: Text(
                              "Peek in",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "drawerbody",
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ),
          );
  }
}

class DeletedMediaPage extends StatelessWidget {
  final String title;
  const DeletedMediaPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "foster",
          style: TextStyle(color: Colors.white, fontFamily: "drawerhead"),
        ),
        actions: [
          Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            width: 40,
            height: 40,
          )
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white54, fontFamily: "drawerbody"),
          ),
        ],
      ),
    );
  }
}
