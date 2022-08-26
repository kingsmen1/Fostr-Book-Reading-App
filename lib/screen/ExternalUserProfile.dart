import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/ExternalUserActivity.dart';
import 'package:fostr/pages/user/ProfileInfo.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/screen/ReportContent.dart';
import 'package:fostr/services/InAppNotificationService.dart';
import 'package:fostr/services/NotificationApiService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import 'package:sizer/sizer.dart';

class ExternalProfilePage extends StatefulWidget {
  final User user;
  ExternalProfilePage({Key? key, required this.user}) : super(key: key);
  @override
  State<ExternalProfilePage> createState() => _ExternalProfilePageState();
}

class _ExternalProfilePageState extends State<ExternalProfilePage>
    with FostrTheme {
  final UserService userService = GetIt.I<UserService>();
  final InAppNotificationService _inAppNotificationService =
      GetIt.I<InAppNotificationService>();
  NotificationApiService notificationApiService = NotificationApiService();
  bool isFollowed = false;

  ScrollController _scrollController = ScrollController();

  bool isBlocked = false;
  bool isInactive = false;
  bool amiblocked = false;

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

  int followers = 0;
  int followings = 0;

  @override
  void initState() {
    getColor();
    getData();
    super.initState();
  }

  void getData() async {
    try{
      setState(() {
        followers = widget.user.followers!.length;
        followings = widget.user.followings!.length;
      });
    } catch(e) {
      setState(() {
        followers = 0;
        followings = 0;
      });
    }
  }

  void getColor() async {
    setState(() {
      color = colors[_random.nextInt(colors.length)];
    });
  }

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: widget.user.id)
        .where('accDeleted', isEqualTo: true)
        .limit(1)
        .get()
        .then((value){
      if(value.docs.length == 1){
        if(value.docs.first['accDeleted']){
          setState(() {
            isInactive = true;
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
        .where('blockedId', isEqualTo: widget.user.id)
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

  // void amIBlocked(String authId) async {
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(authId)
  //       .get()
  //       .then((value){
  //         try{
  //           List list = value['blocked_by'].toList() ?? [];
  //             amiblocked = list.contains(widget.user.id);
  //           print("try am i blocked? $amiblocked");
  //         } catch (e) {
  //             amiblocked = false;
  //             print("catch am i blocked? $amiblocked");
  //         }
  //
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.user!;

    checkIfUserIsInactive();
    checkIfUserIsBlocked(auth.user!.id);
    // amIBlocked(auth.user!.id);

    if (currentUser.followings != null) {
      if (currentUser.followings!.contains(widget.user.id)) {
        isFollowed = true;
      }
    }

    //print(isFollowed);
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
                            "@${widget.user.userName}",
                            style: TextStyle(fontSize: 20, fontFamily: "drawerhead"),
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
                    child: auth.user!.id == widget.user.id || isInactive?
                    Image.asset(
                      "assets/images/logo.png",
                      width: 50,
                    ) :
                    PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert,
                        ),
                        color: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: theme.colorScheme.secondary, width: 1),
                            borderRadius: BorderRadius.circular(10)),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry>[

                          //share
                          PopupMenuItem(
                            value: 'share',
                            child: ListTile(
                              leading: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                              // Icon(
                              //   Icons.share,
                              // ),
                              title: Text(
                                'Share profile',
                                style: TextStyle(
                                  fontFamily: "drawerbody",
                                ),
                              ),
                            ),
                          ),

                          //block/unblock
                          PopupMenuItem(
                            value: isBlocked ? 'unblock' : 'block',
                            child: ListTile(
                              leading: Icon(
                                Icons.block,
                              ),
                              title: isBlocked ?
                              Text(
                                'Unblock profile',
                                style: TextStyle(
                                  fontFamily: "drawerbody",
                                ),
                              ) :
                              Text(
                                'Block profile',
                                style: TextStyle(
                                  fontFamily: "drawerbody",
                                ),
                              ),
                            ),
                          ),

                          //report
                          const PopupMenuItem(
                            value: 'report',
                            child: ListTile(
                              leading: Icon(
                                Icons.report_problem_outlined,
                              ),
                              title: Text(
                                'Report profile',
                                style: TextStyle(
                                  fontFamily: "drawerbody",
                                ),
                              ),
                            ),
                          ),

                        ],
                        onSelected: (value) async {

                          //share
                          if (value == 'share') {
                            final url = await DynamicLinksApi.fosterUserLink(
                                userId: widget.user.id, name: widget.user.name);
                            try {
                              Share.share(url);
                            } catch (e) {
                              ToastMessege("Couldn't share your profile", context: context);
                            }
                          }

                          //block
                          if (value == 'block') {

                            const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                            Random _rnd = Random();

                            String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
                                length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

                            await FirebaseFirestore.instance
                                .collection("block tracking")
                                .doc(auth.user!.id)
                                .collection('block_list')
                                .doc(widget.user.id)
                                .set({
                              'uniqueId' : getRandomString(12),
                              'blockedById' : auth.user!.id,
                              'blockedId' : widget.user.id,
                              'blockDateTime' : DateTime.now(),
                              'unBlockDateTime' : null,
                              'isBlocked' : true,
                            },SetOptions(merge: true)).then((value) async {
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .where('id', isEqualTo: widget.user.id)
                                  .where('blockedCount')
                                  .limit(1)
                                  .get()
                                  .then((value) async {
                                if(value.docs.length == 1){
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(widget.user.id)
                                      .update({
                                    'blockedCount' : FieldValue.increment(1),
                                  });
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(widget.user.id)
                                      .set({
                                    'blockedCount' : 1
                                  }, SetOptions(merge: true));
                                }
                                setState(() {
                                  isBlocked = true;
                                });
                              });


                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .where('id', isEqualTo: widget.user.id)
                                  .where('blockedCount')
                                  .limit(1)
                                  .get()
                                  .then((value) async {
                                if(value.docs.length == 1){
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(widget.user.id)
                                      .update({
                                    'blockedCount' : FieldValue.increment(1),
                                  });
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(widget.user.id)
                                      .set({
                                    'blockedCount' : 1
                                  }, SetOptions(merge: true));
                                }
                                setState(() {
                                  isBlocked = true;
                                });
                              });

                            });

                          }

                          //unblock
                          if (value == 'unblock') {

                            await FirebaseFirestore.instance
                                .collection("block tracking")
                                .doc(auth.user!.id)
                                .collection('block_list')
                                .doc(widget.user.id)
                                .update({
                              'isBlocked' : false,
                              'unBlockDateTime' : DateTime.now()
                            }).then((value) async {
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(widget.user.id)
                                  .update({
                                'blockedCount' : FieldValue.increment(-1),
                              });
                              setState(() {
                                isBlocked = false;
                              });
                            });

                          }

                          //report
                          if (value == 'report') {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    ReportContent(
                                        contentId: widget.user.id,
                                        contentType: "Profile",
                                        contentOwnerId: widget.user.id
                                    )));
                          }
                        }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // AppBar(
      //     toolbarHeight: 65,
      //     elevation: 0,
      //     backgroundColor: theme.colorScheme.primary,
      //     leading: InkWell(
      //       onTap: () async {
      //         FostrRouter.pop(context);
      //       },
      //       child: Icon(
      //         Icons.arrow_back_ios,
      //         size: 20.sp,
      //       ),
      //     ),
      //     title: Text(
      //       "@${widget.user.userName}",
      //       style: TextStyle(fontSize: 20, fontFamily: "drawerhead"),
      //     ),
      //     actions: [
      //
      //       //more
      //       auth.user!.id == widget.user.id || isInactive?
      //       Image.asset(
      //         "assets/images/logo.png",
      //         width: 50,
      //       ) :
      //       PopupMenuButton(
      //           icon: Icon(
      //             Icons.more_vert,
      //           ),
      //           color: theme.colorScheme.primary,
      //           shape: RoundedRectangleBorder(
      //               side: BorderSide(
      //                   color: theme.colorScheme.secondary, width: 1),
      //               borderRadius: BorderRadius.circular(10)),
      //           itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      //
      //             //share
      //             PopupMenuItem(
      //               value: 'share',
      //               child: ListTile(
      //                 leading: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
      //                 // Icon(
      //                 //   Icons.share,
      //                 // ),
      //                 title: Text(
      //                   'Share profile',
      //                   style: TextStyle(
      //                     fontFamily: "drawerbody",
      //                   ),
      //                 ),
      //               ),
      //             ),
      //
      //             //block/unblock
      //             PopupMenuItem(
      //               value: isBlocked ? 'unblock' : 'block',
      //               child: ListTile(
      //                 leading: Icon(
      //                   Icons.block,
      //                 ),
      //                 title: isBlocked ?
      //                 Text(
      //                   'Unblock profile',
      //                   style: TextStyle(
      //                     fontFamily: "drawerbody",
      //                   ),
      //                 ) :
      //                 Text(
      //                   'Block profile',
      //                   style: TextStyle(
      //                     fontFamily: "drawerbody",
      //                   ),
      //                 ),
      //               ),
      //             ),
      //
      //             //report
      //             const PopupMenuItem(
      //               value: 'report',
      //               child: ListTile(
      //                 leading: Icon(
      //                   Icons.report_problem_outlined,
      //                 ),
      //                 title: Text(
      //                   'Report profile',
      //                   style: TextStyle(
      //                     fontFamily: "drawerbody",
      //                   ),
      //                 ),
      //               ),
      //             ),
      //
      //           ],
      //           onSelected: (value) async {
      //
      //             //share
      //             if (value == 'share') {
      //               final url = await DynamicLinksApi.fosterUserLink(
      //                   userId: widget.user.id, name: widget.user.name);
      //               try {
      //                 Share.share(url);
      //               } catch (e) {
      //                 ToastMessege("Couldn't share your profile", context: context);
      //               }
      //             }
      //
      //             //block
      //             if (value == 'block') {
      //
      //               const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      //               Random _rnd = Random();
      //
      //               String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      //                   length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
      //
      //               await FirebaseFirestore.instance
      //                   .collection("block tracking")
      //                   .doc(auth.user!.id)
      //                   .collection('block_list')
      //                   .doc(widget.user.id)
      //                   .set({
      //                 'uniqueId' : getRandomString(12),
      //                 'blockedById' : auth.user!.id,
      //                 'blockedId' : widget.user.id,
      //                 'blockDateTime' : DateTime.now(),
      //                 'unBlockDateTime' : null,
      //                 'isBlocked' : true,
      //               },SetOptions(merge: true)).then((value) async {
      //                 await FirebaseFirestore.instance
      //                     .collection("users")
      //                     .where('id', isEqualTo: widget.user.id)
      //                     .where('blockedCount')
      //                     .limit(1)
      //                     .get()
      //                     .then((value) async {
      //                       if(value.docs.length == 1){
      //                         await FirebaseFirestore.instance
      //                             .collection("users")
      //                             .doc(widget.user.id)
      //                             .update({
      //                           'blockedCount' : FieldValue.increment(1),
      //                         });
      //                       } else {
      //                         await FirebaseFirestore.instance
      //                             .collection("users")
      //                             .doc(widget.user.id)
      //                             .set({
      //                           'blockedCount' : 1
      //                         }, SetOptions(merge: true));
      //                       }
      //                       setState(() {
      //                         isBlocked = true;
      //                       });
      //                 });
      //
      //
      //                 await FirebaseFirestore.instance
      //                     .collection("users")
      //                     .where('id', isEqualTo: widget.user.id)
      //                     .where('blockedCount')
      //                     .limit(1)
      //                     .get()
      //                     .then((value) async {
      //                   if(value.docs.length == 1){
      //                     await FirebaseFirestore.instance
      //                         .collection("users")
      //                         .doc(widget.user.id)
      //                         .update({
      //                       'blockedCount' : FieldValue.increment(1),
      //                     });
      //                   } else {
      //                     await FirebaseFirestore.instance
      //                         .collection("users")
      //                         .doc(widget.user.id)
      //                         .set({
      //                       'blockedCount' : 1
      //                     }, SetOptions(merge: true));
      //                   }
      //                   setState(() {
      //                     isBlocked = true;
      //                   });
      //                 });
      //
      //               });
      //
      //             }
      //
      //             //unblock
      //             if (value == 'unblock') {
      //
      //               await FirebaseFirestore.instance
      //                   .collection("block tracking")
      //                   .doc(auth.user!.id)
      //                   .collection('block_list')
      //                   .doc(widget.user.id)
      //                   .update({
      //                 'isBlocked' : false,
      //                 'unBlockDateTime' : DateTime.now()
      //               }).then((value) async {
      //                 await FirebaseFirestore.instance
      //                     .collection("users")
      //                     .doc(widget.user.id)
      //                     .update({
      //                   'blockedCount' : FieldValue.increment(-1),
      //                 });
      //                 setState(() {
      //                   isBlocked = false;
      //                 });
      //               });
      //
      //             }
      //
      //             //report
      //             if (value == 'report') {
      //               Navigator.push(context,
      //                   MaterialPageRoute(builder: (context) =>
      //                       ReportContent(
      //                           contentId: widget.user.id,
      //                           contentType: "Profile",
      //                           contentOwnerId: widget.user.id
      //                       )));
      //             }
      //
      //           })
      //
      //     ]),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: ClampingScrollPhysics(),
          child: Container(
            // height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),

                //dp row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    (widget.user.userProfile?.profileImage == null ||
                        widget.user.userProfile?.profileImage == "" ||
                        widget.user.userProfile?.profileImage == "null") ?

                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle
                      ),
                      child: Center(
                        child: Text(widget.user.userName.toString().characters.first.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontFamily: "drawerbody"
                          ),),
                      ),
                    ) :
                    RoundedImage(
                      width: 90,
                      height: 90,
                      borderRadius: 35,
                      url: widget.user.userProfile?.profileImage,
                    ),

                    Column(
                      children: [
                        Text(
                          "Followers",
                          style:
                              TextStyle(fontSize: 15, fontFamily: "drawerbody"),
                        ),
                        Text("$followers",
                          style: TextStyle(fontFamily: "drawerbody"),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Following",
                          style:
                              TextStyle(fontSize: 15, fontFamily: "drawerbody"),
                        ),
                        Text("$followings",
                            style: TextStyle(fontFamily: "drawerbody")),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                //twitter insta
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (widget.user.userProfile != null)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                (widget.user.userProfile != null &&
                                        widget.user.userProfile!.twitter !=
                                            null &&
                                        widget.user.userProfile!.twitter!
                                            .isNotEmpty)
                                    ? IconButton(
                                        icon: SvgPicture.asset(
                                          "assets/icons/twitter.svg",
                                          height: 35,
                                        ),
                                        // color: Colors.teal[800],
                                        iconSize: 35,
                                        onPressed: () {
                                          try {
                                            var twitter = widget
                                                .user.userProfile!.twitter!;
                                            if (twitter.isNotEmpty &&
                                                twitter[0] == '@') {
                                              twitter = twitter.substring(1);
                                            }
                                            url.launch(
                                                "https://twitter.com/$twitter");
                                          } catch (e) {}
                                        })
                                    : SizedBox.shrink(),
                                (widget.user.userProfile != null &&
                                        widget.user.userProfile!.instagram !=
                                            null &&
                                        widget.user.userProfile!.instagram!
                                            .isNotEmpty)
                                    ? IconButton(
                                        icon: SvgPicture.asset(
                                          "assets/icons/instagram.svg",
                                          height: 35,
                                        ),
                                        // color: Colors.teal[800],
                                        iconSize: 35,
                                        onPressed: () {
                                          try {
                                            var insta = widget
                                                .user.userProfile!.instagram!;
                                            print(insta);
                                            if (insta.isNotEmpty &&
                                                insta[0] == '@') {
                                              insta = insta.substring(1);
                                            }
                                            print(insta);
                                            url.launch(
                                                "http://instagram.com/$insta");
                                          } catch (e) {}
                                        })
                                    : SizedBox.shrink(),
                                (widget.user.userProfile != null &&
                                        widget.user.userProfile!.linkedIn !=
                                            null &&
                                        widget.user.userProfile!.linkedIn!
                                            .isNotEmpty)
                                    ? IconButton(
                                        icon:
                                            FaIcon(FontAwesomeIcons.linkedinIn),
                                        // color: Colors.teal[800],
                                        iconSize: 35,
                                        onPressed: () {
                                          try {
                                            var linkedIn = widget
                                                .user.userProfile!.linkedIn!;
                                            if (linkedIn.isNotEmpty &&
                                                linkedIn[0] == '@') {
                                              linkedIn = linkedIn.substring(1);
                                            }
                                            url.launch(
                                                "https://www.linkedin.com/in/$linkedIn");
                                          } catch (e) {}
                                        })
                                    : SizedBox.shrink(),
                              ],
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),

                //name
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h) +
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (widget.user.bookClubName != null &&
                                  widget.user.bookClubName!.isNotEmpty)
                              ? widget.user.bookClubName!
                              : (widget.user.name.isEmpty)
                                  ? ""
                                  : widget.user.name,
                          // overflow: TextOverflow.ellipsis,
                          style: h1.copyWith(
                            color: theme.colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold,
                              fontFamily: "drawerhead",
                              fontSize: 20.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),

                //user contents
                isBlocked ?
                   Container(
                     width: MediaQuery.of(context).size.width * 0.8,
                     height: 70,
                     decoration: BoxDecoration(
                       color: Colors.transparent,
                       border: Border.all(
                         color: Colors.grey,
                         width: 1
                       ),
                       borderRadius: BorderRadius.circular(10)
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                         children :[
                           Icon(
                            Icons.block,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10,),
                          Text(
                           'Blocked profile',
                           style: TextStyle(
                             color: theme.colorScheme.inversePrimary,
                             fontFamily: "drawerbody",
                           ),
                         ),
                         ]
                     )

                   ) :
                isInactive ?
                Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 70,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                            color: Colors.grey,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children :[
                          Icon(
                            Icons.disabled_by_default,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10,),
                          Text(
                            'Inactive profile',
                            style: TextStyle(
                              color: theme.colorScheme.inversePrimary,
                              fontFamily: "drawerbody",
                            ),
                          ),
                        ]
                    )
                )  :
                   Column(
                  children: [

                    //follow button
                    widget.user.id == currentUser.id
                        ? SizedBox.shrink()
                        : InkWell(
                            onTap: () async {
                              if (!isFollowed) {
                                var newUser = await userService.followUser(
                                    auth.user!, widget.user);
                                setState(() {
                                  isFollowed = true;
                                });
                                auth.refreshUser(newUser);
                                List<String> deviceTokens = [];
                                if (widget.user.deviceToken != null) {
                                  deviceTokens.add(widget.user.deviceToken!);
                                }
                                if (widget.user.notificationToken != null &&
                                    deviceTokens.isEmpty) {
                                  deviceTokens.add(widget.user.notificationToken!);
                                }
                                final payload = NotificationPayload(
                                    type: NotificationType.Follow,
                                    tokens: deviceTokens,
                                    data: {
                                      "tokens": deviceTokens,
                                      "senderUserId": currentUser.id,
                                      "senderUserName": currentUser.userName,
                                      "senderToken": currentUser.deviceToken ??
                                          currentUser.notificationToken,
                                      "authToken": "",
                                      "recipientUserId": widget.user.id,
                                      "recipientUserName": widget.user.userName,
                                      "title":
                                          "Your community is growing! ${currentUser.userName} is now following you",
                                      "body": "",
                                      "payload": {
                                        "userId": currentUser.id,
                                      }
                                    });

                                await _inAppNotificationService
                                    .sendNotification(payload);
                                ToastMessege("Followed Successfully!",
                                    context: context);
                                // Fluttertoast.showToast(
                                //     msg: "Followed Successfully!",
                                //     toastLength: Toast.LENGTH_SHORT,
                                //     gravity: ToastGravity.BOTTOM,
                                //     timeInSecForIosWeb: 1,
                                //     backgroundColor: gradientBottom,
                                //     textColor: Colors.white,
                                //     fontSize: 16.0);
                              } else {
                                var newUser = await userService.unfollowUser(
                                    auth.user!, widget.user);
                                setState(() {
                                  isFollowed = false;
                                });
                                auth.refreshUser(newUser);
                                ToastMessege("Unfollowed Successfully!",
                                    context: context);
                                // Fluttertoast.showToast(
                                //     msg: "Unfollowed Successfully!",
                                //     toastLength: Toast.LENGTH_SHORT,
                                //     gravity: ToastGravity.BOTTOM,
                                //     timeInSecForIosWeb: 1,
                                //     backgroundColor: gradientBottom,
                                //     textColor: Colors.white,
                                //     fontSize: 16.0);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              width: 90.w,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: !isFollowed
                                      ? theme.colorScheme.secondary
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: !isFollowed
                                          ? theme.colorScheme.secondary
                                          : Colors.grey,
                                      width: 0.5)),
                              child: Center(
                                child: Text(
                                  (!isFollowed) ? "Follow" : "Unfollow",
                                  style: h1.copyWith(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: "drawerbody",
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),

                    SizedBox(
                      height: 2.h,
                    ),

                    //bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Bio',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              fontFamily: "drawerhead"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text(
                            widget.user.userProfile?.bio ?? "No bio added",
                            style:
                                h1.copyWith(
                                    color: theme.colorScheme.inversePrimary,fontSize: 14, fontFamily: "drawerbody"),
                          ),
                        ),
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.user.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }

                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return SizedBox.shrink();
                          }

                          return snapshot.data?.data()?["userProfile"]
                                          ?["description"] !=
                                      null &&
                                  snapshot.data
                                          ?.data()?["userProfile"]?["description"]
                                          .trim() !=
                                      ""
                              ? Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0, top: 8),
                                      child: RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'See more',
                                                style: TextStyle(
                                                  color:
                                                      GlobalColors.highlightedText,
                                                  fontFamily: 'drawerbody',
                                                ),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileInfo(
                                                                userid:
                                                                    widget.user.id,
                                                              )),
                                                    );
                                                  }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox.shrink();
                        }),
                    SizedBox(
                      height: 10,
                    ),

                    //genres
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Favourite Genres',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              fontFamily: "drawerhead"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 0),
                      child: Container(
                        padding: const EdgeInsets.only(left: 0),
                        height: 100,
                        // height: MediaQuery.of(context).size.height * 0.2,
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.user.id)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError)
                                return new Text(
                                  'Error: ${snapshot.error}',
                                );
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return new Text(
                                    'Loading...',
                                  );
                                default:
                                  var topReadList =
                                      snapshot.data?['userProfile']?['genres'];
                                  // print(topReadList.isEmpty);
                                  return topReadList != null
                                      ? new ListView(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          children: List.generate(
                                              snapshot
                                                  .data!['userProfile']['genres']
                                                  .length, (index) {
                                            return Container(
                                                child: Column(
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        right: 10, left: 10),
                                                    height: 80,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        color: theme
                                                            .colorScheme.primary,
                                                        borderRadius: BorderRadius.circular(
                                                            5)),
                                                    child: (snapshot.data!['userProfile']
                                                                ['genres'][index] ==
                                                            "Action and Adventure")
                                                        ? Image.asset(
                                                            "assets/images/Genre_A&A.png")
                                                        : (snapshot.data!['userProfile']['genres']
                                                                    [index] ==
                                                                "Biographies and Autobiographies")
                                                            ? Image.asset(
                                                                "assets/images/Genre_B&A.png")
                                                            : (snapshot.data!['userProfile']
                                                                        ['genres'][index] ==
                                                                    "Classics")
                                                                ? Image.asset("assets/images/Genre_Classics.png")
                                                                : (snapshot.data!['userProfile']['genres'][index] == "Comic Book")
                                                                    ? Image.asset("assets/images/Genre_Comic.png")
                                                                    : (snapshot.data!['userProfile']['genres'][index] == "Cookbooks")
                                                                        ? Image.asset("assets/images/Genre_Cooking.png")
                                                                        : (snapshot.data!['userProfile']['genres'][index] == "Detective and Mystery")
                                                                            ? Image.asset("assets/images/Genre_D&M.png")
                                                                            : (snapshot.data!['userProfile']['genres'][index] == "Essays")
                                                                                ? Image.asset("assets/images/Genre_Essay.png")
                                                                                : (snapshot.data!['userProfile']['genres'][index] == "Fantasy")
                                                                                    ? Image.asset("assets/images/Genre_Fantasy.png")
                                                                                    : (snapshot.data!['userProfile']['genres'][index] == "Historical Fiction")
                                                                                        ? Image.asset("assets/images/Genre_HF.png")
                                                                                        : (snapshot.data!['userProfile']['genres'][index] == "Horror")
                                                                                            ? Image.asset("assets/images/Genre_Horror.png")
                                                                                            : (snapshot.data!['userProfile']['genres'][index] == "Literary Fiction")
                                                                                                ? Image.asset("assets/images/Genre_LF.png")
                                                                                                : (snapshot.data!['userProfile']['genres'][index] == "Memoir")
                                                                                                    ? Image.asset("assets/images/Genre_Memoir.png")
                                                                                                    : (snapshot.data!['userProfile']['genres'][index] == "Poetry")
                                                                                                        ? Image.asset("assets/images/Genre_Poetry.png")
                                                                                                        : (snapshot.data!['userProfile']['genres'][index] == "Romance")
                                                                                                            ? Image.asset("assets/images/Genre_Romance.png")
                                                                                                            : (snapshot.data!['userProfile']['genres'][index] == "Science Fiction (Sci-Fi)")
                                                                                                                ? Image.asset("assets/images/Genre_SciFi.png")
                                                                                                                : (snapshot.data!['userProfile']['genres'][index] == "Short Stories")
                                                                                                                    ? Image.asset("assets/images/Genre_SS.png")
                                                                                                                    : (snapshot.data!['userProfile']['genres'][index] == "Suspense and Thrillers")
                                                                                                                        ? Image.asset("assets/images/Genre_S&T.png")
                                                                                                                        : (snapshot.data!['userProfile']['genres'][index] == "Self-Help")
                                                                                                                            ? Image.asset("assets/images/Genre_Self.png")
                                                                                                                            : (snapshot.data!['userProfile']['genres'][index] == "True Crime")
                                                                                                                                ? Image.asset("assets/images/Genre_TC.png")
                                                                                                                                : (snapshot.data!['userProfile']['genres'][index] == "Women's Fiction")
                                                                                                                                    ? Image.asset("assets/images/Genre_WF.png")
                                                                                                                                    : Image.asset("assets/images/quiz.png")),
                                                // SizedBox(height: 5.0),
                                                // Text(
                                                //   snapshot.data![
                                                //           'userProfile']
                                                //       ['genres'][index],
                                                //   style: TextStyle(
                                                //       color: Colors.black,
                                                //       fontSize: 9),
                                                // ),
                                              ],
                                            ));
                                          }),
                                        )
                                      : Center(
                                          child: Text(
                                          'No genres added',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: theme.colorScheme.inversePrimary,
                                            fontFamily: 'drawerbody',
                                            fontSize: 15,
                                          ),
                                        ));
                              }
                            }),
                      ),
                    ),

                    //reads
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Favourite Reads',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              fontFamily: "drawerhead"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(widget.user.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return new Text('Error: ${snapshot.error}');
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return new Text('Loading...');
                              default:
                                var topReadList =
                                    snapshot.data?['userProfile']?['topRead'];
                                return topReadList != null &&
                                        snapshot.data?['userProfile']?['topRead']
                                                .length >
                                            0
                                    ? Container(
                                        height: MediaQuery.of(context).size.height *
                                            0.3,
                                        width: MediaQuery.of(context).size.width,
                                        child: new ListView(
                                          // reverse: true,
                                          scrollDirection: Axis.horizontal,
                                          // shrinkWrap: true,
                                          // controller: new ScrollController(
                                          //     keepScrollOffset: false),
                                          // gridDelegate:
                                          //     SliverGridDelegateWithFixedCrossAxisCount(
                                          //         crossAxisCount: 2,
                                          //         childAspectRatio:
                                          //             (MediaQuery.of(
                                          //                         context)
                                          //                     .size
                                          //                     .width) /
                                          //                 (MediaQuery.of(
                                          //                             context)
                                          //                         .size
                                          //                         .height /
                                          //                     1.3),
                                          //         crossAxisSpacing: 15,
                                          //         mainAxisSpacing: 10),
                                          children: List.generate(
                                              snapshot
                                                  .data!['userProfile']['topRead']
                                                  .length, (index) {
                                            return Stack(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 5),
                                                  child: Container(
                                                    height: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.3,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(10)),
                                                      color:
                                                          theme.colorScheme.primary,
                                                    ),
                                                    child: Card(
                                                        semanticContainer: true,
                                                        margin: EdgeInsets.all(20),
                                                        child: ClipRRect(
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          child: FosterImage(
                                                            imageUrl: snapshot
                                                                            .data![
                                                                        'userProfile']
                                                                    ['topRead'][
                                                                index]['image_link']
                                                            // .toString()
                                                            // .replaceAll(
                                                            //     "https://firebasestorage.googleapis.com",
                                                            //     "https://ik.imagekit.io/fostrreads")
                                                            ,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.6,
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      )
                                    : Center(
                                        child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 25),
                                        child: Text(
                                          'No books added',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: theme.colorScheme.inversePrimary,
                                            fontFamily: 'drawerbody',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ));
                            }
                          }),
                    ),

                    //my activity
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10.0, left: 20, bottom: 10),
                      child: Row(
                        children: [
                          Text(
                            "${widget.user.name.split(" ")[0]}'s Activities",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                fontFamily: "drawerhead"),
                          ),
                        ],
                      ),
                    ),
                    ExternalUserActivity(
                      userId: widget.user.id,
                      scrollController: _scrollController,
                    ),
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
