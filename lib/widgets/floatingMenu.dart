import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/Posts/EnterNewPostDetails.dart';
import 'package:fostr/albums/EnterAlbumDetails.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/rooms/EnterRoomDetails.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/EnterReviewDetails.dart';
import 'package:fostr/theatre/EnterTheatreDetails.dart';
import 'package:provider/provider.dart';
import 'dart:math' show Random;

class FloatingButtonMenu extends StatefulWidget {
  const FloatingButtonMenu({Key? key}) : super(key: key);

  @override
  State<FloatingButtonMenu> createState() => _FloatingButtonMenuState();
}

class _FloatingButtonMenuState extends State<FloatingButtonMenu>
    with SingleTickerProviderStateMixin {
  bool isBottomSheetOpen = false;

  late AnimationController _controller;

  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
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

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _controller.addListener(() {
        if (_controller.value == 1) {
          setState(() {
            isBottomSheetOpen = true;
          });
        } else {
          setState(() {
            isBottomSheetOpen = false;
          });
        }
      });
      setState(() {
        user = auth.user!;
      });

      var doc =
          FirebaseFirestore.instance.collection("users").doc(user.id).get();
      doc.then((value) {
        if (mounted) {
          setState(() {
            user.name = value.data()?['name'];
            user.userName = value.data()?['userName'];
            user.userProfile?.bio = value.data()?['userProfile']['bio'];
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      heroTag: Random().nextInt(100),
      onPressed: () {
        if (!isBottomSheetOpen) {
          showBottomSheet(
              transitionAnimationController: _controller,
              enableDrag: true,
              elevation: 10,
              context: context,
              builder: (context) {
                return Abc();
              });
        } else {
          _controller.reverse();
        }

        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => Abc(),
        //   ),
        // );
      },
      child: Icon(
        (!isBottomSheetOpen) ? Icons.add : Icons.close,
        color: Colors.white,
        size: 28,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
    //   FloatingActionButton(
    //   backgroundColor: Color(0xff2A9D8F),
    //   child: Icon(Icons.add),
    //   onPressed: () {
    //     showGeneralDialog(
    //       barrierLabel: "Label",
    //       barrierDismissible: true,
    //       barrierColor: Colors.black.withOpacity(0.5),
    //       transitionDuration: Duration(milliseconds: 400),
    //       context: context,
    //       pageBuilder: (context, anim1, anim2) {
    //         return Align(
    //             alignment: Alignment.center,
    //             child: ClipRRect(
    //               borderRadius: BorderRadius.all(Radius.circular(20)),
    //               child: Container(
    //                 height: MediaQuery.of(context).size.height * 0.8,
    //                 width: MediaQuery.of(context).size.width * 0.94,
    //                 child:
    //
    //                 //RoomDetails(),
    //
    //                 //room, theater and bookclub
    //                 Column(
    //                   children: [
    //                     Expanded(child: Container()),
    //                     Expanded(child: Container()),
    //
    //                     //room
    //                     Row(
    //                       children: [
    //                         Expanded(child: Container()),
    //                         ElevatedButton.icon(
    //                           onPressed: () {
    //                             Navigator.push(
    //                                 context, MaterialPageRoute(
    //                                 builder: (context) =>
    //                                     EnterRoomDetails()
    //                             )
    //                             );
    //                           },
    //                           style: ButtonStyle(
    //                               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                                   RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(11.0),
    //                                   )),
    //                               backgroundColor: MaterialStateProperty.all(Colors.teal[800]),
    //                               foregroundColor: MaterialStateProperty.all(Colors.white)
    //                           ),
    //                           icon: Icon(Icons.mic),
    //                           label: Text("        Room     "),
    //                         ),
    //                         SizedBox(width: 5)
    //                       ],
    //                     ),
    //
    //                     //bookclub
    //                     Row(
    //                       children: [
    //                         Expanded(child: Container()),
    //                         ElevatedButton.icon(
    //                           onPressed: () {
    //                             Navigator.push(
    //                                 context, MaterialPageRoute(
    //                                 builder: (context) =>
    //                                     EnterBookClubDetails()
    //                             )
    //                             );
    //                           },
    //                           style: ButtonStyle(
    //                               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                                   RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(11.0),
    //                                   )),
    //                               backgroundColor: MaterialStateProperty.all(Colors.teal[800]),
    //                               foregroundColor: MaterialStateProperty.all(Colors.white)
    //                           ),
    //                           icon: Icon(Icons.menu_book_rounded),
    //                           label: Text("     Book Club "),
    //                         ),
    //                         SizedBox(width: 5)
    //                       ],
    //                     ),
    //
    //                     //bookreviews
    //                     Row(
    //                       children: [
    //                         Expanded(child: Container()),
    //                         ElevatedButton.icon(
    //                           onPressed: () {
    //                             Navigator.push(
    //                                 context, MaterialPageRoute(
    //                                 builder: (context) =>
    //                                     EnterReviewDetails()
    //                             )
    //                             );
    //                           },
    //                           style: ButtonStyle(
    //                               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                                   RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(11.0),
    //                                   )),
    //                               backgroundColor: MaterialStateProperty.all(Colors.teal[800]),
    //                               foregroundColor: MaterialStateProperty.all(Colors.white)
    //                           ),
    //                           icon: Icon(Icons.edit),
    //                           label: Text(" Book Review"),
    //                         ),
    //                         SizedBox(width: 5)
    //                       ],
    //                     ),
    //
    //                     //theater
    //                     Row(
    //                       children: [
    //                         Expanded(child: Container()),
    //                         ElevatedButton.icon(
    //                           onPressed: () {
    //                             Navigator.push(
    //                                 context, MaterialPageRoute(
    //                                 builder: (context) =>
    //                                     EnterTheatreDetails()
    //                             )
    //                             );
    //                           },
    //                           style: ButtonStyle(
    //                               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                                   RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(11.0),
    //                                   )),
    //                               backgroundColor: MaterialStateProperty.all(Colors.teal[800]),
    //                               foregroundColor: MaterialStateProperty.all(Colors.white)
    //                           ),
    //                           icon: Icon(Icons.theater_comedy),
    //                           label: Text("      Theater   "),
    //                         ),
    //                         SizedBox(width: 5)
    //                       ],
    //                     ),
    //                     Expanded(child: Container()),
    //                   ],
    //                 ),
    //
    //               ),
    //             ));
    //       },
    //       transitionBuilder: (context, anim1, anim2, child) {
    //         return SlideTransition(
    //           position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
    //               .animate(anim1),
    //           child: child,
    //         );
    //       },
    //     );
    //   },
    // );
  }
}

class Abc extends StatefulWidget {
  const Abc({Key? key}) : super(key: key);

  @override
  State<Abc> createState() => _AbcState();
}

class _AbcState extends State<Abc> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              FontAwesomeIcons.chevronDown,
            )),
        // actions: [
        //   Image.asset(
        //     'assets/images/logo.png',
        //     fit: BoxFit.cover,
        //     width: 50,
        //     height: 50,
        //   )
        // ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "What would you like to create?",
              style: TextStyle(fontFamily: "drawerhead", fontSize: 35),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 400,
              child: GridView(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 20,
                    crossAxisCount: 2),
                children: [

                  //room/theatre
                  CircleButton(
                    icon: Icon(
                      Icons.mic,
                      color: Colors.grey.shade600,
                      size: 50,
                    ),
                    onPressed: () {

                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => EnterRoomDetails()
                      ));
                    },
                    text: Text("Room/Theatre"),
                  ),

                  //album
                  CircleButton(
                    icon: Icon(
                      Icons.album_outlined,
                      color: Colors.grey.shade600,
                      size: 50,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => EnterAlbumDetails()));
                    },
                    text: Text("Podcast"),
                  ),

                  //bit
                  CircleButton(
                    icon: SvgPicture.asset("assets/icons/grey_Bits.svg",width: 40, height: 40,),
                    // Icon(
                    //   Icons.music_note,
                    // color: Colors.grey.shade600,
                    //   size: 50,
                    // ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => EnterReviewDetails()));
                    },
                    text: Text("Reviews"),
                  ),

                  //reading
                  CircleButton(
                    icon: Icon(
                      Icons.post_add,
                      color: Colors.grey.shade600,
                      size: 50,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) =>
                              EnterNewPostDetails(user: auth.user!)));
                    },
                    text: Text("Readings"),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Widget text;
  const CircleButton(
      {Key? key,
      required this.icon,
      required this.onPressed,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.secondary, width: 3)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: 10),
            text,
          ],
        ),
      ),
    );
  }
}

class Xyz extends StatefulWidget {
  const Xyz({Key? key}) : super(key: key);

  @override
  State<Xyz> createState() => _XyzState();
}

class _XyzState extends State<Xyz> {
  PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int currentPage = 0;

  bool isSelectedPage(int index) {
    return currentPage == index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(0,
                          duration: Duration(milliseconds: 700),
                          curve: Curves.linear);
                      setState(() {
                        currentPage = 0;
                      });
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(
                      constraints: BoxConstraints(minWidth: 150),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: theme.colorScheme.secondary, width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: (isSelectedPage(0))
                            ? theme.colorScheme.secondary
                            : null,
                      ),
                      height: 40,
                      child: Center(
                          child: Text(
                        "Room",
                        style: TextStyle(
                            color: (isSelectedPage(0)) ? Colors.white : null),
                      )),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(1,
                          duration: Duration(milliseconds: 700),
                          curve: Curves.linear);
                      setState(() {
                        currentPage = 1;
                      });
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(
                      constraints: BoxConstraints(minWidth: 150),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: theme.colorScheme.secondary, width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: (isSelectedPage(1))
                            ? theme.colorScheme.secondary
                            : null,
                      ),
                      height: 40,
                      child: Center(
                          child: Text(
                        "Theatre",
                        style: TextStyle(
                            color: (isSelectedPage(1)) ? Colors.white : null),
                      )),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(2,
                          duration: Duration(milliseconds: 700),
                          curve: Curves.linear);
                      setState(() {
                        currentPage = 2;
                      });
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(
                      constraints: BoxConstraints(minWidth: 150),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: theme.colorScheme.secondary, width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: (isSelectedPage(2))
                            ? theme.colorScheme.secondary
                            : null,
                      ),
                      height: 40,
                      child: Center(
                          child: Text(
                        "Bits",
                        style: TextStyle(
                            color: (isSelectedPage(2)) ? Colors.white : null),
                      )),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(3,
                          duration: Duration(milliseconds: 700),
                          curve: Curves.linear);
                      setState(() {
                        currentPage = 3;
                      });
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(
                      constraints: BoxConstraints(minWidth: 150),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: theme.colorScheme.secondary, width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: (isSelectedPage(3))
                            ? theme.colorScheme.secondary
                            : null,
                      ),
                      height: 40,
                      child: Center(
                          child: Text(
                        "Reading",
                        style: TextStyle(
                            color: (isSelectedPage(3)) ? Colors.white : null),
                      )),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [
                    EnterRoomDetails(),
                    EnterTheatreDetails(),
                    EnterReviewDetails(),
                    EnterNewPostDetails(user: auth.user!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
