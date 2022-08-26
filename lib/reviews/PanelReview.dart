import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/BitsProvider.dart';
import 'package:fostr/reviews/ReviewLikesAndComments.dart';
import 'package:fostr/services/AudioPlayerService.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:fostr/reviews/PageSingleReview.dart';

import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../providers/FeedProvider.dart';
import '../services/InAppNotificationService.dart';
import '../utils/dynamic_links.dart';
import '../widgets/AppLoading.dart';
import 'package:fostr/models/UserModel/User.dart' as FosterUser;

class PanelReviewCard extends StatefulWidget {
  final String id;
  final String uid;
  final Map reviewData;
  const PanelReviewCard(
      {Key? key, required this.id, required this.reviewData, required this.uid})
      : super(key: key);

  @override
  _PanelReviewCardState createState() => _PanelReviewCardState();
}

class _PanelReviewCardState extends State<PanelReviewCard> {
  // with AutomaticKeepAliveClientMixin {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? reviewsStream;
  String editorName = '';
  String editorUserName = '';
  String editorProfile = '';
  String bookName = '';
  String authorName = '';
  String note = '';
  String audioUrl = '';
  int likes = 0;
  int comment = 0;
  String? imageUrl;
  var raterCount;
  late Timestamp datetime;
  String finalDateTime = "";
  bool isActive = false;

  final AudioPlayerService _audioPlayerService = GetIt.I<AudioPlayerService>();

  AudioPlayer player = AudioPlayer();
  Duration? audioDuration;

  bool isPlaying = false;
  bool loading = false;
  bool isAudioAvailable = true;
  bool isReadyToPlay = false;
  bool isFinished = false;

  int ratingsCount = 0;
  int commentsCount = 0;

  UserModel.User user = UserModel.User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });

  void setBitsData() {
    var bit = widget.reviewData;
    bookName = bit['bookName'] ?? "";
    authorName = bit['bookAuthor'] ?? "";
    note = bit['bookNote'] ?? "";
    audioUrl = bit['url'];
    if (bit["dateTime"].runtimeType != Timestamp) {
      int seconds = int.parse(
          bit["dateTime"].toString().split("_seconds: ")[1].split(", _")[0]);
      int nanoseconds = int.parse(
          bit["dateTime"].toString().split("_nanoseconds: ")[1].split("}")[0]);
      datetime = Timestamp(seconds, nanoseconds);
    } else {
      datetime = bit["dateTime"];
    }
    likes = bit['likes'];
    comment = bit['comments'];
    isActive = bit['isActive'];
    imageUrl = bit['imageUrl'];

    var dateDiff = DateTime.now().difference(datetime.toDate());
    if (dateDiff.inDays >= 1) {
      finalDateTime = DateFormat.yMMMd()
          .addPattern(" | ")
          .add_jm()
          .format(datetime.toDate())
          .toString();
    } else {
      finalDateTime = timeago.format(datetime.toDate());
    }

    ratingsCount = bit['ratedBy'].length;
    commentsCount = bit['comments'];
  }

  @override
  void initState() {
    super.initState();
    setBitsData();
    player = _audioPlayerService.player;
    player.getDuration().then((value) {
      if (mounted) {
        if (value > 0) {
          setState(() {
            audioDuration = Duration(milliseconds: value);
          });
        }
      }
    });
    player.onPlayerStateChanged.listen((state) {
      print(state);
    });

    getRatersCount();
    getUser(widget.id.split('_')[0]);
  }

  void getRatersCount() async {
    if (mounted) {
      if (widget.reviewData["ratedBy"] == null) {
        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(widget.id)
            .get()
            .then((value) {
          setState(() {
            raterCount = value.get("ratedBy");
          });
        });
      } else {
        setState(() {
          raterCount = widget.reviewData["ratedBy"];
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getData(String uid) async {
    isAudioAvailable = true;
  }

  void getUser(String id) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .get()
        .then((value) {
      editorName = value.get("name");
      editorUserName = value.get("userName");

      if (mounted) {
        setState(() {
          user = FosterUser.User.fromJson(value.data()!);
          editorProfile =
              "${value.data()?["userProfile"]?["profileImage"] ?? ""}";
        });
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

  void playPause(String url, PlayerState state,
      {bool isNewAudio = false}) async {
    try {
      state = (isNewAudio) ? PlayerState.STOPPED : state;
      if (loading) {
        return;
      }

      switch (state) {
        case PlayerState.PLAYING:
          player.pause();
          break;
        case PlayerState.PAUSED:
          player.resume();
          break;
        case PlayerState.COMPLETED:
          await player.seek(Duration.zero);
          player.resume();
          break;
        case PlayerState.STOPPED:
          setState(() {
            loading = true;
          });

          setState(() {
            loading = true;
          });
          await player.setUrl(url);
          final duration = await player.getDuration();
          setState(() {
            loading = false;
            audioDuration = Duration(milliseconds: duration);
          });
          player.resume();
          break;
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      ToastMessege("Something went wrong", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);

    return isActive
        ? audioUrl.isNotEmpty
            ? SingleChildScrollView(
              child: Container(
                padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: MediaQuery.of(context).size.width,
                child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      //editor details area
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
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
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(18)),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: editorProfile.isEmpty
                                              ? Image.asset(
                                                  'assets/images/logo.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : FosterImage(
                                                  cachedKey: editorProfile,
                                                  imageUrl: editorProfile,
                                                  fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      editorUserName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Expanded(child: Container()),

                            //add to archive collection
                            // widget.id.split('_')[0] != auth.user!.id
                            //     ? Archive(
                            //         bitsID: widget.id,
                            //         userID: auth.user!.id)
                            //     : SizedBox.shrink(),

                            //delete
                            widget.id.split('_')[0] == auth.user!.id
                                ? Container(
                                    width: 40,
                                    height: 40,
                                    child: GestureDetector(
                                      onTap: () async {
                                        try {
                                          FirebaseFirestore.instance
                                              .collection("reviews")
                                              .doc(widget.id)
                                              .update({"isActive": false});
                                          FirebaseFirestore.instance
                                              .collection("feeds")
                                              .doc(widget.id)
                                              .delete();
                                          final bitsProvider =
                                              Provider.of<BitsProvider>(context,
                                                  listen: false);
                                          final feedsProvider =
                                              Provider.of<FeedProvider>(context,
                                                  listen: false);
                                          feedsProvider.refreshFeed(true);
                                          setState(() {
                                            isActive = false;
                                          });
                                          bitsProvider.refreshFeed(true);
                                        } catch (e) {}
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
                      BookName(bookName: bookName),

                      //book author
                      authorName.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10) +
                                  EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Text(
                                    authorName.isNotEmpty ? "By $authorName" : "",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "drawerbody",
                                    ),
                                  )
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                      (imageUrl != null)
                          ? Container(
                              width: MediaQuery.of(context).size.width - 30,
                              height: MediaQuery.of(context).size.width - 30,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FosterImage(
                                  width: MediaQuery.of(context).size.width - 30,
                                  height: MediaQuery.of(context).size.width - 30,
                                  imageUrl: imageUrl!,
                                  cachedKey: imageUrl.hashCode.toString(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                      //note
                      note.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10) +
                                  EdgeInsets.only(bottom: 5),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  note,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "drawerbody",
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),

                      //pause play seek bar
                      isAudioAvailable
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  StreamBuilder<PlayerState>(
                                      stream: player.onPlayerStateChanged,
                                      builder: (context, snapshot) {
                                        bool isSameAudio = widget.id ==
                                            audioPlayerData.mediaMeta.audioId;
                                        var state = (isSameAudio)
                                            ? player.state
                                            : PlayerState.STOPPED;

                                        return GestureDetector(
                                          onTap: () {
                                            if (!isSameAudio) {
                                              audioPlayerData.setMediaMeta(
                                                  MediaMeta(
                                                    audioId:
                                                        widget.reviewData["id"],
                                                    audioName: widget
                                                        .reviewData["bookName"],
                                                    userName: widget
                                                        .reviewData["bookAuthor"],
                                                  ),
                                                  shouldNotify: true);
                                            }
                                            playPause(audioUrl, player.state,
                                                isNewAudio: !isSameAudio);
                                          },
                                          child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: loading
                                                    ? AppLoading(
                                                        height: 70,
                                                        width: 70,
                                                      )
                                                    : (state !=
                                                            PlayerState.PLAYING)
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
                                        );
                                      }),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: 40,
                                      width: 200,
                                      child: Center(
                                        child: (audioPlayerData
                                                    .mediaMeta.audioId ==
                                                widget.reviewData["id"])
                                            ? StreamBuilder<Duration>(
                                                stream:
                                                    player.onAudioPositionChanged,
                                                builder: (context, snapshot) {
                                                  return ProgressBar(
                                                    progress: snapshot.data ??
                                                        Duration.zero,
                                                    // buffered: buffered,
                                                    total: audioDuration ??
                                                        Duration.zero,
                                                    onSeek: (duration) {
                                                      player.seek(duration);
                                                    },
                                                    barHeight: 5,
                                                    baseBarColor: theme
                                                        .colorScheme.secondary
                                                        .withOpacity(0.5),
                                                    progressBarColor: theme
                                                        .colorScheme.secondary,
                                                    bufferedBarColor: theme
                                                        .colorScheme.secondary
                                                        .withOpacity(0.5),
                                                    thumbColor:
                                                        Colors.grey.shade300,
                                                    barCapShape:
                                                        BarCapShape.round,
                                                    thumbRadius: 10,
                                                    thumbCanPaintOutsideBar:
                                                        false,
                                                    timeLabelLocation:
                                                        TimeLabelLocation.below,
                                                    timeLabelType:
                                                        TimeLabelType.totalTime,
                                                    timeLabelTextStyle: TextStyle(
                                                        fontSize: 10,
                                                        color: theme.colorScheme
                                                            .inversePrimary,
                                                        fontFamily: "drawerbody"),
                                                    timeLabelPadding: 0,
                                                  );
                                                })
                                            : ProgressBar(
                                                progress: Duration.zero,
                                                // buffered: buffered,
                                                total: Duration.zero,
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
                                                    color: theme.colorScheme
                                                        .inversePrimary,
                                                    fontFamily: "drawerbody"),
                                                timeLabelPadding: 0,
                                              ),
                                      ),
                                    ),
                                  ),
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
                              finalDateTime,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "drawerbody",
                              ),
                            )
                          ],
                        ),
                      ),

                      //like button
                      Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                        child: Row(
                          children: [
                            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection("reviews")
                                    .doc(widget.id)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError ||
                                      snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                    return SizedBox.shrink();
                                  }
                                  final bitsData = snapshot.data?.data();
                                  int ratingsCount =
                                      bitsData?['ratedBy']?.length ?? 0;
                                  int commentsCount = bitsData?['comments'] ?? 0;

                                  return Row(
                                    children: [
                                      (commentsCount > 0)
                                          ? Text(
                                              commentsCount.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "drawerbody",
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      Text(
                                        " reviews",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "drawerbody",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      (ratingsCount > 0)
                                          ? Text(
                                              ratingsCount.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "drawerbody",
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      Text(
                                        " ratings",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "drawerbody",
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                            Expanded(
                              child: Container(),
                            ),

                            //view more
                            Expanded(
                              child: Container(),
                            ),
                            widget.id.split('_')[0] == widget.uid
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ReviewLikesAndComments(
                                                      bookName: bookName,
                                                      reviewID: widget.id)));
                                    },
                                    child: Text(
                                      "view more",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  )
                                : SizedBox.shrink(),
                            SizedBox(
                              width: 10,
                            ),
                            widget.id.split('_')[0] == auth.user!.id
                                ? InkWell(
                                    onTap: () async {
                                      // final url =
                                      //     await DynamicLinksApi.fosterBitsLink(
                                      //         widget.postId,
                                      //         bookName: widget.bookName,
                                      //         userName: widget.username);
                                      // try {
                                      //   Share.share(url);
                                      // } catch (e) {}
                                    },
                                    child: Container(
                                      child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                                      // Icon(
                                      //   Icons.share,
                                      // ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),

                      //likes and comments
                      widget.id.split('_')[0] != auth.user!.id
                          ? LikeandCommentButton(
                              postId: widget.id,
                              bookName: bookName,
                              likedCount: likes,
                              commentCount: comment,
                              user: user,
                              url: audioUrl,
                              profile: editorProfile,
                              username: editorUserName,
                              bookAuthor: authorName,
                              bookBio: note,
                              dateTime: finalDateTime,
                              id: widget.id,
                              imageUrl: imageUrl,
                              uid: widget.uid,
                            )
                          :
                          // LikeandCommentButton(
                          //   postId: widget.id,
                          //   bookName: bookName,
                          //   likedCount: likes,
                          //   commentCount: comment,
                          //   user: user,
                          // ) :
                          SizedBox.shrink(),
                    ],
                  ),
              ),
            )
            : SizedBox.shrink()
        : SizedBox.shrink();
  }
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
          if (mounted) {
            setState(() {
              ellipsis = !ellipsis;
            });
          }
        },
        child: ellipsis
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Text(
                        widget.bookName,
                        style: TextStyle(
                          fontSize: 16,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "drawerbody"),
                  textAlign: TextAlign.start,
                ),
              ),
      ),
    );
  }
}

class LikeandCommentButton extends StatefulWidget {
  final int likedCount;
  final int commentCount;
  final UserModel.User user;
  final void Function(bool value)? onStateChange;
  final String postId;
  final String bookName;
  final String url;
  final String profile;
  final String username;
  final String bookAuthor;
  final String bookBio;
  final String dateTime;
  final String id;
  final String uid;
  final String? imageUrl;

  const LikeandCommentButton(
      {required this.postId,
      required this.bookName,
      required this.imageUrl,
      this.onStateChange,
      required this.likedCount,
      required this.commentCount,
      required this.user,
      required this.url,
      required this.profile,
      required this.username,
      required this.bookAuthor,
      required this.bookBio,
      required this.dateTime,
      required this.id,
      required this.uid,
      Key? key})
      : super(key: key);

  @override
  _LikeandCommentButtonState createState() => _LikeandCommentButtonState();
}

class _LikeandCommentButtonState extends State<LikeandCommentButton> {
  late DocumentReference<Map<String, dynamic>> postRef;
  late String userId;
  late DatabaseReference rDBPostRef;
  bool liked = false;
  bool review = false;
  bool posting = false;
  int likeCount = 0;
  int ratingValue = 0;
  int commentCount = 0;
  bool ratingStatsLoaded = false;
  List ratersFinal = [];
  TextEditingController commentController = new TextEditingController();
  //
  UserModel.User user = UserModel.User.fromJson({
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
    super.initState();
    likeCount = widget.likedCount;
    commentCount = widget.commentCount;
    postRef =
        FirebaseFirestore.instance.collection('reviews').doc(widget.postId);
    userId = FirebaseAuth.instance.currentUser!.uid;
    rDBPostRef = FirebaseDatabase.instance
        .ref()
        .child('book_review_stats')
        .child(widget.postId);
    loadAlreadyRatedState();
  }

  void loadAlreadyRatedState() async {
    if (mounted) {
      await postRef.get().then((value) {
        List raters = value.get("ratedBy");

        raters.forEach((element) {
          element.forEach((key, value) {
            if (key == userId) {
              if (mounted) {
                setState(() {
                  ratingValue = value;
                  ratingStatsLoaded = true;
                });
              }
            }
          });
        });
      });
    }
  }

  Future<void> _sendRatingNotification(
      int count, UserModel.User currentuser) async {
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
          "bitsId": widget.postId,
          "rating": count.toString()
        }
      });

      inAppNotification.sendNotification(payload);
    }
  }

  void updateRating(int count, UserModel.User currentuser) async {
    rDBPostRef.child('ratings/$userId').get().then((value) => {
          if (value.exists)
            {
              value.ref.update({
                'username': widget.user.userName,
                'f_name': widget.user.name,
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
                'username': widget.user.userName,
                'f_name': widget.user.name,
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

  Future<void> _sendCommentNotification() async {
    final inAppNotification = GetIt.I<InAppNotificationService>();
    final token = await inAppNotification.getNotificationToken(userId);

    if (token != null) {
      final payload =
          NotificationPayload(type: NotificationType.Comment, tokens: [
        token
      ], data: {
        "senderUserId": "",
        "senderUserName": "",
        "message": "",
        "title": "",
        "body": "",
        "payload": {}
      });

      inAppNotification.sendNotification(payload);
    }
  }

  void saveComment(String comment) async {
    if (mounted) {
      setState(() {
        posting = true;
      });
    }
    postRef =
        FirebaseFirestore.instance.collection('reviews').doc(widget.postId);
    UserService userServices = GetIt.I<UserService>();
    await userServices.getUserById(userId).then((value) async {
      if (value != null) {
        user = value;
        FirebaseAuth.instance.currentUser!.getIdToken().then((token) async {
          await FirebaseDatabase.instance
              .ref()
              .child('book_review_stats')
              .child(widget.postId)
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
            commentController.clear();
            postRef.update({
              'comments': FieldValue.increment(1),
            });
          });
        });
        _sendCommentNotification();
      } else {
        print("user not found");
      }
    });
    if (mounted) {
      setState(() {
        posting = false;
      });
    }
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ReviewLikesAndComments(
    //           bookName: widget.bookName,
    //           reviewID: widget.postId,))).then((value) {
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return Container(
      child: Column(
        children: [
          //buttons
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                //like button
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
                //         likeCount++;
                //         updateLikeCount(1);
                //       } else {
                //         updateLikeCount(-1);
                //         likeCount--;
                //       }
                //       widget.onStateChange != null
                //           ? widget.onStateChange!(liked)
                //           : null;
                //
                //       setState(() {});
                //     },
                //   ),
                // ),

                //comment button
                GestureDetector(
                    onTap: () {
                      // setState(() {
                      //   review = true;
                      // });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PageSingleReview(
                                  url: widget.url,
                                  profile: widget.profile,
                                  username: widget.username,
                                  bookName: widget.bookName,
                                  bookAuthor: widget.bookAuthor,
                                  bookBio: widget.bookBio,
                                  dateTime: widget.dateTime,
                                  imageUrl: widget.imageUrl,
                                  id: widget.id,
                                  uid: widget.uid)));
                    },
                    child: Icon(
                      Icons.insert_comment_outlined,
                    )),
                SizedBox(
                  width: 10,
                ),

                //ratings
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("reviews")
                        .doc(widget.postId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.hasError ||
                          !snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      print("object");
                      dynamic raters = snapshot.data?.data()?["ratedBy"];
                      double? rating;
                      if (raters != null && raters.isNotEmpty) {
                        raters.forEach((element) {
                          element.forEach((key, value) {
                            if (key == userId) {
                              if (mounted) {
                                rating = value.toDouble();
                              }
                            }
                          });
                        });
                      }
                      return RatingBar.builder(
                        initialRating:
                            rating ?? double.parse(ratingValue.toString()),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        unratedColor: Colors.grey,
                        itemCount: 5,
                        itemSize: 20,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: theme.colorScheme.secondary,
                        ),
                        onRatingUpdate: (rating) {
                          updateRating(rating.toInt(), auth.user!);
                          if (mounted) {
                            setState(() {
                              ratingValue = rating.toInt();
                              ratingStatsLoaded = true;
                            });
                          }
                        },
                      );
                    }),

                //view more
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReviewLikesAndComments(
                                bookName: widget.bookName,
                                reviewID: widget.postId)));
                  },
                  child: Text(
                    "view more",
                    style:
                        TextStyle(color: Colors.blue, fontFamily: "drawerbody"),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () async {
                    final url = await DynamicLinksApi.fosterBitsLink(widget.id,
                        bookName: widget.bookName, userName: widget.username);
                    try {
                      Share.share(url);
                    } catch (e) {}
                  },
                  child: Container(
                    child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                    // Icon(
                    //   Icons.share,
                    // ),
                  ),
                )
              ],
            ),
          ),

          //comment box
          // review ?
          // CommentBoxCommon(
          //     type: "review",
          //     reviewId: widget.postId,
          //     postId: "",
          //     userId: userId,
          //     USER: user
          // )
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10) + const EdgeInsets.only(bottom: 10),
          //   child: Row(
          //     children: [
          //
          //       //comment
          //       Container(
          //         height: 40,
          //         width: MediaQuery.of(context).size.width - 110,
          //         child: TextField(
          //           controller: commentController,
          //           keyboardType: TextInputType.text,
          //           decoration: InputDecoration(
          //               contentPadding: EdgeInsets.symmetric(
          //                   vertical: 1),
          //               filled: true,
          //               hintStyle: new TextStyle(
          //                   color: Colors.grey[600]
          //               ),
          //               hintText: "add a comment",
          //               fillColor: Colors.white,
          //               border: new UnderlineInputBorder(
          //                   borderSide: new BorderSide(
          //                       color: Colors.grey
          //                   )
          //               )
          //           ),
          //         ),
          //       ),
          //       SizedBox(width: 10,),
          //
          //       //post button
          //       GestureDetector(
          //         onTap: (){
          //           if(commentController.text.isEmpty){
          //             Fluttertoast.showToast(
          //                 msg: "comment can't be empty",
          //                 toastLength: Toast.LENGTH_SHORT,
          //                 gravity: ToastGravity.BOTTOM,
          //                 timeInSecForIosWeb: 2,
          //                 backgroundColor: gradientBottom,
          //                 textColor: Colors.white,
          //                 fontSize: 16.0);
          //           } else {
          //             saveComment(commentController.text);
          //           }
          //         },
          //
          //         child: Container(
          //             width: 40,
          //             height: 40,
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(20),
          //               color: posting ? Colors.transparent : GlobalColors.signUpSignInButton
          //             ),
          //             child: Center(
          //               child: posting ?
          //               CircularProgressIndicator(color: Color(0xff476747)) :
          //               Icon(Icons.send, size: 18, color: Colors.white),
          //             )
          //         ),
          //       )
          //     ],
          //   ),
          // )
          //     :
          // SizedBox.shrink(),
        ],
      ),
    );
    //   Column(
    //   children: [
    //     // GestureDetector(
    //     //
    //     //   onTap: (){
    //     //     Navigator.push(context, MaterialPageRoute(builder: (context) =>
    //     //         ReviewLikeComment(
    //     //           url: audioUrl,
    //     //           profile: editorProfile,
    //     //           username: editorUserName,
    //     //           bookName: bookName,
    //     //           bookAuthor: authorName,
    //     //           bookBio: note,
    //     //           dateTime: finalDateTime,
    //     //           id: widget.postId,
    //     //           uid: userId,
    //     //         )
    //     //     ));
    //     //   },
    //     //
    //     //   child: Row(
    //     //     children: [
    //     //       Text(
    //     //         "$likeCount",
    //     //         style: TextStyle(
    //     //           fontSize: 12,
    //     //         ),
    //     //       ),
    //     //       Text(
    //     //         " likes",
    //     //         style: TextStyle(
    //     //           fontSize: 12,
    //     //         ),
    //     //       ),
    //     //       SizedBox(
    //     //         width: 5,
    //     //       ),
    //     //       Text(
    //     //         "$commentCount",
    //     //         style: TextStyle(
    //     //           fontSize: 12,
    //     //         ),
    //     //       ),
    //     //       Text(
    //     //         " comments",
    //     //         style: TextStyle(
    //     //           fontSize: 12,
    //     //         ),
    //     //       ),
    //     //       Expanded(child: Container(),),
    //     //       Text("View more",
    //     //         style: TextStyle(
    //     //           fontSize: 12,
    //     //           color: Colors.blue,
    //     //         ),),
    //     //     ],
    //     //   ),
    //     // ),
    //     SizedBox(height: 10),
    //     Divider(height: 0),
    //     Row(
    //       children: [
    //         AnimatedOpacity(
    //           opacity: likedStatsLoaded ? 1 : .25,
    //           duration: Duration(milliseconds: 250),
    //           child: IconButton(
    //             icon: Icon(
    //                 liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined),
    //             onPressed: () {
    //               // if post is loading whether user have already liked or not
    //               if (!likedStatsLoaded) return;
    //
    //               liked = !liked;
    //
    //               if (liked) {
    //                 likeCount++;
    //                 updateLikeCount(1);
    //               } else {
    //                 updateLikeCount(-1);
    //                 likeCount--;
    //               }
    //               widget.onStateChange != null
    //                   ? widget.onStateChange!(liked)
    //                   : null;
    //
    //               setState(() {});
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  }
}
