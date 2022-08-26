import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/albums/EpisodePage.dart';
import 'package:fostr/albums/PanelEpisodeCard.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/enums/role_enum.dart';
import 'package:fostr/pages/rooms/Minimal.dart';
import 'package:fostr/pages/user/userActivity/PanelRecordings.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/RoomProvider.dart';
import 'package:fostr/reviews/PanelReview.dart';
import 'package:fostr/services/AgoraService.dart';
import 'package:fostr/services/AudioPlayerService.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:fostr/theatre/TheatreRoom.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'liveRooms.dart';

class SlidupPanel extends StatefulWidget {
  const SlidupPanel({Key? key}) : super(key: key);

  @override
  State<SlidupPanel> createState() => _SlidupPanelState();
}

class _SlidupPanelState extends State<SlidupPanel> {
  @override
  Widget build(BuildContext context) {
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    if ((audioPlayerData.mediaMeta.mediaType != MediaType.none &&
            roomProvider.shouldShow) ||
        (audioPlayerData.mediaMeta.mediaType != MediaType.bits &&
            audioPlayerData.mediaMeta.mediaType != MediaType.none) ||
        (audioPlayerData.mediaMeta.mediaType != MediaType.episode &&
            audioPlayerData.mediaMeta.mediaType != MediaType.none)) {
      return SlidingUpPanel(
        isDraggable: audioPlayerData.mediaMeta.mediaType != MediaType.rooms &&
            audioPlayerData.mediaMeta.mediaType != MediaType.theatres,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        maxHeight: 500,
        minHeight: 150,
        panel: PanelWidget(
          onCollapsed: () {},
        ),
        collapsed: CollapsedWidget(
          onExpand: () {},
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class CollapsedWidget extends StatefulWidget {
  final VoidCallback onExpand;
  const CollapsedWidget({Key? key, required this.onExpand}) : super(key: key);

  @override
  State<CollapsedWidget> createState() => _CollapsedWidgetState();
}

class _CollapsedWidgetState extends State<CollapsedWidget> {
  final AudioPlayerService _audioPlayerService = GetIt.I<AudioPlayerService>();
  final AgoraService _agoraService = GetIt.I<AgoraService>();
  final RoomService _roomService = GetIt.I<RoomService>();
  final TheatreService _theatreService = GetIt.I<TheatreService>();
  final roomsCollection = FirebaseFirestore.instance.collection('rooms');
  AudioPlayer player = AudioPlayer();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _avabalitySubscription;

  Duration? _totalDuration;

  StreamSubscription<Duration>? durationChangeSubscription;

  @override
  void initState() {
    super.initState();
    player = _audioPlayerService.player;

    player.getDuration().then((value) {
      if (mounted) {
        setState(() {
          _totalDuration = Duration(milliseconds: value);
        });
      }
    });

    durationChangeSubscription = player.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
  }

  void play(url) async {
    await player.setUrl(url).then((value) async {
      await player.resume();
    });
  }

  @override
  void dispose() {
    _avabalitySubscription?.cancel();
    durationChangeSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AudioPlayerData audioPlayerData =
        Provider.of<AudioPlayerData>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final meta = audioPlayerData.mediaMeta;

    // if (_totalDuration == null) {
    //   Future.delayed(Duration(milliseconds: 500), () {
    //     player.getDuration().then((value) {
    //       setState(() {
    //         _totalDuration = Duration(milliseconds: value);
    //       });
    //     });
    //   });
    // }

    if (_subscription == null &&
        (meta.mediaType == MediaType.rooms ||
            meta.mediaType == MediaType.theatres)) {
      if (meta.mediaType == MediaType.rooms) {
        final room = roomProvider.room!;

        _avabalitySubscription = roomCollection
            .doc(room.id)
            .collection("rooms")
            .doc(room.roomID)
            .snapshots()
            .listen((event) async {
          if (event.data()?['isActive'] == false) {
            _roomService.leaveRoom(roomProvider.room!, roomProvider.user!);
            roomProvider.clearRoom();
            _agoraService.destroyEngine();
            audioPlayerData.setMediaMeta(MediaMeta(), shouldNotify: true);
            if (mounted) {
              ToastMessege(
                  "Room has been deleted by the host. Removing you from the room",
                  context: context);
            }
          }
        });

        _subscription = roomCollection
            .doc(room.id)
            .collection("rooms")
            .doc(room.roomID)
            .collection("speakers")
            .doc(auth.user!.userName)
            .snapshots()
            .listen((event) async {
          if (event.data()?['isKickedOut'] == true) {
            _roomService.leaveRoom(roomProvider.room!, roomProvider.user!);
            roomProvider.clearRoom();
            _agoraService.destroyEngine();
            audioPlayerData.setMediaMeta(MediaMeta(), shouldNotify: true);
            if (mounted) {
              ToastMessege("The host has removed you from the room.",
                  context: context);
            }
          }
        });
      } else if (meta.mediaType == MediaType.theatres) {
        final theatre = roomProvider.theatre!;
        _avabalitySubscription = roomCollection
            .doc(theatre.createdBy)
            .collection("amphitheatre")
            .doc(theatre.theatreId)
            .snapshots()
            .listen((event) async {
          if (event.data()?['isActive'] == false) {
            _theatreService.leaveRoom(
                roomProvider.theatre!, roomProvider.user!);
            roomProvider.clearRoom();
            audioPlayerData.setMediaMeta(MediaMeta(), shouldNotify: true);
            _agoraService.destroyEngine();
            if (mounted) {
              ToastMessege("Room has been deleted by the host. Removing you from the theatre",
                  context: context);
            }
          }
        });
        _subscription = roomCollection
            .doc(theatre.createdBy)
            .collection("amphitheatre")
            .doc(theatre.theatreId)
            .collection("users")
            .doc(auth.user!.userName)
            .snapshots()
            .listen((event) async {
          if (event.data()?['isKickedOut'] == true) {
            _theatreService.leaveRoom(
                roomProvider.theatre!, roomProvider.user!);
            roomProvider.clearRoom();
            audioPlayerData.setMediaMeta(MediaMeta(), shouldNotify: true);
            _agoraService.destroyEngine();
            if (mounted) {
              ToastMessege("The host has removed you from the theatre.",
                  context: context);
            }
          }
        });
      }
    }

    return GestureDetector(
      onTap: () {
        if (meta.mediaType == MediaType.rooms) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              settings: RouteSettings(name: 'minimal'),
              builder: (context) => Scaffold(
                body: Minimal(
                  room: roomProvider.room!,
                  role: ClientRole.Broadcaster,
                ),
              ),
            ),
          );
        }
        else if (meta.mediaType == MediaType.theatres) {
          var role = (auth.user?.id == roomProvider.theatre?.createdBy)
              ? Role.Host
              : Role.Participant;
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => Scaffold(
                  body: TheatreRoom(
                role: role,
                theatre: roomProvider.theatre!,
                shouldUseNewToken: false,
              )),
            ),
          );
        }
      },
      child: Material(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          meta.audioName ?? "Play something",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "drawerbody"),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "By " + (meta.userName ?? "someone"),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "drawerbody",
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [

                      ///when you are pressing next or previous,
                      ///its updating the index as well and there for when you try to fetch data from firestore,
                      ///that value doesn't exist, so simply look into the index.

                      //play previous
                      (meta.mediaType == MediaType.episode
                          && meta.episodeIndex! > 0)
                          ? GestureDetector(
                        onTap: () async {

                          await FirebaseFirestore.instance
                              .collection("albums")
                              .doc(meta.albumId)
                              .collection("episodes")
                              .doc(meta.episodeList![meta.episodeIndex!-1])
                              .get()
                              .then((episode){

                            print("previous");
                            print(meta.episodeList![meta.episodeIndex!-1]);
                            print(meta.episodeIndex!-1);
                            print(episode);
                            print(episode.data());
                            // print(episode.data()!['title']);
                            // print(episode.data()!['audio']);

                                player.release().then((value){
                                  audioPlayerData.setMediaMeta(MediaMeta(),shouldNotify: true);
                                  audioPlayerData.setMediaMeta(
                                      MediaMeta(
                                          audioId: episode.id,
                                          audioName: episode.data()!['title'],
                                          userName: meta.userName,
                                          albumId: meta.albumId,
                                          episodeList: meta.episodeList,
                                          episodeNames: meta.episodeNames,
                                          episodeIndex: meta.episodeList!.indexOf(episode.id),
                                          rawData: {
                                            "episode" : episode.data()
                                          },
                                          mediaType: MediaType.episode),
                                      shouldNotify: true);
                                  play(episode.data()!['audio']);
                                });

                                });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(
                            Icons.skip_previous_rounded,
                            size: 30,
                          ),
                        ),
                      )
                          :SizedBox.shrink(),

                      (meta.mediaType == MediaType.rooms)
                          ? StreamBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                              stream: roomCollection
                                  .doc(roomProvider.room!.id)
                                  .collection("rooms")
                                  .doc(roomProvider.room!.roomID)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final isMicDisabled = (snapshot.data
                                            ?.data()?["isMutedSpeakers"] ??
                                        false) &&
                                    roomProvider.room?.id != auth.user?.id;
                                return IconButton(
                                  icon: (roomProvider.isMuted ?? true)
                                      ? Icon(Icons.mic_off)
                                      : Icon(
                                          Icons.mic,
                                        ),
                                  onPressed: (isMicDisabled)
                                      ? null
                                      : () {
                                          roomProvider.setIsMuted(
                                              !(roomProvider.isMuted ?? true));
                                          _agoraService.toggleMute(
                                              (roomProvider.isMuted ?? true));
                                        },
                                );
                              })
                          : (meta.mediaType == MediaType.theatres)
                              ? IconButton(
                                  icon: (roomProvider.isMuted ?? true)
                                      ? Icon(Icons.mic_off)
                                      : Icon(
                                          Icons.mic,
                                        ),
                                  onPressed: () {
                                    roomProvider.setIsMuted(
                                        !(roomProvider.isMuted ?? true));
                                    roomCollection
                                        .doc(roomProvider.theatre!.createdBy)
                                        .collection("amphitheatre")
                                        .doc(roomProvider.theatre!.theatreId)
                                        .collection("users")
                                        .doc(auth.user!.userName)
                                        .update({
                                      "isMicOn": (roomProvider.isMuted ?? true),
                                    });
                                    _agoraService.toggleMute(
                                        (roomProvider.isMuted ?? true));
                                  },
                                )
                              : StreamBuilder<PlayerState>(
                                  stream: _audioPlayerService
                                      .player.onPlayerStateChanged,
                                  builder: (context, snapshot) {
                                    final isPlaying =
                                        _audioPlayerService.player.state ==
                                            PlayerState.PLAYING;
                                    return GestureDetector(
                                      onTap: () {
                                        if (isPlaying) {
                                          _audioPlayerService.player.pause();
                                        } else {
                                          _audioPlayerService.player.resume();
                                        }
                                      },
                                      child: Icon(
                                        (isPlaying)
                                            ? Icons.pause
                                            : Icons.play_arrow_rounded,
                                        size: 50,
                                      ),
                                    );
                                  }),

                      //play next
                      (meta.mediaType == MediaType.episode
                          && (meta.episodeList!.indexOf(meta.episodeList!.last) != meta.episodeIndex!))
                          ? GestureDetector(
                        onTap: () async {

                          await FirebaseFirestore.instance
                              .collection("albums")
                              .doc(meta.albumId)
                              .collection("episodes")
                              .doc(meta.episodeList![meta.episodeIndex!+1])
                              .get()
                              .then((episode){

                            print("next");
                            print(meta.episodeList![meta.episodeIndex!+1]);
                            print(meta.episodeIndex!+1);
                            print(episode);
                            print(episode.data());
                            // print(episode.data()!['title']);
                            // print(episode.data()!['audio']);

                            player.release().then((value){
                              audioPlayerData.setMediaMeta(MediaMeta(),shouldNotify: true);
                              audioPlayerData.setMediaMeta(
                                  MediaMeta(
                                      audioId: episode.id,
                                      audioName: episode.data()!['title'],
                                      userName: meta.userName,
                                      albumId: meta.albumId,
                                      episodeList: meta.episodeList,
                                      episodeNames: meta.episodeNames,
                                      episodeIndex: meta.episodeList!.indexOf(episode.id),
                                      rawData: {
                                        "episode" : episode.data()
                                      },
                                      mediaType: MediaType.episode),
                                  shouldNotify: true);
                              play(episode.data()!['audio']);
                            });

                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(
                            Icons.skip_next_rounded,
                            size: 30,
                          ),
                        ),
                      )
                          :SizedBox.shrink(),

                      (meta.mediaType == MediaType.rooms)
                          ? GestureDetector(
                              onTap: () async {
                                await _roomService.leaveRoom(
                                    roomProvider.room!, roomProvider.user!);
                                roomProvider.clearRoom();
                                _agoraService.destroyEngine();

                                audioPlayerData.setMediaMeta(MediaMeta(),
                                    shouldNotify: true);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.logout,
                                  size: 30,
                                ),
                              ),
                            )
                          : (meta.mediaType == MediaType.theatres)
                              ? GestureDetector(
                                  onTap: () async {
                                    await _theatreService.leaveRoom(
                                        roomProvider.theatre!,
                                        roomProvider.user!);
                                    roomProvider.clearRoom();
                                    audioPlayerData.setMediaMeta(MediaMeta(),
                                        shouldNotify: true);
                                    _agoraService.destroyEngine();
                                  },
                                  child: Icon(
                                    Icons.logout,
                                    size: 30,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    player.release();
                                    audioPlayerData.setMediaMeta(MediaMeta(),
                                        shouldNotify: true);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Icon(
                                      Icons.clear,
                                      size: 30,
                                    ),
                                  ),
                                ),
                    ],
                  ),
                ],
              ),
              (audioPlayerData.mediaMeta.mediaType == MediaType.recordings ||
                      meta.mediaType == MediaType.bits ||
                  meta.mediaType == MediaType.episode)
                  ? StreamBuilder<Duration>(
                      stream: player.onAudioPositionChanged,
                      builder: (context, snapshot) {
                        final progress = snapshot.data;
                        return Flexible(
                          child: ProgessBar(
                            onSeeek: (value) {
                              player.seek(value);
                            },
                            currentTime: progress ?? Duration.zero,
                            totalTime: _totalDuration,
                          ),
                        );
                      },
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
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

class PanelWidget extends StatefulWidget {
  final VoidCallback onCollapsed;
  const PanelWidget({Key? key, required this.onCollapsed}) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final type = audioPlayerData.mediaMeta.mediaType;
    return Material(
      color: theme.colorScheme.primary,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (type == MediaType.bits)
                ? Stack(
                  children: [
                    PanelReviewCard(
                        id: audioPlayerData.mediaMeta.rawData?['id'],
                        reviewData: audioPlayerData.mediaMeta.rawData!,
                        uid: auth.user!.id),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(),
                    )
                  ],
                )
                : SizedBox.shrink(),
            (type == MediaType.recordings)
                ? PanelRecordingTile(
                    roomData: audioPlayerData.mediaMeta.rawData?["roomData"],
                    recordingData:
                        audioPlayerData.mediaMeta.rawData?["recordingData"])
                : SizedBox.shrink(),
            (type == MediaType.rooms)
                ? LiveRoomCardSingle(
                    roomProvider.room!.toJson(), roomProvider.room!, "room", auth.user!.id)
                : SizedBox.shrink(),
          (type == MediaType.episode)
          ? Stack(
            children: [
              PanelEpisodeCard(episode: audioPlayerData.mediaMeta.rawData?["episode"]),
              Align(
                alignment: Alignment.topRight,
                child: Container(),
              )
            ],
          )
          : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
