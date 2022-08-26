import 'dart:async';
import 'dart:developer';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/core/functions.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/RoomProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/AgoraService.dart';
import 'package:fostr/services/AudioPlayerService.dart';
import 'package:fostr/services/NotificationService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/core/settings.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/rooms/Minimal.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/rooms/Profile.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class SelectTheme extends StatefulWidget {
  final Room room;
  SelectTheme({required this.room});

  @override
  _SelectThemeState createState() => _SelectThemeState();
}

class _SelectThemeState extends State<SelectTheme> with FostrTheme {
  String roomTheme = "Minimalist", userKind = "speaker";
  int speakersCount = 0, participantsCount = 0;
  ClientRole role = ClientRole.Broadcaster;
  bool isLoading = false;
  String enteredpass = "";
  String roompass = "";
  bool initLoad = false;

  final RoomService roomService = GetIt.I<RoomService>();
  final AgoraService agoraService = GetIt.I<AgoraService>();
  final AudioPlayerService audioPlayerService = GetIt.I<AudioPlayerService>();
  late String userId;

  bool hostEntered = false;
  String? rtcTOKEN;

  late String roomId;
  late Future<QuerySnapshot<Map<String, dynamic>>>? roomSpeakers;
  late String UserID;

  List specialUsers = [];
  List adminUsers = [];

  Event buildEvent(DateTime dateTime) {
    return Event(
      title: 'Foster Event : ${widget.room.title}',
      description: '',
      location: 'Foster Reads',
      startDate: dateTime,
      endDate: dateTime.add(Duration(minutes: 45)),
      iosParams: IOSParams(
          // reminder: Duration(minutes: 40),
          ),
      androidParams: AndroidParams(
          // emailInvites: ["test@example.com"],
          ),
    );
  }

  void getSpecialUsers() async {
    await FirebaseFirestore.instance
        .collection('special_users')
        .doc('admins')
        .get()
        .then((value){
      setState(() {
        adminUsers = value['admins'].toList();
      });
    });
    await FirebaseFirestore.instance
        .collection('special_users')
        .doc('users')
        .get()
        .then((value){
      setState(() {
        specialUsers = value['users'].toList();
      });
    });
    // print('func admins');
    // print(adminUsers);
    // print('func special users');
    // print(specialUsers);
  }

  @override
  void initState() {
    super.initState();

    rtcTOKEN = widget.room.token;
    UserID = widget.room.id!;
    roomId = widget.room.roomID!;

    getSpecialUsers();

    roomSpeakers = FirebaseFirestore.instance
        .collection("rooms")
        .doc(UserID)
        .collection("rooms")
        .doc(roomId)
        .collection("speakers")
        .get();

    agoraService.initEngine();
    roomService.initRoom(widget.room,
        (participantsC, speakersC, tokenC, channelNameC, roompassC) {
      setState(() {
        participantsCount = participantsC;
        speakersCount = speakersC;
        token = tokenC;
        channelName = channelNameC;
        roompass = roompassC ?? "";
      });
    });

    FirebaseFirestore.instance
    .collection("rooms")
    .doc(widget.room.id)
    .collection("rooms")
    .doc(widget.room.roomID)
    .snapshots()
    .listen((event) {
      setState(() {
        rtcTOKEN = event['token'];
      });

    });

  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final user = auth.user!;
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 350,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(32),
          topEnd: Radius.circular(32),
        ),
        color: theme.colorScheme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child:
                                Text("${widget.room.title}", style: h1.apply()
                                    // style: h1.apply(color: Colors.black87),
                                    ),
                          ),
                          Center(
                            child: Text(
                              "${widget.room.roomCreator}",
                            ),
                          ),
                        ],
                      ),

                      //participant count
                      !widget.room.isActive! ||
                          (widget.room.dateTime!
                              .toUtc()
                              .subtract(Duration(minutes: 10))
                              .isBefore(DateTime.now().toUtc()) &&
                              widget.room.dateTime!
                                  .toUtc()
                                  .add(Duration(minutes: 45))
                                  .isBefore(DateTime.now().toUtc())) ?
                      SizedBox.shrink() :
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: StreamBuilder(
                          stream: roomCollection
                              .doc(widget.room.id)
                              .collection("rooms")
                              .doc(widget.room.roomID)
                              .collection("speakers")
                              .where("isActiveInRoom", isEqualTo: true)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasData) {
                              return Center(
                                child: Text(
                                  "Participants  ${snapshot.data!.docs.length}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20),
                                ),
                              );
                            } else {
                              return Container(
                                width: 0.0,
                                height: 0.0,
                              );
                            }
                          },
                        ),
                      ),

                      //author name
                      widget.room.authorName!.isNotEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Author name ${widget.room.authorName}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (!widget.room.isFollowersOnly)
                _InviteOnlyBuilder(
                  room: widget.room,
                ),
              (widget.room.id == fa.FirebaseAuth.instance.currentUser!.uid) ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child:
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            // Opacity will become zero
                            // if (!isInviteOnly) return;
                            Share.share(await DynamicLinksApi.inviteOnlyRoomLink(
                              widget.room.roomID!,
                              widget.room.id!,
                              roomName: widget.room.title!,
                              imageUrl: widget.room.imageUrl,
                              creatorName: widget.room.roomCreator ?? "",
                            ));
                          },
                          child: Text(
                            "Share Invite",
                          ),
                        ),

                        // if (false)
                        //   Switch(
                        //     value: isInviteOnly,
                        //     activeColor: GlobalColors.signUpSignInButton,
                        //     onChanged: (value) async {
                        //       if (_isAlreadyUpdatingData) return;
                        //       isInviteOnly = value;
                        //       _isAlreadyUpdatingData = true;
                        //       await changeInviteState();
                        //       _isAlreadyUpdatingData = false;
                        //       setState(() {});
                        //     },
                        //   ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () async {
                        // Opacity will become zero
                        // if (!isInviteOnly) return;
                        Share.share(await DynamicLinksApi.inviteOnlyRoomLink(
                          widget.room.roomID!,
                          widget.room.id!,
                          roomName: widget.room.title!,
                          imageUrl: widget.room.imageUrl,
                          creatorName: widget.room.roomCreator ?? "",
                        ));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                              // Icon(
                              //   Icons.share_rounded,
                              // ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ) : SizedBox(),
              Divider(
                color: theme.colorScheme.secondary,
              ),
              isLoading
                  ? CircularProgressIndicator(
                      color: theme.colorScheme.secondary,
                    )
                  : StreamBuilder(
                      stream: roomCollection
                          .doc(widget.room.id)
                          .collection("rooms")
                          .doc(widget.room.roomID)
                          .collection("speakers")
                          .where("isActiveInRoom", isEqualTo: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length > 14) {
                            return ElevatedButton(
                              child: Text(
                                'Room Full',
                                style: TextStyle(fontFamily: "drawerbody"),
                              ),
                              onPressed: () async {},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.redAccent),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            );
                          }
                          var joinButton = widget.room.isActive! &&
                                  widget.room.isUpcoming!
                              ?
                              //upcoming
                              ElevatedButton(
                                  child: Text(
                                    'Add to calendar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    Add2Calendar.addEvent2Cal(
                                        buildEvent(widget.room.dateTime!));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        theme.colorScheme.secondary),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                )
                              : widget.room.isActive!
                                  ?
                          // widget.room.dateTime!
                          //                     .toUtc()
                          //                     .subtract(Duration(minutes: 10))
                          //                     .isBefore(
                          //                         DateTime.now().toUtc()) &&
                                          widget.room.dateTime!
                                              .toUtc()
                                              .add(Duration(minutes: 45))
                                              .isBefore(DateTime.now().toUtc())
                                      ?
                                      //finished
                                      ElevatedButton(
                                          child: Text(
                                            'Event finished',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () async {},
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(theme
                                                    .colorScheme.secondary),
                                            shape: MaterialStateProperty.all<
                                                OutlinedBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        )
                                      :
                                      //join
                                      ElevatedButton(
                                          child: auth.user!.id == widget.room.id ?
                                            Text('Join Room', style: TextStyle(color: Colors.white)) :
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("rooms")
                                                  .doc(widget.room.id)
                                                  .collection("rooms")
                                                  .doc(widget.room.roomID)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Container();
                                                }

                                                try {
                                                  if (snapshot
                                                      .data?['hostEntered']) {
                                                    return Text('Join Room',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white));
                                                  } else {
                                                    return Text(
                                                      'Waiting for the host to join in.',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .white),);
                                                  }
                                                } catch (e) {
                                                  return Text(
                                                    'Waiting for the host to join in.',
                                                    style: TextStyle(
                                                        color: Colors.white),);
                                                }
                                              }
                                            ),

                                          onPressed: () async {

                                            if(auth.user!.id == widget.room.id) {

                                              await FirebaseFirestore.instance
                                                  .collection("rooms")
                                                  .doc(widget.room.id)
                                                  .collection("rooms")
                                                  .where("hostEntered", isEqualTo: true)
                                                  .where("roomID", isEqualTo: widget.room.roomID)
                                                  .limit(1)
                                                  .get()
                                              .then((value) async {
                                                if(value.docs.length == 1){

                                                  ///when host joins back after leaving
                                                  await roomCollection
                                                      .doc(widget.room.id)
                                                      .collection("rooms")
                                                      .doc(widget.room.roomID)
                                                      .collection("speakers")
                                                      .get()
                                                      .then((value) async {
                                                    List users = [];
                                                    value.docs.forEach((element)  {
                                                      users.add(element.id);
                                                    });
                                                    if(users.indexOf(auth.user!.userName)>-1){

                                                      await roomCollection
                                                          .doc(widget.room.id)
                                                          .collection("rooms")
                                                          .doc(widget.room.roomID)
                                                          .collection("speakers")
                                                          .doc(auth.user!.userName)
                                                          .get()
                                                          .then((value) async {
                                                        if(value['isKickedOut']){
                                                          ToastMessege(
                                                            "You have already been kicked out of this room.",
                                                            context: context,
                                                          );
                                                        }
                                                        else{
                                                          if (audioPlayerData
                                                              .mediaMeta.audioId !=
                                                              widget.room.roomID) {
                                                            await FirebaseFirestore.instance
                                                                .collection("rooms")
                                                                .doc(widget.room.id)
                                                                .collection("rooms")
                                                                .doc(widget.room.roomID)
                                                                .get()
                                                                .then((value) async {
                                                              roomService.getRoomById(
                                                                  value['roomID'], value['id']
                                                              ).then((room) async {
                                                                roomProvider.setRoom(
                                                                    room!, auth.user!);
                                                                audioPlayerService.release();
                                                                audioPlayerData.setMediaMeta(
                                                                  MediaMeta(
                                                                    audioId: value['roomID'],
                                                                    audioName: value['title'],
                                                                    userName: value['roomCreator'],
                                                                    mediaType: MediaType.rooms,
                                                                    rawData: room.toJson(),
                                                                  ),
                                                                  shouldNotify: true,
                                                                );
                                                                await updateRoom(user, context,
                                                                    roomProvider.isMuted ?? true);
                                                                await agoraService.joinChannel(
                                                                    value['token'],
                                                                    value['roomID']);
                                                                navigateToRoom(room);
                                                              });
                                                            });
                                                          }
                                                        }
                                                      });

                                                    } else {
                                                      if (audioPlayerData
                                                          .mediaMeta.audioId !=
                                                          widget.room.roomID) {
                                                        await FirebaseFirestore.instance
                                                            .collection("rooms")
                                                            .doc(widget.room.id)
                                                            .collection("rooms")
                                                            .doc(widget.room.roomID)
                                                            .get()
                                                            .then((value) async {
                                                          roomService.getRoomById(
                                                              value['roomID'], value['id']
                                                          ).then((room) async {
                                                            roomProvider.setRoom(
                                                                room!, auth.user!);
                                                            audioPlayerService.release();
                                                            audioPlayerData.setMediaMeta(
                                                              MediaMeta(
                                                                audioId: value['roomID'],
                                                                audioName: value['title'],
                                                                userName: value['roomCreator'],
                                                                mediaType: MediaType.rooms,
                                                                rawData: room.toJson(),
                                                              ),
                                                              shouldNotify: true,
                                                            );
                                                            await updateRoom(user, context,
                                                                roomProvider.isMuted ?? true);
                                                            await agoraService.joinChannel(
                                                                value['token'],
                                                                value['roomID']);
                                                            navigateToRoom(room);
                                                          });
                                                        });
                                                      }
                                                    }
                                                  });
                                                } else {

                                                  ///when host enters first time
                                                  await FirebaseFirestore.instance
                                                      .collection("rooms")
                                                      .doc(widget.room.id)
                                                      .collection("rooms")
                                                      .doc(widget.room.roomID)
                                                  .get()
                                                  .then((room){
                                                    // roomService.createRoomNow(
                                                    //     user,
                                                    //     room['title'],
                                                    //     room['button toggle'],
                                                    //     room['agenda'],
                                                    //     room['genre'],
                                                    //     room['image'],
                                                    //     room['password'],
                                                    //     room['dateTime'],
                                                    //     room['authorName'],
                                                    //     room['summary'],
                                                    //     room['adTitle'],
                                                    //     room['adDescription'],
                                                    //     room['redirectLink'],
                                                    //     room['imageUrl2'],
                                                    //     room['inviteOnly'],
                                                    //     room['followersOnly']
                                                    // )
                                                        getRTCToken(widget.room.roomID!)
                                                        .then((token) async {
                                                      await FirebaseFirestore.instance
                                                          .collection("rooms")
                                                          .doc(widget.room.id)
                                                          .collection("rooms")
                                                          .doc(widget.room.roomID)
                                                          .set({
                                                        'hostEntered' : true,
                                                        'token' : token
                                                      }, SetOptions(merge: true));
                                                      await roomCollection
                                                          .doc(widget.room.id)
                                                          .collection("rooms")
                                                          .doc(widget.room.roomID)
                                                          .collection("speakers")
                                                          .get()
                                                          .then((value) async {
                                                        List users = [];
                                                        value.docs.forEach((element)  {
                                                          users.add(element.id);
                                                        });
                                                        if(users.indexOf(auth.user!.userName)>-1){

                                                          await roomCollection
                                                              .doc(widget.room.id)
                                                              .collection("rooms")
                                                              .doc(widget.room.roomID)
                                                              .collection("speakers")
                                                              .doc(auth.user!.userName)
                                                              .get()
                                                              .then((value) async {
                                                            if(value['isKickedOut']){
                                                              ToastMessege(
                                                                "You have already been kicked out of this room.",
                                                                context: context,
                                                              );
                                                            }
                                                            else{
                                                              if (audioPlayerData
                                                                  .mediaMeta.audioId !=
                                                                  widget.room.roomID) {
                                                                await FirebaseFirestore.instance
                                                                    .collection("rooms")
                                                                    .doc(widget.room.id)
                                                                    .collection("rooms")
                                                                    .doc(widget.room.roomID)
                                                                    .get()
                                                                    .then((value) async {
                                                                  roomService.getRoomById(
                                                                      value['roomID'], value['id']
                                                                  ).then((room) async {
                                                                    roomProvider.setRoom(
                                                                        room!, auth.user!);
                                                                    audioPlayerService.release();
                                                                    audioPlayerData.setMediaMeta(
                                                                      MediaMeta(
                                                                        audioId: value['roomID'],
                                                                        audioName: value['title'],
                                                                        userName: value['roomCreator'],
                                                                        mediaType: MediaType.rooms,
                                                                        rawData: room.toJson(),
                                                                      ),
                                                                      shouldNotify: true,
                                                                    );
                                                                    await updateRoom(user, context,
                                                                        roomProvider.isMuted ?? true);
                                                                    await agoraService.joinChannel(
                                                                        value['token'],
                                                                        value['roomID']);
                                                                    navigateToRoom(room);
                                                                  });
                                                                });
                                                              }
                                                            }
                                                          });

                                                        }
                                                        else {
                                                          if (audioPlayerData
                                                              .mediaMeta.audioId !=
                                                              widget.room.roomID) {
                                                            await FirebaseFirestore.instance
                                                                .collection("rooms")
                                                                .doc(widget.room.id)
                                                                .collection("rooms")
                                                                .doc(widget.room.roomID)
                                                                .get()
                                                                .then((value) async {
                                                              roomService.getRoomById(
                                                                  value['roomID'], value['id']
                                                              ).then((room) async {
                                                                roomProvider.setRoom(
                                                                    room!, auth.user!);
                                                                audioPlayerService.release();
                                                                audioPlayerData.setMediaMeta(
                                                                  MediaMeta(
                                                                    audioId: value['roomID'],
                                                                    audioName: value['title'],
                                                                    userName: value['roomCreator'],
                                                                    mediaType: MediaType.rooms,
                                                                    rawData: room.toJson(),
                                                                  ),
                                                                  shouldNotify: true,
                                                                );
                                                                await updateRoom(user, context,
                                                                    roomProvider.isMuted ?? true);
                                                                await agoraService.joinChannel(
                                                                    value['token'],
                                                                    value['roomID']);
                                                                navigateToRoom(room);
                                                              });
                                                            });
                                                          }
                                                        }
                                                      });
                                                    });
                                                  });

                                                }
                                              });

                                            } else {

                                              ///users entering
                                              await FirebaseFirestore.instance
                                                  .collection("rooms")
                                                  .doc(widget.room.id)
                                                  .collection("rooms")
                                                  .where("hostEntered", isEqualTo: true)
                                                  .where("roomID", isEqualTo: widget.room.roomID)
                                                  .limit(1)
                                                  .get()
                                                  .then((value) async {

                                                    ///host already entered
                                                    if(value.docs.length == 1){
                                                      setState(() {
                                                        hostEntered = true;
                                                      });
                                                      await roomCollection
                                                          .doc(widget.room.id)
                                                          .collection("rooms")
                                                          .doc(widget.room.roomID)
                                                          .collection("speakers")
                                                          .get()
                                                          .then((value) async {
                                                        List users = [];
                                                        value.docs.forEach((element)  {
                                                          users.add(element.id);
                                                        });
                                                        if(users.indexOf(auth.user!.userName)>-1){

                                                          await roomCollection
                                                              .doc(widget.room.id)
                                                              .collection("rooms")
                                                              .doc(widget.room.roomID)
                                                              .collection("speakers")
                                                              .doc(auth.user!.userName)
                                                              .get()
                                                              .then((value) async {
                                                            if(value['isKickedOut']){
                                                              ToastMessege(
                                                                "You have already been kicked out of this room.",
                                                                context: context,
                                                              );
                                                            }
                                                            else{
                                                              if (audioPlayerData
                                                                  .mediaMeta.audioId !=
                                                                  widget.room.roomID) {
                                                                await FirebaseFirestore.instance
                                                                    .collection("rooms")
                                                                    .doc(widget.room.id)
                                                                    .collection("rooms")
                                                                    .doc(widget.room.roomID)
                                                                    .get()
                                                                    .then((value) async {
                                                                  roomService.getRoomById(
                                                                      value['roomID'], value['id']
                                                                  ).then((room) async {
                                                                    roomProvider.setRoom(
                                                                        room!, auth.user!);
                                                                    audioPlayerService.release();
                                                                    audioPlayerData.setMediaMeta(
                                                                      MediaMeta(
                                                                        audioId: value['roomID'],
                                                                        audioName: value['title'],
                                                                        userName: value['roomCreator'],
                                                                        mediaType: MediaType.rooms,
                                                                        rawData: room.toJson(),
                                                                      ),
                                                                      shouldNotify: true,
                                                                    );
                                                                    await updateRoom(user, context,
                                                                        roomProvider.isMuted ?? true);
                                                                    await agoraService.joinChannel(
                                                                        value['token'],
                                                                        value['roomID']);
                                                                    navigateToRoom(room);
                                                                  });
                                                                });
                                                              }
                                                            }
                                                          });

                                                        }
                                                        else {
                                                          if (audioPlayerData
                                                              .mediaMeta.audioId !=
                                                              widget.room.roomID) {
                                                            await FirebaseFirestore.instance
                                                                .collection("rooms")
                                                                .doc(widget.room.id)
                                                                .collection("rooms")
                                                                .doc(widget.room.roomID)
                                                                .get()
                                                                .then((value) async {
                                                              roomService.getRoomById(
                                                                  value['roomID'], value['id']
                                                              ).then((room) async {
                                                                roomProvider.setRoom(
                                                                    room!, auth.user!);
                                                                audioPlayerService.release();
                                                                audioPlayerData.setMediaMeta(
                                                                  MediaMeta(
                                                                    audioId: value['roomID'],
                                                                    audioName: value['title'],
                                                                    userName: value['roomCreator'],
                                                                    mediaType: MediaType.rooms,
                                                                    rawData: room.toJson(),
                                                                  ),
                                                                  shouldNotify: true,
                                                                );
                                                                await updateRoom(user, context,
                                                                    roomProvider.isMuted ?? true);
                                                                await agoraService.joinChannel(
                                                                    value['token'],
                                                                    value['roomID']);

                                                                navigateToRoom(room);
                                                              });
                                                            });
                                                          }
                                                        }
                                                      });
                                                    }
                                                    else {
                                                      ToastMessege("Please wait until the host enters the room.", context: context);
                                                      setState(() {
                                                        hostEntered = false;
                                                      });
                                                    }
                                              });

                                            }

                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(theme
                                                    .colorScheme.secondary),
                                            shape: MaterialStateProperty.all<
                                                OutlinedBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        )
                                  :
                                  //delete
                                  ElevatedButton(
                                      child: Text(
                                        'Event deleted',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {},
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                theme.colorScheme.secondary),
                                        shape: MaterialStateProperty.all<
                                            OutlinedBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    );

                          if (widget.room.isFollowersOnly &&
                              fa.FirebaseAuth.instance.currentUser!.uid !=
                                  widget.room.id) {
                            return FollowersOnlyJoinButton(
                              joinButton: joinButton,
                              room: widget.room,
                            );
                          } else {
                            return joinButton;
                          }
                        } else {
                          return Container(
                            width: 0.0,
                            height: 0.0,
                          );
                        }
                      },
                    ),
              SizedBox(
                height: 20,
              ),

              //add bots
              adminUsers.contains(auth.user!.id) ?
              // auth.user!.id == "tlMTZ9Wt9iRgojhFqOkEP7yDmVe2" ?
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(

                        onTap: () async {
                          User bot1, bot2, bot3, bot4, bot5, bot6;


                          UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value1){ //sarahreads "G76B9y4G4TQaYH2MzLF4wuWrEbF3"
                            bot1 = value1!;
                            UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value2){ //mitesh14 "Gfqvx3GZg2YVkfaqoe7DM57Iilu1"
                              bot2 = value2!;
                              UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value3){ //renuraj "9Awa0HRhQIPcufxpY0f1qu5xq0O2"
                                bot3 = value3!;
                                UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value4){ //youngmike "Ej1R25VETWZ5PaUeZaIXhoRHp5J2"
                                  bot4 = value4!;
                                  UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value5){ //monica "5ai2yEOuWSZuxIlwpEeFkcOuQxx2"
                                    bot5 = value5!;
                                      UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value6){ //amarsdiary "BtMUYkEIiabkGsUSRFEqMCwj0703"
                                        bot6 = value6!;

                                        roomService.joinRoomAsSpeaker(widget.room, bot1, enteredpass, roompass, speakersCount, true);
                                        roomService.joinRoomAsSpeaker(widget.room, bot2, enteredpass, roompass, speakersCount, true);
                                        roomService.joinRoomAsSpeaker(widget.room, bot3, enteredpass, roompass, speakersCount, true);
                                        roomService.joinRoomAsSpeaker(widget.room, bot4, enteredpass, roompass, speakersCount, true);
                                        roomService.joinRoomAsSpeaker(widget.room, bot5, enteredpass, roompass, speakersCount, true);
                                        roomService.joinRoomAsSpeaker(widget.room, bot6, enteredpass, roompass, speakersCount, true);


                                    });
                                  });
                                });
                              });
                            });
                          });

                        },

                        child: Container(
                          width: 150,
                          height: 30,
                          color: Colors.grey,
                          child: Center(
                            child: Text("Add special users",style: TextStyle(color: Colors.black),),
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //
                      //   onTap: () async {
                      //     User bot1, bot2, bot3, bot4, bot5, bot6;
                      //
                      //     UserService().getUserById("ra30ZrxbUig7IPgr7ovvTOP6gf22").then((value1){ //alanthomas
                      //       bot1 = value1!;
                      //       UserService().getUserById("0K9KDvJMQcP4dnOU5YIX1MWCxi12").then((value2){ //himani
                      //         bot2 = value2!;
                      //         UserService().getUserById("gOGf6tdFfedwnN3c1qxsmecNMw02").then((value3){ //shubham_23
                      //           bot3 = value3!;
                      //           UserService().getUserById("sMxK4h5CTuSgEI5YVxa5lCNj6TI3").then((value4){ //rashijain
                      //             bot4 = value4!;
                      //             UserService().getUserById("49j0Qyy6O4fzNjimR0T18Xc4Z9l1").then((value5){ //yash001
                      //               bot5 = value5!;
                      //               UserService().getUserById("BhnsIZl3dsW3cNKyllhWNoWxFDV2").then((value6){ //sara
                      //                 bot6 = value6!;
                      //
                      //                 roomService.joinRoomAsSpeaker(widget.room, bot1, enteredpass, roompass, speakersCount, true);
                      //                 roomService.joinRoomAsSpeaker(widget.room, bot2, enteredpass, roompass, speakersCount, true);
                      //                 roomService.joinRoomAsSpeaker(widget.room, bot3, enteredpass, roompass, speakersCount, true);
                      //                 roomService.joinRoomAsSpeaker(widget.room, bot4, enteredpass, roompass, speakersCount, true);
                      //                 roomService.joinRoomAsSpeaker(widget.room, bot5, enteredpass, roompass, speakersCount, true);
                      //                 roomService.joinRoomAsSpeaker(widget.room, bot6, enteredpass, roompass, speakersCount, true);
                      //
                      //               });
                      //             });
                      //           });
                      //         });
                      //       });
                      //     });
                      //
                      //   },
                      //
                      //   child: Container(
                      //     width: 100,
                      //     height: 30,
                      //     color: Colors.grey,
                      //     child: Center(
                      //       child: Text("Add Bots 2",style: TextStyle(color: Colors.black),),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  // SizedBox(height: 5,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     GestureDetector(
                  //
                  //       onTap: () async {
                  //         User bot1, bot2, bot3, bot4, bot5, bot6;
                  //
                  //         UserService().getUserById("zi5IGrlVEahPwL0TtrOv8Juf0ok2").then((value1){ //sumit
                  //           bot1 = value1!;
                  //           UserService().getUserById("3mu3VZEHk9gUenep0Efk0cBJUgS2").then((value2){ //snehak
                  //             bot2 = value2!;
                  //             UserService().getUserById("maCAcXKYvVQF7LpkGtlREttsBmy1").then((value3){ //meerareads
                  //               bot3 = value3!;
                  //               UserService().getUserById("1mYKKbntWsWPTljTHI4qzFHVWa93").then((value4){ //RakeshR
                  //                 bot4 = value4!;
                  //                 UserService().getUserById("YKkcHAJvi1R1dqYXelbMWOyI6vY2").then((value5){ //samv
                  //                   bot5 = value5!;
                  //                   UserService().getUserById("bPr1oURIlONvI8ny94GAtQ1qSG03").then((value6){ //eforeshaan
                  //                     bot6 = value6!;
                  //
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot1, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot2, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot3, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot4, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot5, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot6, enteredpass, roompass, speakersCount, true);
                  //
                  //
                  //                   });
                  //                 });
                  //               });
                  //             });
                  //           });
                  //         });
                  //
                  //       },
                  //
                  //       child: Container(
                  //         width: 100,
                  //         height: 30,
                  //         color: Colors.grey,
                  //         child: Center(
                  //           child: Text("Add Bots 3",style: TextStyle(color: Colors.black),),
                  //         ),
                  //       ),
                  //     ),
                  //     GestureDetector(
                  //
                  //       onTap: () async {
                  //         User bot1, bot2, bot3, bot4, bot5, bot6;
                  //
                  //         UserService().getUserById("RgcbGtHgqWeQXndtCl2sw5YdCXe2").then((value1){ //goelarman
                  //           bot1 = value1!;
                  //           UserService().getUserById("eGLr0oho39MXXcPdVYMnQ3j4gVH3").then((value2){ //jenny_t
                  //             bot2 = value2!;
                  //             UserService().getUserById("XiFifJUvMMaaLOLbkLbBfXYXLg52").then((value3){ //riya
                  //               bot3 = value3!;
                  //               UserService().getUserById("TAzNRayWOgXEfu20OphCAUl3KMj2").then((value4){ //r.k
                  //                 bot4 = value4!;
                  //                 UserService().getUserById("bFbSoVCzroOtXmg1uUu8YEDOWtH2").then((value5){ //akritic
                  //                   bot5 = value5!;
                  //                   UserService().getUserById("AwlT2XWps7UpIxgOp6lQ5jnlLme2").then((value6){ //deepansh
                  //                     bot6 = value6!;
                  //
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot1, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot2, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot3, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot4, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot5, enteredpass, roompass, speakersCount, true);
                  //                     roomService.joinRoomAsSpeaker(widget.room, bot6, enteredpass, roompass, speakersCount, true);
                  //
                  //
                  //                   });
                  //                 });
                  //               });
                  //             });
                  //           });
                  //         });
                  //
                  //       },
                  //
                  //       child: Container(
                  //         width: 100,
                  //         height: 30,
                  //         color: Colors.grey,
                  //         child: Center(
                  //           child: Text("Add Bots 4",style: TextStyle(color: Colors.black),),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              )
              : SizedBox.shrink(),
              auth.user!.id == "tlMTZ9Wt9iRgojhFqOkEP7yDmVe2" ?
              SizedBox(
                height: 20,
              )
                  : SizedBox.shrink(),

              //send notifications
              // adminUsers.contains(auth.user!.id) ?
              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: GestureDetector(
              //     onTap: (){
              //       NotificationService().sendNewRoomPhoneNotification(
              //           widget.room.authorName.toString().isEmpty ? widget.room.roomCreator! : widget.room.authorName!,
              //           widget.room.title!,
              //           UserID,
              //           roomId
              //       );
              //     },
              //     child: Container(
              //       color: Colors.white,
              //       width: 120,
              //       height: 30,
              //       child: Center(child: Text("Send Notification")),
              //     ),
              //   ),
              // )
              //     : SizedBox.shrink(),

              Container(
                width: MediaQuery.of(context).size.width,
                // color: Colors.grey,
                child: Text(
                  "Maximum of 15 participants are allowed.",
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child:
                !widget.room.isActive! ||
                    (widget.room.dateTime!
                        .toUtc()
                        .subtract(Duration(minutes: 10))
                        .isBefore(DateTime.now().toUtc()) &&
                        widget.room.dateTime!
                            .toUtc()
                            .add(Duration(minutes: 45))
                            .isBefore(DateTime.now().toUtc()))
                    ? FutureBuilder(
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
                            "",
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
                      return GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                        itemCount: data.length,
                        padding: EdgeInsets.all(2.0),
                        itemBuilder:
                            (BuildContext context, int index) {
                          return Profile(
                              user: User.fromJson(data[index]),
                              size: 60,
                              isMute: false,
                              volume: 0,
                              myVolume: 0);
                        },
                      );
                    }) :

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: roomCollection
                        .doc(widget.room.id)
                        .collection("rooms")
                        .doc(widget.room.roomID)
                        .collection('speakers')
                        .where("isActiveInRoom", isEqualTo: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.length == 0) {
                        return Align(
                          child: Text(
                            "No speakers yet!",
                          ),
                          alignment: Alignment.topCenter,
                        );
                      } else if (snapshot.hasData) {
                        List<QueryDocumentSnapshot<Map<String, dynamic>>> map =
                            snapshot.data!.docs;
                        return Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemCount: map.length,
                            padding: EdgeInsets.all(2.0),
                            itemBuilder: (BuildContext context, int index) {
                              return Profile(
                                  user: User.fromJson(map[index].data()),
                                  size: 60,
                                  isMute: false,
                                  volume: 0,
                                  myVolume: 0);
                            },
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future updateRoom(User user, BuildContext context, bool isMicOn) async {
    setState(() {
      isLoading = true;
    });

    if (userKind == "speaker") {
      // update the list of speakers
      if (roompass != "") {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('This Room Is Password Protected'),
              content: TextFormField(
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xB2476747),
                  fontFamily: "Lato",
                ),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(
                    color: Color(0xff476747),
                  ),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.next,
                onChanged: (val) {
                  enteredpass = val;
                },
              ),
              actions: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xff94B5AC))),
                  onPressed: () {
                    enteredpass = "";
                    Navigator.pop(context);
                  },
                  child: Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xff94B5AC))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }

      var speakersC = await GetIt.I<RoomService>().joinRoomAsSpeaker(
          widget.room, user, enteredpass, roompass, speakersCount, isMicOn);
      if (speakersC == null) {
        ToastMessege("Please Enter Correct password", context: context);
        // Fluttertoast.showToast(
        //     msg: "Please Enter Correct password",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: gradientBottom,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
        setState(() {
          // msg = "Incorrect Password";
          isLoading = false;
        });
        return false;
      } else {
        setState(() {
          speakersCount = speakersC;
          isLoading = false;
        });
        return true;
      }
    }
    // else {
    //   var participantsC = await GetIt.I<RoomService>()
    //       .joinRoomAsParticipant(widget.room, user, participantsCount);
    //   setState(() {
    //     participantsCount = participantsC;
    //     isLoading = false;
    //   });
    // }

    setState(() {
      isLoading = false;
    });
    return true;
  }

  navigateToRoom(Room room) async {
    // print(roomTheme);
    // navigate to the room
    await roomService.dispose();
    // if (roomTheme == "Minimalist") {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        settings: RouteSettings(name: 'minimal'),
        builder: (context) => Scaffold(
          body: Minimal(
            room: room,
            role: role,
          ),
        ),
      ),
    );
  }

  Future<bool> isUserBanned() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool temp = false;
    var checkUser = await roomCollection
        .doc(widget.room.id)
        .collection("rooms")
        .doc(widget.room.roomID)
        .collection('speakers')
        .doc(auth.user!.userName)
        .get();
    if (checkUser.exists) {
      checkUser.data()!['isBanned'] ? temp = true : temp = false;
    }
    return temp;
  }
}

class _InviteOnlyBuilder extends StatefulWidget {
  final Room room;
  const _InviteOnlyBuilder({required this.room, Key? key}) : super(key: key);

  @override
  State<_InviteOnlyBuilder> createState() => __InviteOnlyBuilderState();
}

class __InviteOnlyBuilderState extends State<_InviteOnlyBuilder> {
  bool isInviteOnly = false;
  bool _isAlreadyUpdatingData = false;

  @override
  void initState() {
    isInviteOnly = widget.room.isInviteOnly;
    // log(widget.room.roomID!);
    // log(widget.room.id!);
    super.initState();
  }

  Future<void> changeInviteState() {
    return FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.room.id)
        .collection("rooms")
        .doc(widget.room.roomID)
        .update({
      'inviteOnly': isInviteOnly,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.room.id != fa.FirebaseAuth.instance.currentUser!.uid) {
      return Container();
    }
    return !widget.room.isActive! ||
        (widget.room.dateTime!
            .toUtc()
            .subtract(Duration(minutes: 10))
            .isBefore(DateTime.now().toUtc()) &&
            widget.room.dateTime!
                .toUtc()
                .add(Duration(minutes: 45))
                .isBefore(DateTime.now().toUtc())) ?
      SizedBox.shrink() :


      StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rooms")
            .doc(widget.room.id)
            .collection("rooms")
            .doc(widget.room.roomID)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }

          return snapshot.data!.get("inviteOnly")?
          SizedBox.shrink() :
          (widget.room.id != fa.FirebaseAuth.instance.currentUser!.uid) ?
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child:
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      // Opacity will become zero
                      // if (!isInviteOnly) return;
                      Share.share(await DynamicLinksApi.inviteOnlyRoomLink(
                        widget.room.roomID!,
                        widget.room.id!,
                        roomName: widget.room.title!,
                        imageUrl: widget.room.imageUrl,
                        creatorName: widget.room.roomCreator ?? "",
                      ));
                    },
                    child: Text(
                      "Share Invite",
                    ),
                  ),

                  // if (false)
                  //   Switch(
                  //     value: isInviteOnly,
                  //     activeColor: GlobalColors.signUpSignInButton,
                  //     onChanged: (value) async {
                  //       if (_isAlreadyUpdatingData) return;
                  //       isInviteOnly = value;
                  //       _isAlreadyUpdatingData = true;
                  //       await changeInviteState();
                  //       _isAlreadyUpdatingData = false;
                  //       setState(() {});
                  //     },
                  //   ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: //isInviteOnly ?
                  1,
              // :
              // 0,
              duration: Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () async {
                  // Opacity will become zero
                  // if (!isInviteOnly) return;
                  Share.share(await DynamicLinksApi.inviteOnlyRoomLink(
                    widget.room.roomID!,
                    widget.room.id!,
                    roomName: widget.room.title!,
                    imageUrl: widget.room.imageUrl,
                    creatorName: widget.room.roomCreator ?? "",
                  ));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                        // Icon(
                        //   Icons.share_rounded,
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
    ) :
          SizedBox.shrink();
        }
      );
  }
}

class FollowersOnlyJoinButton extends StatefulWidget {
  final Widget joinButton;
  final Room room;
  const FollowersOnlyJoinButton(
      {Key? key, required this.room, required this.joinButton})
      : super(key: key);

  @override
  State<FollowersOnlyJoinButton> createState() =>
      _FollowersOnlyJoinButtonState();
}

class _FollowersOnlyJoinButtonState extends State<FollowersOnlyJoinButton> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      followerListenerSubscription;
  bool loading = true;
  bool doesUserFollowAuthor = false;

  User user = User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  UserService userServices = GetIt.I<UserService>();

  @override
  void initState() {
    checkDoesUserFollowAuthor();
    super.initState();
  }

  void getUser(Function() after) async {
    var value = await userServices.getUserById(widget.room.id!);
    if (value != null) {
      user = value;
      loading = false;
      // log('followers...');
      // log(user.followers.toString());
      after();
      setState(() {});
    }
  }

  void checkDoesUserFollowAuthor() async {
    getUser(() {
      if (user.followers?.contains(fa.FirebaseAuth.instance.currentUser!.uid) ??
          false) {
        doesUserFollowAuthor = true;
      } else {
        doesUserFollowAuthor = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (doesUserFollowAuthor) return widget.joinButton;
    if (loading)
      return Center(
        child: CircularProgressIndicator(
          color: GlobalColors.signUpSignInButton,
        ),
      );
    return Container(
      child: Column(
        children: [
          Text(
            'This is a Followers Only Room',
            style: TextStyle(
                color: Colors.black, fontSize: 12, fontFamily: "drawerbody"),
          ),
          ElevatedButton(
            child: Text('Follow Author'),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExternalProfilePage(user: user)));
              setState(() {
                loading = true;
              });
              checkDoesUserFollowAuthor();
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(GlobalColors.signUpSignInButton),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    followerListenerSubscription?.cancel();
    super.dispose();
  }
}
