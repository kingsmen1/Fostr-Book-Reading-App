import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/albums/BookMarkedList.dart';
import 'package:fostr/pages/user/userActivity/PodcastComments.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/AudioPlayerService.dart';

import 'package:fostr/services/RecordingService.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/widget_constants.dart';

import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/rooms/Profile.dart';
import 'package:get_it/get_it.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' show pi;

import '../../../models/UserModel/User.dart';

class UserRecorings extends StatefulWidget {
  final String? id;
  final int page;
  const UserRecorings({Key? key, this.id, required this.page}) : super(key: key);

  @override
  State<UserRecorings> createState() => _UserRecoringsState();
}

class _UserRecoringsState extends State<UserRecorings> {
  late Future<QuerySnapshot<Map<String, dynamic>>>? getRecordings;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.page);
    if (widget.id != null) {
      getRecordings = FirebaseFirestore.instance
          .collection("recordings")
          .where("userId", isEqualTo: widget.id)
          .where("isActive", isEqualTo: true)
          .get();
    } else {
      getRecordings = FirebaseFirestore.instance
          .collection("recordings")
          .where("isActive", isEqualTo: true)
          .orderBy("dateTime", descending: true)
          .get();
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Material(
      color: theme.colorScheme.primary,
      child: SafeArea(
        child: Container(
          child: FutureBuilder(
            future: getRecordings,
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: AppLoading(),
                );
              }

              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                  child: Text(
                    "Something went wrong",
                  ),
                );
              }

              if (snapshot.data == null) {
                return Center(
                  child: Text(
                    "No recordings",
                  ),
                );
              }
              if (snapshot.hasData) {
                return Stack(
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: pageController,
                      itemCount: snapshot.data!.docs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == snapshot.data!.docs.length) {
                          return Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 500,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Whoa we are impressed!",
                                ),
                              ],
                            ),
                          );
                        }

                        // final room = rooms[rooms.keys.elementAt(index)]!;
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          color: theme.colorScheme.primary,
                          child: RoomTile(
                            authId: auth.user!.id,
                            last: (index < snapshot.data!.docs.length-1) ? true : false,
                            index: index,
                            roomData: [
                              {
                                "id": snapshot.data!.docs[index].id,
                                ...snapshot.data!.docs[index].data(),
                              }
                            ],
                          ),
                        );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: Center(
                          child: Text(
                            (widget.id == null) ? "Recordings" : "My Recordings",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 28, fontFamily: "drawerhead"),
                          ),
                        ),
                      ),
                    ),

                    // (widget.id == null) ?
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back_ios),
                        // icon: Icon(FontAwesomeIcons.chevronDown),
                      ),
                    )
                    // : SizedBox.shrink()
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class RoomTile extends StatefulWidget {
  final List<Map<String, dynamic>> roomData;
  final bool showShare;
  final String authId;
  final int? index;
  final bool? last;
  final bool? single;
  const RoomTile({
    Key? key,
    this.index,
    this.last,
    required this.roomData,
    required this.authId,
    this.showShare = true,
    this.single = false,
  }) : super(key: key);

  @override
  State<RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends State<RoomTile> {
  late String userId;
  late String roomId;
  late String sid;
  late String type;
  late Future<DocumentSnapshot<Map<String, dynamic>>>? getRoom;
  late Future<QuerySnapshot<Map<String, dynamic>>>? roomSpeakers;

  bool bookmarked = false;
  int bookm_count = 0;
  int share_count = 0;
  List bookmarkUsers = [];
  int index = 0;
  bool last = false;

  static const DEFAULT_IMAGE =
      "https://static.wixstatic.com/media/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png/v1/fill/w_1920,h_1080,al_c/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png";

  @override
  void initState() {
    super.initState();
    index = widget.index ?? 0;
    last = widget.last ?? false;
    userId = widget.roomData.first["userId"];
    roomId = widget.roomData.first["roomId"];
    sid = widget.roomData.first["sid"];
    type = widget.roomData.first["type"];
    if (type == "ROOM") {
      getRoom = FirebaseFirestore.instance
          .collection("rooms")
          .doc(userId)
          .collection("rooms")
          .doc(roomId)
          .get();

      roomSpeakers = FirebaseFirestore.instance
          .collection("rooms")
          .doc(userId)
          .collection("rooms")
          .doc(roomId)
          .collection("speakers")
          .get();
    } else {
      getRoom = FirebaseFirestore.instance
          .collection("rooms")
          .doc(userId)
          .collection("amphitheatre")
          .doc(roomId)
          .get();

      roomSpeakers = FirebaseFirestore.instance
          .collection("rooms")
          .doc(userId)
          .collection("amphitheatre")
          .doc(roomId)
          .collection("users")
          .get();
    }

    checkIfBookmarked();
    checkShareCount();
  }

  void bookmark(String authId) async {
    await FirebaseFirestore.instance
        .collection("recordings")
        .where("sid", isEqualTo: sid)
        .get()
        .then((value){
          value.docs.forEach((element) async {
            await FirebaseFirestore.instance
                .collection("recordings")
                .doc(element.id)
                .set({
              "bookmark" : !bookmarked ? FieldValue.arrayRemove([authId]) : FieldValue.arrayUnion([authId])
            }, SetOptions(merge: true)).then((value){
              setState(() {
                !bookmarked ? bookm_count-- : bookm_count++;
              });
            });
          });
    });
  }

  void checkIfBookmarked() async {
    await FirebaseFirestore.instance
        .collection("recordings")
        .where("sid", isEqualTo: sid)
        .get()
        .then((value){
      value.docs.forEach((element) async {
        try {
          List list = element["bookmark"].toList();
            setState(() {
              bookmarked = list.contains(widget.authId) ? true : false;
              bookm_count = list.length;
              bookmarkUsers = list;
            });
        } catch (e) {
          setState(() {
            bookmarked = false;
            bookm_count = 0;
          });
        }
      });
    });
  }

  void share() async {
    await FirebaseFirestore.instance
        .collection("recordings")
        .where("sid", isEqualTo: sid)
        .get()
        .then((value){
      value.docs.forEach((element) async {
        await FirebaseFirestore.instance
            .collection("recordings")
            .doc(element.id)
            .set({
          "shareCount" : FieldValue.increment(1)
        }, SetOptions(merge: true)).then((value){
          setState(() {
            share_count++;
          });
        });
      });
    });
  }

  void checkShareCount() async {
    await FirebaseFirestore.instance
        .collection("recordings")
        .where("sid", isEqualTo: sid)
        .get()
        .then((value){
      value.docs.forEach((element) async {
        try {
          setState(() {
            share_count = element["shareCount"];
          });
        } catch (e) {
          setState(() {
            share_count = 0;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      child: Container(
        child: FutureBuilder(
          future: getRoom,
          builder: (context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Something went wrong",
                ),
              );
            }

            if (snapshot.data?.data() == null) {
              return Center(
                child: Text(
                  "Could not find Room recording",
                ),
              );
            }

            if (snapshot.hasData) {
              final data = snapshot.data!.data();
              return Container(
                constraints: BoxConstraints(minHeight: 200),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                width: size.width,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [

                    //content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: widget.single! ? 50 : 100,
                        ),

                        //image
                        Container(
                          height: MediaQuery.of(context).size.width - 160,
                          width: MediaQuery.of(context).size.width - 160,
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(minHeight: 160),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: theme.colorScheme.inversePrimary, width: 3),
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FosterImageProvider(
                                imageUrl: data?["image"] != ""
                                    ? data!["image"]
                                    : DEFAULT_IMAGE,
                              ),
                              fit: BoxFit.contain,
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 10),
                                blurRadius: 10,
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),

                        //title
                        Text( data?["title"] ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "drawerhead"),
                        ),

                        //author name
                        type == "ROOM" ?
                        (data?["roomCreator"] != null && data?["roomCreator"] != "") ? SizedBox(
                          height: 10,
                        )
                            : SizedBox.shrink() :
                        (data?["creatorUsername"] != null && data?["creatorUsername"] != "") ? SizedBox(
                          height: 10,
                        )
                            : SizedBox.shrink(),
                        Text(
                          type == "ROOM" ?
                          (data?["roomCreator"] != null && data?["roomCreator"] != "")
                              ? "by " + data!["roomCreator"]
                              : "" :
                          (data?["creatorUsername"] != null && data?["aucreatorUsernamethorName"] != "")
                              ? "by " + data!["creatorUsername"]
                              : "" ,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: "drawerhead"),
                        ),
                        type == "ROOM" ?
                        (data?["roomCreator"] != null && data?["roomCreator"] != "") ? SizedBox(
                          height: 10,
                        )
                            : SizedBox.shrink() :
                        (data?["creatorUsername"] != null && data?["creatorUsername"] != "") ? SizedBox(
                          height: 10,
                        )
                            : SizedBox.shrink(),
                        SizedBox.shrink(),

                        //bookmarks
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            share_count < 1 ?
                            SizedBox.shrink() :
                            Row(
                              children: [
                                SvgPicture.asset("assets/icons/blue_share.svg"),
                                // Icon(Icons.share, size: 20,color: theme.colorScheme.secondary,),
                                SizedBox(width: 5,),
                                Text(
                                  "${share_count}" ,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "drawerhead"),
                                ),
                                SizedBox(width: 20,),
                              ],
                            ),

                            bookm_count < 1 ?
                            SizedBox.shrink() :
                            GestureDetector(

                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection("recordings")
                                    .where("sid", isEqualTo: sid)
                                    .get()
                                    .then((value){
                                  value.docs.forEach((element) async {
                                    try {
                                      List list = element["bookmark"].toList();
                                      Navigator.push(
                                          context, MaterialPageRoute(
                                          builder: (context) =>
                                              BookMarkedList(
                                                  title: data?["title"] ?? "",
                                                  users: list
                                              )
                                      ));
                                    } catch (e) {
                                      print("error fetching list $e");
                                    }
                                  });
                                });
                              },

                              child: Row(
                                children: [
                                  Icon(Icons.bookmark, size: 20,color: theme.colorScheme.secondary,),
                                  SizedBox(width: 5,),
                                  Text(
                                    "${bookm_count}" ,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "drawerhead"),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),

                        //profiles
                        // FutureBuilder(
                        //     future: roomSpeakers,
                        //     builder: (context,
                        //         AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        //             snapshot) {
                        //       if (snapshot.connectionState ==
                        //           ConnectionState.waiting) {
                        //         return Container();
                        //       }
                        //
                        //       if (snapshot.hasError) {
                        //         return Center(
                        //           child: Text(
                        //             "Something went wrong",
                        //           ),
                        //         );
                        //       }
                        //
                        //       if (snapshot.data?.size == 0) {
                        //         return Center(
                        //           child: Text(
                        //             "There were no speakers",
                        //           ),
                        //         );
                        //       }
                        //       final data = snapshot.data!.docs
                        //           .map((element) => element.data())
                        //           .toList();
                        //       return Flexible(
                        //         child: GridView.builder(
                        //           physics: ClampingScrollPhysics(),
                        //           gridDelegate:
                        //               SliverGridDelegateWithFixedCrossAxisCount(
                        //                   crossAxisCount: 3),
                        //           itemCount: data.length,
                        //           padding: EdgeInsets.all(2.0),
                        //           itemBuilder: (BuildContext context, int index) {
                        //             return Profile(
                        //                 user: User.fromJson(data[index]),
                        //                 size: 60,
                        //                 isMute: false,
                        //                 volume: 0,
                        //                 myVolume: 0);
                        //           },
                        //         ),
                        //       );
                        //     }),

                        //player
                        Column(
                          children: widget.roomData.map((roomData) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: RecordingTile(
                                duration: roomData["duration"] ?? 0,
                                roomId: roomId,
                                userId: userId,
                                recordingId: roomData["fileName"],
                                recordingDocId: roomData["id"],
                                roomData: {
                                  ...data!,
                                  "id": snapshot.data!.id,
                                },
                                recordingData: widget.roomData.first,
                              ),
                            );
                          }).toList(),
                        ),

                      ],
                    ),

                    //back button
                    (!widget.showShare)
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: (IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                              ),
                            )),
                          )
                        : SizedBox.shrink(),

                    //swipe down
                    index != 0?
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.keyboard_arrow_down, size: 28, color: Colors.grey,),
                            Text("swipe down for previous",
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                  color: Colors.grey
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) :
                    SizedBox.shrink(),

                    //swipe up
                    last?
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_up, size: 28, color: Colors.grey,),
                          Text("swipe up for next",
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ) :
                    SizedBox.shrink(),

                    //share
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        height: 100,
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                share();
                                final url = await DynamicLinksApi.fosterPodsLink(
                                  widget.roomData.first["id"],
                                  roomName: data?["title"] ?? "",
                                );
                                Share.share(url);
                              },
                              icon: SvgPicture.asset("assets/icons/blue_share.svg", width: 30, height: 30,)
                              // Icon(Icons.share, size: 28,),
                            ),
                            Text("share",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    //bookmark
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 70),
                        child: Container(
                          height: 100,
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    bookmarked = !bookmarked;
                                  });
                                  bookmark(widget.authId);
                                },
                                icon: bookmarked ?
                                Icon(Icons.bookmark, size: 30,color: theme.colorScheme.secondary,) :
                                Icon(Icons.bookmark_border_rounded, size: 30,color: theme.colorScheme.secondary,),
                              ),
                              Text("bookmark",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    //logo
                    !widget.single! ?
                    Align(
                      alignment: Alignment.topRight,
                      child: Image.asset("assets/images/logo.png",
                        fit: BoxFit.contain,
                        width: 40,
                        height: 40,),
                    )
                        :
                    SizedBox.shrink()
                    ,
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

class RecordingTile extends StatefulWidget {
  final String roomId;
  final String userId;
  final String recordingId;
  final int? duration;
  final String recordingDocId;
  final Map<String, dynamic>? recordingData;
  final Map<String, dynamic>? roomData;
  const RecordingTile(
      {Key? key,
      required this.roomId,
      required this.userId,
      required this.recordingId,
      required this.duration,
      required this.recordingDocId,
      required this.recordingData,
      required this.roomData})
      : super(key: key);

  @override
  State<RecordingTile> createState() => _RecordingTileState();
}

class _RecordingTileState extends State<RecordingTile> {
  @override
  Widget build(BuildContext context) {
    return RecordingPlayer(
      rawData: {
        "roomData": widget.roomData,
        "recordingData": widget.recordingData,
      },
      fileName: widget.recordingId,
      duration: widget.duration,
      onDurationFetched: (duration) {
        FirebaseFirestore.instance
            .collection("recordings")
            .doc(widget.recordingDocId)
            .update({"duration": duration?.inSeconds});
      },
    );
  }
}

class RecordingPlayer extends StatefulWidget {
  final String fileName;
  final int? duration;
  final Map<dynamic, dynamic>? rawData;
  final Function(Duration? duration) onDurationFetched;
  const RecordingPlayer(
      {Key? key,
      required this.fileName,
      required this.onDurationFetched,
      required this.duration,
      this.rawData})
      : super(key: key);

  @override
  State<RecordingPlayer> createState() => _RecordingPlayerState();
}

class _RecordingPlayerState extends State<RecordingPlayer> {
  final AudioPlayerService _audioPlayerService = GetIt.I<AudioPlayerService>();

  AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  bool isReadyToPlay = false;
  bool isFinished = false;
  bool makingReadyToPlay = false;
  bool bookmarked = false;

  bool isUrlSet = false;

  String? url;

  Duration? _totalDuration = Duration.zero;
  StreamSubscription<Duration>? durationChangeSubscription;
  @override
  void initState() {
    super.initState();
    player = _audioPlayerService.player;
    _totalDuration = Duration(seconds: widget.duration ?? 0);
    final audioPlayerData =
        Provider.of<AudioPlayerData>(context, listen: false);
    player.getDuration().then((value) {
      if (mounted && audioPlayerData.mediaMeta.audioId == widget.fileName) {
        if (value > 0) {
          setState(() {
            _totalDuration = Duration(milliseconds: value);
          });
        }
      }
    });
    setUrl();
  }

  @override
  void dispose() {
    durationChangeSubscription?.cancel();
    super.dispose();
  }

  void setUrl() {
    FirebaseStorage.instanceFor(bucket: "fostercloudrecordings")
        .ref()
        .child(widget.fileName)
        .getDownloadURL()
        .then((url) {
      if (mounted) {
        setState(() {
          isUrlSet = true;
          this.url = url;
        });
      }
    });
  }

  void play(String url, PlayerState state, {bool isNewAudio = false}) async {
    try {
      state = (isNewAudio) ? PlayerState.STOPPED : state;
      if (makingReadyToPlay) {
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
            makingReadyToPlay = true;
          });
          await player.stop();
          await player.setUrl(url);
          // await player.getDuration().then((duration) {
          //   setState(() {
          //     makingReadyToPlay = false;
          //     _totalDuration = Duration(milliseconds: duration);
          //   });
          //   widget.onDurationFetched(_totalDuration);
          player.resume();
          // });
          setState(() {
            makingReadyToPlay = false;
          });
          // Future.delayed(Duration(seconds: 2), () {
          //   if (mounted) {
          //     player.getDuration().then((duration) {
          //       setState(() {
          //         makingReadyToPlay = false;
          //         _totalDuration = Duration(milliseconds: duration);
          //       });
          //       widget.onDurationFetched(_totalDuration);
          //       player.resume();
          //     });
          //   }
          // });

          break;
      }
    } catch (e) {
      setState(() {
        makingReadyToPlay = false;
      });
      ToastMessege("Something went wrong", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    if (durationChangeSubscription == null) {
      durationChangeSubscription = player.onDurationChanged.listen((event) {
        if (mounted) {
          if (widget.fileName == audioPlayerData.mediaMeta.audioId) {
            setState(() {
              _totalDuration = event;
            });
          }
        }
      });
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: (widget.fileName == audioPlayerData.mediaMeta.audioId)
          ? StreamBuilder<Duration>(
              stream: player.onAudioPositionChanged,
              builder: (context, AsyncSnapshot<Duration> snapshot) {
                final progress = snapshot.data;
                return Column(
                  children: [
                    ProgessBar(
                      onSeeek: (value) {
                        player.seek(value);
                      },
                      currentTime: progress,
                      totalTime: _totalDuration,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        //back
                        GestureDetector(
                          onTap: () {
                            if (progress != null) {
                              player.seek(progress - Duration(seconds: 15));
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 100,
                                child: Transform.rotate(
                                  angle: -pi / 5,
                                  child: Icon(
                                    Icons.replay,
                                    color: theme.colorScheme.secondary,
                                    size: 50,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 28,
                                left: -0,
                                child: Container(
                                  color: theme.colorScheme.primary,
                                  child: Text(
                                    "15",
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),

                        // pause play
                        StreamBuilder<PlayerState>(
                            stream: player.onPlayerStateChanged,
                            builder: (context, snapshot) {
                              bool isSameAudio = widget.fileName ==
                                  audioPlayerData.mediaMeta.audioId;
                              var state = (isSameAudio)
                                  ? player.state
                                  : PlayerState.STOPPED;

                              return GestureDetector(
                                onTap: () {
                                  if (!isSameAudio) {
                                    audioPlayerData.setMediaMeta(
                                        MediaMeta(
                                            audioId: widget.fileName,
                                            audioName: widget
                                                .rawData?["roomData"]["title"],
                                            userName:
                                                widget.rawData?["roomData"]
                                                    ["roomCreator"],
                                            rawData: widget.rawData,
                                            mediaType: MediaType.recordings),
                                        shouldNotify: true);
                                  }
                                  play(url!, player.state,
                                      isNewAudio: !isSameAudio);
                                },
                                child: (makingReadyToPlay)
                                    ? CircularProgressIndicator(
                                        color: theme.colorScheme.secondary,
                                      )
                                    : Icon(
                                        (state == PlayerState.COMPLETED)
                                            ? Icons.replay
                                            : (state != PlayerState.PLAYING)
                                                ? Icons.play_circle
                                                : Icons.pause_circle_filled,
                                        color: theme.colorScheme.secondary,
                                        size: 60,
                                      ),
                              );
                            }),
                        SizedBox(
                          width: 20,
                        ),

                        //forward
                        GestureDetector(
                          onTap: () {
                            if (progress != null) {
                              player.seek(progress + Duration(seconds: 15));
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 100,
                                child: Transform(
                                  transform: Matrix4.rotationY(pi),
                                  alignment: Alignment.center,
                                  child: Transform.rotate(
                                    angle: -pi / 5,
                                    child: Icon(
                                      Icons.replay,
                                      color: theme.colorScheme.secondary,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 28,
                                right: 0,
                                child: Container(
                                  color: theme.colorScheme.primary,
                                  child: Text(
                                    "15",
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            )
          : Column(
              children: [
                ProgessBar(
                  onSeeek: (value) {
                    player.seek(value);
                  },
                  currentTime: Duration.zero,
                  totalTime: _totalDuration,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    // //bookmark
                    // GestureDetector(
                    //   onTap: (){
                    //     setState(() {
                    //       bookmarked = !bookmarked;
                    //     });
                    //   },
                    //
                    //   child: Icon(
                    //     bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    //     color: theme.colorScheme.secondary,
                    //     size: 45,
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: 10,
                    // ),

                    //back
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            child: Transform.rotate(
                              angle: -pi / 5,
                              child: Icon(
                                Icons.replay,
                                color: theme.colorScheme.secondary,
                                size: 50,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 28,
                            left: -0,
                            child: Container(
                              color: theme.colorScheme.primary,
                              child: Text(
                                "15",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   width: 20,
                    // ),

                    //pause play
                    StreamBuilder<PlayerState>(
                        stream: player.onPlayerStateChanged,
                        builder: (context, snapshot) {
                          bool isSameAudio = widget.fileName ==
                              audioPlayerData.mediaMeta.audioId;
                          var state = (isSameAudio)
                              ? player.state
                              : PlayerState.STOPPED;

                          return GestureDetector(
                            onTap: () {
                              if (!isSameAudio) {
                                audioPlayerData.setMediaMeta(
                                    MediaMeta(
                                        audioId: widget.fileName,
                                        audioName: widget.rawData?["roomData"]
                                            ["title"],
                                        userName: widget.rawData?["roomData"]
                                            ["roomCreator"],
                                        rawData: widget.rawData,
                                        mediaType: MediaType.recordings),
                                    shouldNotify: true);
                              }
                              play(url!, player.state,
                                  isNewAudio: !isSameAudio);
                            },
                            child: (makingReadyToPlay)
                                ? CircularProgressIndicator(
                                    color: theme.colorScheme.secondary,
                                  )
                                : Icon(
                                    (state == PlayerState.COMPLETED)
                                        ? Icons.replay
                                        : (state != PlayerState.PLAYING)
                                            ? Icons.play_circle
                                            : Icons.pause_circle_filled,
                                    color: theme.colorScheme.secondary,
                                    size: 60,
                                  ),
                          );
                        }),
                    // SizedBox(
                    //   width: 20,
                    // ),

                    //forward
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            child: Transform(
                              transform: Matrix4.rotationY(pi),
                              alignment: Alignment.center,
                              child: Transform.rotate(
                                angle: -pi / 5,
                                child: Icon(
                                  Icons.replay,
                                  color: theme.colorScheme.secondary,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 28,
                            right: 0,
                            child: Container(
                              color: theme.colorScheme.primary,
                              child: Text(
                                "15",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    // //comment
                    // SizedBox(
                    //   width: 10,
                    // ),
                    // GestureDetector(
                    //   onTap: (){
                    //     print("sid");
                    //     print(widget.rawData?["recordingData"]
                    //     ["sid"]);
                    //     print("title");
                    //     print(widget.rawData?["roomData"]
                    //     ["title"]);
                    //     Navigator.push(
                    //         context, MaterialPageRoute(
                    //         builder: (context) =>
                    //             PodcastComments(
                    //                 sid: widget.rawData?["recordingData"]
                    //                 ["sid"],
                    //                 title: widget.rawData?["roomData"]
                    //             ["title"])
                    //     ));
                    //   },
                    //
                    //   child: Icon(
                    //     Icons.comment_outlined,
                    //     color: theme.colorScheme.secondary,
                    //     size: 42,
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
    );
  }
}

class ProgessBar extends StatelessWidget {
  final Duration? currentTime;
  final Duration? totalTime;
  final Function(Duration duration)? onSeeek;
  const ProgessBar({Key? key, this.onSeeek, this.currentTime, this.totalTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ProgressBar(
      timeLabelPadding: 10,
      onSeek: (value) {
        if (onSeeek != null) {
          onSeeek!(value);
        }
      },
      timeLabelTextStyle: TextStyle(color: theme.colorScheme.inversePrimary),
      progressBarColor: theme.colorScheme.secondary,
      thumbColor: theme.colorScheme.secondary,
      baseBarColor: theme.colorScheme.secondary.withOpacity(0.5),
      progress: currentTime ?? Duration.zero,
      total: totalTime ?? Duration.zero,
    );
  }
}
