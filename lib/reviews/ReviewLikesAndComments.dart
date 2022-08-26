import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/widgets/CommentsList.dart';
import 'package:fostr/widgets/LikesList.dart';
import 'package:fostr/widgets/RatedByList.dart';



class ReviewLikesAndComments extends StatefulWidget {
  final String bookName;
  final String reviewID;
  const ReviewLikesAndComments({
    Key? key,
    required this.bookName,
    required this.reviewID,
  }) : super(key: key);

  @override
  _ReviewLikesAndCommentsState createState() => _ReviewLikesAndCommentsState();
}

class _ReviewLikesAndCommentsState extends State<ReviewLikesAndComments> {
  bool loadInitiated = false;
  List ratedByID = [];
  List ratedByRating = [];
  List commentIDs = [];
  List comment = [];
  List commentUserIDs = [];
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
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.reviewID)
        .get()
        .then((value) {

      List list = [];

      try {
        list = value["bookmark"].toList();
      } catch (e){
        list = [];
      }
          setState(() {
            ratedByRating = list;
          });
      // List raters = value.get("ratedBy");
      //
      // raters.forEach((element) {
      //   element.forEach((key, value) {
      //     setState(() {
      //       ratedByID.add(key.toString());
      //       ratedByRating.add(value.toString());
      //     });
      //   });
      // });

      // raters.keys.forEach((element) {
      //   setState(() {
      //     likeIDs.add(element.toString());
      //   });
      // });

      // raters.forEach((element) {
      //   element.keys.forEach((element) {
      //     setState(() {
      //       likeIDs.add(element.toString());
      //     });
      //   });
      // });
      // List list = [];
      // for(int i = 0; i< raters.length; i++){
      //   likeIDs.add(raters[i].toString().split("_")[0]);
      // if(i==0){
      //   likeIDs.add(raters[i].toString().split("_")[0]);
      // }
      // else {
      //   for(int j = 0; i< raters.length; i++){
      //     if(raters[i].toString().split("_")[0] != raters[i].toString().split("_")[0]){
      //       likeIDs.add(raters[i].toString().split("_")[0]);
      //     }
      //   }
      // }
      //
      // for(int j = 1; i<= list.length; i++){
      //   if(raters[i].toString().split("_")[0] != list[j-1]){
      //     setState(() {
      //       likeIDs.add(raters[i].toString().split("_")[0]);
      //       print(raters[i].toString().split("_")[0]);
      //     });
      //   }
      // }
      // }
    });
  }

  void getCommentsList() async {
    await FirebaseDatabase.instance
        .ref()
        .child('book_review_stats')
        .child(widget.reviewID)
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
          //   // title: Text(
          //   //   widget.bookName,
          //   //   style: TextStyle(fontSize: 20),
          //   // ),
          //   actions: [
          //     Image.asset(
          //       'assets/images/logo.png',
          //       fit: BoxFit.cover,
          //       width: 40,
          //       height: 40,
          //     )
          //   ],
          //   bottom: TabBar(
          //     labelStyle: TextStyle(
          //       fontFamily: "drawerbody",
          //     ),
          //     indicatorColor: theme.colorScheme.secondary,
          //     tabs: [
          //       Tab(
          //         child: Text(
          //           "Comments",
          //           style: TextStyle(color: theme.colorScheme.inversePrimary),
          //         ),
          //       ),
          //       Tab(
          //         child: Text(
          //           "Bookmarks",
          //           style: TextStyle(color: theme.colorScheme.inversePrimary),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          backgroundColor: theme.colorScheme.primary,
          body: TabBarView(
            children: [
              //comments
              CommentsList(
                  type: 'comment',
                  comment: comment,
                  commentUserId: commentUserIDs,
                  commentIDs: commentIDs,
                  commentDate: commentDate,
                  commentProfile: commentProfile,
                  commentUsername: commentUsername),

              //rated by
              LikesList(
                  likeIDs: ratedByRating,
                  type: "bookmark"
              )
              // RatedByList(
              //     name: ratedByID, rating: ratedByRating, type: "raters"),
            ],
          ),
          // Container(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //     child: Column(
          //       children: [
          //         //tabs
          //         Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 20),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               //comments tab
          //               Expanded(
          //                   child: Container(
          //                     height: 40,
          //                     child: GestureDetector(
          //                       onTap: () {
          //                         setState(() {
          //                           likesTab = false;
          //                         });
          //                       },
          //                       child: Column(
          //                         children: [
          //                           Expanded(child: Container()),
          //                           Text(
          //                             "Reviews",
          //                             style: TextStyle(
          //                               color: Colors.white,
          //                                 fontWeight: likesTab
          //                                     ? FontWeight.normal
          //                                     : FontWeight.bold),
          //                           ),
          //                           Expanded(child: Container()),
          //                           Container(
          //                             height: 2,
          //                             color: likesTab
          //                                 ? Colors.grey
          //                                 : GlobalColors.signUpSignInButton,
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   )),
          //
          //               //rated by tab
          //               Expanded(
          //                   child: Container(
          //                     height: 40,
          //                     child: GestureDetector(
          //                       onTap: () {
          //                         setState(() {
          //                           likesTab = true;
          //                         });
          //                       },
          //                       child: Column(
          //                         children: [
          //                           Expanded(child: Container()),
          //                           Text(
          //                             "Rated By",
          //                             style: TextStyle(
          //                               color: Colors.white,
          //                                 fontWeight: likesTab
          //                                     ? FontWeight.bold
          //                                     : FontWeight.normal),
          //                           ),
          //                           Expanded(child: Container()),
          //                           Container(
          //                             height: 2,
          //                             color: likesTab
          //                                 ? GlobalColors.signUpSignInButton
          //                                 : Colors.grey,
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   )),
          //             ],
          //           ),
          //         ),
          //
          //         likesTab
          //             ?
          //
          //         //rated by
          //         RatedByList(name: ratedByID, rating: ratedByRating, type: "raters")
          //             :
          //
          //         //comments
          //         CommentsList(
          //           comment: comment,
          //           commentIDs: commentIDs,
          //           commentDate: commentDate,
          //           commentProfile: commentProfile,
          //           commentUsername: commentUsername
          //         )
          //       ],
          //     )
          // )
        ),
      ),
    );
  }
}

// class LikesUserCard extends StatefulWidget {
//   final String id;
//   const LikesUserCard({Key? key, required this.id}) : super(key: key);
//
//   @override
//   State<LikesUserCard> createState() => _LikesUserCardState();
// }
//
// class _LikesUserCardState extends State<LikesUserCard> with FostrTheme {
//   User user = User.fromJson({
//     "name": "user",
//     "userName": "user",
//     "id": "userId",
//     "userType": "USER",
//     "createdOn": DateTime.now().toString(),
//     "lastLogin": DateTime.now().toString(),
//     "invites": 10,
//   });
//   bool followed = true;
//   final UserService userService = GetIt.I<UserService>();
//
//   @override
//   void initState() {
//     super.initState();
//     userService.getUserById(widget.id).then((value) => {
//       if (value != null)
//         {
//           setState(() {
//             user = value;
//           })
//         }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context);
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         CupertinoPageRoute(
//           builder: (context) {
//             return ExternalProfilePage(
//               user: user,
//             );
//           },
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(left: 10.0, right: 10),
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           // height: 65,
//           constraints: BoxConstraints(minHeight: 80),
//           width: 80.w,
//           decoration: BoxDecoration(
//               color: Color(0xffffffff), borderRadius: BorderRadius.circular(10)
//             // boxShadow: [
//             //   BoxShadow(
//             //     offset: Offset(0, 4),
//             //     blurRadius: 10,
//             //     color: Colors.black.withOpacity(0),
//             //   )
//             // ],
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                 height: 12.w,
//                 width: 12.w,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   image: DecorationImage(
//                       fit: BoxFit.cover,
//                       image: (user.userProfile != null)
//                           ? (user.userProfile?.profileImage != null)
//                           ? Image.network(
//                         user.userProfile!.profileImage!,
//                       ).image
//                           : Image.asset(IMAGES + "profile.png").image
//                           : Image.asset(IMAGES + "profile.png").image),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     (user.name.isNotEmpty)
//                         ? Text(
//                       user.name,
//                       style: h1.copyWith(
//                           fontSize: 12.sp, fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     )
//                         : SizedBox.shrink(),
//                     SizedBox(
//                       height: 5,
//                     ),
//                     (user.bookClubName != null && user.bookClubName!.isNotEmpty)
//                         ? Text(
//                       user.bookClubName!,
//                       style: h1.copyWith(
//                           fontSize: 12.sp, fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     )
//                         : SizedBox.shrink(),
//                     SizedBox(
//                       height: 5,
//                     ),
//                     Text(
//                       "@" + user.userName,
//                       style: h2.copyWith(fontSize: 12),
//                       overflow: TextOverflow.ellipsis,
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }