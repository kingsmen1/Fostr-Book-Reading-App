import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/core/functions.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/ReviewLikesAndComments.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/screen/ReportContent.dart';
import 'package:fostr/services/AudioPlayerService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ArchiveBitsWidget.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants.dart';
import '../services/InAppNotificationService.dart';
import '../utils/dynamic_links.dart';
import '../widgets/AppLoading.dart';

class PageSingleReview extends StatefulWidget {
  final String url;
  final String profile;
  final String username;
  final String bookName;
  final String bookAuthor;
  final String bookBio;
  final String dateTime;
  final String id;
  final String uid;
  final String? imageUrl;

  const PageSingleReview(
      {Key? key,
      required this.url,
      required this.profile,
      required this.username,
      required this.bookName,
      required this.bookAuthor,
      required this.bookBio,
      required this.dateTime,
      required this.id,
      required this.imageUrl,
      required this.uid})
      : super(key: key);

  @override
  _PageSingleReviewState createState() => _PageSingleReviewState();
}

class _PageSingleReviewState extends State<PageSingleReview> with FostrTheme {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> postStream;
  bool liked = false;
  bool posting = false;
  int ratingValue = 0;

  TextEditingController commentTextEditingController =
      new TextEditingController();
  late DocumentReference<Map<String, dynamic>> postRef;

  String userid = auth.FirebaseAuth.instance.currentUser!.uid;
  bool ratingStatsLoaded = false;
  late String userId;
  bool authorActive = true;
  bool isBlocked = false;
  List raterCount = [];
  late DatabaseReference rDBPostRef;
  // late AuthProvider Auth;
  User user = User.fromJson({
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
    postStream = FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.id)
        .snapshots();
    postRef = FirebaseFirestore.instance.collection('reviews').doc(widget.id);
    userId = auth.FirebaseAuth.instance.currentUser!.uid;
    rDBPostRef = FirebaseDatabase.instance
        .ref()
        .child('book_review_stats')
        .child(widget.id);
    getRatersCount();
    loadAlreadyRatedState();
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (!ratingStatsLoaded) {
        // loadAlreadyRatedState();
      }
    });
  }

  void loadAlreadyRatedState() async {
    await postRef.get().then((value) {
      List raters = value.get("ratedBy");

      raters.forEach((element) {
        element.forEach((key, value) {
          if (key == userId) {
            setState(() {
              ratingValue = value;
              ratingStatsLoaded = true;
            });
          }
        });
      });
    });
  }

  void getRatersCount() async {
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.id)
        .get()
        .then((value) {
      List raters = value.get("ratedBy");

      raters.forEach((element) {
        element.forEach((key, value) {
          setState(() {
            raterCount.add(key.toString());
          });
        });
      });
    });
  }

  Future<void> _sendRatingNotification(int count, User currentuser) async {
    final inAppNotification = GetIt.I<InAppNotificationService>();
    final token =
        await inAppNotification.getNotificationToken(widget.id.split("_")[0]);

    if (token != null) {
      final payload =
          NotificationPayload(type: NotificationType.Rating, tokens: [
        token
      ], data: {
        "recipientUserId": widget.id.split("_")[0],
        "senderUserId": currentuser.id,
        "senderUserName": currentuser.userName,
        "title": "Your bit has received new ratings!",
        "body": "",
        "payload": {
          "senderUserId": currentuser.id,
          "senderUserName": currentuser.userName,
          "senderUserProfile": currentuser.userProfile!.profileImage,
          "bitsId": widget.id,
          "rating": count.toString()
        }
      });

      inAppNotification.sendNotification(payload);
    }
  }

  void updateRating(int count, User currentuser) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    rDBPostRef.child('ratings/$userId').get().then((value) => {
          if (value.exists)
            {
              value.ref.update({
                'username': auth.user!.userName,
                'f_name': auth.user!.name,
                "rating": count,
                'on': DateFormat.yMMMd()
                    .addPattern(" | ")
                    .add_jm()
                    .format(DateTime.now())
                    .toString(),
              })
            }
          else
            {
              value.ref.set({
                'username': auth.user!.userName,
                'f_name': auth.user!.name,
                "rating": count,
                'on': DateFormat.yMMMd()
                    .addPattern(" | ")
                    .add_jm()
                    .format(DateTime.now())
                    .toString(),
              })
            }
        });

    final postDoc = await postRef.get();
    final post = postDoc.data();
    final ratedBy = post?['ratedBy'];
    if (ratedBy != null && ratedBy.isNotEmpty) {
      bool rated = false;
      ratedBy.forEach((element) {
        element.forEach((key, value) {
          if (key == userId) {
            post?["ratings"] -= value;
            ratingValue = count;
            element[userId] = count;
            rated = true;
          }
        });
      });
      if (rated) {
        post?["ratings"] += count;
        postRef.update({
          'ratings': post?['ratings'],
          'ratedBy': ratedBy
          // [{userId: count}]
        });
      } else {
        post?["ratings"] += count;
        ratedBy.add({userId: count});
        postRef.update({
          'ratings': post?['ratings'],
          'ratedBy': ratedBy,
        });
      }
    } else {
      postRef.update({
        'ratings': FieldValue.increment(count),
        'ratedBy': [
          {userId: count}
        ]
      });
    }

    _sendRatingNotification(count, currentuser);
  }

  Future<void> _sendCommentNotification(User currentuser) async {
    final inAppNotification = GetIt.I<InAppNotificationService>();
    final token =
        await inAppNotification.getNotificationToken(widget.id.split("_")[0]);
    // print("-------11111------${widget.id}--------------");
    // print("-------22222-----${widget.uid}--------------");
    // print("-------33333-----${currentuser.id}--------------");

    if (token != null) {
      final payload =
          NotificationPayload(type: NotificationType.Review, tokens: [
        token
      ], data: {
        "senderUserId": currentuser.id,
        "senderUserName": currentuser.userName,
        "recipientUserId": widget.id.split("_")[0],
        "message": "",
        "title": "Your bit has received a new review!",
        "body": "",
        "payload": {
          "senderUserId": currentuser.id,
          "senderUserName": currentuser.userName,
          "senderUserProfile": currentuser.userProfile!.profileImage,
          "bitsId": widget.id,
        }
      });

      inAppNotification.sendNotification(payload);
    }
  }

  void saveComment(String comment, User currentuser) async {
    setState(() {
      posting = true;
    });
    postRef = FirebaseFirestore.instance.collection('reviews').doc(widget.id);
    UserService userServices = GetIt.I<UserService>();
    await userServices.getUserById(widget.uid).then((value) async {
      if (value != null) {
        user = value;
        auth.FirebaseAuth.instance.currentUser!
            .getIdToken()
            .then((token) async {
          await FirebaseDatabase.instance
              .ref()
              .child('book_review_stats')
              .child(widget.id)
              .child("comments")
              .push()
              .set({
            'by': user.id,
            'username': user.userName,
            'f_name': user.name,
            'profile': user.userProfile!.profileImage,
            'comment': comment,
            'active': true,
            'on': DateTime.now().millisecondsSinceEpoch,
          }).then((value) {
            commentTextEditingController.clear();
            postRef.update({
              'comments': FieldValue.increment(1),
            });
            _sendCommentNotification(currentuser);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReviewLikesAndComments(
                          bookName: widget.bookName,
                          reviewID: widget.id,
                        )));
          });
        });
      } else {
        print("user not found");
      }
    });
    setState(() {
      posting = false;
    });
  }

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: widget.id.split("_")[0])
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
        .where('blockedId', isEqualTo: widget.id.split('_')[0])
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    checkIfUserIsInactive();
    checkIfUserIsBlocked(auth.user!.id);

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
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
                          "Review",
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

          backgroundColor: theme.colorScheme.primary,

          body: authorActive && !isBlocked?
          SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                //card
                ReviewCard(
                    url: widget.url,
                    profile: widget.profile,
                    username: widget.username,
                    bookName: widget.bookName,
                    bookAuthor: widget.bookAuthor,
                    bookBio: widget.bookBio,
                    dateTime: widget.dateTime,
                    id: widget.id,
                    imageUrl: widget.imageUrl,
                    uid: widget.uid,
                  authId: auth.user!.id,
                ),

                //ratings
                // (auth.user!.id != widget.id.split("_")[0])
                //     ? Padding(
                //         padding: const EdgeInsets.all(7),
                //         child: Row(
                //           children: [
                //             RatingBar.builder(
                //               initialRating:
                //                   double.parse(ratingValue.toString()),
                //               minRating: 1,
                //               direction: Axis.horizontal,
                //               allowHalfRating: false,
                //               itemCount: 5,
                //               itemSize: 20,
                //               unratedColor: Colors.grey,
                //               itemBuilder: (context, _) => Icon(
                //                 Icons.star,
                //                 color: theme.colorScheme.secondary,
                //               ),
                //               onRatingUpdate: (rating) {
                //                 updateRating(rating.toInt(), auth.user!);
                //                 setState(() {
                //                   ratingValue = rating.toInt();
                //                   ratingStatsLoaded = true;
                //                 });
                //               },
                //             ),
                //           ],
                //         ),
                //       )
                //     : SizedBox.shrink(),

                //likes and comments
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReviewLikesAndComments(
                                    bookName: widget.bookName,
                                    reviewID: widget.id,
                                  )));
                    },
                    child: Row(
                      children: [
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('reviews')
                                .doc(widget.id)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError)
                                return new Text('Error: ${snapshot.error}');
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Text(
                                    "  comments",
                                  );
                                default:
                              }
                              final data = snapshot.data?.data()?["comments"];
                              return Text(
                                (data != null && data > 0)
                                    ? data.toString() + " comments"
                                    : "comments",
                              );
                            }),

                        SizedBox(
                          width: 5,
                        ),

                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('reviews')
                                .doc(widget.id)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError)
                                return new Text('Error: ${snapshot.error}');
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Text(
                                    "  bookmarks",
                                  );
                                default:
                              }

                              int cnt = 0;

                              try {
                                List data = snapshot.data?.data()?["bookmark"].toList();
                                cnt = data.length;
                              } catch (e){
                                cnt = 0;
                              }
                              return Text(
                                (cnt != null && cnt > 0)
                                    ? cnt.toString() + " bookmarks"
                                    : "bookmarks",
                              );
                            }),

                        //comment
                        // StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        //     stream: FirebaseFirestore.instance
                        //         .collection('reviews')
                        //         .doc(widget.id)
                        //         .snapshots(),
                        //     builder: (context, snapshot) {
                        //       if (snapshot.hasError)
                        //         return new Text('Error: ${snapshot.error}');
                        //       switch (snapshot.connectionState) {
                        //         case ConnectionState.waiting:
                        //           return Text(
                        //             "  ratings ",
                        //           );
                        //         default:
                        //       }
                        //       final data =
                        //           snapshot.data?.data()?["ratedBy"]?.length;
                        //
                        //       return Text(
                        //         (data != null && data > 0)
                        //             ? data.toString() + " ratings"
                        //             : "ratings",
                        //       );
                        //     }),
                        Expanded(child: Container()),
                        Text(
                          "View more",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //comments box
                (auth.user!.id != widget.id.split("_")[0])
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: commentTextEditingController,
                          style: h2.copyWith(
                              color: theme.colorScheme.inversePrimary),
                          maxLength: 500,
                          maxLines: 5,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            filled: true,
                            hintText: "Share your thoughts",
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                  width: 0.5, color: Colors.transparent),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          autofocus: false,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                        ),
                      )
                    : SizedBox.shrink(),

                //post button
                (auth.user!.id != widget.id.split("_")[0])
                    ? posting
                        ? AppLoading(
                            height: 70,
                            width: 70,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (commentTextEditingController.text.isEmpty) {
                                  ToastMessege("Please write a comment!",
                                      context: context);
                                }
                                else {
                                  KeyBoardUnfocus(context);
                                  saveComment(commentTextEditingController.text,
                                      auth.user!);
                                }
                              },
                              child: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    Expanded(child: Container()),
                                    Text(
                                      "Post  ",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                    Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                    Expanded(child: Container()),
                                  ],
                                ),
                              ),
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5)),
                                backgroundColor: MaterialStateProperty.all(
                                    theme.colorScheme.secondary),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          )
                    : SizedBox.shrink(),
              ],
            ),
          ) :

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
      ),
    );
  }
}

class ReviewCard extends StatefulWidget {
  final String url;
  final String profile;
  final String username;
  final String bookName;
  final String bookAuthor;
  final String bookBio;
  final String dateTime;
  final String id;
  final String uid;
  final String authId;
  final String? imageUrl;

  const ReviewCard(
      {Key? key,
      required this.url,
      required this.imageUrl,
      required this.profile,
      required this.username,
      required this.bookName,
      required this.bookAuthor,
      required this.bookBio,
      required this.dateTime,
      required this.id,
        required this.authId,
      required this.uid})
      : super(key: key);

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  AudioPlayer player = AudioPlayer();
  bool isAudioAvailable = false;
  bool loading = false;
  bool isReadyToPlay = false;
  bool isPlaying = false;
  bool isFinished = false;
  Duration? audioDuration;

  String logo = "https://firebasestorage.googleapis.com/v0/b/fostr2021.appspot.com/o/FCMImages%2Ffostr.jpg?alt=media&token=42c10be6-9066-491b-a440-72e5b25fbef7";
  User user = User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  bool bookmarked = false;

  @override
  void initState() {
    checkIfBookmarked();
    player.positionStream.listen((event) async {
      if (audioDuration != null && event == audioDuration) {
        await player.stop();
        player.seek(Duration.zero);
        setState(() {
          isPlaying = false;
          isFinished = true;
        });
      }
    });
    getUserModel();
    isAudioAvailable = true;
    super.initState();
  }

  void _init() async {
    try {
      await player.setUrl(widget.url).then((value) {
        setState(() {
          audioDuration = value;
          isAudioAvailable = true;
          isReadyToPlay = true;
          isPlaying = true;
          loading = false;
        });
        player.play();
      });
    } catch (e) {
      debugPrint('An error occured $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void downloadWidget(String url) {
    setState(() {
      loading = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _init();
      }
    });
  }

  void getUserModel() {
    UserService userServices = GetIt.I<UserService>();
    userServices.getUserById(widget.id.split('_')[0]).then((value) {
      if (value != null) {
        user = value;
      }
    });
  }


  void bookmark(bool remove) async {
    await FirebaseFirestore.instance
        .collection("reviews")
        .where("id", isEqualTo: widget.id)
        .get()
        .then((value){
      value.docs.forEach((element) async {
        await FirebaseFirestore.instance
            .collection("reviews")
            .doc(element.id)
            .set({
          "bookmark" : remove ? FieldValue.arrayRemove([widget.authId]) : FieldValue.arrayUnion([widget.authId])
        }, SetOptions(merge: true));
      });
    });
  }

  void checkIfBookmarked() async {
    await FirebaseFirestore.instance
        .collection("reviews")
        .where("id", isEqualTo: widget.id)
        .get()
        .then((value){
      value.docs.forEach((element) async {
        try {
          List list = element["bookmark"].toList();
          setState(() {
            bookmarked = list.contains(widget.authId) ? true : false;
          });
        } catch (e) {
          setState(() {
            bookmarked = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    String currentUserId = auth.user!.id;
    return
        //audioUrl.isNotEmpty ?
        Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            //editor details area
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: [
                  //dp
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ExternalProfilePage(user: user)));
                    },
                    child: Container(
                      height: 40,
                      width: 280,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: widget.profile.isEmpty
                                    ? Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : FosterImage(
                                        imageUrl: widget.profile,
                                        fit: BoxFit.cover),
                              ),
                            ),
                          ),

                          //name and username
                          Container(
                            width: 220,
                            child: Column(
                              children: [
                                Expanded(child: Container()),
                                // Row(
                                //   children: [
                                //     Text(editorName,
                                //       style: TextStyle(
                                //         fontWeight: FontWeight.bold,
                                //       ),)
                                //   ],
                                // ),
                                Row(
                                  children: [
                                    Text(
                                      widget.username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                                Expanded(child: Container()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(child: Container()),

                  //delete
                  widget.id.split('_')[0] == currentUserId
                      ? Container(
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () async {
                              await FirebaseFirestore.instance
                                  .collection("reviews")
                                  .doc(widget.id)
                                  .update({"isActive": false}).then(
                                      (value) async {
                                await FirebaseFirestore.instance
                                    .collection('feeds')
                                    .doc(widget.id)
                                    .delete()
                                    .then((value) async {
                                  try{
                                    await FirebaseFirestore.instance
                                        .collection('booksearch')
                                        .doc(widget.bookName.toString().toLowerCase().trim())
                                        .collection("activities")
                                        .doc(widget.id)
                                        .delete();
                                  } catch(e) {}
                                  Navigator.pop(context);
                                });
                              });
                            },
                            child: Center(
                                child: Icon(
                              Icons.delete,
                              color: Colors.grey,
                              size: 20,
                            )),
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),

            //book name
            BookName(bookName: widget.bookName),

            //book author
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10) +
                  EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Text(
                    widget.bookAuthor.isNotEmpty
                        ? "By ${widget.bookAuthor}"
                        : "",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "drawerbody",
                    ),
                  )
                ],
              ),
            ),

            //image
            (widget.imageUrl != null)
                ? Container(
                    width: MediaQuery.of(context).size.width - 30,
                    height: MediaQuery.of(context).size.width - 30,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FosterImage(
                        width: MediaQuery.of(context).size.width - 30,
                        height: MediaQuery.of(context).size.width - 30,
                        imageUrl: widget.imageUrl!,
                        cachedKey: widget.imageUrl.hashCode.toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
              width: MediaQuery.of(context).size.width - 30,
              height: MediaQuery.of(context).size.width - 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FosterImage(
                  width: MediaQuery.of(context).size.width - 30,
                  height: MediaQuery.of(context).size.width - 30,
                  imageUrl: logo,
                  cachedKey: logo.hashCode.toString(),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            //note
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                child: Text(
                  widget.bookBio,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "drawerbody",
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),

            //pause play seek bar
            isAudioAvailable
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //load button
                        GestureDetector(
                          onTap: () {
                            if (!loading) {
                              if (!isReadyToPlay) {
                                downloadWidget(widget.url);
                              } else if (!isPlaying) {
                                setState(() {
                                  isPlaying = true;
                                });
                                player.play();
                              } else {
                                setState(() {
                                  isPlaying = false;
                                });
                                player.pause();
                              }
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: loading
                                    ? AppLoading(
                                        height: 70,
                                        width: 70,
                                      )
                                    : (!isReadyToPlay)
                                        ? Icon(
                                            Icons.play_arrow,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                        : (!isPlaying)
                                            ? Icon(
                                                Icons.play_arrow,
                                                size: 20,
                                                color: Colors.white,
                                              )
                                            : Icon(
                                                Icons.pause,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            height: 40,
                            width: 250,
                            child: Center(
                              child: StreamBuilder<DurationState>(
                                stream: Rx.combineLatest2<Duration,
                                        PlaybackEvent, DurationState>(
                                    player.positionStream,
                                    player.playbackEventStream,
                                    (position, playbackEvent) => DurationState(
                                          progress: position,
                                          buffered:
                                              playbackEvent.bufferedPosition,
                                          total: playbackEvent.duration,
                                        )),
                                builder: (context, snapshot) {
                                  final durationState = snapshot.data;
                                  final position =
                                      durationState?.progress ?? Duration.zero;
                                  final buffered =
                                      durationState?.buffered ?? Duration.zero;
                                  final total =
                                      durationState?.total ?? Duration.zero;

                                  return StreamBuilder<Duration>(
                                      stream: player.positionStream,
                                      builder: (context, snapshot) {
                                        return ProgressBar(
                                          progress:
                                              snapshot.data ?? Duration.zero,
                                          buffered: buffered,
                                          total: total,
                                          onSeek: (duration) {
                                            player.seek(duration);
                                          },
                                          barHeight: 5,
                                          baseBarColor: theme
                                              .colorScheme.secondary
                                              .withOpacity(0.5),
                                          progressBarColor:
                                              theme.colorScheme.secondary,
                                          bufferedBarColor: theme
                                              .colorScheme.secondary
                                              .withOpacity(0.5),
                                          thumbColor: Colors.grey.shade300,
                                          barCapShape: BarCapShape.round,
                                          thumbRadius: 10,
                                          thumbCanPaintOutsideBar: false,
                                          timeLabelLocation:
                                              TimeLabelLocation.below,
                                          timeLabelType:
                                              TimeLabelType.totalTime,
                                          timeLabelTextStyle: TextStyle(
                                            fontSize: 10,
                                            fontFamily: "drawerbody",
                                            color: theme
                                                .colorScheme.inversePrimary,
                                          ),
                                          timeLabelPadding: 0,
                                        );
                                      });
                                },
                              ),
                            ),
                          ),
                        ),

                        //pause button
                      ],
                    ),
                  )
                : Container(),

            //date time
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    widget.dateTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "drawerbody",
                    ),
                  ),
                  Expanded(child: Container()),

                  //bookmark
                  StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("reviews")
                          .doc(widget.id)
                          .snapshots(),
                      builder: (context, snapshot) {

                        try{
                          List list = snapshot.data!["bookmark"].toList();
                          bookmarked = list.contains(auth.user!.id);
                        } catch (e) {
                          bookmarked =  false;
                        }

                        return IconButton(
                          onPressed: () async {
                            bookmark(bookmarked);
                          },
                          icon: bookmarked ?
                          Icon(Icons.bookmark,color: theme.colorScheme.secondary,) :
                          Icon(Icons.bookmark_border_rounded,color: theme.colorScheme.secondary,),
                        );
                      }
                  ),

                  //share
                  InkWell(
                    onTap: () async {
                      final url = await DynamicLinksApi.fosterBitsLink(
                          widget.id,
                          bookName: widget.bookName,
                          userName: widget.username);
                      try {
                        Share.share(url);
                      } catch (e) {}
                    },
                    child: Container(
                      child: SvgPicture.asset("assets/icons/blue_share.svg")
                      // Icon(
                      //   Icons.share,
                      //   size: 22,
                      // ),
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
                                    contentId: widget.id,
                                    contentType: 'Bit',
                                    contentOwnerId: widget.uid,
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
          ],
        ),
      ),
    );
    //:
    //SizedBox.shrink();
    //     }
    // );
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;
}

class BookName extends StatefulWidget {
  final String bookName;
  const BookName({Key? key, required this.bookName}) : super(key: key);

  @override
  _BookNameState createState() => _BookNameState();
}

class _BookNameState extends State<BookName> {
  bool ellipsis = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 10) + EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            ellipsis = !ellipsis;
          });
        },
        child: ellipsis
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Text(
                        widget.bookName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "drawerbody",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  widget.bookName,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "drawerbody"),
                  textAlign: TextAlign.start,
                ),
              ),
      ),
    );
  }
}
