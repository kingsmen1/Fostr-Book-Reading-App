import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/PostLikesAndComments.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/screen/ReportContent.dart';
import 'package:fostr/services/InAppNotificationService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:fostr/services/UserService.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/AppLoading.dart';

class PageSinglePost extends StatefulWidget {
  final String postId;
  final Timestamp dateTime;
  final String userid;
  final String userProfile;
  final String username;
  final String image;
  final String caption;
  final String likes;
  final String comments;
  const PageSinglePost({
    Key? key,
    required this.postId,
    required this.dateTime,
    required this.userid,
    required this.userProfile,
    required this.username,
    required this.image,
    required this.caption,
    required this.likes,
    required this.comments,
  }) : super(key: key);

  @override
  _PageSinglePostState createState() => _PageSinglePostState();
}

class _PageSinglePostState extends State<PageSinglePost>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  UserModel.User user = UserModel.User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  UserService userServices = GetIt.I<UserService>();
  late DocumentReference<Map<String, dynamic>> postRef;
  bool isActive = true;
  String authorID = "";
  String userID = "";
  var streamBuilder;
  bool authorActive = true;
  bool isBlocked = false;

  bool liked = false;

  @override
  void initState() {
    super.initState();
    // checkIsActive();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    userID = FirebaseAuth.instance.currentUser!.uid;
    loadAlreadyLikedState();
  }

  Future<void> loadAlreadyLikedState() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var rDBPostRef = FirebaseDatabase.instance
        .ref()
        .child('Posts')
        .child(widget.postId.replaceAll(" ", "_").replaceAll(".", "_"));
    var likeObject = await rDBPostRef.child('likes/$userId').get();
    var isLiked =
        likeObject.value != null && (likeObject.value as Map)['liked'] == true;
    if (isLiked) {
      setState(() {
        liked = true;
        shouldShow = true;
      });
      _animationController.forward();
    }
  }

  void deletePost() async {
    postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    postRef.update({
      'isActive': false,
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(widget.postId)
          .delete();
      Navigator.pop(context);
    });
  }

  void updateLikeCount(
      int count, UserModel.User user, UserModel.User currentUser) async {
    var postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var rDBPostRef = FirebaseDatabase.instance
        .ref()
        .child('Posts')
        .child(widget.postId.replaceAll(" ", "_").replaceAll(".", "_"));

    if (count == 1) {
      rDBPostRef.child('likes/$userId').update({
        'username': user.userName,
        'f_name': user.name,
        'liked': true,
        'on': DateFormat.yMMMd()
            .addPattern(" | ")
            .add_jm()
            .format(DateTime.now())
            .toString(),
      });
      _sendLikeNotification(user, currentUser);
    } else {
      rDBPostRef.child('likes/$userId').remove();
    }
    postRef.update({
      'likes': FieldValue.increment(count),
    });
  }

  Future<void> _sendLikeNotification(
      UserModel.User user, UserModel.User currentUser) async {
    final inAppNotificationService = GetIt.I<InAppNotificationService>();

    final token =
        await inAppNotificationService.getNotificationToken(widget.userid);
    if (token != null) {
      final payload =
          NotificationPayload(type: NotificationType.Bookmarked, tokens: [
        token
      ], data: {
        "senderUserId": currentUser.id,
        "senderUserName": currentUser.userName,
        "recipientUserId": widget.userid,
        "title": "${currentUser.userName} bookmarked your reading.",
        "payload": {
          "senderUserId": currentUser.id,
          "senderUserName": currentUser.userName,
          "recipientUserId": widget.userid,
          "postId": widget.postId,
          "postImage": widget.image,
          "postUserId": widget.userid,
          "postUserProfile": widget.userProfile,
          "postUserName": widget.username,
        }
      });

      inAppNotificationService.sendNotification(payload);
    }
  }

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: widget.userid)
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
        .where('blockedId', isEqualTo: widget.userid)
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

  bool shouldShow = false;
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    checkIfUserIsInactive();
    checkIfUserIsBlocked(auth.user!.id);

    var dateObject = DateTime.fromMillisecondsSinceEpoch(
        widget.dateTime.millisecondsSinceEpoch);
    String dateString;
    var dateDiff = DateTime.now().difference(dateObject);
    if (dateDiff.inDays >= 1) {
      dateString = DateFormat.yMMMd()
          .addPattern(" | ")
          .add_jm()
          .format(dateObject)
          .toString();
    } else {
      dateString = timeago.format(dateObject);
    }

    userServices.getUserById(widget.userid).then((value) {
      if (value != null) {
        user = value;
      }
    });

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                        "Readings",
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
        //   title: Text(
        //     "Post",
        //     style: TextStyle(fontFamily: "drawerhead", fontSize: 20),
        //   ),
        //   centerTitle: true,
        //   leading: GestureDetector(
        //     onTap: () {
        //       Navigator.of(context).pop();
        //     },
        //     child: Icon(
        //       Icons.arrow_back_ios,
        //     ),
        //   ),
        //   actions: [
        //     GestureDetector(
        //       onTap: () {
        //         FostrRouter.goto(context, Routes.userProfile);
        //       },
        //       child: RoundedImage(
        //         width: 38,
        //         height: 38,
        //         borderRadius: 35,
        //         url: auth.user?.userProfile?.profileImage,
        //       ),
        //     ),
        //     SizedBox(
        //       width: 10,
        //     )
        //   ],
        // ),

        body: authorActive && !isBlocked?
        SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Stack(
              children: [
                Container(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      // color: theme.colorScheme.surface,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),

                        //dp, username and delete
                        Container(
                          height: 40,
                          child: Row(
                            children: [
                              //dp
                              SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ExternalProfilePage(user: user)));
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: widget.userProfile.isNotEmpty
                                        ? FosterImage(
                                            imageUrl: widget.userProfile,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            "assets/images/logo.png",
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),

                              //username
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ExternalProfilePage(user: user)));
                                },
                                child: Text(
                                  widget.username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),

                              //delete
                              widget.userid == userID
                                  ? GestureDetector(
                                      onTap: () {
                                        deletePost();
                                      },
                                      child: Icon(Icons.delete,
                                          size: 20, color: Colors.grey))
                                  : SizedBox.shrink(),
                              SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        //time
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Text(
                                dateString,
                                style: TextStyle(
                                    fontSize: 12, fontFamily: "drawerbody"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        //image
                        GestureDetector(
                          onDoubleTap: () async {
                            if (!liked && widget.userid != userID) {
                              setState(() {
                                shouldShow = !shouldShow;
                              });
                              _animationController.forward();
                              setState(() {
                                liked = true;
                              });
                              updateLikeCount(1, user, auth.user!);
                            }
                          },
                          child: Container(
                            child: FosterImage(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              imageUrl: widget.image,
                              cachedKey: widget.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        //caption
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              widget.caption.isNotEmpty ? widget.caption : "",
                              style: TextStyle(
                                  fontSize: 16, fontFamily: "drawerbody"),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),

                        //likes and comments
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20) +
                              const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("posts")
                                    .doc(widget.postId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return new Text('Error: ${snapshot.error}');
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return new Text("");
                                    default:
                                      String? data = snapshot.data!
                                          .get("likes")
                                          .toString();
                                      return Text(
                                        data == "null" || data == "0"
                                            ? "bookmarks"
                                            : data + " bookmarks",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: "drawerbody"),
                                      );
                                  }
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("posts")
                                    .doc(widget.postId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return new Text('Error: ${snapshot.error}');
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return new Text("");
                                    default:
                                      String? data = snapshot.data!
                                          .get("comments")
                                          .toString();
                                      return Text(
                                        data == "null" || data == "0"
                                            ? "comments"
                                            : data + " comments",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: "drawerbody"),
                                      );
                                  }
                                },
                              ),

                              Expanded(
                                child: Container(),
                              ),

                              //view more
                              widget.userid == userID
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PostLikesAndComments(
                                                        postID:
                                                            widget.postId)));
                                      },
                                      child: Text(
                                        "view more",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontFamily: "drawerbody"),
                                      ),
                                    )
                                  : SizedBox.shrink()
                            ],
                          ),
                        ),

                        widget.userid != userID
                            ? LikeandCommentButton(
                                postId: widget.postId,
                                user: user,
                                postUserid: widget.userid,
                                isLiked: liked,
                                currentUser: auth.user!,
                                postimage: widget.image,
                                postUsername: widget.username,
                                postprofileImage: widget.userProfile,
                                onStateChange: (likeState) {
                                  setState(() {
                                    liked = likeState;
                                    shouldShow = !shouldShow;
                                  });
                                  likeState
                                      ? _animationController.forward()
                                      : _animationController.reverse();
                                },
                              )
                            : SizedBox.shrink()
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.9, -1),
                  child: (shouldShow)
                      ? LottieBuilder.asset(
                          // "assets/lottie/bookmark.json",
                          "assets/lottie/heart.json",
                          controller: _animationController,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover)
                      : SizedBox.shrink(),
                )
              ],
            )) :

            //inactive content
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: Center(
              child: Container(
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
                          'Inactive content',
                          style: TextStyle(
                            color: theme.colorScheme.inversePrimary,
                            fontFamily: "drawerbody",
                          ),
                        ),
                      ]
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LikeandCommentButton extends StatefulWidget {
  final UserModel.User user;
  final void Function(bool value) onStateChange;
  final String postId;
  final String postUserid;
  final bool isLiked;
  final UserModel.User currentUser;
  final String postimage;
  final String postprofileImage;
  final String postUsername;
  const LikeandCommentButton(
      {required this.postId,
      required this.postimage,
      required this.postprofileImage,
      required this.postUsername,
      required this.onStateChange,
      required this.user,
      required this.currentUser,
      required this.postUserid,
      Key? key,
      required this.isLiked})
      : super(key: key);

  @override
  _LikeandCommentButtonState createState() => _LikeandCommentButtonState();
}

class _LikeandCommentButtonState extends State<LikeandCommentButton> {
  late DocumentReference<Map<String, dynamic>> postRef;
  late DatabaseReference rDBPostRef;
  bool postingComment = false;
  late String userId;
  bool liked = false;
  bool comment = false;
  bool likedStatsLoaded = false;
  TextEditingController commentController = new TextEditingController();

  UserModel.User USER = UserModel.User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });

  @override
  void initState() {
    postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    userId = FirebaseAuth.instance.currentUser!.uid;
    rDBPostRef = FirebaseDatabase.instance
        .ref()
        .child('Posts')
        .child(widget.postId.replaceAll(" ", "_").replaceAll(".", "_"));
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (!likedStatsLoaded) {
        loadAlreadyLikedState();
      }
    });
  }

  void loadAlreadyLikedState() async {
    var likeObject = await rDBPostRef.child('likes/$userId').get();
    var isLiked =
        likeObject.value != null && (likeObject.value as Map)['liked'] == true;
    if (isLiked) {
      setState(() {
        liked = true;
      });
    }
    setState(() {
      likedStatsLoaded = true;
    });
  }

  void updateLikeCount(int count) async {
    await FirebaseAuth.instance.currentUser!.getIdToken().then((token) async {
      if (count == 1) {
        // PostService().addLike(
        //     token,
        //     widget.postId,
        //     userId,
        //     widget.user.userName,
        //     widget.user.name
        // ).then((value){
        //   if(value){
        //     print("post like successfull");
        //   } else {
        //     print("post like unsuccessfull");
        //   }
        // });

        rDBPostRef.child('likes/$userId').update({
          'username': widget.user.userName,
          'f_name': widget.user.name,
          'liked': true,
          'on': DateFormat.yMMMd()
              .addPattern(" | ")
              .add_jm()
              .format(DateTime.now())
              .toString(),
        });
        _sendLikeNotification(widget.user, widget.currentUser);
      } else {
        // PostService().unLike(
        //   token,
        //   widget.postId,
        //   userId,
        // ).then((value){
        //   if(value){
        //     print("post unlike successfull");
        //   } else {
        //     print("post unlike unsuccessfull");
        //   }
        // });

        rDBPostRef.child('likes/$userId').remove();
      }
    });

    postRef.update({
      'likes': FieldValue.increment(count),
    });
  }

  Future<void> _sendLikeNotification(
      UserModel.User user, UserModel.User currentUser) async {
    final inAppNotificationService = GetIt.I<InAppNotificationService>();

    final token = await inAppNotificationService
        .getNotificationToken(widget.postId.split("_")[0]);
    if (token != null) {
      final payload =
          NotificationPayload(type: NotificationType.Bookmarked, tokens: [
        token
      ], data: {
        "senderUserId": currentUser.id,
        "senderUserName": currentUser.userName,
        "recipientUserId": widget.postId.split("_")[0],
        "title": "${currentUser.userName} bookmarked your reading.",
        "payload": {
          "senderUserId": currentUser.id,
          "senderUserName": currentUser.userName,
          "postId": widget.postId,
          "postImage": widget.postimage,
          "postUserId": widget.postId.split("_")[0],
          "postUserProfile": widget.postprofileImage,
          "postUserName": widget.postUsername,
        }
      });

      inAppNotificationService.sendNotification(payload);
    }
  }

  void postComment(String comment) async {
    setState(() {
      postingComment = true;
    });
    postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    UserService userServices = GetIt.I<UserService>();
    await userServices.getUserById(userId).then((value) async {
      if (value != null) {
        USER = value;

        // await FirebaseAuth.instance.currentUser!.getIdToken().then((token){
        //   PostService().addComment(
        //       token,
        //       widget.postId,
        //       USER.id,
        //       USER.userName,
        //       USER.name,
        //       USER.userProfile!.profileImage ?? "",
        //       comment
        //   ).then((value){
        //     if(value){
        //       // commentController.clear();
        //     } else {
        //       print("post comment didn't post");
        //     }
        //   });
        // });

        await FirebaseDatabase.instance
            .ref()
            .child('Posts')
            .child(widget.postId.replaceAll(" ", "_").replaceAll(".", "_"))
            .child("comments")
            .push()
            .set({
          'by': USER.id,
          'username': USER.userName,
          'f_name': USER.name,
          'profile': USER.userProfile!.profileImage,
          'comment': commentController.text,
          'active': true,
          'on': DateTime.now().millisecondsSinceEpoch,
        }).then((value) {
          commentController.clear();
          postRef.update({
            'comments': FieldValue.increment(1),
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PostLikesAndComments(postID: widget.postId)));
        });
        _sendCommentNotification(USER);
      } else {
        print("user not found");
      }
    });
    setState(() {
      postingComment = false;
    });
  }

  Future<void> _sendCommentNotification(UserModel.User user) async {
    final inAppNotificationService = GetIt.I<InAppNotificationService>();
    final token =
        await inAppNotificationService.getNotificationToken(widget.postUserid);

    if (token != null) {
      final payload =
          NotificationPayload(type: NotificationType.Comment, tokens: [
        token
      ], data: {
        "recipientUserId": widget.postUserid,
        "senderUserId": userId,
        "senderUserName": user.userName,
        "title": "Your reading has a new comment from ${user.userName}!",
        "body": "",
        "payload": {
          "senderUserName": user.userName,
          "postId": widget.postId,
          "senderUserId": userId,
          "senderUserProfile": user.userProfile?.profileImage,
          "comment": commentController.text,
        },
      });

      inAppNotificationService.sendNotification(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    liked = widget.isLiked;
    final theme = Theme.of(context);
    return Column(
      children: [
        //buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              //like button
              AnimatedOpacity(
                opacity: likedStatsLoaded ? 1 : .25,
                duration: Duration(milliseconds: 250),
                child: IconButton(
                  icon: Icon(
                    liked ? Icons.bookmark : Icons.bookmark_border,
                    color: theme.colorScheme.secondary,
                    // liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                  ),
                  onPressed: () {
                    // if post is loading whether user have already liked or not
                    if (!likedStatsLoaded) return;

                    if (!liked) {
                      updateLikeCount(1);
                    } else {
                      updateLikeCount(-1);
                    }
                    liked = !liked;

                    widget.onStateChange(liked);

                    setState(() {});
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),

              //comment button
              GestureDetector(
                  onTap: () {
                    setState(() {
                      comment = true;
                    });
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => PageSinglePost()));
                  },
                  child: Icon(
                    Icons.insert_comment_outlined,
                    color: theme.colorScheme.secondary,
                    size: 22,
                  )),
              Expanded(
                child: Container(),
              ),

              //view more
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PostLikesAndComments(postID: widget.postId)));
                },
                child: Text(
                  "view more",
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              //report
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReportContent(
                                contentId: widget.postId,
                                contentType: 'Reading',
                                contentOwnerId: widget.postUserid,
                              )
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(Icons.flag,color: Colors.red, size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
        // AnimatedOpacity(
        //   opacity: likedStatsLoaded ? 1 : .25,
        //   duration: Duration(milliseconds: 250),
        //   child: IconButton(
        //     icon: Icon(
        //         liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined),
        //     onPressed: () {
        //       // if post is loading whether user have already liked or not
        //       if (!likedStatsLoaded) return;
        //
        //       liked = !liked;
        //
        //       if (liked) {
        //         updateLikeCount(1);
        //       } else {
        //         updateLikeCount(-1);
        //       }
        //       widget.onStateChange != null
        //           ? widget.onStateChange!(liked)
        //           : null;
        //
        //       setState(() {});
        //     },
        //   ),
        // ),

        //add comment
        // comment ?
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10) +
              const EdgeInsets.only(bottom: 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 80,
            child: Row(
              children: [
                //comment
                Expanded(
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width - 110,
                    child: TextField(
                      controller: commentController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          color: theme.colorScheme.inversePrimary,
                          fontFamily: "drawerbody"),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 1),
                          // filled: true,
                          hintStyle: new TextStyle(
                              color: Colors.grey[600], fontFamily: "drawerbody"),
                          hintText: "add a comment",
                          // fillColor: Colors.white,
                          border: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.grey))),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),

                //post button
                GestureDetector(
                  onTap: () {
                    if (commentController.text.isEmpty) {
                      ToastMessege("comment can't be empty", context: context);
                      // Fluttertoast.showToast(
                      //     msg: "comment can't be empty",
                      //     toastLength: Toast.LENGTH_SHORT,
                      //     gravity: ToastGravity.BOTTOM,
                      //     timeInSecForIosWeb: 2,
                      //     backgroundColor: gradientBottom,
                      //     textColor: Colors.white,
                      //     fontSize: 16.0);
                    } else {
                      postComment(commentController.text);
                    }
                  },
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: postingComment
                              ? Colors.transparent
                              : theme.colorScheme.secondary),
                      child: postingComment
                          ? AppLoading(
                              height: 70,
                              width: 70,
                            )
                          :
                          // CircularProgressIndicator(color: GlobalColors.signUpSignInButton) :
                          Icon(
                              Icons.send,
                              size: 18,
                              color: Colors.white,
                            )),
                )
              ],
            ),
          ),
        )
        // :
        // SizedBox.shrink(),
      ],
    );
  }
}
