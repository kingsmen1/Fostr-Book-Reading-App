import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/PageSinglePost.dart';
import 'package:fostr/Posts/PostLikesAndComments.dart';
import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/screen/ReportContent.dart';
import 'package:fostr/services/PostService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/constants.dart';
import '../providers/FeedProvider.dart';
import '../providers/PostProvider.dart';
import '../services/InAppNotificationService.dart';
import '../widgets/AppLoading.dart';

class FeedPostCard extends StatefulWidget {
  final Map<String, dynamic> feed;
  final String? page;
  const FeedPostCard({Key? key, required this.feed, this.page})
      : super(key: key);

  @override
  _FeedPostCardState createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard>
    with SingleTickerProviderStateMixin {
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
  String? profile = "";
  var username = "";
  var image = "";
  bool liked = false;
  bool likedStatsLoaded = false;
  bool shouldlike = false;
  bool shouldShow = false;

  bool readMore = false;
  bool authorActive = true;
  bool isBlocked = false;

  late String likes;
  late String comments;
  late Timestamp dateTime;
  late String dateString;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    checkIsActive();
    // loadAlreadyLikedState();
  }

  @override
  void dispose() {
    if (mounted) {
      _animationController.dispose();
    }
    super.dispose();
  }

  void loadAlreadyLikedState() async {
    var postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.feed['id']);
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var rDBPostRef = FirebaseDatabase.instance
        .ref()
        .child('Posts')
        .child(widget.feed["id"].replaceAll(" ", "_").replaceAll(".", "_"));
    var likeObject = await rDBPostRef.child('likes/$userId').get();
    var isLiked =
        likeObject.value != null && (likeObject.value as Map)['liked'] == true;
    if (isLiked) {
      liked = true;
      shouldlike = false;
      if (mounted) {
        setState(() {
          (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("108") : null);
          shouldShow = true;
          shouldlike = false;
          likedStatsLoaded = true;
        });
        _animationController.forward();
      }
    } else {
      if (mounted) {
        setState(() {
          (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("118") : null);
          shouldlike = true;
          likedStatsLoaded = true;
        });
      }
    }
  }

  void updateLikeCount(
      int count, UserModel.User user, UserModel.User currentuser) async {
    var postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.feed['id']);
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var rDBPostRef = FirebaseDatabase.instance
        .ref()
        .child('Posts')
        .child(widget.feed["id"].replaceAll(" ", "_").replaceAll(".", "_"));

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
      _sendLikeNotification(user, currentuser);
    } else {
      rDBPostRef.child('likes/$userId').remove();
    }
    postRef.update({
      'likes': FieldValue.increment(count),
    });
  }

  Future<void> _sendLikeNotification(
      UserModel.User user, UserModel.User currentuser) async {
    final inAppNotificationService = GetIt.I<InAppNotificationService>();
    final token = await inAppNotificationService
        .getNotificationToken(widget.feed['id'].split("_")[0]);

    if (token != null) {
      final payload =
          NotificationPayload(type: NotificationType.Bookmarked, tokens: [
        token
      ], data: {
        "senderUserId": currentuser.id,
        "senderUserName": currentuser.userName,
        "recipientUserId": widget.feed['id'].split("_")[0],
        "title": "${currentuser.userName} bookmarked your reading.",
        "payload": {
          "senderUserId": currentuser.id,
          "senderUserName": currentuser.userName,
          "recipientUserId": widget.feed["id"].split("_")[0],
          "postId": widget.feed["id"],
          "postImage": widget.feed["image"],
          "postUserId": widget.feed["userid"],
          "postUserProfile": widget.feed["userProfile"],
          "postUserName": widget.feed["userName"],
        }
      });

      inAppNotificationService.sendNotification(payload);
    }
  }

  void checkIsActive() {
    isActive = widget.feed["isActive"];
    authorID = widget.feed["userid"];
    // userID = FirebaseAuth.instance.currentUser!.uid;
    userServices.getUserById(authorID).then((value) {
      if (mounted) {
        setState(() {
          (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("194") : null);
          user = value!;
          profile = user.userProfile!.profileImage;
          username = user.userName;
        });
      }
    });
    likes = widget.feed["likes"].toString();
    comments = widget.feed["comments"].toString();

    if (widget.page == 'feed') {
      int seconds = int.parse(widget.feed["dateTime"]
          .toString()
          .split("_seconds: ")[1]
          .split(", _")[0]);
      int nanoseconds = int.parse(widget.feed["dateTime"]
          .toString()
          .split("_nanoseconds: ")[1]
          .split("}")[0]);
      dateTime = Timestamp(seconds, nanoseconds);
      loadAlreadyLikedState();
    } else {
      dateTime = widget.feed["dateTime"];
    }

    var dateObject =
        DateTime.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch);
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
  }

  void deletePost(BuildContext context) async {
    postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.feed['id']);
    postRef.update({
      'isActive': false,
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(widget.feed['id'])
          .delete();
      setState(() {
        (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("244") : null);
        isActive = false;
      });
      final postProvider = Provider.of<PostsProvider>(context, listen: false);
      final feedsProvider = Provider.of<FeedProvider>(context, listen: false);
      feedsProvider.refreshFeed(true);
      await postProvider.refreshPosts(true);
      try{
        await FirebaseFirestore.instance
            .collection('booksearch')
            .doc(widget.feed['bookName'].toString().toLowerCase().trim())
            .collection("activities")
            .doc(widget.feed['id'])
            .delete();
      } catch(e) {}
    });
  }

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: authorID)
        .where('accDeleted', isEqualTo: true)
        .limit(1)
        .get()
        .then((value){
      if(value.docs.length == 1){
        if(value.docs.first['accDeleted']){
          setState(() {
            (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("273") : null);
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
        .where('blockedId', isEqualTo: authorID)
        .limit(1)
        .get()
        .then((value){
      if(value.docs.length == 1){
        if(value.docs.first['isBlocked']){
          setState(() {
            (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("293") : null);
            isBlocked = true;
          });
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    checkIfUserIsInactive();
    checkIfUserIsBlocked(auth.user!.id);
    return isActive && authorActive && !isBlocked
        ? Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
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
                                  child: //widget.feed['userProfile']
                                      profile != null && profile!.isNotEmpty
                                          ? FosterImage(
                                              imageUrl:
                                                  profile!, //widget.feed['userProfile'],
                                              cachedKey:
                                                  profile, //widget.feed['userProfile'],
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
                                // widget.feed['username'],
                                username,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(child: Container()),

                            //delete
                            authorID == userID
                                ? GestureDetector(
                                    onTap: () {
                                      deletePost(context);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      size: 20,
                                    ))
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
                                  fontFamily: "drawerbody", fontSize: 12),
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
                          if (!liked && shouldlike && authorID != userID) {
                            setState(() {
                              (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("427") : null);
                              shouldShow = !shouldShow;
                            });
                            _animationController.forward().then((value) {});

                            updateLikeCount(1, user, auth.user!);
                            setState(() {
                              (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("434") : null);
                              liked = true;
                              shouldlike = false;
                            });
                          }
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FosterImage(
                                imageUrl: widget.feed['image'],
                                cachedKey: widget.feed['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //caption
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Wrap(
                            spacing: 10,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                widget.feed['caption'].isNotEmpty
                                    ? widget.feed['caption']
                                    : "",
                                overflow: (readMore)
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              (widget.feed["caption"].length > 30)
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("484") : null);
                                          readMore = !readMore;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          (readMore) ? "Show Less" : "Show More",
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink()
                            ],
                          ),
                        ),
                      ),

                      //likes and comments
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20) +
                            const EdgeInsets.only(bottom: 5, top: 15),
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("posts")
                                .doc(widget.feed['id'])
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              final feed = snapshot.data?.data();
                              return Row(
                                children: [
                                  (feed?["likes"] > 0)
                                      ? Text(
                                          feed?["likes"].toString() ?? "",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                  Text(
                                    " bookmarks ",
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  (feed?["comments"] > 0)
                                      ? Text(
                                          feed?["comments"].toString() ?? "",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                  Text(
                                    " comments",
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(),
                                  ),

                                  //view more
                                  authorID == userID
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PostLikesAndComments(
                                                            postID: widget
                                                                .feed['id'])));
                                          },
                                          child: Text(
                                            "view more",
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        )
                                      : SizedBox.shrink()
                                ],
                              );
                            }),
                      ),

                      authorID != userID
                          ? LikeandCommentButton(
                              postId: widget.feed['id'],
                              user: user,
                              currentuser: auth.user!,
                              dateTime: dateTime,
                              userid: widget.feed['userid'],
                              userProfile: widget.feed['userProfile'],
                              username: widget.feed['username'],
                              image: widget.feed['image'],
                              caption: widget.feed['caption'],
                              likes: likes,
                              comments: comments,
                              shouldLike: shouldlike,
                              onLike: (likeSate) {
                                setState(() {
                                  (widget.feed["id"] == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("594") : null);
                                  shouldlike = !likeSate;
                                  liked = likeSate;
                                  shouldShow = !shouldShow;
                                });
                                likeSate
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
          )
        : SizedBox.shrink();
  }
}

class LikeandCommentButton extends StatefulWidget {
  final UserModel.User user;
  final UserModel.User currentuser;
  final void Function(bool value)? onStateChange;
  final String postId;
  final Timestamp dateTime;
  final String userid;
  final String userProfile;
  final String username;
  final String image;
  final String caption;
  final String likes;
  final String comments;
  final bool shouldLike;
  final Function(bool value) onLike;
  const LikeandCommentButton(
      {required this.postId,
      this.onStateChange,
      required this.user,
      required this.currentuser,
      required this.dateTime,
      required this.userid,
      required this.userProfile,
      required this.username,
      required this.image,
      required this.caption,
      required this.likes,
      required this.comments,
      required this.shouldLike,
      required this.onLike,
      Key? key})
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
      if (!likedStatsLoaded && mounted) {
        loadAlreadyLikedState();
      }
    });
  }

  void loadAlreadyLikedState() async {
    var likeObject = await rDBPostRef.child('likes/$userId').get();
    var isLiked =
        likeObject.value != null && (likeObject.value as Map)['liked'] == true;
    if (isLiked) {
      liked = true;
    }
    if (mounted) {
      setState(() {
        (widget.postId == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("711") : null);
        likedStatsLoaded = true;
      });
    }
  }

  void updateLikeCount(int count) async {
    await FirebaseAuth.instance.currentUser!.getIdToken().then((token) async {
      if (count == 1) {
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
        _sendLikeNotification(widget.user, widget.currentuser);
      } else {
        rDBPostRef.child('likes/$userId').remove();
      }
    });
    postRef.update({
      'likes': FieldValue.increment(count),
    });
    if (count == 1) {
      widget.onLike(true);
    } else if (count == -1) {
      widget.onLike(false);
    }
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
          "postImage": widget.image,
          "postUserId": widget.postId.split("_")[0],
          "postUserProfile": widget.userProfile,
          "postUserName": widget.username,
        }
      });

      inAppNotificationService.sendNotification(payload);
    }
  }

  void postComment(String comment) async {
    setState(() {
      (widget.postId == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("777") : null);
      postingComment = true;
    });
    postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    UserService userServices = GetIt.I<UserService>();
    await userServices.getUserById(userId).then((value) async {
      if (value != null) {
        USER = value;

        await FirebaseAuth.instance.currentUser!.getIdToken().then((token) {
          PostService()
              .addComment(token, widget.postId, USER.id, USER.userName,
                  USER.name, USER.userProfile!.profileImage ?? "", comment)
              .then((value) {
            if (value) {
              // commentController.clear();
            } else {
              print("post comment didn't post");
            }
          });
        });
        _sendCommentNotification(USER);
      } else {
        print("user not found");
      }
    });
    setState(() {
      (widget.postId == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("804") : null);
      postingComment = false;
    });
  }

  Future<void> _sendCommentNotification(UserModel.User user) async {
    final inAppNotificationService = GetIt.I<InAppNotificationService>();
    final token =
        await inAppNotificationService.getNotificationToken(widget.userid);

    if (token != null) {
      final payload =
          NotificationPayload(type: NotificationType.Comment, tokens: [
        token
      ], data: {
        "recipientUserId": widget.userid,
        "senderUserId": user.id,
        "senderUserName": user.userName,
        "title": "Your reading has a new comment from ${user.userName}!",
        "body": "",
        "payload": {
          "senderUserName": user.userName,
          "postId": widget.postId,
          "senderUserId": user.id,
          "senderUserProfile": user.userProfile?.profileImage,
          "comment": commentController.text,
        },
      });

      inAppNotificationService.sendNotification(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    liked = widget.shouldLike;
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
                    !widget.shouldLike
                        // ? Icons.thumb_up_alt
                        // : Icons.thumb_up_alt_outlined,
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () {
                    // if post is loading whether user have already liked or not
                    if (!likedStatsLoaded) return;

                    liked = !liked;

                    if (!liked) {
                      updateLikeCount(1);
                    } else {
                      updateLikeCount(-1);
                    }
                    widget.onStateChange != null
                        ? widget.onStateChange!(liked)
                        : null;

                    setState(() {
                      (widget.postId == "h8ip9jjSOjRivCwPZpY7NX27UF43_1661242250958" ? print("877") : null);
                    });
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),

              //comment button
              GestureDetector(
                  onTap: () {
                    // setState(() {
                    //   comment = true;
                    // });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PageSinglePost(
                                postId: widget.postId,
                                dateTime: widget.dateTime,
                                userid: widget.userid,
                                userProfile: widget.userProfile,
                                username: widget.username,
                                image: widget.image,
                                caption: widget.caption,
                                likes: widget.likes,
                                comments: widget.comments)
                        ));
                  },
                  child: Icon(
                    Icons.insert_comment_outlined, color: theme.colorScheme.secondary,
                  )),
              Expanded(child: Container()),

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
                                  contentOwnerId: widget.userid,
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

        //add comment
        comment
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10) +
                    const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    //comment
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width - 110,
                      child: TextField(
                        controller: commentController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 1),
                            // filled: true,
                            hintStyle: new TextStyle(color: Colors.grey[600]),
                            hintText: "add a comment",
                            // fillColor: Colors.white,
                            border: new UnderlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.grey))),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),

                    //post button
                    GestureDetector(
                      onTap: () {
                        if (commentController.text.isEmpty) {
                          ToastMessege("comment can't be empty",
                              context: context);
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
                                  : GlobalColors.signUpSignInButton),
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
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
