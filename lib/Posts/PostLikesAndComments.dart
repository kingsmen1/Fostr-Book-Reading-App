import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/CommentsList.dart';
import 'package:fostr/widgets/LikesList.dart';

class PostLikesAndComments extends StatefulWidget {
  final String postID;
  const PostLikesAndComments({
    Key? key,
    required this.postID,
  }) : super(key: key);

  @override
  _PostLikesAndCommentsState createState() => _PostLikesAndCommentsState();
}

class _PostLikesAndCommentsState extends State<PostLikesAndComments> {
  bool loadInitiated = false;
  List likeIDs = [];
  List commentIDs = [];
  List commentUserIDs = [];
  List comment = [];
  List commentUsername = [];
  List commentProfile = [];
  List commentDate = [];
  bool likesTab = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // To Call load methods after screen have built
      if (!loadInitiated) {
        loadInitiated = true;
        getLikesList();
        getCommentsList();
      }
    });
  }

  void getLikesList() async {
    await FirebaseDatabase.instance
        .ref()
        .child('Posts')
        .child(widget.postID.replaceAll(" ", "_").replaceAll(".", "_"))
        .child('likes')
        .get()
        .then((value) {
      value.children.forEach((element) {
        if ((element.value as Map)['liked'] == true) {
          setState(() {
            likeIDs.add(element.key);
          });
        }
      });
    });
  }

  void getCommentsList() async {
    await FirebaseDatabase.instance
        .ref()
        .child('Posts')
        .child(widget.postID.replaceAll(" ", "_").replaceAll(".", "_"))
        .child('comments')
        .get()
        .then((value) {
      value.children.forEach((element) {
        if ((element.value as Map)['active'] == true) {
          setState(() {
            commentIDs.add(element.key);
            comment.add((element.value as Map)['comment']);
            commentUserIDs.add((element.value as Map)['by']);
            commentUsername.add((element.value as Map)['username']);
            commentProfile.add((element.value as Map)['profile']);
            commentDate.add((element.value as Map)['on']);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 70),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 210,
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
                      alignment: Alignment(-0.9,0),
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
                      alignment: Alignment(0,1),
                      child: Container(
                        height: 50,
                        child: TabBar(
                          labelStyle: TextStyle(
                            fontFamily: "drawerbody",
                          ),
                          indicatorColor: theme.colorScheme.secondary,
                          tabs: [
                            Tab(
                              child: Text(
                                "Comments",
                                style: TextStyle(color: theme.colorScheme.inversePrimary),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Bookmarks",
                                style: TextStyle(color: theme.colorScheme.inversePrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.9,0),
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
            //   automaticallyImplyLeading: false,
            //   backgroundColor: theme.colorScheme.primary,
            //   elevation: 0,
            //   leading: GestureDetector(
            //       onTap: () {
            //         Navigator.pop(context);
            //         // Navigator.push(context, MaterialPageRoute(
            //         //     builder: (context)=>
            //         //         UserDashboard(tab: "all",)
            //         // ));
            //       },
            //       child: Icon(
            //         Icons.arrow_back_ios,
            //       )),
            //   actions: [
            //     Image.asset(
            //       'assets/images/logo.png',
            //       fit: BoxFit.cover,
            //       width: 40,
            //       height: 40,
            //     )
            //   ],
            //   bottom: TabBar(
            //     indicatorColor: theme.colorScheme.secondary,
            //     labelStyle: TextStyle(
            //         color: theme.colorScheme.inversePrimary,
            //         fontFamily: "drawerbody"),
            //     tabs: [
            //       Tab(
            //         child: Text(
            //           "Comments",
            //           style: TextStyle(
            //             color: theme.colorScheme.inversePrimary,
            //           ),
            //         ),
            //       ),
            //       Tab(
            //         child: Text(
            //           "Likes",
            //           style: TextStyle(
            //             color: theme.colorScheme.inversePrimary,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            backgroundColor: theme.colorScheme.primary,
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                children: [
                  //comments
                  CommentsList(
                      type: 'reading',
                      comment: comment,
                      commentUserId: commentUserIDs,
                      commentIDs: commentIDs,
                      commentDate: commentDate,
                      commentProfile: commentProfile,
                      commentUsername: commentUsername),

                  //likes
                  LikesList(
                    likeIDs: likeIDs,
                    type: "bookmark",
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
