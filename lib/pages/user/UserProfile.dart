import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/TopReads.dart';
import 'package:fostr/pages/user/ArchivedBits.dart';
import 'package:fostr/pages/user/BookMarkedActivties.dart';
import 'package:fostr/pages/user/SearchBook.dart';
import 'package:fostr/pages/user/SlidupPanel.dart';
import 'package:fostr/pages/user/UserActivity.dart';
import 'package:fostr/pages/user/userActivity/UserRecordings.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/screen/FollowFollowing.dart';
import 'package:fostr/screen/Settings.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/floatingMenu.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:fostr/models/UserModel/User.dart';

import 'package:fostr/pages/user/ProfileInfo.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'SelectProfileGenre.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with FostrTheme {
  TextEditingController controller = TextEditingController();
  bool isClub = false;
  ScrollController scrollController = ScrollController();
  bool shouldShowScrollToTop = false;

  UserService userServices = GetIt.I<UserService>();
  User user = User.fromJson({
    "name": "",
    "userName": "",
    "id": "",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
    // "bookClubName": ""
  });

  void updateProfile(Map<String, dynamic> data) async {
    await userServices.updateUserField(data);
  }

  List<dynamic> top_reads = [];
  List<dynamic> genre = [];

  Future<List<dynamic>> fetchReads(User? user) async {
    var doc =
        FirebaseFirestore.instance.collection("users").doc(user!.id).get();
    var list;
    doc.then((value) => {
          list = value.data()?['userProfile']?["topRead"],
          top_reads = list == null ? [] : list
        });
    return top_reads;
  }

  Future fetchFields(User? user) async {
    var doc =
        FirebaseFirestore.instance.collection("users").doc(user!.id).get();
    List<dynamic> list;
    doc.then((value) => {
          if (value.data()?['userProfile']?["genres"] != null)
            {
              list = value.data()?['userProfile']?["genres"],
              genre = list == null ? [] : list
            }
        });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        user = auth.user!;
      });

      var doc =
          FirebaseFirestore.instance.collection("users").doc(user.id).get();
      doc.then((value) {
        setState(() {
          user.name = value.data()?['name'];
          user.userName = value.data()?['userName'];
          user.userProfile?.bio = value.data()?['userProfile']['bio'];
          user.points = value.data()?['points'] ?? 0;
        });
      });

      fetchFields(user);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    if (auth.user != null) {
      user = auth.user!;
    }
    isClub = auth.userType == UserType.CLUBOWNER;

    return Scaffold(
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
                      (user.userName.isEmpty) ? "" : "@" + user.userName,
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 20,
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
                    child: InkWell(
                      onTap: () {

                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              )
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          builder: (context) {
                            return Wrap(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            dark_blue,
                                            theme.colorScheme.primary
                                            // dark_blue
                                            //Color(0xFF2E3170)
                                          ],
                                          begin : Alignment.topCenter,
                                          end : Alignment.bottomCenter,
                                          stops: [0,0.92]
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                      )
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20) + EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [

                                        //settings
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                builder: (context) => SettingsScreen(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 120,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(10),
                                              // border: Border.all(color: Colors.grey, width: 1)
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 120,
                                                  height: 100,
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      "assets/icons/settings.svg",
                                                      width: 50,
                                                      height: 50,
                                                      color: dark_blue,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 100,
                                                  height: 1,
                                                  color: Colors.grey,
                                                ),
                                                Container(
                                                  width: 120,
                                                  height: 48,
                                                  child: Center(
                                                      child: Text("Settings",
                                                        style: TextStyle(
                                                            color: dark_blue,
                                                            fontSize: 18,
                                                            fontFamily: "drawerhead"
                                                        ),)
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),

                                        //bookmarked
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                builder: (context) => BookMarkedActivties(
                                                  authId: auth.user!.id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 120,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(10),
                                              // border: Border.all(color: Colors.grey, width: 1)
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 120,
                                                  height: 100,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.bookmark_border_rounded,
                                                      size: 50,
                                                      color: dark_blue,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 100,
                                                  height: 1,
                                                  color: Colors.grey,
                                                ),
                                                Container(
                                                  width: 120,
                                                  height: 48,
                                                  child: Center(
                                                      child: Text("Bookmarked",
                                                        style: TextStyle(
                                                            color: dark_blue,
                                                            fontSize: 18,
                                                            fontFamily: "drawerhead"
                                                        ),)
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(Icons.more_vert_rounded,color: Colors.black,),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // AppBar(
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   leading: GestureDetector(
      //     onTap: () {
      //       Navigator.of(context).pop();
      //     },
      //     child: Icon(
      //       Icons.arrow_back_ios,
      //       color: theme.colorScheme.inversePrimary,
      //     ),
      //   ),
      //   backgroundColor: theme.backgroundColor,
      //   title: Text(
      //     (user.userName.isEmpty) ? "" : "@" + user.userName,
      //     style: TextStyle(
      //         color: theme.colorScheme.onPrimary,
      //         fontSize: 20,
      //         fontFamily: 'drawerhead',
      //         fontWeight: FontWeight.w500),
      //   ),
      //   actions: [
      //     InkWell(
      //       onTap: () {
      //
      //         showModalBottomSheet(
      //           context: context,
      //           shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.only(
      //                 topLeft: Radius.circular(30),
      //                 topRight: Radius.circular(30),
      //               )
      //           ),
      //           backgroundColor: theme.colorScheme.primary,
      //           builder: (context) {
      //             return Wrap(
      //               children: [
      //                 Container(
      //                   decoration: BoxDecoration(
      //                       gradient: LinearGradient(
      //                           colors: [
      //                             dark_blue,
      //                             theme.colorScheme.primary
      //                             // dark_blue
      //                             //Color(0xFF2E3170)
      //                           ],
      //                           begin : Alignment.topCenter,
      //                           end : Alignment.bottomCenter,
      //                           stops: [0,0.92]
      //                       ),
      //                       borderRadius: BorderRadius.only(
      //                         topLeft: Radius.circular(30),
      //                         topRight: Radius.circular(30),
      //                       )
      //                   ),
      //                   child: Padding(
      //                     padding: const EdgeInsets.all(20) + EdgeInsets.only(bottom: 20),
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                       children: [
      //
      //                         //settings
      //                         GestureDetector(
      //                           onTap: (){
      //                             Navigator.push(
      //                                   context,
      //                                   new MaterialPageRoute(
      //                                     builder: (context) => SettingsScreen(),
      //                                   ),
      //                                 );
      //                           },
      //                           child: Container(
      //                             width: 120,
      //                             height: 150,
      //                             decoration: BoxDecoration(
      //                               color: Colors.grey.shade200,
      //                               borderRadius: BorderRadius.circular(10),
      //                               // border: Border.all(color: Colors.grey, width: 1)
      //                             ),
      //                             child: Column(
      //                               children: [
      //                                 Container(
      //                                   width: 120,
      //                                   height: 100,
      //                                   child: Center(
      //                                     child: SvgPicture.asset(
      //                                       "assets/icons/settings.svg",
      //                                       width: 50,
      //                                       height: 50,
      //                                       color: dark_blue,
      //                                     ),
      //                                   ),
      //                                 ),
      //                                 Container(
      //                                   width: 100,
      //                                   height: 1,
      //                                   color: Colors.grey,
      //                                 ),
      //                                 Container(
      //                                   width: 120,
      //                                   height: 48,
      //                                   child: Center(
      //                                       child: Text("Settings",
      //                                       style: TextStyle(
      //                                         color: dark_blue,
      //                                         fontSize: 18,
      //                                         fontFamily: "drawerhead"
      //                                       ),)
      //                                   ),
      //                                 )
      //                               ],
      //                             ),
      //                           ),
      //                         ),
      //
      //                         //bookmarked
      //                         GestureDetector(
      //                           onTap: (){
      //                             Navigator.push(
      //                               context,
      //                               new MaterialPageRoute(
      //                                 builder: (context) => BookMarkedActivties(
      //                                   authId: auth.user!.id,
      //                                 ),
      //                               ),
      //                             );
      //                           },
      //                           child: Container(
      //                             width: 120,
      //                             height: 150,
      //                             decoration: BoxDecoration(
      //                               color: Colors.grey.shade200,
      //                               borderRadius: BorderRadius.circular(10),
      //                               // border: Border.all(color: Colors.grey, width: 1)
      //                             ),
      //                             child: Column(
      //                               children: [
      //                                 Container(
      //                                   width: 120,
      //                                   height: 100,
      //                                   child: Center(
      //                                     child: Icon(
      //                                       Icons.bookmark_border_rounded,
      //                                       size: 50,
      //                                       color: dark_blue,
      //                                     ),
      //                                   ),
      //                                 ),
      //                                 Container(
      //                                   width: 100,
      //                                   height: 1,
      //                                   color: Colors.grey,
      //                                 ),
      //                                 Container(
      //                                   width: 120,
      //                                   height: 48,
      //                                   child: Center(
      //                                       child: Text("Bookmarked",
      //                                         style: TextStyle(
      //                                             color: dark_blue,
      //                                             fontSize: 18,
      //                                             fontFamily: "drawerhead"
      //                                         ),)
      //                                   ),
      //                                 )
      //                               ],
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 )
      //               ],
      //             );
      //           },
      //         );
      //       },
      //       child: Icon(Icons.more_vert_rounded,color: Colors.black,),
      //     ),
      //     // SizedBox(
      //     //   width: 20,
      //     // ),
      //     // InkWell(
      //     //   onTap: () {
      //     //     showMenu(
      //     //       context: context,
      //     //       position: RelativeRect.fromLTRB(
      //     //           MediaQuery.of(context).size.width, 0, 20, 200),
      //     //       items: [
      //     //         PopupMenuItem(
      //     //           value: 1,
      //     //           child: InkWell(
      //     //             onTap: () {
      //     //               Navigator.of(context).push(
      //     //                 MaterialPageRoute(
      //     //                   builder: (context) => AddPhoneDetails(),
      //     //                 ),
      //     //               );
      //     //             },
      //     //             child: Text("Add Phone Details"),
      //     //           ),
      //     //         ),
      //     //         PopupMenuItem(
      //     //           child: InkWell(
      //     //             child: Text("Add Email Details"),
      //     //             onTap: () {
      //     //               Navigator.of(context).push(
      //     //                 MaterialPageRoute(
      //     //                   builder: (context) => AddEmailDetails(),
      //     //                 ),
      //     //               );
      //     //             },
      //     //           ),
      //     //           value: 1,
      //     //         ),
      //     //       ],
      //     //     );
      //     //   },
      //     //   child: Icon(
      //     //     Icons.more_vert,
      //     //     color: Colors.grey,
      //     //   ),
      //     // ),
      //     SizedBox(
      //       width: 20,
      //     ),
      //   ],
      // ),
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  controller: scrollController,
                  children: <Widget>[
                    // Container(
                    //   color: Colors.black,
                    //   height: 90,
                    //   width: MediaQuery.of(context).size.width,
                    //   child: Padding(
                    //     padding:
                    //         const EdgeInsets.only(top: 40, left: 20, right: 20),
                    //     child: Row(
                    //       children: <Widget>[

                    //         SizedBox(
                    //           width: 10,
                    //         ),
                    //         Spacer(),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // user details
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                      child: Container(
                        // height: MediaQuery.of(context).size.height*0.45,
                        decoration: BoxDecoration(
                            color: theme.colorScheme.background,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Stack(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //dp row
                                Center(
                                  child: buildFollowersStack(context),
                                ),

                                //name
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 20.0),
                                  child: Text(
                                    user.name,
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: 'drawerbody',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ),

                                //bio
                                user.userProfile?.bio != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, left: 20.0, right: 20),
                                        child: Text(
                                          user.userProfile!.bio.toString(),
                                          style: TextStyle(
                                              fontFamily: 'drawerbody',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 20.0),
                                  child: Text(
                                      "Member since " + getDate(user.createdOn),
                                      style: TextStyle(
                                          color: Color(0xff565656),
                                          fontFamily: 'drawerbody',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: (user.userProfile != null)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            (user.userProfile != null &&
                                                    user.userProfile!.twitter !=
                                                        null &&
                                                    user.userProfile!.twitter!
                                                        .isNotEmpty)
                                                ? IconButton(
                                                    icon: SvgPicture.asset(
                                                      "assets/icons/twitter.svg",
                                                      height: 35,
                                                    ),
                                                    color: Colors.teal[800],
                                                    iconSize: 35,
                                                    onPressed: () {
                                                      try {
                                                        var twitter = user
                                                            .userProfile!
                                                            .twitter!;
                                                        if (twitter
                                                                .isNotEmpty &&
                                                            twitter[0] == '@') {
                                                          twitter = twitter
                                                              .substring(1);
                                                        }
                                                        url.launch(
                                                            "https://twitter.com/$twitter");
                                                      } catch (e) {}
                                                    })
                                                : SizedBox.shrink(),
                                            (user.userProfile != null &&
                                                    user.userProfile!
                                                            .instagram !=
                                                        null &&
                                                    user.userProfile!.instagram!
                                                        .isNotEmpty)
                                                ? IconButton(
                                                    icon: SvgPicture.asset(
                                                      "assets/icons/instagram.svg",
                                                      height: 35,
                                                    ),
                                                    onPressed: () {
                                                      try {
                                                        var insta = user
                                                            .userProfile!
                                                            .instagram!;
                                                        print(insta);
                                                        if (insta.isNotEmpty &&
                                                            insta[0] == '@') {
                                                          insta = insta
                                                              .substring(1);
                                                        }
                                                        url.launch(
                                                            "http://instagram.com/$insta");
                                                      } catch (e) {}
                                                    })
                                                : SizedBox.shrink(),
                                            (user.userProfile != null &&
                                                    user.userProfile!
                                                            .linkedIn !=
                                                        null &&
                                                    user.userProfile!.linkedIn!
                                                        .isNotEmpty)
                                                ? IconButton(
                                                    icon: SvgPicture.asset(
                                                      "assets/icons/intagram.svg",
                                                      height: 35,
                                                    ),
                                                    color: Colors.teal[800],
                                                    iconSize: 35,
                                                    onPressed: () {
                                                      try {
                                                        var linkedIn = user
                                                            .userProfile!
                                                            .linkedIn!;
                                                        if (linkedIn
                                                                .isNotEmpty &&
                                                            linkedIn[0] ==
                                                                '@') {
                                                          linkedIn = linkedIn
                                                              .substring(1);
                                                        }
                                                        url.launch(
                                                            "https://www.linkedin.com/in/$linkedIn");
                                                      } catch (e) {}
                                                    })
                                                : SizedBox.shrink(),
                                            // IconButton(
                                            //     icon: Icon(
                                            //         CupertinoIcons.archivebox),
                                            //     color:
                                            //         theme.colorScheme.secondary,
                                            //     iconSize: 28,
                                            //     onPressed: () {
                                            //       Navigator.push(
                                            //           context,
                                            //           MaterialPageRoute(
                                            //               builder: (context) =>
                                            //                   ArchivedBits()));
                                            //     }),
                                            // IconButton(
                                            //     icon: Icon(Icons.podcasts),
                                            //     color:
                                            //         theme.colorScheme.secondary,
                                            //     iconSize: 28,
                                            //     onPressed: () {
                                            //       Navigator.push(
                                            //           context,
                                            //           MaterialPageRoute(
                                            //               builder: (context) =>
                                            //                   UserRecorings(
                                            //                     id: user.id,
                                            //                   )));
                                            //     }),
                                          ],
                                        )
                                      : SizedBox.shrink(),
                                ),

                                //see more
                                // user.userProfile?.description != null ?
                                StreamBuilder<
                                        DocumentSnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(user.id)
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      if (!snapshot.hasData) {
                                        return SizedBox.shrink();
                                      }

                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return SizedBox.shrink();
                                      }

                                      return snapshot.data?.data()?[
                                                          "userProfile"]
                                                      ?["description"] !=
                                                  null &&
                                              snapshot.data
                                                      ?.data()?["userProfile"]
                                                          ?["description"]
                                                      .trim() !=
                                                  ""
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0, top: 8),
                                              child: RichText(
                                                text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: 'See more',
                                                        style: TextStyle(
                                                          color: GlobalColors
                                                              .highlightedText,
                                                          fontFamily:
                                                              'drawerbody',
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              ProfileInfo(
                                                                                userid: user.id,
                                                                              )),
                                                                );
                                                              }),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink();
                                    })
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 20),
                      child: Row(
                        children: [
                          Text("Favourite Genres",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'drawerhead',
                              )),
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.edit),
                            iconSize: 14,
                            onPressed: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => SelectProfileGenre(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 0),
                      child: Container(
                        padding: const EdgeInsets.only(left: 0),
                        height: 80,
                        // color: Colors.pink,
                        // height: MediaQuery.of(context).size.height*0.15,
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(user.id)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError)
                                return new Text('Error: ${snapshot.error}');
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return new Text('Loading...');
                                default:
                                  var topReadList =
                                      snapshot.data?['userProfile']?['genres'];
                                  // print(topReadList.isEmpty);
                                  return topReadList != null
                                      ? new ListView(
                                          //shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          children: List.generate(
                                              snapshot
                                                  .data!['userProfile']
                                                      ['genres']
                                                  .length, (index) {
                                            return Container(
                                              child: Column(children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        right: 10, left: 10),
                                                    width: 70,
                                                    height: 80,
                                                    // height: MediaQuery.of(context).size.width*0.2,
                                                    // width: MediaQuery.of(context).size.width*0.2,
                                                    decoration: BoxDecoration(
                                                        // color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: FittedBox(
                                                      fit: BoxFit.fill,
                                                      child: (snapshot.data!['userProfile']
                                                                      ['genres']
                                                                  [index] ==
                                                              "Action and Adventure")
                                                          ? Image.asset(
                                                              "assets/images/Genre_A&A.png")
                                                          : (snapshot.data!['userProfile']
                                                                          ['genres']
                                                                      [index] ==
                                                                  "Biographies and Autobiographies")
                                                              ? Image.asset(
                                                                  "assets/images/Genre_B&A.png")
                                                              : (snapshot.data!['userProfile']['genres'][index] ==
                                                                      "Classics")
                                                                  ? Image.asset(
                                                                      "assets/images/Genre_Classics.png")
                                                                  : (snapshot.data!['userProfile']['genres']
                                                                              [index] ==
                                                                          "Comic Book")
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
                                                                                                                                      : Image.asset("assets/images/quiz.png"),
                                                    )),
                                              ]),
                                            );
                                          }),
                                        )
                                      : Center(
                                          child: Text(
                                            'No genres added',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'drawerbody',
                                              fontSize: 15,
                                            ),
                                          ),
                                        );
                              }
                            }),
                      ),
                    ),

                    //top 5 reads
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20),
                      child: Row(
                        children: [
                          Text("Favourite Reads",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'drawerhead',
                              )),
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.edit),
                            iconSize: 14,
                            onPressed: () {
                              var doc = FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user.id)
                                  .get();
                              List list = [];
                              doc.then((value) {
                                if (value.data()?['userProfile']?["topRead"] !=
                                    null)
                                  list =
                                      value.data()?['userProfile']?["topRead"];
                                print(list.length);
                                if (list.length == 5) {
                                  ToastMessege("Can add only 5 books",
                                      context: context);
                                  // Fluttertoast.showToast(
                                  //     msg: "Can add only 5 books",
                                  //     toastLength: Toast.LENGTH_SHORT,
                                  //     gravity: ToastGravity.BOTTOM,
                                  //     timeInSecForIosWeb: 1,
                                  //     backgroundColor: gradientBottom,
                                  //     textColor: Colors.white,
                                  //     fontSize: 16.0);
                                } else {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => SearchBook(),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10.0, left: 0, right: 0),
                      child: buildGenreTab(),
                    ),

                    //my activity
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 20, bottom: 10),
                      child: Row(
                        children: [
                          Text("My Activity",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'drawerhead',
                              )),
                        ],
                      ),
                    ),
                    UserActivity(
                      scrollController: scrollController,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: FloatinButton(
                scrollController: scrollController,
              ),
            ),
          ),
          SlidupPanel(),
        ],
      ),
    );
  }

  StreamBuilder<DocumentSnapshot<Object?>> buildClubsTab() {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              var topReadList = snapshot.data?['userProfile']?['topRead'];
              return topReadList != null
                  ? new GridView(
                      shrinkWrap: true,
                      controller: new ScrollController(keepScrollOffset: false),
                      // crossAxisCount: 2,
                      // childAspectRatio: (MediaQuery.of(context).size.width) /
                      //     (MediaQuery.of(context).size.height/1),

                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.65),
                      children: List.generate(
                          snapshot.data!['userProfile']['topRead'].length,
                          (index) {
                        return Card(
                            child: ClipRRect(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(10.0),
                          child: FosterImage(
                            imageUrl: snapshot.data!['userProfile']['topRead']
                                [index]['image_link'],
                            height: MediaQuery.of(context).size.height * 0.5,
                          ),
                        ));
                      }),
                    )
                  : Center(
                      child: Text(
                      'Search for books to add',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'drawerbody',
                          fontSize: 15,
                          color: Colors.white),
                    ));
          }
        });
  }

  StreamBuilder<DocumentSnapshot<Object?>> buildGenreTab() {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              var topReadList = snapshot.data?['userProfile']?['topRead'];
              final theme = Theme.of(context);
              return topReadList != null && topReadList.length > 0
                  ? Container(
                      height: 170,
                      // height: MediaQuery.of(context).size.height*0.5,
                      width: MediaQuery.of(context).size.width,
                      child: new ListView(
                        // reverse: true,
                        scrollDirection: Axis.horizontal,
                        // shrinkWrap: true,
                        // controller: new ScrollController(keepScrollOffset: false),
                        //scrollDirection: Axis.horizontal,
                        // crossAxisCount: 2,
                        // childAspectRatio: (MediaQuery.of(context).size.width) /
                        //     (MediaQuery.of(context).size.height/1),

                        // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //     crossAxisCount: 2,
                        //     childAspectRatio: (MediaQuery.of(context).size.width) /
                        //              (MediaQuery.of(context).size.height/1.3),
                        //     crossAxisSpacing:15,
                        //   mainAxisSpacing: 10
                        // ),
                        children: List.generate(topReadList.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: 160,
                                  // height:MediaQuery.of(context).size.height*0.28,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    color: theme.colorScheme.primary,
                                  ),

                                  child: Card(
                                      semanticContainer: true,
                                      margin: EdgeInsets.all(20),
                                      child: ClipRRect(
                                        clipBehavior: Clip.antiAlias,
                                        child: FosterImage(
                                          imageUrl: snapshot
                                                  .data!['userProfile']
                                              ['topRead'][index]['image_link']
                                          // .toString()
                                          // .replaceAll(
                                          //     "https://firebasestorage.googleapis.com",
                                          //     "https://ik.imagekit.io/fostrreads")
                                          ,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                        ),
                                      )),
                                ),
                                // Positioned(
                                //   top:0.0,
                                //   right: 0.0,
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(8.0),
                                //     child: new IconButton(
                                //       onPressed: (){},
                                //       icon: Icon(Icons.close,color: Colors.red,),
                                //     )
                                //   ),
                                // )
                                Positioned(
                                  top: -12,
                                  right: -12,
                                  child: Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () {
                                          final _userCollection =
                                              FirebaseFirestore.instance
                                                  .collection("users");
                                          TopReads tr = TopReads(
                                              snapshot.data!['userProfile']
                                                      ['topRead'][index]
                                                  ['book_name'],
                                              snapshot.data!['userProfile']
                                                      ['topRead'][index]
                                                  ['image_link']);

                                          _userCollection.doc(user.id).set({
                                            "userProfile": {
                                              "topRead": FieldValue.arrayRemove(
                                                  [tr.toMap()])
                                            }
                                          }, SetOptions(merge: true));
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          size: 24,
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    )
                  : Center(
                      child: Text(
                      'Search for books to add',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'acumin-pro',
                        fontSize: 15,
                      ),
                    ));
          }
        });
  }

  Row buildFollowersStack(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        RoundedImage(
          width: 80,
          height: 80,
          borderRadius: 35,
          margin: EdgeInsets.zero,
          url: user.userProfile?.profileImage
          // .toString().replaceAll(
          // "https://firebasestorage.googleapis.com",
          // "https://ik.imagekit.io/fostrreads")
          ,
        ),
        InkWell(
          onTap: () {
            FostrRouter.gotoWithArg(
              context,
              FollowFollowing(
                items: user.followers,
                title: "Followers",
              ),
            );
          },
          child: Column(
            children: <Widget>[
              Text("Followers",
                  style: TextStyle(
                      fontFamily: 'drawerbody',
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
              Text(
                user.followers!.length.toString(),
                style: TextStyle(
                    fontFamily: 'drawerbody',
                    fontWeight: FontWeight.w500,
                    fontSize: 19),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            FostrRouter.gotoWithArg(
              context,
              FollowFollowing(
                items: user.followings,
                title: "Following",
              ),
            );
          },
          child: Column(
            children: <Widget>[
              Text("Following",
                  style: TextStyle(
                      fontFamily: 'drawerbody',
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
              Text(
                user.followings!.length.toString(),
                style: TextStyle(
                    fontFamily: 'drawerbody',
                    fontWeight: FontWeight.w500,
                    fontSize: 19),
              )
            ],
          ),
        )
      ],
    );
  }

  String getDate(DateTime startTime) {
    var format = new DateFormat('d MMM y');
    // var date = DateTime.fromMillisecondsSinceEpoch(startTime * 1000);
    return format.format(startTime);
  }

  void showDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 5,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '12000',
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 35),
                  ),
                  Text(
                    "Foster Points",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 15,
                        fontWeight: FontWeight.w100,
                        color: Colors.grey),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                      child: Text(
                    "Silver Bookmark",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 20,
                        color: Colors.black),
                  )),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.12,
                  ),
                  Center(
                    child: MaterialButton(
                      onPressed: () {},
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      color: GlobalColors.signUpSignInButton,
                      minWidth: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.11,
                      child: Text(
                        "Claim Rewards",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Center(
                        child: Text(
                      'How does foster Point works',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
                  ),
                ],
              ),
            ),
            // margin: EdgeInsets.only(top: 150,bottom: 90, left: 12, right: 12),
            margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 10,
                horizontal: MediaQuery.of(context).size.width / 13),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        );
      },
      // transitionBuilder: (_, anim, __, child) {
      //   return SlideTransition(
      //     position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
      //     child: child,
      //   );
      // },
    );
  }
}

class FloatinButton extends StatefulWidget {
  final ScrollController scrollController;
  const FloatinButton({Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<FloatinButton> createState() => _FloatinButtonState();
}

class _FloatinButtonState extends State<FloatinButton> {
  bool isVisible = false;
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels == 0 && isVisible) {
        setState(() {
          isVisible = false;
        });
      } else if (!isVisible) {
        setState(() {
          isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return isVisible
        ? FloatingActionButton(
            backgroundColor: theme.colorScheme.secondary,
            onPressed: () {
              widget.scrollController
                  .jumpTo(widget.scrollController.position.minScrollExtent);
            },
            child: Icon(Icons.arrow_upward),
          )
        : FloatingButtonMenu();
  }
}
