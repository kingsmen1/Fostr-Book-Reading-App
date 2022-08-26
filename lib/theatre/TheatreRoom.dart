import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/core/functions.dart';
import 'package:fostr/core/settings.dart';
import 'package:fostr/enums/role_enum.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/rooms/TheatreInfo.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/RoomProvider.dart';
import 'package:fostr/reviews/EnterReviewDetails.dart';
import 'package:fostr/services/AgoraService.dart';
import 'package:fostr/services/AgoraUserEvents.dart';
import 'package:fostr/services/RecordingService.dart';
import 'package:fostr/services/RemoteConfigService.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:fostr/theatre/AllParticipantsList.dart';
import 'package:fostr/theatre/ParticipantsList.dart';
import 'package:fostr/theatre/RequestToSpeakList.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/theatre/TheatreProfile.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:time_elapsed/time_elapsed.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../core/constants.dart';
import '../router/router.dart';
import '../router/routes.dart';
import '../services/InAppNotificationService.dart';
import '../utils/dynamic_links.dart';
import '../widgets/AppLoading.dart';

class TheatreRoom extends StatefulWidget {
  final Role role;
  final Theatre theatre;
  final bool shouldUseNewToken;
  const TheatreRoom(
      {required this.role,
      required this.theatre,
      this.shouldUseNewToken = true});

  @override
  _TheatreRoomState createState() => _TheatreRoomState();
}

class _TheatreRoomState extends State<TheatreRoom>
    with FostrTheme, WidgetsBindingObserver {
  final RecordingService _recordingService = GetIt.I<RecordingService>();
  final RemoteConfigService _remoteConfigService =
      GetIt.I.get<RemoteConfigService>();
  final AgoraService _agoraService = GetIt.I.get<AgoraService>();
  final TheatreService _theatreService = GetIt.I.get<TheatreService>();
  TextEditingController thoughtController = TextEditingController();
  bool recording = false;
  bool isHostRecording = false;
  Timer? recordingTimer;
  int recordingTime = 0;
  Timer? elapsedTimer;

  String? adLink;
  String? adUrl;

  Map<int, int> info = {0: 10};
  List followers = [];
  int? activeUserID;
  int userID = 0;
  String username = '';
  String userAccountId = '';
  String rtmToken = "";
  bool muted = true, isMicOn = true;
  bool isMuted = false;
  bool isActive = true;
  bool isRequested = false, notification = false, isSpeaker = false;
  int counter = 0;

  bool stopRecording = false;

  Duration? elapsedDuration;

  bool initialThought = true;
  String thoughtNotification = "";
  bool newThought = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? profileStream;

  AgoraRtmClient? _client;

  final RoomService _roomService = GetIt.I<RoomService>();

  getNotification() async {
    var doc = await roomCollection
        .doc(widget.theatre.createdBy)
        .collection("amphitheatre")
        .doc(widget.theatre.theatreId)
        .collection("users")
        .where("rtcId", isEqualTo: userID)
        .get();
    if (doc.docs.length > 0) {
      setState(() {
        notification = true;
      });
    }
  }

  Future<void> leaveChannel() async {
    await _agoraService.leaveChannel();
  }

  // Future<void> destroy() async {
  //   await _agoraService.destroyInstance();
  // }

  void getFollowers(User user) async {
    followers = user.followers ?? [];
  }

  @override
  void initState() {
    super.initState();

    print("theatre room");
    print(widget.theatre.token);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    WidgetsBinding.instance?.addObserver(this);

    token = widget.theatre.token!;
    channelName = widget.theatre.theatreId!;
    username = auth.user!.userName;
    userAccountId = auth.user!.id;

    profileStream = roomCollection
        .doc(widget.theatre.createdBy)
        .collection("amphitheatre")
        .doc(widget.theatre.theatreId)
        .collection('users')
        .where("isActiveInRoom", isEqualTo: true)
        .orderBy("role", descending: false)
        .snapshots();

    roomCollection
        .doc(widget.theatre.createdBy)
        .collection("amphitheatre")
        .doc(widget.theatre.theatreId)
        .collection('users')
        .get()
    .then((value){
      value.docs.forEach((element) async {
        if(element.id == auth.user!.userName){
          print("-------------------");
          print("${element.id} available");
          print("-------------------");
          await roomCollection
              .doc(widget.theatre.createdBy)
              .collection("amphitheatre")
              .doc(widget.theatre.theatreId)
              .collection("users")
              .doc(auth.user!.userName)
              .update({"isActiveInRoom": true});
        }
      });
    });


    getNotification();
    initialize(auth.user!);
    FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.theatre.createdBy)
        .collection("amphitheatre")
        .doc(widget.theatre.theatreId)
        .snapshots()
        .listen((event) {
      if (mounted) {
        if (adLink == null || adUrl == null) {
          setState(() {
            adLink = event.data()?["adLink"];
            adUrl = event.data()?["adUrl"];
          });
        }
        bool roomRecording = event.data()?["recording"] ?? false;
        if (widget.theatre.createdBy != auth.user!.id &&
            roomRecording != recording) {
          if (roomRecording) {
            ToastMessege("Recording started", context: context);
          } else {
            ToastMessege("Recording stopped", context: context);
          }
        }
        if (widget.theatre.createdBy == auth.user!.id &&
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
                //   ToastMessege(
                //     "Recording stopped",
                //     context: context,
                //   );
                //   recordingTimer?.cancel();
                //   setState(() {
                //     recordingTime = 0;
                //     recording = false;
                //   });
                //
                //   _recordingService
                //       .stopRecording(
                //     roomId: widget.theatre.theatreId!,
                //     userId: widget.theatre.createdBy!,
                //     type: RecordingType.AMPHITHEATRE,
                //   )
                //       .then((value) {
                //     if (mounted) {
                //       ToastMessege(
                //         "Recording saved",
                //         context: context,
                //       );
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
        .doc(widget.theatre.theatreId)
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


    DateTime dob = widget.theatre.scheduleOn!;
    elapsedDuration =  DateTime.now().difference(dob);
    elapsedTimer = Timer.periodic(Duration(seconds: 1), (Timer t){
      setState(() {
        elapsedDuration =  DateTime.now().difference(dob);
      });
    }
    );


  }

  void setClientRole(role) {
    _agoraService.engine?.setClientRole(role);
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    elapsedTimer?.cancel();
    // if (recording) {
    //   _recordingService.stopRecording(
    //     roomId: widget.theatre.theatreId!,
    //     userId: widget.theatre.createdBy!,
    //     roomTitle: widget.theatre.title!.toLowerCase().trim(),
    //     type: RecordingType.AMPHITHEATRE,
    //   );
    // }
    super.dispose();
  }

  void uploadThought(
      String userid, String image, String participantName) async {
    await FirebaseFirestore.instance
        .collection("roomThoughts")
        .doc(widget.theatre.theatreId)
        .collection("Thoughts")
        .doc(
            "${userid}_${DateTime.now().toUtc().millisecondsSinceEpoch.toString()}")
        .set({
      "userId": userid,
      "image": image,
      "authorId": widget.theatre.createdBy,
      "authorName": widget.theatre.title,
      "participantName": participantName,
      "roomId": widget.theatre.theatreId,
      "thought": thoughtController.text,
      "thoughtID":
          "${userid}_${DateTime.now().toUtc().millisecondsSinceEpoch.toString()}",
      "isActive": true,
      "dateTime": DateTime.now().toUtc()
    },SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection("roomThoughts")
        .doc(widget.theatre.theatreId)
        .set({"messege": "$participantName shared a thought"},SetOptions(merge: true)).then((value) {
      FocusManager.instance.primaryFocus?.unfocus();
      thoughtController.clear();
      ToastMessege("Thought shared!", context: context);
    });
  }

  ///create rtm client
  void _createClient() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    var client = await _agoraService.getRtmClient(channelName, auth.user!.id,
        auth.user!.userName, widget.shouldUseNewToken);

    if (mounted) {
      setState(() {
        _client = client;
      });
    }
    print("-----------------");
    print(_client != null);
    print("-----------------");
    client?.onMessageReceived = (AgoraRtmMessage message, String peerId) async {
      print("heeeeee----------------");
      if (message.text == "makeSpeaker") {
        setClientRole(ClientRole.Broadcaster);

        roomProvider.setIsMuted(false, shouldNotify: true);
        print("object");
        roomCollection
            .doc(widget.theatre.createdBy)
            .collection("amphitheatre")
            .doc(widget.theatre.theatreId)
            .collection("users")
            .doc(auth.user!.userName)
            .update({
          "isMicOn": false,
        });
        print("done 2");
        _roomService.sendLogs({
          "roomId": widget.theatre.theatreId,
          "creatorId": widget.theatre.createdBy,
          "event": "user is made speaker by the host",
          "logLevel": "INFO",
          "roomUserId": username
        });
        if (mounted) {
          ToastMessege("You have been made speaker", context: context);
        }
      } else if (message.text == "makeParticipant") {
        setClientRole(ClientRole.Audience);
        roomProvider.setIsMuted(true, shouldNotify: true);
        print("object");
        roomCollection
            .doc(widget.theatre.createdBy)
            .collection("amphitheatre")
            .doc(widget.theatre.theatreId)
            .collection("users")
            .doc(auth.user!.userName)
            .update({
          "isMicOn": true,
        });
        _theatreService.updateUserProfile(
            widget.theatre, auth.user!, {"requestToSpeak": false});
        _roomService.sendLogs({
          "roomId": widget.theatre.theatreId,
          "creatorId": widget.theatre.createdBy,
          "event": "user is made participant by the host",
          "logLevel": "INFO",
          "roomUserId": username
        });
        // if (mounted) {
          ToastMessege("You have been muted by host", context: context);
        // }
      }
    };
    client?.onConnectionStateChanged = (int state, int reason) {
      print('Connection state changed: ' +
          state.toString() +
          ', reason: ' +
          reason.toString());
      if (state == 5) {
        _client?.logout();
        print('Logout.');
        if (mounted) {
          setState(() {});
        }
      }
    };
  }

  Future<void> initialize(User user) async {
    _addAgoraEventHandlers(user);
    await _agoraService.setChannelProfile(ChannelProfile.LiveBroadcasting);

    _createClient();
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
                    roomId: widget.theatre.theatreId!,
                    userId: widget.theatre.createdBy!,
                    roomTitle: widget.theatre.title!.toLowerCase().trim(),
                    type: RecordingType.AMPHITHEATRE,
                  );
                }
              }
            });
          }

        },
        activeSpeaker: (id) {
          if (mounted) {
            setState(() {
              activeUserID = id;
            });
          }
        },
        error: (code) {},
        joinChannelSuccess: (channel, uid, elapsed) {
          if (mounted) {
            setState(() {
              userID = uid;
            });
          }
          roomCollection
              .doc(widget.theatre.createdBy)
              .collection("amphitheatre")
              .doc(widget.theatre.theatreId)
              .collection("users")
              .doc(user.userName)
              .update({
            "rtcId": uid,
          });
          if (user.id != widget.theatre.createdBy) {
            AgoraUserEvents(cname: widget.theatre.title, uid: uid)
                .muteParticipant(uid);
          }

          _roomService.sendLogs({
            "roomId": widget.theatre.theatreId,
            "creatorId": widget.theatre.createdBy,
            "event": "theatre_join",
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
            await leaveChannel();
            var res = await roomCollection
                .doc(widget.theatre.createdBy)
                .collection("amphitheatre")
                .doc(widget.theatre.theatreId)
                .collection("users")
                .doc(user.userName)
                .update({"isActiveInRoom": false}).then((value) => print("---------line 491--------"));

            _roomService.sendLogs({
              "roomId": widget.theatre.theatreId,
              "creatorId": widget.theatre.createdBy,
              "event": "theatre_left due to connection interrupted",
              "logLevel": "INFO",
              "roomUserName": user.userName,
              "roomUserId": user.id,
              "reason": reason.toString(),
              "state": state.toString()
            });
          } else if (reason == ConnectionChangedReason.LeaveChannel &&
              state == ConnectionStateType.Disconnected) {
            // Navigator.of(context).pop();
            await leaveChannel();
            var res = await roomCollection
                .doc(widget.theatre.createdBy)
                .collection("amphitheatre")
                .doc(widget.theatre.theatreId)
                .collection("users")
                .doc(user.userName)
                .update({"isActiveInRoom": false}).then((value) => print("---------line 513--------"));

            _roomService.sendLogs({
              "roomId": widget.theatre.theatreId,
              "creatorId": widget.theatre.createdBy,
              "event": "theatre_left due to connection leave channel",
              "logLevel": "INFO",
              "roomUserName": user.userName,
              "roomUserId": user.id,
              "reason": reason.toString(),
              "state": state.toString()
            });
          }
        },
        connectionLost: () {
          print("Connection lost");
        },
        userJoined: (uid, elapsed) {
          print('userJoined: $uid');
        },
        userOffline: (id, reason) async {
          log(id.toString() + "---" + reason.toString());

          if (reason == UserOfflineReason.Dropped) {
            var res = await roomCollection
                .doc(widget.theatre.createdBy)
                .collection("amphitheatre")
                .doc(widget.theatre.theatreId)
                .collection("users")
                .where("rtcId", isEqualTo: id)
                .get();
            res.docs.forEach((doc) {
              doc.reference.update({"isActiveInRoom": false}).then((value) => print("---------line 545--------"));
            });

            _roomService.sendLogs({
              "roomId": widget.theatre.theatreId,
              "creatorId": widget.theatre.createdBy,
              "event": "user dropped by agora",
              "logLevel": "INFO",
              "roomUserId": res.docs.first.data()["id"],
              "reason": reason.toString(),
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    final user = auth.user!;
    final theme = Theme.of(context);
    isMicOn = roomProvider.isMuted ?? true;
    getFollowers(user);
    print("user:");
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () async {
                // await leaveChannel();
                // await _theatreService.leaveRoom(widget.theatre, user);

                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) =>
                //         UserDashboard(tab: "all", selectDay: DateTime.now())));
                Navigator.of(context).pop();
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
                      .doc(widget.theatre.createdBy)
                      .collection("amphitheatre")
                      .doc(widget.theatre.theatreId)
                      .collection("users")
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
          //   // widget.theatre.title ?? "Hallway",
          //   style: TextStyle(fontFamily: "drawerhead", fontSize: 20),
          //   overflow: TextOverflow.ellipsis,
          //   // style: h1,
          // ),
          actions: [

            isHostRecording && recording
        ? Container(
          height: 20,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.transparent,
            // theme.colorScheme.secondary,
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

            //bell icon
            user.id == widget.theatre.createdBy
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      children: <Widget>[
                        IconButton(
                            onPressed: () async {
                              var rawParticipants = await roomCollection
                                  .doc(widget.theatre.createdBy)
                                  .collection("amphitheatre")
                                  .doc(widget.theatre.theatreId)
                                  .collection('users')
                                  .where("isActiveInRoom", isEqualTo: true)
                                  .where("requestToSpeak", isEqualTo: true)
                                  .get();

                              var participants = rawParticipants.docs
                                  .map((e) => e.data())
                                  .toList();

                              List participantNames = [];
                              print(participants.length);
                              participants.forEach((element) {
                                setState(() {
                                  participantNames
                                      .add(element['name'].toString());
                                });
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RequestList(
                                        participants: participants,
                                        userID: userID,
                                        theatre: widget.theatre)),
                              );
                            },
                            icon: Icon(
                              Icons.notifications,
                            )),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: roomCollection
                                .doc(widget.theatre.createdBy)
                                .collection("amphitheatre")
                                .doc(widget.theatre.theatreId)
                                .collection('users')
                                .where("requestToSpeak", isEqualTo: true)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.length == 0) {
                                return SizedBox.shrink();
                              } else if (snapshot.hasData) {
                                return Positioned(
                                  right: 0,
                                  child: new Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: new BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                    child: new Text(
                                      '!',
                                      style: new TextStyle(
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            }),
                      ],
                    ),
                  )
                : SizedBox.shrink(),

            user.id == widget.theatre.createdBy
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
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
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
                                'Delete Theatre',
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
                            .doc(widget.theatre.createdBy)
                            .collection("amphitheatre")
                            .doc(widget.theatre.theatreId)
                            .collection('users') // participants
                            .get();

                        var participants =
                            rawParticipants.docs.map((e) => e.data()).toList();

                        List participantRtcIDs = [];

                        var doc = await FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.theatre.createdBy)
                            .get();
                        String theatreCreator = doc.data()!["name"];

                        participants.forEach((element) {
                          setState(() {
                            if (element['name'] != theatreCreator) {
                              participantRtcIDs.add(element['rtcId']);
                            }
                          });
                        });
                        if (isMuted == false) {
                          AgoraUserEvents(cname: widget.theatre.title, uid: 123)
                              .muteAllParticipants(participantRtcIDs);
                          setState(() {
                            isMuted = true;
                          });
                          await roomCollection
                              .doc(widget.theatre.createdBy)
                              .collection("amphitheatre")
                              .doc(widget.theatre.theatreId)
                              .update({
                            "isMutedSpeakers": true,
                            "isUnmutedSpeakers": false
                          });
                        } else {
                          AgoraUserEvents(cname: widget.theatre.title, uid: 123)
                              .unMuteAllParticipants(participantRtcIDs);
                          setState(() {
                            isMuted = false;
                          });
                          await roomCollection
                              .doc(widget.theatre.createdBy)
                              .collection("amphitheatre")
                              .doc(widget.theatre.theatreId)
                              .update({
                            "isMutedSpeakers": false,
                            "isUnmutedSpeakers": true
                          });
                        }
                      }

                      //show participants
                      if (value == 'participants') {
                        var rawParticipants = await roomCollection
                            .doc(widget.theatre.createdBy)
                            .collection("amphitheatre")
                            .doc(widget.theatre.theatreId)
                            .collection('users')
                            .where("isActiveInRoom",
                                isEqualTo: true) // participants
                            .get();

                        var participants =
                            rawParticipants.docs.map((e) => e.data())
                                .where((element)=> element['id'] != widget.theatre.createdBy)
                                .toList();

                        List participantNames = [];
                        print(participants.length);
                        participants.forEach((element) {
                          setState(() {
                              participantNames.add(element['name'].toString());
                          });
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TheatreParticipantsList(
                              participants: participants,
                              userID: userID,
                              theatre: widget.theatre,
                            ),
                          ),
                        );
                      }

                      //delete room
                      if (value == 'deleteRoom') {
                        if (recording) {
                          _recordingService
                              .stopRecording(
                                  roomId: widget.theatre.theatreId!,
                                  userId: widget.theatre.createdBy!,
                              roomTitle: widget.theatre.title!.toLowerCase().trim(),
                                  type: RecordingType.AMPHITHEATRE)
                              .then((value) async {
                            leaveChannel(); // host leaves the channel
                            // destroy(); // destroying the channel
                          });
                        }

                        await roomCollection
                            .doc(widget.theatre.createdBy)
                            .collection("amphitheatre")
                            .doc(widget.theatre.theatreId)
                            .collection('users')
                            .doc(user.userName)
                            .update({"isActiveInRoom": false}).then((value) => print("---------line 946--------"));

                        await roomCollection
                            .doc(widget.theatre.createdBy)
                            .collection("amphitheatre")
                            .doc(widget.theatre.theatreId)
                            .update({"isActive": false});

                        await FirebaseFirestore.instance
                            .collection("feeds")
                            .doc(widget.theatre.theatreId)
                            .delete();

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => UserDashboard(
                                tab: "all", selectDay: DateTime.now())));
                      }

                      //share
                      if(value == 'share') {
                        Share.share(await DynamicLinksApi.inviteOnlyTheatreLink(
                          widget.theatre.theatreId!,
                          widget.theatre.createdBy!,
                          roomName: widget.theatre.title!,
                          imageUrl: widget.theatre.imageUrl,
                          creatorName: "",
                        ));
                      }

                      //recording
                      if (value == "recording") {
                        if (!recording) {
                          setState(() {
                            recording = true;
                          });
                          ToastMessege(
                            "Recording started",
                            context: context,
                          );
                          recordingTimer =
                              Timer.periodic(Duration(seconds: 1), (Timer t) {
                            if (mounted) {
                              setState(() {

                                // if(recordingTime < 3600)
                                  recordingTime++;
                              });
                            }
                          });
                          _recordingService.startRecording(
                            widget.theatre.theatreId!,
                            widget.theatre.theatreId!,
                            widget.theatre.createdBy!,
                            type: RecordingType.AMPHITHEATRE,
                          );
                        } else {
                          ToastMessege(
                            "Recording stopped",
                            context: context,
                          );
                          recordingTimer?.cancel();
                          setState(() {
                            recordingTime = 0;
                            recording = false;
                          });

                          _recordingService
                              .stopRecording(
                            roomId: widget.theatre.theatreId!,
                            userId: widget.theatre.createdBy!,
                            roomTitle: widget.theatre.title!.toLowerCase().trim(),
                            type: RecordingType.AMPHITHEATRE,
                          )
                              .then((value) {
                            if (mounted) {
                              ToastMessege(
                                "Recording saved",
                                context: context,
                              );
                            }
                          });
                        }
                      }
                    })
                :
            //for participants
            GestureDetector(
                onTap: () async {
                  Share.share(await DynamicLinksApi.inviteOnlyTheatreLink(
                    widget.theatre.theatreId!,
                    widget.theatre.createdBy!,
                    roomName: widget.theatre.title!,
                    imageUrl: widget.theatre.imageUrl,
                    creatorName: "",
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

            // user.id != widget.theatre.createdBy
            //     ? PopupMenuButton(
            //         icon: Icon(Icons.more_vert),
            //         color: theme.colorScheme.primary,
            //         shape: RoundedRectangleBorder(
            //             side: BorderSide(
            //                 color: theme.colorScheme.secondary, width: 1),
            //             borderRadius: BorderRadius.circular(10)),
            //         itemBuilder: (context) {
            //           return [
            //             PopupMenuItem(
            //               child: Text("Participants"),
            //               value: "Participants",
            //             ),
            //           ];
            //         },
            //         onSelected: (value) {
            //           if (value == "Participants") {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => AllTheatreParticipantsList(
            //                   theatre: widget.theatre,
            //                 ),
            //               ),
            //             );
            //           }
            //         },
            //       )
            //     : SizedBox.shrink(),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   widget.theatre.title ?? "Hallway",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(fontFamily: "drawerhead", fontSize: 20),
              //   overflow: TextOverflow.ellipsis,
              //   // style: h1,
              // ),
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
                    Column(
                      children: [

                        //advertisement
                        (adLink != null && adLink!.isNotEmpty)
                            ? GestureDetector(
                                onTap: () {
                                  if (adUrl != null && adUrl!.isNotEmpty) {
                                    if (adUrl!.contains("https://")) {
                                      url_launcher.launchUrl(Uri.parse(adUrl!),
                                          mode: url_launcher
                                              .LaunchMode.externalApplication);
                                    } else {
                                      url_launcher.launchUrl(
                                          Uri.parse("https://$adUrl"),
                                          mode: url_launcher
                                              .LaunchMode.externalApplication);
                                    }
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  height: 124,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: FosterImageProvider(
                                          imageUrl: adLink!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),

                        // info and timer
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              //title box
                              Container(
                                height: 60,
                                width: 230,
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
                                            width: 180,
                                            child: Text(
                                              widget.theatre.title ?? "Hallway",
                                              style: TextStyle(fontFamily: "drawerhead", fontSize: 18),
                                              overflow: TextOverflow.ellipsis,
                                              // style: h1,
                                            ),
                                          ),

                                          // // members count
                                          // StreamBuilder(
                                          //     stream: roomCollection
                                          //         .doc(widget.theatre.createdBy)
                                          //         .collection("amphitheatre")
                                          //         .doc(widget.theatre.theatreId)
                                          //         .collection("users")
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
                                          //             width: 180,
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
                                        .doc(widget.theatre.createdBy)
                                        .collection("amphitheatre")
                                        .doc(widget.theatre.theatreId)
                                        .get()
                                        .then((value){
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) =>
                                                  TheatreInfo(data: value.data()!, insideTheatre: true,
                                                  )));
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
                        Text('Pull to refresh',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontStyle: FontStyle.italic
                        ),),
                        Expanded(
                          child: StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                              stream: profileStream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data!.docs.length == 0) {
                                  return Align(
                                    child: Text(
                                      "No speakers yet!",
                                      style:
                                          TextStyle(fontFamily: "drawerbody"),
                                    ),
                                    alignment: Alignment.topCenter,
                                  );
                                } else if (snapshot.hasData) {
                                  List<
                                          QueryDocumentSnapshot<
                                              Map<String, dynamic>>> map =
                                      snapshot.data!.docs;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 25),
                                    child: RefreshIndicator(
                                      onRefresh: () async {
                                        // print('refreshed');
                                        setState(() {});
                                      },
                                      color: theme.colorScheme.secondary,
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3),
                                        itemCount: map.length,
                                        padding: EdgeInsets.all(2.0),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          int? vol() {
                                            if (info[map[index]
                                                    .data()["rtcId"]] !=
                                                null) {
                                              return info[
                                                  map[index].data()["rtcId"]];
                                            }
                                            return 0;
                                          }

                                          return TheatreProfile(
                                              role: map[index].data()["role"] ==
                                                      0
                                                  ? Role.Host
                                                  : map[index].data()["role"] ==
                                                          1
                                                      ? Role.Speaker
                                                      : Role.Participant,
                                              user: User.fromJson(
                                                  map[index].data()),
                                              size: 60,
                                              isMute:
                                                  map[index].data()["isMicOn"],
                                              volume: vol(),
                                              myVolume: info[0] ?? 0);
                                        },
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              }),
                        ),
                      ],
                    ),

                    //Theatre has been deleted alert
                    FutureBuilder(
                      future: roomCollection
                          .doc(widget.theatre.createdBy)
                          .collection("amphitheatre")
                          .doc(widget.theatre.theatreId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.data()!['isActive'] == false) {
                            return Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "Theatre has been deleted by the host.Please leave the channel",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "drawerbody"),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              )),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.red),
                                            ),
                                            onPressed: () async {
                                              leaveChannel();

                                              roomProvider.clearRoom();
                                              audioPlayerData.setMediaMeta(
                                                  MediaMeta(),
                                                  shouldNotify: true);
                                              await roomCollection
                                                  .doc(widget.theatre.createdBy)
                                                  .collection("amphitheatre")
                                                  .doc(widget.theatre.theatreId)
                                                  .collection('users')
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
                                                  color: Colors.white,
                                                  fontFamily: "drawerbody"),
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
                    FutureBuilder(
                      future: roomCollection
                          .doc(widget.theatre.createdBy)
                          .collection("amphitheatre")
                          .doc(widget.theatre.theatreId)
                          .collection("users")
                          .doc(auth.user!.userName)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.data()?['isKickedOut'] == true) {
                            return Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "The host has removed you from the theatre.",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "drawerbody"),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              )),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.red),
                                            ),
                                            onPressed: () async {
                                              leaveChannel();
                                              roomProvider.clearRoom();
                                              audioPlayerData.setMediaMeta(
                                                  MediaMeta(),
                                                  shouldNotify: true);
                                              await roomCollection
                                                  .doc(widget.theatre.createdBy)
                                                  .collection("amphitheatre")
                                                  .doc(widget.theatre.theatreId)
                                                  .collection('users')
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
                                                  color: Colors.white,
                                                  fontFamily: "drawerbody"),
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

                    FutureBuilder(
                      future: roomCollection
                          .doc(widget.theatre.createdBy)
                          .collection("amphitheatre")
                          .doc(widget.theatre.theatreId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.data()!['isMutedSpeakers'] ==
                              true) {
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
                                .doc(widget.theatre.createdBy)
                                .collection("amphitheatre")
                                .doc(widget.theatre.theatreId)
                                .update({
                              "isMutedSpeakers": false,
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
                    FutureBuilder(
                      future: roomCollection
                          .doc(widget.theatre.createdBy)
                          .collection("amphitheatre")
                          .doc(widget.theatre.theatreId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.data()!['isUnmutedSpeakers'] ==
                              true) {
                            ToastMessege("You have been un-muted by host",
                                context: context);
                            // Fluttertoast.showToast(
                            //     msg: "You have been un-muted by host",
                            //     toastLength: Toast.LENGTH_SHORT,
                            //     gravity: ToastGravity.CENTER,
                            //     timeInSecForIosWeb: 6,
                            //     backgroundColor: Colors.white,
                            //     textColor: Colors.black,
                            //     fontSize: 16.0);
                            roomCollection
                                .doc(widget.theatre.createdBy)
                                .collection("amphitheatre")
                                .doc(widget.theatre.theatreId)
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
                            (user.id == widget.theatre.createdBy)
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
                                        color: Colors.white30, width: 1),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        onEditingComplete: () {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        controller: thoughtController,
                                        style: h2.copyWith(
                                            color: theme
                                                .colorScheme.inversePrimary),
                                        decoration:
                                            registerInputDecoration.copyWith(
                                                hintText: 'Share a thought',
                                                fillColor: theme
                                                    .inputDecorationTheme
                                                    .fillColor),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection("rooms")
                                            .doc(widget.theatre.createdBy)
                                            .collection("amphitheatre")
                                            .doc(widget.theatre.theatreId)
                                        .get()
                                        .then((value) async {
                                          if(value['isActive']) {
                                            if (thoughtController.text
                                                .isEmpty) {
                                              ToastMessege(
                                                  "Please enter a thought!",
                                                  context: context);
                                            } else {

                                              await roomCollection
                                                  .doc(widget.theatre.createdBy)
                                                  .collection("amphitheatre")
                                                  .doc(widget.theatre.theatreId)
                                                  .collection('users')
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
                                                      "You have been removed from the theatre",
                                                      context: context);
                                                }
                                              });
                                            }


                                          }
                                          else {
                                            ToastMessege(
                                                "Theatre has been deleted",
                                                context: context);
                                          }
                                        });

                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(13),
                                                bottomRight:
                                                    Radius.circular(13))),
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
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(10)),
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

                    //recording counter
                    // (recording && widget.theatre.createdBy == user.id)
                    //     ? Align(
                    //         alignment: Alignment.topRight,
                    //         child: Container(
                    //           padding: const EdgeInsets.all(3),
                    //           height: 50,
                    //           width: 100,
                    //           decoration: BoxDecoration(
                    //             color: Colors.transparent,
                    //             // borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text("T I M E  L E F T",
                    //                 style: TextStyle(
                    //                     color: Colors.grey, fontSize: 10),
                    //               ),
                    //
                    //               Text(
                    //                 Duration(seconds:
                    //                 3600 -
                    //                     recordingTime)
                    //                     .toString()
                    //                     .split('.')[0]
                    //                     .substring(2, 7),
                    //                 style: TextStyle(
                    //                     color: theme.colorScheme.inversePrimary, fontSize: 18),
                    //               ),
                    //               // Container(
                    //               //   margin: EdgeInsets.only(left: 10),
                    //               //   child: Icon(
                    //               //     Icons.fiber_manual_record,
                    //               //     color: Colors.red,
                    //               //     size: 20,
                    //               //   ),
                    //               // )
                    //             ],
                    //           ),
                    //         ),
                    //       )
                    //     : SizedBox.shrink(),
                    // (isHostRecording && recording
                    //     // widget.theatre.createdBy != user.id
                    // )
                    //     ? Align(
                    //         alignment: Alignment.topRight,
                    //         child: Container(
                    //           height: 20,
                    //           width: 20,
                    //           decoration: BoxDecoration(
                    //             color: Colors.transparent,
                    //             // theme.colorScheme.secondary,
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //
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
              )),
            ],
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            //mic
            (user.id == widget.theatre.createdBy)
                ? FutureBuilder(
                    future: roomCollection
                        .doc(widget.theatre.createdBy)
                        .collection("amphitheatre")
                        .doc(widget.theatre.theatreId)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.data()!['isMicDisabled'] == true &&
                            widget.theatre.createdBy != auth.user!.id) {
                          return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  child: IconButton(
                                    color: theme.colorScheme.surface,
                                    //     GlobalColors.signUpSignInButton,
                                    icon: !isMicOn
                                        ? Icon(
                                            FontAwesomeIcons.microphone,
                                            size: 30,
                                            color: theme.colorScheme.secondary,
                                          )
                                        : Icon(
                                            FontAwesomeIcons.microphoneSlash,
                                            size: 30,
                                            color: theme.colorScheme.secondary,
                                          ),
                                    onPressed: () {},
                                  )));
                        }

                        return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    // color: Color(0xff112B3C),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: theme.colorScheme.surface,
                                        width: 1)),
                                child: IconButton(
                                  color: Colors.transparent,
                                  //     GlobalColors.signUpSignInButton,
                                  icon: !isMicOn
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
                                        .doc(widget.theatre.createdBy)
                                        .collection("amphitheatre")
                                        .doc(widget.theatre.theatreId)
                                        .collection("users")
                                        .doc(auth.user!.userName)
                                        .update({
                                      "isMicOn": isMicOn,
                                    });
                                    roomProvider.setIsMuted(isMicOn,
                                        shouldNotify: true);
                                    _agoraService.toggleMute(isMicOn);
                                  },
                                )));
                      } else {
                        return Container(
                          width: 0.0,
                          height: 0.0,
                        );
                      }
                    },
                  )
                : StreamBuilder(
                    stream: roomCollection
                        .doc(widget.theatre.createdBy)
                        .collection("amphitheatre")
                        .doc(widget.theatre.theatreId)
                        .collection('users')
                        .doc(auth.user!.userName)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?["requestToSpeak"] == false &&
                            snapshot.data?["role"] == 2) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              SizedBox.shrink();
                              break;
                            case ConnectionState.waiting:
                              AppLoading(
                                height: 70,
                                width: 70,
                              );
                              // CircularProgressIndicator(color: GlobalColors.signUpSignInButton);
                              break;

                            case ConnectionState.active:
                              AppLoading(
                                height: 70,
                                width: 70,
                              );
                              // CircularProgressIndicator(color: GlobalColors.signUpSignInButton);
                              break;

                            case ConnectionState.done:
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          // color: Color(0xff112B3C),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: theme.colorScheme.surface,
                                              width: 1)),
                                      child: IconButton(
                                        tooltip: 'Request to speak',
                                        color: Colors.transparent,
                                        //     GlobalColors.signUpSignInButton,
                                        icon: Icon(
                                          Icons.voice_over_off_sharp,
                                          // FontAwesomeIcons.volumeXmark,
                                          size: 28,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        onPressed: () async {},
                                      )));
                          }
                          // ToastMessege("You are muted by Host",context: context);
                          return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      // color: Color(0xff112B3C),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: theme.colorScheme.surface,
                                          width: 1)),
                                  child: IconButton(
                                    tooltip: 'Request to speak',
                                    color: Colors.transparent,
                                    //     GlobalColors.signUpSignInButton,
                                    icon: Icon(
                                      Icons.voice_over_off_sharp,
                                      // FontAwesomeIcons.volumeXmark,
                                      size: 28,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    onPressed: () async {
                                      await roomCollection
                                          .doc(widget.theatre.createdBy)
                                          .collection("amphitheatre")
                                          .doc(widget.theatre.theatreId)
                                          .collection('users')
                                          .doc(user.userName)
                                          .update({"requestToSpeak": true});
                                      setState(() {
                                        isRequested = true;
                                      });
                                    },
                                  )));
                        } else if (snapshot.data!["requestToSpeak"] == true &&
                            snapshot.data!["role"] == 2) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              SizedBox.shrink();
                              break;

                            case ConnectionState.waiting:
                              AppLoading(
                                height: 70,
                                width: 70,
                              );
                              break;
                            // CircularProgressIndicator(color: GlobalColors.signUpSignInButton);

                            case ConnectionState.active:
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          // color: Color(0xff112B3C),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: theme.colorScheme.surface,
                                              width: 1)),
                                      child: IconButton(
                                        color: Colors.transparent,
                                        //     GlobalColors.signUpSignInButton,
                                        icon: Icon(
                                          Icons.mic_off,
                                          size: 28,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        onPressed: () async {},
                                      )));
                              break;
                            // CircularProgressIndicator(color: GlobalColors.signUpSignInButton);

                            case ConnectionState.done:
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          // color: Color(0xff112B3C),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: theme.colorScheme.surface,
                                              width: 1)),
                                      child: IconButton(
                                        color: Colors.transparent,
                                        //     GlobalColors.signUpSignInButton,
                                        icon: Icon(
                                          Icons.mic_off,
                                          size: 28,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        onPressed: () async {},
                                      )));
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  // color: Color(0xff112B3C),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 1)),
                              child: IconButton(
                                color: Colors.transparent,
                                //     GlobalColors.signUpSignInButton,
                                icon: Icon(
                                  Icons.mic_off,
                                  size: 28,
                                  color: theme.colorScheme.secondary,
                                ),
                                onPressed: () async {},
                              ),
                            ),
                          );
                        }
                      }
                      return FutureBuilder(
                        future: roomCollection
                            .doc(widget.theatre.createdBy)
                            .collection("amphitheatre")
                            .doc(widget.theatre.theatreId)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.data()!['isMicDisabled'] ==
                                    true &&
                                widget.theatre.createdBy != auth.user!.id) {
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      child: IconButton(
                                        color: theme.colorScheme.surface,
                                        //     GlobalColors.signUpSignInButton,
                                        icon: !isMicOn
                                            ? Icon(
                                                FontAwesomeIcons.microphone,
                                                size: 30,
                                                color:
                                                    theme.colorScheme.secondary,
                                              )
                                            : Icon(
                                                FontAwesomeIcons
                                                    .microphoneSlash,
                                                size: 30,
                                                color:
                                                    theme.colorScheme.secondary,
                                              ),
                                        onPressed: () {},
                                      )));
                            }

                            return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        // color: Color(0xff112B3C),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: theme.colorScheme.surface,
                                            width: 1)),
                                    child: IconButton(
                                      color: Colors.transparent,
                                      //     GlobalColors.signUpSignInButton,
                                      icon: !isMicOn
                                          ? Icon(
                                              Icons.mic,
                                              size: 28,
                                              color:
                                                  theme.colorScheme.secondary,
                                            )
                                          : Icon(
                                              Icons.mic_off,
                                              size: 28,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                      onPressed: () async {
                                        setState(() {
                                          isMicOn = !isMicOn;
                                        });
                                        roomCollection
                                            .doc(widget.theatre.createdBy)
                                            .collection("amphitheatre")
                                            .doc(widget.theatre.theatreId)
                                            .collection("users")
                                            .doc(auth.user!.userName)
                                            .update({
                                          "isMicOn": isMicOn,
                                        });
                                        roomProvider.setIsMuted(isMicOn,
                                            shouldNotify: true);
                                        _agoraService.toggleMute(isMicOn);
                                      },
                                    )));
                          } else {
                            return Container(
                              width: 0.0,
                              height: 0.0,
                            );
                          }
                        },
                      );
                    }),

            //share
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 1)),
                child: IconButton(
                  color: Colors.transparent,
                  // GlobalColors.signUpSignInButton,
                  icon: Icon(
                    Icons.refresh,
                    size: 28,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () async {
                    setState(() {
                      profileStream = roomCollection
                          .doc(widget.theatre.createdBy)
                          .collection("amphitheatre")
                          .doc(widget.theatre.theatreId)
                          .collection('users')
                          .where("isActiveInRoom", isEqualTo: true)
                          .orderBy("role", descending: false)
                          .snapshots();
                    });
                  },
                ),
              ),
            ),

            // thoughts
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 1)),
                child: IconButton(
                  color: Colors.transparent,
                  // GlobalColors.signUpSignInButton,
                  icon: Icon(
                    FontAwesomeIcons.solidCommentDots,
                    size: 23,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () async {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 500,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
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
                                      width: MediaQuery.of(context).size.width,
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
                                          stream: FirebaseFirestore.instance
                                              .collection("roomThoughts")
                                              .doc(widget.theatre.theatreId)
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
                                            return snapshot.data!.docs.length ==
                                                    0
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Text(
                                                      "No thoughts shared yet",
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    physics:
                                                        ClampingScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount: snapshot
                                                        .data!.docs.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      if (!snapshot.hasData) {
                                                        return SizedBox
                                                            .shrink();
                                                      }
                                                      String image = snapshot
                                                          .data!.docs[index]
                                                          .get("image");
                                                      String name = snapshot
                                                          .data!.docs[index]
                                                          .get(
                                                              "participantName");
                                                      String thought = snapshot
                                                          .data!.docs[index]
                                                          .get("thought");
                                                      String thoughtID =
                                                          snapshot
                                                              .data!.docs[index]
                                                              .get("thoughtID");
                                                      String authouID = snapshot
                                                          .data!.docs[index]
                                                          .get("authorId");
                                                      String userID = snapshot
                                                          .data!.docs[index]
                                                          .get("userId");

                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10.0),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        width: 80.w,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                              child: Row(
                                                                children: [
                                                                  //dp
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                    child:
                                                                        RoundedImage(
                                                                      width: 25,
                                                                      height:
                                                                          25,
                                                                      borderRadius:
                                                                          15,
                                                                      url:
                                                                          image,
                                                                    ),
                                                                  ),

                                                                  //name
                                                                  Text(
                                                                    name,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            "drawerhead"),
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Container()),
                                                                  (authouID == user.id ||
                                                                          userID ==
                                                                              user
                                                                                  .id)
                                                                      ? GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            await FirebaseFirestore.instance.collection("roomThoughts").doc(widget.theatre.theatreId).collection("Thoughts").doc(thoughtID).update({
                                                                              "isActive": false
                                                                            });
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.delete,
                                                                            color:
                                                                                Colors.grey,
                                                                            size:
                                                                                20,
                                                                          ))
                                                                      : SizedBox
                                                                          .shrink(),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  )
                                                                ],
                                                              ),
                                                            ),

                                                            //comment
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        right:
                                                                            10),
                                                                child:
                                                                    Container(
                                                                  child: Text(
                                                                    thought,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        fontFamily:
                                                                            "drawerbody"),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
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
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 1)),
                child: IconButton(
                  color: Colors.transparent,
                  // GlobalColors.signUpSignInButton,
                  icon: Icon(
                    Icons.people,
                    size: 28,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () async {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return AddPeopleSheet(
                            followers: followers, room: widget.theatre);
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
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 1)),
                child: IconButton(
                  color: Colors.transparent,
                  // GlobalColors.signUpSignInButton,
                  icon: Icon(
                    Icons.logout,
                    size: 28,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () async {
                    if (recording &&
                        auth.user?.id == widget.theatre.createdBy) {
                      _recordingService.stopRecording(
                          roomId: widget.theatre.theatreId!,
                          userId: widget.theatre.createdBy!,
                          roomTitle: widget.theatre.title!.toLowerCase().trim(),
                          type: RecordingType.AMPHITHEATRE);
                    }
                    leaveChannel();
                    _agoraService.destroyClient();
                    roomProvider.clearRoom();
                    audioPlayerData.setMediaMeta(MediaMeta(),
                        shouldNotify: true);
                    _theatreService.leaveRoom(widget.theatre, user);
                    _roomService.sendLogs({
                      "theatreId": widget.theatre.theatreId,
                      "creatorId": widget.theatre.createdBy,
                      "event": "room_left",
                      "logLevel": "INFO",
                      "roomUserId": user.userName
                    });
                    try {
                      Navigator.of(context).pop();
                    } catch (e) {}
                    // FostrRouter?.replaceGoto(context, Routes.userDashboard);
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
    );
  }
}

class AddPeopleSheet extends StatefulWidget {
  final List<dynamic> followers;
  final Theatre room;
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
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
          color: theme.colorScheme.primary,
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
                        fontSize: 18,
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
                        style: h2.copyWith(
                            fontSize: 14.sp,
                            color: theme.colorScheme.inversePrimary),
                        onEditingComplete: () {
                          setState(() {
                            query = _controller.text.toLowerCase();
                          });
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (value) {},
                        decoration: registerInputDecoration.copyWith(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.colorScheme.inversePrimary,
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.colorScheme.secondary, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Search for your followers',
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
                      child: Icon(Icons.clear, size: 30),
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
                                                          "type": "theatre",
                                                          "roomId": widget
                                                              .room.theatreId,
                                                          "creatorId": widget
                                                              .room.createdBy,
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

class ElapsedTime extends StatefulWidget {
  final DateTime? timestamp;
  const ElapsedTime({
    Key? key,
    required this.timestamp,
  }) : super(key: key);

  @override
  _ElapsedTimeState createState() => _ElapsedTimeState();
}

class _ElapsedTimeState extends State<ElapsedTime> {
  Timer? _timer;

  DateTime? _initialTime;
  String? _currentDuration;


  @override
  void didUpdateWidget(ElapsedTime oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.timestamp != oldWidget.timestamp) {
      _initialTime = widget.timestamp;
      _currentDuration = _formatDuration(_calcElapsedTime());
    }
  }

  @override
  void initState() {
    super.initState();

    _initialTime = widget.timestamp;
    _currentDuration = _formatDuration(_calcElapsedTime());

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _currentDuration = _formatDuration(_calcElapsedTime());
      });
    });
  }

  Duration _calcElapsedTime() => _initialTime!.difference(DateTime.now());

  // DateTime _parseTimestamp() => DateTime.parse(widget.timestamp);

  // TODO update this to fit your own needs
  String _formatDuration(final Duration duration) => duration.toString();

  @override
  void dispose() {
    _timer!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentDuration ?? "",
      style: TextStyle(
          fontSize: 14,
      ),);
  }
}
