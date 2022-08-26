import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/RecordingService.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/rooms/Profile.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' show pi;

import '../../../models/UserModel/User.dart';

class RoomRecorings extends StatefulWidget {
  final String id;
  final String roomId;
  final RecordingType? type;
  const RoomRecorings(
      {Key? key,
      required this.id,
      required this.roomId,
      this.type = RecordingType.ROOM})
      : super(key: key);

  @override
  State<RoomRecorings> createState() => _RoomRecoringsState();
}

class _RoomRecoringsState extends State<RoomRecorings> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Material(
      color: theme.colorScheme.primary,
      child: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("recordings")
                .where("userId", isEqualTo: widget.id)
                .where("roomId", isEqualTo: widget.roomId)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: AppLoading(),
                );
              }

              if (snapshot.hasError) {
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
                final data = snapshot.data!.docs.where(
                  (element) {
                    final doc = element.data();
                    final isDeleted = doc["isActive"];
                    return isDeleted;
                  },
                ).toList();

                return Stack(
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: data.length + 1,
                      itemBuilder: (context, index) {
                        if (index == data.length) {
                          return Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 500,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No More Recordings",
                                ),
                              ],
                            ),
                          );
                        }

                        // final room = rooms[rooms.keys.elementAt(index)]!;
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: RoomTile(
                            roomData: [
                              {
                                "id": data[index].id,
                                ...data[index].data(),
                                "type": widget.type.toString(),
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
                            (widget.id == null || widget.id != auth.user?.id)
                                ? "Podcasts"
                                : "My Podcasts",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
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
                        icon: Icon(
                          Icons.arrow_back_ios,
                        ),
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
  const RoomTile({
    Key? key,
    required this.roomData,
    this.showShare = true,
  }) : super(key: key);

  @override
  State<RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends State<RoomTile> {
  late String userId;
  late String roomId;
  late String type;
  late Future<DocumentSnapshot<Map<String, dynamic>>>? getRoom;
  late Future<QuerySnapshot<Map<String, dynamic>>>? roomSpeakers;

  static const DEFAULT_IMAGE =
      "https://static.wixstatic.com/media/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png/v1/fill/w_1920,h_1080,al_c/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png";

  @override
  void initState() {
    super.initState();
    userId = widget.roomData.first["userId"];
    roomId = widget.roomData.first["roomId"];
    type = widget.roomData.first["type"];
    if (type == RecordingType.ROOM.toString()) {
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = Provider.of<AuthProvider>(context);
    return FutureBuilder(
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
              // color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      data?["title"] ?? "",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "drawerbody"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      data?["authorName"] != null && data?["authorName"] != ""
                          ? "By " + data!["authorName"]
                          : "",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: "drawerbody"),
                    ),
                    SizedBox.shrink(),
                    Container(
                      height: 250,
                      width: 250,
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(minHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 3),
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
                    FutureBuilder(
                        future: roomSpeakers,
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "Something went wrong",
                              ),
                            );
                          }

                          if (snapshot.data?.size == 0) {
                            return Center(
                              child: Text(
                                "There were no speakers",
                              ),
                            );
                          }
                          final data = snapshot.data!.docs
                              .map((element) => element.data())
                              .toList();
                          return Flexible(
                            child: GridView.builder(
                              physics: ClampingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3),
                              itemCount: data.length,
                              padding: EdgeInsets.all(2.0),
                              itemBuilder: (BuildContext context, int index) {
                                return Profile(
                                    user: User.fromJson(data[index]),
                                    size: 60,
                                    isMute: false,
                                    volume: 0,
                                    myVolume: 0);
                              },
                            ),
                          );
                        }),
                    Column(
                      children: widget.roomData.map((roomData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: RecordingTile(
                            duration: roomData["duration"] ?? 0,
                            roomId: roomId,
                            userId: userId,
                            recordingId: roomData["fileName"],
                            recordingDocId: roomData["id"],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // (widget.showShare)
                //     ?

                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      (widget.roomData.first['userId'] == auth.user?.id)
                          ? IconButton(
                              onPressed: () async {
                                FirebaseFirestore.instance
                                    .collection("recordings")
                                    .doc(widget.roomData.first["id"])
                                    .update({
                                  "isActive": false,
                                }).then((value) {
                                  if (mounted) {
                                    ToastMessege("Recording has been deleted",
                                        context: context);
                                  }
                                });
                              },
                              icon: Icon(Icons.delete),
                            )
                          : SizedBox.shrink(),
                      IconButton(
                        onPressed: () async {
                          final url = await DynamicLinksApi.fosterPodsLink(
                            widget.roomData.first["id"],
                            roomName: data?["title"] ?? "",
                          );
                          Share.share(url);
                        },
                        icon: SvgPicture.asset("assets/icons/blue_share.svg"),
                        // Icon(Icons.share),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class RecordingTile extends StatefulWidget {
  final String roomId;
  final String userId;
  final String recordingId;
  final int? duration;
  final String recordingDocId;
  const RecordingTile({
    Key? key,
    required this.roomId,
    required this.userId,
    required this.recordingId,
    required this.duration,
    required this.recordingDocId,
  }) : super(key: key);

  @override
  State<RecordingTile> createState() => _RecordingTileState();
}

class _RecordingTileState extends State<RecordingTile> {
  @override
  Widget build(BuildContext context) {
    return RecordingPlayer(
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
  final Function(Duration? duration) onDurationFetched;
  const RecordingPlayer(
      {Key? key,
      required this.fileName,
      required this.duration,
      required this.onDurationFetched})
      : super(key: key);

  @override
  State<RecordingPlayer> createState() => _RecordingPlayerState();
}

class _RecordingPlayerState extends State<RecordingPlayer> {
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isPlaying = false;
  bool isReadyToPlay = false;
  bool isFinished = false;
  bool makingReadyToPlay = false;

  bool isUrlSet = false;

  String? url;
  Duration? _totalDuration = Duration.zero;
  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(seconds: widget.duration ?? 0);
    setUrl();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
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

  void play() async {
    if (isUrlSet) {
      if (isReadyToPlay) {
        if (!isPlaying) {
          setState(() {
            isFinished = false;
            isPlaying = true;
          });
          audioPlayer.play();
        } else {
          setState(() {
            isPlaying = false;
          });
          audioPlayer.pause();
        }
      } else {
        await makeReadyToPlay();
        if (isReadyToPlay) {
          audioPlayer.play();
          setState(() {
            isPlaying = true;
          });
        }
      }
    }
  }

  Future<void> makeReadyToPlay() async {
    try {
      setState(() {
        makingReadyToPlay = true;
      });
      final totalDuration = await audioPlayer.setUrl(url!);
      widget.onDurationFetched(totalDuration);
      setState(() {
        _totalDuration = totalDuration;
        isReadyToPlay = true;
        makingReadyToPlay = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isReadyToPlay = false;
        makingReadyToPlay = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<Duration>(
        stream: audioPlayer.positionStream,
        builder: (context, AsyncSnapshot<Duration> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ProgessBar();
          }
          if (snapshot.connectionState == ConnectionState.active) {
            final progress = snapshot.data!;
            if (progress == _totalDuration && isPlaying) {
              Future.delayed(Duration(milliseconds: 500), () {
                audioPlayer.stop();
                audioPlayer.seek(Duration.zero);
                setState(() {
                  isFinished = true;
                });
              });
            }
            return Column(
              children: [
                ProgessBar(
                  onSeeek: (value) {
                    audioPlayer.seek(value);
                  },
                  currentTime: progress,
                  totalTime: _totalDuration,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        audioPlayer.seek(progress - Duration(seconds: 15));
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
                    GestureDetector(
                      onTap: () {
                        play();
                      },
                      child: (makingReadyToPlay)
                          ? CircularProgressIndicator(
                              color: theme.colorScheme.secondary,
                            )
                          : Icon(
                              (isFinished)
                                  ? Icons.replay
                                  : (!isPlaying)
                                      ? Icons.play_circle
                                      : Icons.pause_circle_filled,
                              color: theme.colorScheme.secondary,
                              size: 60,
                            ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        audioPlayer.seek(progress + Duration(seconds: 15));
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
          } else {
            return ProgessBar();
          }
        },
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
      baseBarColor: theme.colorScheme.secondary.withOpacity(0.4),
      progress: currentTime ?? Duration.zero,
      total: totalTime ?? Duration.zero,
    );
  }
}
