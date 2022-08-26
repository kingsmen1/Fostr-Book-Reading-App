import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/core/settings.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/rooms/RoomInfo.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/RoomProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/services/AgoraService.dart';
import 'package:fostr/services/AgoraUserEvents.dart';
import 'package:fostr/services/InAppNotificationService.dart';
import 'package:fostr/services/RatingsService.dart';
import 'package:fostr/services/RecordingService.dart';
import 'package:fostr/services/RemoteConfigService.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/rooms/Profile.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/AppLoading.dart';

class Minimal extends StatefulWidget {
  final Room room;
  final ClientRole role;
  const Minimal({Key? key, required this.room, required this.role})
      : super(key: key);

  @override
  State<Minimal> createState() => _MinimalState();
}

class _MinimalState extends State<Minimal>
    with FostrTheme, WidgetsBindingObserver {
  final RecordingService _recordingService = GetIt.I.get<RecordingService>();
  final RemoteConfigService _remoteConfigService =
      GetIt.I.get<RemoteConfigService>();

  final AgoraService _agoraService = GetIt.I<AgoraService>();
  int speakersCount = 0, participantsCount = 0;
  String roompass = "";
  bool muted = true, isMicOn = true;

  // final RatingService _ratingService = GetIt.I<RatingService>();
  final RoomService _roomService = GetIt.I<RoomService>();

  List speakers = [];

  Map<int, int> info = {0: 10};
  bool isMuted = false;
  bool isActive = true;
  String authorID = "";
  List followers = [];
  String thoughtNotification = "";
  bool newThought = false;
  bool recording = false;
  TextEditingController thoughtController = TextEditingController();

  bool isMicDisabled = false;

  bool initialThought = true;

  Timer? recordingTimer;

  int recordingTime = 0;

  bool isHostRecording = false;

  bool stopRecording = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? profileStream;

  Timer? elapsedTimer;
  Duration? elapsedDuration;

  int? userID;
  int? activeUserID;
  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    WidgetsBinding.instance?.addObserver(this);

    profileStream = roomCollection
        .doc(widget.room.id)
        .collection("rooms")
        .doc(widget.room.roomID)
        .collection('speakers')
        .where("isActiveInRoom", isEqualTo: true)
        .snapshots();

    _roomService.initRoom(widget.room,
        (participantsC, speakersC, tokenC, channelNameC, roompassC) {
      if (mounted) {
        setState(() {
          participantsCount = participantsC;
          speakersCount = speakersC;
          token = tokenC;
          channelName = channelNameC;
          roompass = roompassC ?? "";
        });
      }
    });
    initialize(auth.user!);

    FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.room.id)
        .collection("rooms")
        .doc(widget.room.roomID)
        .snapshots()
        .listen((event) {
      if (mounted) {
        bool roomRecording = event.data()?["recording"] ?? false;
        if (widget.room.id != auth.user!.id && roomRecording != recording) {
          if (roomRecording) {
            ToastMessege("Recording started", context: context);
          } else {
            ToastMessege("Recording stopped", context: context);
          }
        }
        if (widget.room.id == auth.user!.id &&
            recordingTimer?.isActive != true &&
            roomRecording) {
          if (event.data()?["recordingStartTime"] == null) {
            recordingTime = 0;
          } else {
            recordingTime = DateTime.now()
                .toUtc()
                .difference(DateTime.parse(
                        event.data()!["recordingStartTime"].toDate().toString())
                    .toUtc())
                .inSeconds;
          }
          recordingTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
            if (mounted) {
              setState(() {
                // if(recordingTime < 3600)
                  recordingTime++;
                // if(recordingTime == 3600){
                //   ToastMessege("Recording stopped",
                //       context: context);
                //   recordingTimer?.cancel();
                //   setState(() {
                //     recordingTime = 0;
                //     recording = false;
                //   });
                //
                //   _recordingService
                //       .stopRecording(
                //       roomId: widget.room.roomID!,
                //       userId: widget.room.id!,
                //       type: RecordingType.ROOM)
                //       .then((value) {
                //     if (mounted) {
                //       ToastMessege("Recording saved",
                //           context: context);
                //     }
                //   });
                // }
              });
            }
          });
        }
        setState(() {
          recording = roomRecording;
          isHostRecording = roomRecording;
        });
      }
    });

    FirebaseFirestore.instance
        .collection("roomThoughts")
        .doc(widget.room.roomID)
        .snapshots()
        .listen((event) {
      if (mounted) {
        setState(() {
          newThought = true;
          thoughtNotification = event.data()?["messege"] ?? "";
        });
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              newThought = false;
              initialThought = false;
            });
          }
        });
      }
    });

    DateTime dob = widget.room.dateTime!;
    elapsedDuration =  DateTime.now().difference(dob);
    elapsedTimer = Timer.periodic(Duration(seconds: 1), (Timer t){
      setState(() {
        elapsedDuration =  DateTime.now().difference(dob);
      });
    }
    );

    // fetchIsActive();
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    elapsedTimer?.cancel();
    // if (recording) {
    //   _recordingService.stopRecording(
    //       roomId: widget.room.roomID!,
    //       userId: widget.room.id!,
    //       roomTitle: widget.room.title!.toLowerCase().trim(),
    //       type: RecordingType.ROOM);
    // }
    super.dispose();
  }

  Future<void> leaveChannel() async {
    await _agoraService.leaveChannel();
  }

  // Future<void> destroy() async {
  //   await _agoraService.destroyInstance();
  // }

  disableMic() {
    if (mounted) {}
    setState(() {
      isMicDisabled = !isMicDisabled;
    });
  }

  /// Create Agora SDK instance and initialize
  Future<void> initialize(User user) async {
    _addAgoraEventHandlers(user);
  }

  void getFollowers(User user) async {
    followers = user.followers ?? [];
  }

  /// Add Agora event handlers
  Future<void> _addAgoraEventHandlers(User user) async {

    _agoraService.setAgoraEventHandlers(
      RtcEngineEventHandler(
        audioVolumeIndication: (speakers, volume) {
          if (mounted) {
            setState(() {
              for (int i = 0; i < speakers.length; i++) {
                stopRecording = false;
                info[speakers[i].uid] = speakers[i].volume;
              }
            });
          }

          if(speakers.length < 1){
            setState(() {
              stopRecording = true;
            });
            Future.delayed(Duration(minutes: 1)).then((value){
              if(stopRecording){
                if (recording) {
                  _recordingService.stopRecording(
                      roomId: widget.room.roomID!,
                      userId: widget.room.id!,
                      roomTitle: widget.room.title!.toLowerCase().trim(),
                      type: RecordingType.ROOM);
                }
              }
            });
          }

        },
        joinChannelSuccess: (channel, uid, elapsed) {
          if (mounted) {
            setState(() {
              userID = uid;
            });
          }
          if (widget.role == ClientRole.Broadcaster) {
            roomCollection
                .doc(widget.room.id)
                .collection("rooms")
                .doc(widget.room.roomID)
                .collection("speakers")
                .doc(user.userName)
                .update({
              "rtcId": uid,
            });
          }

          _roomService.sendLogs({
            "roomId": widget.room.roomID,
            "creatorId": widget.room.id,
            "event": "room_join",
            "logLevel": "INFO",
            "roomUserId": user.userName
          });
        },
        leaveChannel: (stats) {
          log(stats.toJson().toString());
        },
        connectionStateChanged: (state, reason) async {
          if (reason == ConnectionChangedReason.Interrupted &&
              state == ConnectionStateType.Failed) {
            Navigator.of(context).pop();

            var res = await roomCollection
                .doc(widget.room.id)
                .collection("rooms")
                .doc(widget.room.roomID)
                .collection("speakers")
                .doc(user.userName)
                .update({"isActiveInRoom": false});

            _roomService.sendLogs({
              "roomId": widget.room.roomID,
              "creatorId": widget.room.id,
              "event": "room_left due to connection interrupted",
              "logLevel": "INFO",
              "roomUserId": user.id,
              "roomUserName": user.userName,
              "state": state.toString(),
              "reason": reason.toString()
            });

            await roomCollection
                .doc(widget.room.id)
                .collection("rooms")
                .doc(widget.room.roomID)
                .update(
              {
                'speakersCount': speakersCount,
              },
            );
          } else if (reason == ConnectionChangedReason.LeaveChannel &&
              state == ConnectionStateType.Disconnected) {
            await leaveChannel();

            var res = await roomCollection
                .doc(widget.room.id)
                .collection("rooms")
                .doc(widget.room.roomID)
                .collection("speakers")
                .doc(user.userName)
                .update({"isActiveInRoom": false});

            _roomService.sendLogs({
              "roomId": widget.room.roomID,
              "creatorId": widget.room.id,
              "event": "room_left due to connection reason as leave channel",
              "logLevel": "INFO",
              "roomUserName": user.userName,
              "roomUserId": user.id,
            });

            await roomCollection
                .doc(widget.room.id)
                .collection("rooms")
                .doc(widget.room.roomID)
                .update(
              {
                'speakersCount': speakersCount,
              },
            );
          }
        },
        connectionLost: () {
          ToastMessege("Connection lost, try to rejoin", context: context);
          print("Connection lost");
        },
        userJoined: (uid, elapsed) {
          print('userJoined: $uid');
        },
        userOffline: (id, reason) async {
          log(id.toString() + "---" + reason.toString());

          if (reason == UserOfflineReason.Dropped) {
            var res = await roomCollection
                .doc(widget.room.id)
                .collection("rooms")
                .doc(widget.room.roomID)
                .collection("speakers")
                .where("rtcId", isEqualTo: id)
                .get();
            res.docs.forEach((doc) {
              doc.reference.update({"isActiveInRoom": false});
            });

            _roomService.sendLogs({
              "roomId": widget.room.roomID,
              "creatorId": widget.room.id,
              "event": "user dropped by agora",
              "logLevel": "INFO",
              "roomUserId": id
            });
          }
        },
      ),
    );
  }

  void uploadThought(
      String userid, String image, String participantName) async {
    await FirebaseFirestore.instance
        .collection("roomThoughts")
        .doc(widget.room.roomID)
        .collection("Thoughts")
        .doc(
            "${userid}_${DateTime.now().toUtc().millisecondsSinceEpoch.toString()}")
        .set({
      "userId": userid,
      "image": image,
      "authorId": widget.room.id,
      "authorName": widget.room.roomCreator,
      "participantName": participantName,
      "roomId": widget.room.roomID,
      "thought": thoughtController.text,
      "thoughtID":
          "${userid}_${DateTime.now().toUtc().millisecondsSinceEpoch.toString()}",
      "isActive": true,
      "dateTime": DateTime.now().toUtc()
    },SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection("roomThoughts")
        .doc(widget.room.roomID)
        .set({"messege": "$participantName shared a thought"},SetOptions(merge: true)).then((value) {
      FocusManager.instance.primaryFocus?.unfocus();
      thoughtController.clear();
      ToastMessege("Thought shared!", context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    muted = roomProvider.isMuted ?? true;
    isMicOn = roomProvider.isMuted ?? true;
    final theme = Theme.of(context);
    final user = auth.user!;
    getFollowers(user);

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          color: theme.colorScheme.primary,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: theme.colorScheme.primary,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                    onPressed: () async {
                      // _ratingService.setCurrentRoom(
                      //     widget.room.title!, widget.room.id!, user.id);
                      // await leaveChannel();
                      // final newUser = await _roomService.leaveRoom(widget.room,
                      //     user, widget.role, speakersCount, participantsCount);
                      // if (widget.room.id == user.id) {
                      //   auth.refreshUser(newUser);
                      //   destroy();
                      // }
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => UserDashboard(
                      //         tab: "all", selectDay: DateTime.now())));
                      Navigator.pop(context);
                      elapsedTimer?.cancel();
                    },
                    icon: Icon(
                      FontAwesomeIcons.chevronDown,
                    )),
                elevation: 0,
                toolbarHeight: 65,
                backgroundColor: theme.colorScheme.primary,
                title: Container(
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      border:
                      Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      StreamBuilder(
                        stream: roomCollection
                            .doc(widget.room.id)
                            .collection("rooms")
                            .doc(widget.room.roomID)
                            .collection("speakers")
                            .where("isActiveInRoom", isEqualTo: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                QuerySnapshot<
                                    Map<String, dynamic>>>
                            snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!.docs.length.toString(),
                              style: TextStyle(color: theme.colorScheme.inversePrimary, fontSize: 16),
                            );
                          } else {
                            return Text("");
                          }
                        },
                      )
                    ],
                  ),
                ),
                // Text("",
                //   // widget.room.title ?? "Hallway",
                //   style: TextStyle(fontFamily: "drawerhead", fontSize: 18),
                //   // style: h1,
                // ),
                actions: [


                  (isHostRecording && recording
                      // widget.room.id != user.id
                  )
                      ? Container(
                        height: 20,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Icon(
                                Icons.fiber_manual_record,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                            Text(
                              " Rec",
                              style: TextStyle(
                                  color: theme.colorScheme.inversePrimary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                      : SizedBox.shrink(),


                  user.id == widget.room.id
                      ?
                      //for host
                      PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert,
                          ),
                          color: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: theme.colorScheme.secondary, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry>[
                                //nute
                            PopupMenuItem(
                              value: 'mute',
                              child: isMuted == false
                                  ? ListTile(
                                      leading: Icon(
                                        Icons.mic_off,
                                      ),
                                      title: Text(
                                        'Mute all',
                                        style: TextStyle(
                                          fontFamily: "drawerbody",
                                        ),
                                      ),
                                    )
                                  : ListTile(
                                      leading: Icon(
                                        Icons.mic,
                                      ),
                                      title: Text(
                                        'Un-mute all',
                                        style: TextStyle(
                                          fontFamily: "drawerbody",
                                        ),
                                      ),
                                    ),
                            ),

                            //participants
                            const PopupMenuItem(
                              value: 'participants',
                              child: ListTile(
                                leading: Icon(
                                  Icons.people_outline_rounded,
                                ),
                                title: Text(
                                  'Participants',
                                  style: TextStyle(
                                    fontFamily: "drawerbody",
                                  ),
                                ),
                              ),
                            ),

                            //recording
                            (!recording)
                                ? PopupMenuItem(
                                    value: 'recording',
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.record_voice_over,
                                      ),
                                      title: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                                text: 'Start Recording',
                                                style: TextStyle(
                                                  fontFamily: "drawerbody",
                                                )),
                                            TextSpan(
                                                text: (_remoteConfigService
                                                        .betaRecording)
                                                    ? " BETA"
                                                    : "",
                                                style: TextStyle(
                                                    fontFamily: "drawerbody",
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : PopupMenuItem(
                                    value: 'recording',
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.record_voice_over,
                                      ),
                                      title: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                                text: 'Stop Recording',
                                                style: TextStyle(
                                                  fontFamily: "drawerbody",
                                                )),
                                            TextSpan(
                                                text: (_remoteConfigService
                                                        .betaRecording)
                                                    ? " BETA"
                                                    : "",
                                                style: TextStyle(
                                                    fontFamily: "drawerbody",
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                //share
                                PopupMenuItem(
                                  value: 'share',
                                  child: ListTile(
                                    leading: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                                    // Icon(
                                    //   Icons.share,
                                    // ),
                                    title: Text(
                                      'Share',
                                      style: TextStyle(
                                        fontFamily: "drawerbody",
                                      ),
                                    ),
                                  ),
                                ),

                            //delete
                            const PopupMenuItem(
                              value: 'deleteRoom',
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete,
                                ),
                                title: Text(
                                  'Delete Room',
                                  style: TextStyle(
                                    fontFamily: "drawerbody",
                                  ),
                                ),
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            //all mute
                            if (value == 'mute') {
                              var rawParticipants = await roomCollection
                                  .doc(widget.room.id)
                                  .collection("rooms")
                                  .doc(widget.room.roomID)
                                  .collection("speakers") // participants
                                  .get();

                              var participants = rawParticipants.docs
                                  .map((e) => e.data())
                                  .toList();

                              List participantRtcIDs = [];

                              if (isMuted == false) {
                                // AgoraUserEvents(cname: widget.room.title, uid: 123).muteAllParticipants(participantRtcIDs);
                                setState(() {
                                  isMuted = true;
                                });
                                // participants.forEach((element) {
                                //   if(element['name'] != widget.room.roomCreator){
                                //       // participantRtcIDs.add(element['rtcId']);
                                //       _engine.muteRemoteAudioStream(element['rtcId'], true);
                                //     }
                                // });
                                await roomCollection
                                    .doc(widget.room.id)
                                    .collection("rooms")
                                    .doc(widget.room.roomID)
                                    .update({
                                  "isMutedSpeakers": true,
                                  "isUnmutedSpeakers": false
                                });
                              } else {
                                setState(() {
                                  isMuted = false;
                                });
                                await roomCollection
                                    .doc(widget.room.id)
                                    .collection("rooms")
                                    .doc(widget.room.roomID)
                                    .update({
                                  "isMutedSpeakers": false,
                                  "isUnmutedSpeakers": true
                                });
                              }
                              roomProvider.setIsMuted(isMuted);
                            }

                            //show participants
                            if (value == 'participants') {
                              var rawParticipants = await roomCollection
                                  .doc(widget.room.id)
                                  .collection("rooms")
                                  .doc(widget.room.roomID)
                                  .collection("speakers")
                                  .where("isActiveInRoom",
                                      isEqualTo: true) // participants
                                  .get();

                              var participants = rawParticipants.docs
                                  .map((e) => e.data()).where((element)=> element['id'] != widget.room.id)
                                  .toList();

                              List participantNames = [];
                              print(participants.length);
                              participants.forEach((element) {
                                setState(() {
                                    participantNames.add(element['name'].toString());
                                });
                              });

                              await createParticipantList(
                                  context, theme, participants);
                            }

                            //delete room
                            if (value == 'deleteRoom') {
                              if (recording) {
                                _recordingService
                                    .stopRecording(
                                        roomId: widget.room.roomID!,
                                        userId: widget.room.id!,
                                    roomTitle: widget.room.title!.toLowerCase().trim(),
                                        type: RecordingType.ROOM)
                                    .then((value) async {
                                  await leaveChannel(); // host leaves the channel
                                  // destroy(); // destroying the channel
                                  _recordingService.deleteRecordingInfo(
                                      widget.room.roomID!, widget.room.id!);
                                });
                              }
                              await roomCollection
                                  .doc(widget.room.id)
                                  .collection("rooms")
                                  .doc(widget.room.roomID)
                                  .collection('speakers')
                                  .doc(user.userName)
                                  .update({"isActiveInRoom": false});

                              await roomCollection
                                  .doc(widget.room.id)
                                  .collection("rooms")
                                  .doc(widget.room.roomID)
                                  .update({"isActive": false});

                              await FirebaseFirestore.instance
                                  .collection("feeds")
                                  .doc(widget.room.roomID)
                                  .delete();

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => UserDashboard(
                                      tab: "all", selectDay: DateTime.now()),
                                ),
                              );
                            }

                            //share
                            if(value == 'share'){
                              Share.share(await DynamicLinksApi.inviteOnlyRoomLink(
                                widget.room.roomID!,
                                widget.room.id!,
                                roomName: widget.room.title!,
                                imageUrl: widget.room.imageUrl,
                                creatorName: widget.room.roomCreator ?? "",
                              ));
                            }

                            //recording
                            if (value == "recording") {
                              if (!recording) {
                                setState(() {
                                  recording = true;
                                });
                                ToastMessege("Recording started",
                                    context: context);
                                recordingTimer = Timer.periodic(
                                    Duration(seconds: 1), (Timer t) {
                                  if (mounted) {
                                    setState(() {
                                      // if(recordingTime < 3600)
                                        recordingTime++;
                                      // if(recordingTime == 3600){
                                      //   ToastMessege("Recording stopped",
                                      //       context: context);
                                      //   recordingTimer?.cancel();
                                      //   setState(() {
                                      //     recordingTime = 0;
                                      //     recording = false;
                                      //   });
                                      //
                                      //   _recordingService
                                      //       .stopRecording(
                                      //       roomId: widget.room.roomID!,
                                      //       userId: widget.room.id!,
                                      //       type: RecordingType.ROOM)
                                      //       .then((value) {
                                      //     if (mounted) {
                                      //       ToastMessege("Recording saved",
                                      //           context: context);
                                      //     }
                                      //   });
                                      // }
                                    });
                                  }
                                });
                                _recordingService.startRecording(
                                  widget.room.roomID!,
                                  widget.room.roomID!,
                                  widget.room.id!,
                                );
                              } else {
                                ToastMessege("Recording stopped",
                                    context: context);
                                recordingTimer?.cancel();
                                setState(() {
                                  recordingTime = 0;
                                  recording = false;
                                });

                                _recordingService
                                    .stopRecording(
                                        roomId: widget.room.roomID!,
                                        userId: widget.room.id!,
                                    roomTitle: widget.room.title!.toLowerCase().trim(),
                                        type: RecordingType.ROOM)
                                    .then((value) {
                                  if (mounted) {
                                    ToastMessege("Recording saved",
                                        context: context);
                                  }
                                });
                              }
                            }
                          },
                        )
                      :
                      //for participants
                      GestureDetector(
                        onTap: () async {
                          Share.share(await DynamicLinksApi.inviteOnlyRoomLink(
                            widget.room.roomID!,
                            widget.room.id!,
                            roomName: widget.room.title!,
                            imageUrl: widget.room.imageUrl,
                            creatorName: widget.room.roomCreator ?? "",
                          ));
                        },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                          )
                      )
                      // Image.asset(
                      //     "assets/images/logo.png",
                      //     width: 50,
                      //   )
                ],
              ),
              body: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //ads
                      (widget.room.adTitle!.length > 0 &&
                              widget.room.adDescription!.length > 0)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    var url = widget.room.redirectLink;
                                    if (url != null) {
                                      if (await canLaunch(url)) {
                                        await launch(
                                          url,
                                          forceSafariVC: false,
                                          forceWebView: false,
                                          headers: <String, String>{
                                            'my_header_key': 'my_header_value'
                                          },
                                        );
                                      } else {
                                        ToastMessege("Could not launch URL",
                                            context: context);
                                      }
                                    } else {
                                      ToastMessege("No redirect link",
                                          context: context);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(16),
                                    width: MediaQuery.of(context).size.width,
                                    height: 180,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                "${widget.room.imageUrl2}"),
                                            fit: BoxFit.fill),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Color.fromRGBO(0, 0, 0, 0.13)),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 10,
                            ),

                      // info and timer
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(),

                            //title box
                            Container(
                              height: 60,
                              width: 250,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Row(
                                children: [

                                  //title and member count
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        //title
                                        Container(
                                          width: 200,
                                          child: Text(widget.room.title ?? "Hallway",
                                            style: TextStyle(fontFamily: "drawerhead", fontSize: 18),
                                            overflow: TextOverflow.ellipsis,
                                            // style: h1,
                                          ),
                                        ),

                                        // // members count
                                        // StreamBuilder(
                                        //     stream: roomCollection
                                        //         .doc(widget.room.id)
                                        //         .collection("rooms")
                                        //         .doc(widget.room.roomID)
                                        //         .collection("speakers")
                                        //         .where("isActiveInRoom", isEqualTo: true)
                                        //         .snapshots(),
                                        //     builder: (context, AsyncSnapshot<
                                        //         QuerySnapshot<
                                        //             Map<String, dynamic>>> snapshot) {
                                        //
                                        //       if (snapshot.hasData){
                                        //         return snapshot.data!.docs.length > 0 ?
                                        //         Padding(
                                        //           padding: const EdgeInsets.only(top: 2),
                                        //           child: Container(
                                        //             width: 200,
                                        //             child: Row(
                                        //               mainAxisAlignment: MainAxisAlignment.start,
                                        //               children: [
                                        //
                                        //                 Text(
                                        //                   snapshot.data!.docs.length.toString(),
                                        //                   style: TextStyle(fontFamily: "drawerhead", fontStyle: FontStyle.italic, fontSize: 12),
                                        //                 ),
                                        //
                                        //                 Text(snapshot.data!.docs.length > 1 ?
                                        //                 "  members" :
                                        //                 "  member",
                                        //                   style: TextStyle(fontFamily: "drawerhead", fontStyle: FontStyle.italic, fontSize: 12),
                                        //                 ),
                                        //               ],
                                        //             ),
                                        //           ),
                                        //         ) :
                                        //         SizedBox.shrink();
                                        //       } else {
                                        //         return Text("");
                                        //       }
                                        //     }
                                        // )
                                      ],
                                    ),
                                  ),

                                  //info
                                  GestureDetector(

                                    onTap: () async {
                                      await FirebaseFirestore.instance
                                          .collection("rooms")
                                          .doc(widget.room.id)
                                          .collection("rooms")
                                          .doc(widget.room.roomID)
                                          .get()
                                          .then((value){
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) =>
                                                RoomInfo(data: value.data()!, insideRoom: true,)
                                            ));
                                      });

                                    },

                                    child: Container(
                                        width: 20,
                                        child: Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: Colors.grey,
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),

                            //time elapsed
                            Container(
                              height: 60,
                              width: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("TIME ELAPSED",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey
                                    ),),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text("${elapsedDuration!.inHours.remainder(60).toString().padLeft(2,"0")} : ${elapsedDuration!.inMinutes.remainder(60).toString().padLeft(2,"0")} : ${(elapsedDuration!.inSeconds.remainder(60).toString().padLeft(2,"0"))}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ),

                                  // ElapsedTime(timestamp: widget.theatre.scheduleOn)
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),

                      //gridview of people in the theatre
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 20,
                        child: Center(
                          child: Text('Pull to refresh',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontStyle: FontStyle.italic
                            ),),
                        ),
                      ),

                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(32),
                            topLeft: Radius.circular(32),
                          ),
                        ),
                        child: Stack(
                          children: [

                            buildProfiles(theme),
                            FutureBuilder(
                              future: roomCollection
                                  .doc(widget.room.id)
                                  .collection("rooms")
                                  .doc(widget.room.roomID)
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!
                                              .data()!['isMutedSpeakers'] ==
                                          true &&
                                      widget.room.id != auth.user!.id) {
                                    _agoraService.toggleMute(true);
                                    roomCollection
                                        .doc(widget.room.id)
                                        .collection("rooms")
                                        .doc(widget.room.roomID)
                                        .update({"isMicDisabled": true});
                                    roomProvider.setMicDisabled(true);
                                  } else if (snapshot.data!
                                              .data()!['isUnmutedSpeakers'] ==
                                          true &&
                                      widget.room.id != auth.user!.id) {
                                    _agoraService.toggleMute(false);
                                    roomCollection
                                        .doc(widget.room.id)
                                        .collection("rooms")
                                        .doc(widget.room.roomID)
                                        .update({"isMicDisabled": false});
                                    roomProvider.setMicDisabled(false);
                                  }
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                  );
                                } else {
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                  );
                                }
                              },
                            ),

                            // //limit up for host
                            // widget.room.id == user.id ?
                            // FutureBuilder(
                            //   future: roomCollection
                            //       .doc(widget.room.id)
                            //       .collection("rooms")
                            //       .doc(widget.room.roomID)
                            //       .get(),
                            //   builder: (BuildContext context,
                            //       AsyncSnapshot<
                            //           DocumentSnapshot<
                            //               Map<String, dynamic>>>
                            //       snapshot) {
                            //
                            //     DateTime scheduledOn = snapshot.data!.data()!['dateTime'].toDate();
                            //
                            //     if (snapshot.hasData) {
                            //       if (scheduledOn.toUtc().isAfter(DateTime.now().toUtc().subtract(Duration(minutes: 45)))) {
                            //         return Container(
                            //             padding: EdgeInsets.all(10),
                            //             decoration: BoxDecoration(
                            //                 color: theme.colorScheme.secondary,
                            //                 borderRadius: BorderRadius.all(
                            //                     Radius.circular(20))),
                            //             child: Row(
                            //               mainAxisAlignment:
                            //               MainAxisAlignment.spaceEvenly,
                            //               children: [
                            //                 Flexible(
                            //                   child: Text(
                            //                     "Room duration limit has exceeded.",
                            //                     style: TextStyle(
                            //                         fontFamily: "drawerbody",
                            //                         color: Colors.white),
                            //                   ),
                            //                 ),
                            //
                            //                 //delete room
                            //                 Padding(
                            //                     padding:
                            //                     EdgeInsets.only(left: 3),
                            //                     child: ElevatedButton(
                            //                         style: ButtonStyle(
                            //                           shape: MaterialStateProperty.all<
                            //                               RoundedRectangleBorder>(
                            //                               RoundedRectangleBorder(
                            //                                 borderRadius:
                            //                                 BorderRadius
                            //                                     .circular(15.0),
                            //                               )),
                            //                           backgroundColor:
                            //                           MaterialStateProperty
                            //                               .all<Color>(
                            //                               Colors.red),
                            //                         ),
                            //                         onPressed: () async {
                            //                           if (recording) {
                            //                             _recordingService
                            //                                 .stopRecording(
                            //                                 roomId: widget.room.roomID!,
                            //                                 userId: widget.room.id!,
                            //                                 type: RecordingType.ROOM)
                            //                                 .then((value) async {
                            //                               await leaveChannel(); // host leaves the channel
                            //                               // destroy(); // destroying the channel
                            //                               _recordingService.deleteRecordingInfo(
                            //                                   widget.room.roomID!, widget.room.id!);
                            //                             });
                            //                           }
                            //                           await roomCollection
                            //                               .doc(widget.room.id)
                            //                               .collection("rooms")
                            //                               .doc(widget.room.roomID)
                            //                               .collection('speakers')
                            //                               .doc(user.userName)
                            //                               .update({"isActiveInRoom": false});
                            //
                            //                           await roomCollection
                            //                               .doc(widget.room.id)
                            //                               .collection("rooms")
                            //                               .doc(widget.room.roomID)
                            //                               .update({"isActive": false});
                            //
                            //                           await FirebaseFirestore.instance
                            //                               .collection("feeds")
                            //                               .doc(widget.room.roomID)
                            //                               .delete();
                            //
                            //                           Navigator.of(context).pushReplacement(
                            //                             MaterialPageRoute(
                            //                               builder: (context) => UserDashboard(
                            //                                   tab: "all", selectDay: DateTime.now()),
                            //                             ),
                            //                           );
                            //                         },
                            //                         child: Text(
                            //                           "Delete Room",
                            //                           style: TextStyle(
                            //                               fontFamily:
                            //                               "drawerbody",
                            //                               fontSize: 12,
                            //                               color: Colors.white),
                            //                         ))
                            //                 ),
                            //
                            //                 //extend room
                            //                 Padding(
                            //                     padding:
                            //                     EdgeInsets.only(left: 3),
                            //                     child: ElevatedButton(
                            //                         style: ButtonStyle(
                            //                           shape: MaterialStateProperty.all<
                            //                               RoundedRectangleBorder>(
                            //                               RoundedRectangleBorder(
                            //                                 borderRadius:
                            //                                 BorderRadius
                            //                                     .circular(15.0),
                            //                               )),
                            //                           backgroundColor:
                            //                           MaterialStateProperty
                            //                               .all<Color>(
                            //                               Colors.red),
                            //                         ),
                            //                         onPressed: () async {
                            //
                            //                           await roomCollection
                            //                               .doc(widget.room.id)
                            //                               .collection("rooms")
                            //                               .doc(widget.room.roomID)
                            //                               .update({"duration": 90});
                            //
                            //                         },
                            //                         child: Text(
                            //                           "Extend Room",
                            //                           style: TextStyle(
                            //                               fontFamily:
                            //                               "drawerbody",
                            //                               fontSize: 12,
                            //                               color: Colors.white),
                            //                         )))
                            //               ],
                            //             ));
                            //       }
                            //       return Container(
                            //         width: 0.0,
                            //         height: 0.0,
                            //       );
                            //     } else {
                            //       return Container(
                            //         width: 0.0,
                            //         height: 0.0,
                            //       );
                            //     }
                            //   },
                            // ) :
                            // SizedBox.shrink(),
                            //
                            // //limit up for participants
                            // widget.room.id != user.id ?
                            // FutureBuilder(
                            //   future: roomCollection
                            //       .doc(widget.room.id)
                            //       .collection("rooms")
                            //       .doc(widget.room.roomID)
                            //       .get(),
                            //   builder: (BuildContext context,
                            //       AsyncSnapshot<
                            //           DocumentSnapshot<
                            //               Map<String, dynamic>>>
                            //       snapshot) {
                            //
                            //     DateTime scheduledOn = snapshot.data!.data()!['dateTime'].toDate();
                            //
                            //     if (snapshot.hasData) {
                            //       if (
                            //       snapshot.data!.data()!['duration'] == 45 &&
                            //           scheduledOn.toUtc().isAfter(DateTime.now().toUtc().subtract(Duration(minutes: 45))) &&
                            //           !snapshot.data!.data()!['isActive']
                            //       ) {
                            //         return Container(
                            //             padding: EdgeInsets.all(10),
                            //             decoration: BoxDecoration(
                            //                 color: theme.colorScheme.secondary,
                            //                 borderRadius: BorderRadius.all(
                            //                     Radius.circular(20))),
                            //             child: Row(
                            //               mainAxisAlignment:
                            //               MainAxisAlignment.spaceEvenly,
                            //               children: [
                            //                 Flexible(
                            //                   child: Text(
                            //                     "Room duration limit has been exceeded and deleted by the host. Please leave the channel",
                            //                     style: TextStyle(
                            //                         fontFamily: "drawerbody",
                            //                         fontSize: 12,
                            //                         color: Colors.white),
                            //                   ),
                            //                 ),
                            //
                            //                 //leave
                            //                 Padding(
                            //                     padding:
                            //                     EdgeInsets.only(left: 5),
                            //                     child: ElevatedButton(
                            //                         style: ButtonStyle(
                            //                           shape: MaterialStateProperty.all<
                            //                               RoundedRectangleBorder>(
                            //                               RoundedRectangleBorder(
                            //                                 borderRadius:
                            //                                 BorderRadius
                            //                                     .circular(15.0),
                            //                               )),
                            //                           backgroundColor:
                            //                           MaterialStateProperty
                            //                               .all<Color>(
                            //                               Colors.red),
                            //                         ),
                            //                         onPressed: () async {
                            //                           await leaveChannel();
                            //                           await roomCollection
                            //                               .doc(widget.room.id)
                            //                               .collection("rooms")
                            //                               .doc(widget
                            //                               .room.roomID)
                            //                               .collection(
                            //                               'speakers')
                            //                               .doc(user.userName)
                            //                               .update({
                            //                             "isActiveInRoom": false
                            //                           });
                            //                           Navigator.of(context)
                            //                               .pushReplacement(
                            //                             MaterialPageRoute(
                            //                               builder: (context) =>
                            //                                   UserDashboard(
                            //                                     tab: "all",
                            //                                     selectDay:
                            //                                     DateTime.now(),
                            //                                   ),
                            //                             ),
                            //                           );
                            //                         },
                            //                         child: Text(
                            //                           "Leave",
                            //                           style: TextStyle(
                            //                               fontFamily:
                            //                               "drawerbody",
                            //                               color: Colors.white),
                            //                         )))
                            //               ],
                            //             ));
                            //       }
                            //       return Container(
                            //         width: 0.0,
                            //         height: 0.0,
                            //       );
                            //     } else {
                            //       return Container(
                            //         width: 0.0,
                            //         height: 0.0,
                            //       );
                            //     }
                            //   },
                            // ) :
                            // SizedBox.shrink(),

                            //room has been deleted
                            FutureBuilder(
                              future: roomCollection
                                  .doc(widget.room.id)
                                  .collection("rooms")
                                  .doc(widget.room.roomID)
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.data()!['isActive'] ==
                                      false) {
                                    return Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Room has been deleted by the host.Please leave the channel",
                                                style: TextStyle(
                                                    fontFamily: "drawerbody",
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      )),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.red),
                                                    ),
                                                    onPressed: () async {
                                                      await leaveChannel();
                                                      await roomCollection
                                                          .doc(widget.room.id)
                                                          .collection("rooms")
                                                          .doc(widget
                                                              .room.roomID)
                                                          .collection(
                                                              'speakers')
                                                          .doc(user.userName)
                                                          .update({
                                                        "isActiveInRoom": false
                                                      });
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserDashboard(
                                                            tab: "all",
                                                            selectDay:
                                                                DateTime.now(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      "Leave",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "drawerbody",
                                                          color: Colors.white),
                                                    )))
                                          ],
                                        ));
                                  }
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                  );
                                } else {
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                  );
                                }
                              },
                            ),

                            //you have been kicked out
                            FutureBuilder(
                              future: roomCollection
                                  .doc(widget.room.id)
                                  .collection("rooms")
                                  .doc(widget.room.roomID)
                                  .collection("speakers")
                                  .doc(auth.user!.userName)
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.data()!['isKickedOut'] ==
                                      true) {
                                    return Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "The host has removed you from the room.",
                                                style: TextStyle(
                                                    fontFamily: "drawerbody",
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  )),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.red),
                                                ),
                                                onPressed: () async {
                                                  leaveChannel();
                                                  await roomCollection
                                                      .doc(widget.room.id)
                                                      .collection("rooms")
                                                      .doc(widget.room.roomID)
                                                      .collection('speakers')
                                                      .doc(user.userName)
                                                      .update({
                                                    "isActiveInRoom": false
                                                  });
                                                  Navigator.of(context).pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserDashboard(
                                                                  tab: "all",
                                                                  selectDay:
                                                                      DateTime
                                                                          .now())));
                                                },
                                                child: Text(
                                                  "Leave",
                                                  style: TextStyle(
                                                      fontFamily: "drawerbody",
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                          ],
                                        ));
                                  }
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                  );
                                } else {
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                  );
                                }
                              },
                            ),

                            //you have been muted
                            FutureBuilder(
                              future: roomCollection
                                  .doc(widget.room.id)
                                  .collection("rooms")
                                  .doc(widget.room.roomID)
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!
                                              .data()!['isMutedSpeakers'] ==
                                          true &&
                                      widget.room.id != auth.user!.id) {
                                    ToastMessege("You have been muted by host",
                                        context: context);
                                    // Fluttertoast.showToast(
                                    //     msg: "You have been muted by host",
                                    //     toastLength: Toast.LENGTH_SHORT,
                                    //     gravity: ToastGravity.CENTER,
                                    //     timeInSecForIosWeb: 6,
                                    //     backgroundColor: Colors.white,
                                    //     textColor: Colors.black,
                                    //     fontSize: 16.0);
                                    roomCollection
                                        .doc(widget.room.id)
                                        .collection("rooms")
                                        .doc(widget.room.roomID)
                                        .update({
                                      "isMutedSpeakers": false,
                                    });
                                  } else if (snapshot.data!
                                              .data()!['isUnmutedSpeakers'] ==
                                          true &&
                                      widget.room.id != auth.user!.id) {
                                    ToastMessege(
                                        "You have been un-muted by host",
                                        context: context);
                                    roomCollection
                                        .doc(widget.room.id)
                                        .collection("rooms")
                                        .doc(widget.room.roomID)
                                        .update({
                                      "isUnmutedSpeakers": false,
                                    });
                                  }
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                  );
                                } else {
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                  );
                                }
                              },
                            ),

                            ///thought box
                            Align(
                              alignment: Alignment(-1, 1),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 60,
                                child: Row(
                                  children: [
                                    // (user.id == widget.room.id)
                                    //     ? GestureDetector(
                                    //         onTap: () async {
                                    //           if (!recording) {
                                    //             setState(() {
                                    //               recording = true;
                                    //             });
                                    //             ToastMessege(
                                    //                 "Recording started");
                                    //             recordingTimer = Timer.periodic(
                                    //                 Duration(seconds: 1),
                                    //                 (Timer t) {
                                    //               if (mounted) {
                                    //                 setState(() {
                                    //                   recordingTime++;
                                    //                 });
                                    //               }
                                    //             });
                                    //             _recordingService
                                    //                 .startRecording(
                                    //               widget.room.roomID!,
                                    //               widget.room.roomID!,
                                    //               widget.room.id!,
                                    //             );
                                    //           } else {
                                    //             ToastMessege(
                                    //                 "Recording stopped");
                                    //             recordingTimer?.cancel();
                                    //             setState(() {
                                    //               recordingTime = 0;
                                    //               recording = false;
                                    //             });

                                    //             _recordingService
                                    //                 .stopRecording()
                                    //                 .then((value) {
                                    //               ToastMessege(
                                    //                   "Recording saved");
                                    //             });
                                    //           }
                                    //         },
                                    //         child: Container(
                                    //           width: 60,
                                    //           decoration: BoxDecoration(
                                    //               color: Colors.black,
                                    //               border: Border.all(
                                    //                   color: Colors.white30,
                                    //                   width: 1),
                                    //               borderRadius:
                                    //                   BorderRadius.circular(
                                    //                       15)),
                                    //           child: Center(
                                    //             child: Icon(
                                    //               CupertinoIcons.recordingtape,
                                    //               color: recording
                                    //                   ? GlobalColors
                                    //                       .signUpSignInButton
                                    //                   : Colors.white30,
                                    //               size: 30,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       )
                                    //     : SizedBox.shrink(),
                                    (user.id == widget.room.id)
                                        ? SizedBox(
                                            width: 5,
                                          )
                                        : SizedBox.shrink(),
                                    Expanded(
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width,
                                        // height: 60,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white30,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                onEditingComplete: () {
                                                  FocusScope.of(context)
                                                      .nextFocus();
                                                },
                                                controller: thoughtController,
                                                style: h2.copyWith(
                                                    color: theme.colorScheme
                                                        .inversePrimary),
                                                decoration: registerInputDecoration
                                                    .copyWith(
                                                        hintText:
                                                            'Share a thought',
                                                        fillColor: theme
                                                            .inputDecorationTheme
                                                            .fillColor),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {

                                                await FirebaseFirestore.instance
                                                    .collection("rooms")
                                                    .doc(widget.room.id)
                                                    .collection("rooms")
                                                    .doc(widget.room.roomID)
                                                .get()
                                                .then((value) async {
                                                  if(value['isActive'])
                                                  {
                                                    if (thoughtController
                                                        .text.isEmpty) {
                                                      ToastMessege(
                                                          "Please enter a thought!",
                                                          context: context);
                                                    } else {

                                                      await roomCollection
                                                          .doc(widget.room.id)
                                                          .collection("rooms")
                                                          .doc(widget.room.roomID)
                                                          .collection('speakers')
                                                          .doc(user.userName)
                                                          .get()
                                                          .then((value){
                                                        if (!value['isKickedOut']) {
                                                          if (thoughtController.text
                                                              .isEmpty) {
                                                            ToastMessege(
                                                                "Please enter a thought!",
                                                                context: context);
                                                          } else {
                                                            uploadThought(
                                                                user.id,
                                                                user.userProfile!
                                                                    .profileImage ??
                                                                    "",
                                                                user.name);
                                                          }
                                                        } else {
                                                          print("is kicked out");
                                                          ToastMessege(
                                                              "You have been removed from the room",
                                                              context: context);
                                                        }
                                                      });


                                                    }
                                                  } else {
                                                    ToastMessege(
                                                        "Room has been deleted",
                                                        context: context);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme.secondary,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(13),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    13))),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.send,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            newThought && !initialThought
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        thoughtNotification,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),

                            // // members count
                            // Align(
                            //   alignment: Alignment.topLeft,
                            //   child: Container(
                            //     width: 60,
                            //     decoration: BoxDecoration(
                            //         color: Colors.black26,
                            //         border:
                            //         Border.all(color: Colors.black, width: 0.5),
                            //         borderRadius: BorderRadius.circular(20)),
                            //     child: Row(
                            //       children: [
                            //         Padding(
                            //           padding: const EdgeInsets.all(5),
                            //           child: Icon(
                            //             Icons.mic,
                            //             color: Colors.white,
                            //             size: 20,
                            //           ),
                            //         ),
                            //         StreamBuilder(
                            //           stream: roomCollection
                            //               .doc(widget.room.id)
                            //               .collection("rooms")
                            //               .doc(widget.room.roomID)
                            //               .collection("speakers")
                            //               .where("isActiveInRoom", isEqualTo: true)
                            //               .snapshots(),
                            //           builder: (BuildContext context,
                            //               AsyncSnapshot<
                            //                   QuerySnapshot<
                            //                       Map<String, dynamic>>>
                            //               snapshot) {
                            //             if (snapshot.hasData) {
                            //               return Text(
                            //                 snapshot.data!.docs.length.toString(),
                            //                 style: TextStyle(color: theme.colorScheme.inversePrimary),
                            //               );
                            //             } else {
                            //               return Text("");
                            //             }
                            //           },
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      )),
                    ],
                  ),


                  //recording timer
                  // (recording && widget.room.id == user.id)
                  //     ? Align(
                  //         alignment: Alignment.topRight,
                  //         child: Container(
                  //           padding: const EdgeInsets.all(3),
                  //           height: 30,
                  //           width: 100,
                  //           decoration: BoxDecoration(
                  //             color: theme.colorScheme.secondary,
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               Text(
                  //                 Duration(seconds:
                  //                 // 3600 -
                  //                     recordingTime)
                  //                     .toString()
                  //                     .split('.')[0]
                  //                     .substring(2, 7),
                  //                 style: TextStyle(
                  //                     color: Colors.white, fontSize: 18),
                  //               ),
                  //               Container(
                  //                 margin: EdgeInsets.only(left: 10),
                  //                 child: Icon(
                  //                   Icons.fiber_manual_record,
                  //                   color: Colors.red,
                  //                   size: 20,
                  //                 ),
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox.shrink(),
                  // (isHostRecording && recording
                  //     // widget.room.id != user.id
                  // )
                  //     ? Align(
                  //         alignment: Alignment.topRight,
                  //         child: Container(
                  //           height: 20,
                  //           width: 20,
                  //           decoration: BoxDecoration(
                  //             color: Colors.transparent,
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               // Text(
                  //               //   "Rec",
                  //               //   style: TextStyle(
                  //               //       color: Colors.white, fontSize: 18),
                  //               // ),
                  //               Container(
                  //                 child: Icon(
                  //                   Icons.fiber_manual_record,
                  //                   color: Colors.red,
                  //                   size: 20,
                  //                 ),
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox.shrink(),
                ],
              ),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  //mic
                  FutureBuilder(
                    future: roomCollection
                        .doc(widget.room.id)
                        .collection("rooms")
                        .doc(widget.room.roomID)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.data()!['isMicDisabled'] == true &&
                            widget.room.id != auth.user!.id) {
                          return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: !isMicOn
                                        ? Icon(
                                            Icons.mic,
                                            size: 30,
                                            color: theme.colorScheme.secondary,
                                          )
                                        : Icon(
                                            Icons.mic_off,
                                            size: 30,
                                            color: theme.colorScheme.secondary,
                                          ),
                                  )));
                        }

                        return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white30, width: 1)),
                                child: FloatingActionButton(
                                  heroTag: null,
                                  backgroundColor: theme.colorScheme.surface,
                                  //     GlobalColors.signUpSignInButton,
                                  child: !isMicOn
                                      ? Icon(
                                          Icons.mic,
                                          size: 28,
                                          color: theme.colorScheme.secondary,
                                        )
                                      : Icon(
                                          Icons.mic_off,
                                          size: 28,
                                          color: theme.colorScheme.secondary,
                                        ),
                                  onPressed: () async {
                                    setState(() {
                                      isMicOn = !isMicOn;
                                    });
                                    roomCollection
                                        .doc(widget.room.id)
                                        .collection("rooms")
                                        .doc(widget.room.roomID)
                                        .collection("speakers")
                                        .doc(auth.user!.userName)
                                        .update({
                                      "isMicOn": isMicOn,
                                    });
                                    _agoraService.toggleMute(isMicOn);
                                    roomProvider.setIsMuted(isMicOn);
                                  },
                                )));
                      } else {
                        return Container(
                          width: 0.0,
                          height: 0.0,
                        );
                      }
                    },
                  ),

                  //refresh
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1)),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: theme.colorScheme.surface,
                        // GlobalColors.signUpSignInButton,
                        child: Icon(
                          Icons.refresh,
                          size: 28,
                          color: theme.colorScheme.secondary,
                        ),
                        onPressed: () async {
                          setState(() {
                            profileStream = roomCollection
                                .doc(widget.room.id)
                                .collection("rooms")
                                .doc(widget.room.roomID)
                                .collection('speakers')
                                .where("isActiveInRoom", isEqualTo: true)
                                .snapshots();
                          });
                        },
                      ),
                    ),
                  ),

                  //thoughts
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1)),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: theme.colorScheme.surface,
                        // GlobalColors.signUpSignInButton,
                        child: Icon(
                          FontAwesomeIcons.solidCommentDots,
                          size: 23,
                          color: theme.colorScheme.secondary,
                        ),
                        onPressed: () async {
                          showModalBottomSheet(
                              backgroundColor: theme.colorScheme.surface,
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: 500,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20, top: 20),
                                    child: Container(
                                      // height: 480,
                                      constraints: BoxConstraints(
                                        minHeight: 480,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 40,
                                            // color: Colors.green,
                                            child: Center(
                                              child: Text(
                                                "Thoughts",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: "drawerhead",
                                                    fontStyle: FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection("roomThoughts")
                                                    .doc(widget.room.roomID)
                                                    .collection("Thoughts")
                                                    .where("isActive",
                                                        isEqualTo: true)
                                                    .orderBy("dateTime",
                                                        descending: true)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return SizedBox.shrink();
                                                  }
                                                  return snapshot.data!.docs
                                                              .length ==
                                                          0
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: Text(
                                                            "No thoughts shared yet",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        )
                                                      : ListView.builder(
                                                          physics:
                                                              ClampingScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount: snapshot
                                                              .data!
                                                              .docs
                                                              .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            if (!snapshot
                                                                .hasData) {
                                                              return SizedBox
                                                                  .shrink();
                                                            }
                                                            String image =
                                                                snapshot.data!
                                                                    .docs[index]
                                                                    .get(
                                                                        "image");
                                                            String name = snapshot
                                                                .data!
                                                                .docs[index]
                                                                .get(
                                                                    "participantName");
                                                            String thought =
                                                                snapshot.data!
                                                                    .docs[index]
                                                                    .get(
                                                                        "thought");
                                                            String thoughtID =
                                                                snapshot.data!
                                                                    .docs[index]
                                                                    .get(
                                                                        "thoughtID");
                                                            String authouID =
                                                                snapshot.data!
                                                                    .docs[index]
                                                                    .get(
                                                                        "authorId");
                                                            String userID =
                                                                snapshot.data!
                                                                    .docs[index]
                                                                    .get(
                                                                        "userId");

                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10.0),
                                                              child: Container(
                                                                width: 80.w,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          vertical:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          //dp
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 5),
                                                                            child:
                                                                                RoundedImage(
                                                                              width: 25,
                                                                              height: 25,
                                                                              borderRadius: 15,
                                                                              url: image,
                                                                            ),
                                                                          ),

                                                                          //name
                                                                          Text(
                                                                            name,
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: "drawerhead"),
                                                                          ),
                                                                          Expanded(
                                                                              child: Container()),
                                                                          (authouID == user.id || userID == user.id)
                                                                              ? GestureDetector(
                                                                                  onTap: () async {
                                                                                    await FirebaseFirestore.instance.collection("roomThoughts").doc(widget.room.roomID).collection("Thoughts").doc(thoughtID).update({
                                                                                      "isActive": false
                                                                                    });
                                                                                  },
                                                                                  child: Icon(
                                                                                    Icons.delete,
                                                                                    color: Colors.grey,
                                                                                    size: 20,
                                                                                  ))
                                                                              : SizedBox.shrink(),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    //comment
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Text(
                                                                            thought,
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontStyle: FontStyle.italic,
                                                                                fontFamily: "drawerbody"),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  ),

                  //add
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1)),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: theme.colorScheme.surface,
                        // GlobalColors.signUpSignInButton,
                        child: Icon(
                          Icons.people,
                          size: 28,
                          color: theme.colorScheme.secondary,
                        ),
                        onPressed: () async {
                          showModalBottomSheet(
                            backgroundColor: theme.colorScheme.surface,
                            context: context,
                            builder: (context) {
                              return AddPeopleSheet(
                                  followers: followers, room: widget.room);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  //leave
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1)),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: theme.colorScheme.surface,
                        // GlobalColors.signUpSignInButton,
                        child: Icon(
                          Icons.logout,
                          size: 28,
                          color: theme.colorScheme.secondary,
                        ),
                        onPressed: () async {

                          // showDialog(
                          //   context: context,
                          //   barrierDismissible: false,
                          //   builder: (context) {
                          //     final size = MediaQuery.of(context).size;
                          //     return Container(
                          //       height: size.height,
                          //       width: size.width,
                          //       child: BackdropFilter(
                          //         filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          //         child: Align(
                          //           alignment: Alignment(0, -0.5),
                          //           child: Material(
                          //             color: Colors.transparent,
                          //             child: Container(
                          //               padding:
                          //               const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          //               width: size.width * 0.9,
                          //               constraints: BoxConstraints(
                          //                 maxHeight: 300,
                          //               ),
                          //               decoration: BoxDecoration(
                          //                 color: Colors.black,
                          //                 borderRadius: BorderRadius.circular(12),
                          //               ),
                          //               child: Column(
                          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                 children: [
                          //                   Text(
                          //                     'Enter your $field',
                          //                     style: TextStyle(
                          //                         color: Colors.white),
                          //                   ),
                          //                   SizedBox(
                          //                       height: (maxLine != null && maxLine > 4) ? 180 : 60,
                          //                       child:
                          //                       buildField("Enter link", _linkController, theme)),
                          //                   Row(
                          //                     mainAxisAlignment: MainAxisAlignment.end,
                          //                     children: [
                          //                       TextButton(
                          //                         onPressed: () {
                          //                           Navigator.of(context).pop([false]);
                          //                         },
                          //                         child: Text(
                          //                           "CANCEL",
                          //                           style: TextStyle(
                          //                               color: Colors.white),
                          //                         ),
                          //                       ),
                          //                       TextButton(
                          //                         onPressed: () {
                          //                           Navigator.of(context).pop([true, value]);
                          //                         },
                          //                         child: Text(
                          //                           "UPDATE",
                          //                           style: TextStyle(
                          //                               color: Colors.white),
                          //                         ),
                          //                       )
                          //                     ],
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // );

                          await leaveChannel();
                          roomProvider.clearRoom();
                          audioPlayerData.setMediaMeta(MediaMeta(),
                              shouldNotify: true);
                          final newUser =
                              await _roomService.leaveRoom(widget.room, user);
                          _roomService.sendLogs({
                            "roomId": widget.room.roomID,
                            "creatorId": widget.room.id,
                            "event": "room_left",
                            "logLevel": "INFO",
                            "roomUserId": user.userName
                          });
                          FostrRouter.replaceGoto(
                              context, Routes.userDashboard);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  createParticipantList(BuildContext context, ThemeData theme,
      List<Map<String, dynamic>> participants) async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      // Icon(Icons.close, size: 20, color: GlobalColors.signUpSignInButton,),
                      Text(" Remove participants",
                          style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 14,
                              fontStyle: FontStyle.italic))
                    ]),
                    participants.length > 0
                        ? ListView.builder(
                            shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                            itemCount: participants.length,
                            itemBuilder: (BuildContext context, int index) {
                              return participants[index]['rtcId'] != userID
                                  ? ListTile(
                                      title: Container(
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              participants[index]['name'],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: "drawerbody"),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                AgoraUserEvents(
                                                        cname: widget.room.title,
                                                        uid: participants[index]
                                                            ['rtcId'])
                                                    .kickOutParticipant();

                                                await roomCollection
                                                    .doc(widget.room.id)
                                                    .collection("rooms")
                                                    .doc(widget.room.roomID)
                                                    .collection('speakers')
                                                    .doc(participants[index]
                                                        ['userName'])
                                                    .update({
                                                  "isActiveInRoom": false,
                                                  "isKickedOut": true
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: Icon(
                                                Icons.close,
                                                size: 20,
                                                color:
                                                    theme.colorScheme.secondary,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink();
                            })
                        : Center(
                            child: Text(
                              "No participants present",
                              style: TextStyle(
                                  color: theme.colorScheme.inversePrimary,
                                  fontFamily: "drawerbody"),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> buildProfiles(ThemeData theme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: profileStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.length == 0) {
            return Align(
              child: Text(
                "No speakers yet!",
                style: TextStyle(fontFamily: "drawerbody"),
              ),
              alignment: Alignment.topCenter,
            );
          } else if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> map =
                snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.only(top: 25),
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                color: theme.colorScheme.secondary,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: map.length,
                  padding: EdgeInsets.all(2.0),
                  itemBuilder: (BuildContext context, int index) {
                    int? vol() {
                      if (info[map[index].data()["rtcId"]] != null) {
                        return info[map[index].data()["rtcId"]];
                      }
                      return 0;
                    }

                    return Profile(
                        user: User.fromJson(map[index].data()),
                        size: 60,
                        isMute: map[index].data()["isMicOn"],
                        volume: vol(),
                        myVolume: info[0] ?? 0);
                  },
                ),
              ),
            );
          } else {
            return AppLoading(
              height: 70,
              width: 70,
            );
            // CircularProgressIndicator(color:GlobalColors.signUpSignInButton);
          }
        });
  }

  Future<bool?> confirmDialog(BuildContext context, TextStyle h2) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Container(
          height: size.height,
          width: size.width,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Align(
              alignment: Alignment(0, 0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: size.width * 0.9,
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cannot delete the room with speakers inside the room.',
                        style: h2.copyWith(
                          fontSize: 15.sp,
                          fontFamily: "drawerbody",
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  GlobalColors.signUpSignInButton),
                            ),
                            onPressed: () {
                              WidgetsBinding.instance?.addPostFrameCallback((_) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => UserDashboard(
                                            tab: "all",
                                            selectDay: DateTime.now())));
                              });
                            },
                            child: Text(
                              "Ok",
                              style: h2.copyWith(
                                fontSize: 17.sp,
                                fontFamily: "drawerbody",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddPeopleSheet extends StatefulWidget {
  final List<dynamic> followers;
  final Room room;
  const AddPeopleSheet({Key? key, required this.followers, required this.room})
      : super(key: key);

  @override
  _AddPeopleSheetState createState() => _AddPeopleSheetState();
}

class _AddPeopleSheetState extends State<AddPeopleSheet> with FostrTheme {
  final InAppNotificationService _inAppNotificationService =
      GetIt.I<InAppNotificationService>();

  List<bool> invited = [];

  @override
  void initState() {
    super.initState();
    invited = List.generate(widget.followers.length, (index) => false);
  }

  TextEditingController _controller = TextEditingController();

  String query = "";

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Container(
          constraints: BoxConstraints(
            minHeight: 480,
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                // color: Colors.green,
                child: Center(
                  child: Text(
                    "Add people",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "drawerhead",
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _controller,
                        validator: (va) {
                          if (va!.isEmpty) {
                            return "Search can't be empty";
                          }
                          return null;
                        },
                        style: h2.copyWith(fontSize: 14.sp),
                        onEditingComplete: () {
                          setState(() {
                            query = _controller.text.toLowerCase();
                          });
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (value) {},
                        decoration: registerInputDecoration.copyWith(
                            hintText: 'Search for your followers',
                            hintStyle: h2.copyWith(color: Colors.black38),
                            fillColor: Colors.white12),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() {
                          query = "";
                          _controller.clear();
                        });
                      }
                    },
                    child: SizedBox(
                      width: 40,
                      child: Icon(Icons.clear, color: Colors.black38, size: 30),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: widget.followers.length == 0
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "You nave no followers",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.followers.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(widget.followers[index])
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox.shrink();
                                }
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return SizedBox.shrink();

                                  default:
                                    final doc = snapshot.data;
                                    if (query.isEmpty ||
                                        doc
                                            ?.data()?["name"]
                                            .toLowerCase()
                                            .contains(query) ||
                                        doc
                                            ?.data()?["userName"]
                                            .toLowerCase()
                                            .contains(query)) {
                                      return Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        constraints:
                                            BoxConstraints(minHeight: 80),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                40,
                                        decoration: BoxDecoration(
                                            color: Color(0xffffffff),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: (snapshot.data![
                                                                "userProfile"] !=
                                                            null)
                                                        ? (snapshot.data![
                                                                        "userProfile"]
                                                                    [
                                                                    "profileImage"] !=
                                                                null)
                                                            ? FosterImageProvider(
                                                                imageUrl: snapshot
                                                                            .data![
                                                                        "userProfile"]
                                                                    [
                                                                    "profileImage"]
                                                                // .toString()
                                                                // .replaceAll(
                                                                //     "https://firebasestorage.googleapis.com",
                                                                //     "https://ik.imagekit.io/fostrreads")
                                                                ,
                                                              )
                                                            : Image.asset(IMAGES +
                                                                    "profile.png")
                                                                .image
                                                        : Image.asset(IMAGES +
                                                                "profile.png")
                                                            .image),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  (snapshot.data!
                                                          .get("name")
                                                          .toString()
                                                          .isNotEmpty)
                                                      ? Text(
                                                          snapshot.data!
                                                              .get("name"),
                                                          style: h1.copyWith(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : SizedBox.shrink(),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "@" +
                                                        snapshot.data!
                                                            .get("userName"),
                                                    style: h1.copyWith(
                                                        fontSize: 12),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () async {
                                                if (!invited[index]) {
                                                  final doc =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("users")
                                                          .doc(widget
                                                              .followers[index])
                                                          .get();
                                                  final user = User.fromJson(
                                                      doc.data()!);

                                                  List<String> deviceTokens =
                                                      [];

                                                  if (user.deviceToken !=
                                                      null) {
                                                    deviceTokens
                                                        .add(user.deviceToken!);
                                                  }
                                                  if (user.notificationToken !=
                                                          null &&
                                                      deviceTokens.isEmpty) {
                                                    deviceTokens.add(user
                                                        .notificationToken!);
                                                  }

                                                  NotificationPayload payload =
                                                      NotificationPayload(
                                                          type: NotificationType
                                                              .Invite,
                                                          tokens: deviceTokens,
                                                          data: {
                                                        "recipientUserId":
                                                            user.id,
                                                        "recipientUserName":
                                                            user.userName,
                                                        "senderUserId":
                                                            auth.user!.id,
                                                        "senderUserName":
                                                            auth.user!.userName,
                                                        "title":
                                                            "A new door has opened for you! ${auth.user?.userName} has invited you to ${widget.room.title}",
                                                        "body":
                                                            "You have been invited to join a room",
                                                        "payload": {
                                                          "roomId": widget
                                                              .room.roomID,
                                                          "creatorId":
                                                              widget.room.id,
                                                        }
                                                      });
                                                  _inAppNotificationService
                                                      .sendNotification(payload)
                                                      .then((value) {
                                                    // Future.delayed(Duration(milliseconds: 500)).then((value){

                                                    // });
                                                  });
                                                  setState(() {
                                                    invited[index] = true;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                  invited[index]
                                                      ? Icons.check
                                                      : Icons.add,
                                                  size: 30,
                                                  color: invited[index]
                                                      ? Colors.green
                                                      : theme.colorScheme
                                                          .secondary),
                                            )
                                          ],
                                        ),
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                }
                              });
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
