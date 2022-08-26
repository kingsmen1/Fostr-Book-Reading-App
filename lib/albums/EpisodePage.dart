import 'dart:async';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/albums/BookMarkedList.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/SlidupPanel.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/AudioPlayerService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class EpisodePage extends StatefulWidget {
  final Map<String,dynamic> episode;
  final String authorUsername;
  const EpisodePage({
    Key? key,
    required this.episode,
    required this.authorUsername
  }) : super(key: key);

  @override
  State<EpisodePage> createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage> with FostrTheme {

  User? author = User.fromJson({
  "name": "user",
  "userName": "user",
  "id": "userId",
  "userType": "USER",
  "userProfile" : {
    "profileImage" : ""
  },
  "createdOn": DateTime.now().toString(),
  "lastLogin": DateTime.now().toString(),
  "invites": 10,
  });

  late Timestamp datetime;
  String finalDateTime = "";

  AudioPlayer player = AudioPlayer();
  bool isAudioAvailable = false;
  bool loading = false;
  bool isReadyToPlay = false;
  bool isPlaying = false;
  bool isFinished = false;
  Duration? audioDuration;
  StreamSubscription<Duration>? durationChangeSubscription;
  final AudioPlayerService _audioPlayerService = GetIt.I<AudioPlayerService>();

  int share_count = 0;
  int bookm_count = 0;
  List episodeList = [];
  List episodeNames = [];
  int episodeIndex = 0;

  @override
  void initState() {
    getAuthor();
    getEpisodeList();
    player = _audioPlayerService.player;
    final audioPlayerData = Provider.of<AudioPlayerData>(context, listen: false);

    setMediaData(audioPlayerData);

    player.getDuration().then((value) {
      if (mounted && audioPlayerData.mediaMeta.audioId == widget.episode['id']) {
        if (value > 0) {
          setState(() {
            audioDuration = Duration(milliseconds: value);
          });
        }
      }
    });

    if (widget.episode["dateTime"].runtimeType != Timestamp) {
      int seconds = int.parse(
          widget.episode["dateTime"].toString().split("_seconds: ")[1].split(", _")[0]);
      int nanoseconds = int.parse(
          widget.episode["dateTime"].toString().split("_nanoseconds: ")[1].split("}")[0]);
      datetime = Timestamp(seconds, nanoseconds);
    } else {
      datetime = widget.episode["dateTime"];
    }

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

    isAudioAvailable = true;

    checkShareCount();
    checkIfBookmarked();

    super.initState();
  }

  void setMediaData(AudioPlayerData audioPlayerData) async {
    if(audioPlayerData.mediaMeta.audioId == null){
      setState(() {
        loading = false;
      });
      audioPlayerData.setMediaMeta(
          MediaMeta(
              audioId: widget.episode["id"],
              audioName: widget.episode["title"],
              albumId: widget.episode['albumId'],
              userName: widget.authorUsername,
              episodeList: episodeList,
              episodeNames: episodeNames,
              episodeIndex: episodeList.indexOf(widget.episode["id"]),
              rawData: {
                "episode" : widget.episode
              },
              mediaType: MediaType.episode),
          shouldNotify: true);
    }
  }

  void getEpisodeList() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.episode['albumId'])
        .collection("episodes")
        .where("isActive", isEqualTo: true)
        .orderBy("dateTime", descending: true)
        .get()
        .then((value){
      value.docs.forEach((element) {
        setState(() {
          episodeList.add(element.id);
          episodeNames.add(element['title']);
        });
      });
    });
  }

  void getAuthor() async {
    await UserService().getUserById(widget.episode["authorId"])
        .then((value){
          setState(() {
            author = value;
          });
    });
  }

  // void _init() async {
  //   try {
  //     await player.setUrl(widget.episode["audio"]).then((value) {
  //       setState(() {
  //         audioDuration = value;
  //         isAudioAvailable = true;
  //         isReadyToPlay = true;
  //         isPlaying = true;
  //         loading = false;
  //       });
  //       player.play();
  //     });
  //   } catch (e) {
  //     debugPrint('An error occured $e');
  //   }
  // }

  @override
  void dispose() {
    durationChangeSubscription?.cancel();
    // player.dispose();
    super.dispose();
  }

  // void downloadWidget(String url) {
  //   setState(() {
  //     loading = true;
  //   });
  //   Future.delayed(Duration(milliseconds: 500), () {
  //     if (mounted) {
  //       // _init();
  //     }
  //   });
  // }

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
            // loading = true;
          });
          await player.setUrl(url);
          await player.resume();

          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        ToastMessege("Something went wrong", context: context);
      }
    }
  }

  void checkShareCount() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.episode['albumId'])
        .collection("episodes")
        .doc(widget.episode['id'])
        .get()
        .then((value){
      try {
        setState(() {
          share_count = value["shareCount"];
        });
      } catch (e) {
        setState(() {
          share_count = 0;
        });
      }
    });
  }

  void checkIfBookmarked() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.episode['albumId'])
        .collection("episodes")
        .doc(widget.episode['id'])
        .get()
        .then((value){
      try {
        List list = value["bookmark"].toList();
          setState(() {
            bookm_count = list.length;
          });
      } catch (e) {
        setState(() {
          bookm_count = 0;
        });
      }
    });
  }

  void deleteEpisode() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.episode["albumId"])
        .collection("episodes")
        .doc(widget.episode["id"])
        .update({
      "isActive" : false
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);


    if (durationChangeSubscription == null) {
      durationChangeSubscription = player.onDurationChanged.listen((event) {
        if (mounted) {
          if (widget.episode['id'] == audioPlayerData.mediaMeta.audioId) {
            setState(() {
              audioDuration = event;
              loading = false;
            });
          }
        }
      });
    }
    return Scaffold(

      backgroundColor: Colors.transparent,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange.shade200,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios,
                color: Colors.black)
        ),
        actions: [
          widget.episode['authorId'] == auth.user!.id ?
          IconButton(
            onPressed: () async {
              final delete = await confirmDialogEpisode(context, h2);
              if (delete != null && delete) {
                deleteEpisode();
                audioPlayerData.setMediaMeta(MediaMeta(),shouldNotify: true);
                _audioPlayerService.release();
                player.release();
                Navigator.pop(context);
              }
            },

            icon: Icon(Icons.delete,color: Colors.black, size: 25,),
          ) :
          Image.asset("assets/images/logo.png",
            fit: BoxFit.contain,
            width: 40,
            height: 40,),
          SizedBox(width: 10,)
        ],
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.orange.shade200,
          // borderRadius: BorderRadius.circular(60)
        ),
        child: Stack(
          children: [

            //white background
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 200,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        dark_blue,
                        theme.colorScheme.primary
                        //Color(0xFF2E3170)
                      ],
                      begin : Alignment.topCenter,
                      end : Alignment(0,-0.6),
                      // stops: [0,1]
                    ),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(70), topRight: Radius.circular(70))
                ),
              ),
            ),

            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    //image
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.episode['image'].toString().isEmpty ?
                        Center(child: Image.asset("assets/images/logo.png", width: 100, height: 100,)) :
                        Image.network(widget.episode['image'], fit: BoxFit.cover,),
                      ),
                    ),
                    SizedBox(height: 10,),

                    //title
                    Text(widget.episode['title'],
                      style: TextStyle(
                          color: theme.colorScheme.inversePrimary,
                          fontSize: 26,
                          fontFamily: "drawerhead"
                      ),
                    ),
                    SizedBox(height: 10,),

                    //datetime
                    Container(
                      width: MediaQuery.of(context).size.width-40,
                      child: Text(finalDateTime,
                        style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            fontFamily: "drawerbody"
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 5,),

                    //share and bookmark count
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
                                  color: Colors.black,
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
                                .collection("albums")
                                .doc(widget.episode['albumId'])
                                .collection("episodes")
                                .doc(widget.episode['id'])
                                .get()
                                .then((value){
                              try {
                                List list = value["bookmark"].toList();
                                Navigator.push(
                                    context, MaterialPageRoute(
                                    builder: (context) =>
                                        BookMarkedList(
                                            title: value["title"] ?? "",
                                            users: list
                                        )
                                ));
                              } catch (e) {
                                print("error fetching list $e");
                              }
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "drawerhead"),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5,),

                    //desc
                    Container(
                      width: MediaQuery.of(context).size.width-40,
                      child: Text(widget.episode['description'],
                        style: TextStyle(
                            color: theme.colorScheme.inversePrimary,
                            fontSize: 13,
                            fontFamily: "drawerbody"
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10,),

                    // //divider
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 10),
                    //   child: Container(
                    //     width: MediaQuery.of(context).size.width - 50,
                    //     height: 1,
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey,
                    //       borderRadius: BorderRadius.circular(1)
                    //     ),
                    //   ),
                    // ),
                    //
                    // //pause play seek bar
                    // // isAudioAvailable
                    // //     ? Padding(
                    // //   padding: const EdgeInsets.symmetric(
                    // //       horizontal: 20, vertical: 5),
                    // //   child: Row(
                    // //     mainAxisAlignment: MainAxisAlignment.start,
                    // //     children: [
                    // //       StreamBuilder<PlayerState>(
                    // //           stream: player.onPlayerStateChanged,
                    // //           builder: (context, snapshot) {
                    // //             bool isSameAudio = widget.episode['id'] ==
                    // //                 audioPlayerData.mediaMeta.audioId;
                    // //             var state = (isSameAudio)
                    // //                 ? player.state
                    // //                 : PlayerState.STOPPED;
                    // //
                    // //             return GestureDetector(
                    // //               onTap: () {
                    // //                 if (!isSameAudio) {
                    // //                   audioPlayerData.setMediaMeta(
                    // //                       MediaMeta(
                    // //                           audioId: widget.episode["id"],
                    // //                           audioName: widget.episode["title"],
                    // //                           userName: author!.userName,
                    // //                           rawData: {
                    // //                             "episode" : widget.episode
                    // //                           },
                    // //                           mediaType: MediaType.episode),
                    // //                       shouldNotify: true);
                    // //                 }
                    // //                 playPause(widget.episode["audio"], player.state,
                    // //                     isNewAudio: !isSameAudio);
                    // //               },
                    // //               child: Container(
                    // //                 width: 35,
                    // //                 height: 35,
                    // //                 decoration: BoxDecoration(
                    // //                     color:
                    // //                     theme.colorScheme.secondary,
                    // //                     borderRadius:
                    // //                     BorderRadius.circular(20)),
                    // //                 child: Center(
                    // //                   child: ClipRRect(
                    // //                     borderRadius:
                    // //                     BorderRadius.circular(20),
                    // //                     child: loading
                    // //                         ? AppLoading(
                    // //                       height: 70,
                    // //                       width: 70,
                    // //                     )
                    // //                         : (state !=
                    // //                         PlayerState.PLAYING)
                    // //                         ? Icon(
                    // //                       Icons.play_arrow,
                    // //                       size: 20,
                    // //                       color: Colors.white,
                    // //                     )
                    // //                         : Icon(
                    // //                       Icons.pause,
                    // //                       size: 20,
                    // //                       color: Colors.white,
                    // //                     ),
                    // //                   ),
                    // //                 ),
                    // //               ),
                    // //             );
                    // //           }),
                    // //       Expanded(
                    // //         child: Container(
                    // //           padding: const EdgeInsets.symmetric(
                    // //               horizontal: 20),
                    // //           height: 40,
                    // //           width: 200,
                    // //           child: Center(
                    // //             child: (audioPlayerData.mediaMeta.audioId ==
                    // //                 widget.episode["id"])
                    // //                 ? StreamBuilder<Duration>(
                    // //                 stream:
                    // //                 player.onAudioPositionChanged,
                    // //                 builder: (context, snapshot) {
                    // //                   return ProgressBar(
                    // //                     progress: snapshot.data ??
                    // //                         Duration.zero,
                    // //                     // buffered: buffered,
                    // //                     total: audioDuration ??
                    // //                         Duration.zero,
                    // //                     onSeek: (duration) {
                    // //                       player.seek(duration);
                    // //                     },
                    // //                     barHeight: 5,
                    // //                     baseBarColor: theme
                    // //                         .colorScheme.secondary
                    // //                         .withOpacity(0.5),
                    // //                     progressBarColor: theme
                    // //                         .colorScheme.secondary,
                    // //                     bufferedBarColor: theme
                    // //                         .colorScheme.secondary
                    // //                         .withOpacity(0.5),
                    // //                     thumbColor:
                    // //                     Colors.grey.shade300,
                    // //                     barCapShape:
                    // //                     BarCapShape.round,
                    // //                     thumbRadius: 10,
                    // //                     thumbCanPaintOutsideBar:
                    // //                     false,
                    // //                     timeLabelLocation:
                    // //                     TimeLabelLocation.below,
                    // //                     timeLabelType:
                    // //                     TimeLabelType.totalTime,
                    // //                     timeLabelTextStyle: TextStyle(
                    // //                         fontSize: 10,
                    // //                         color: theme.colorScheme
                    // //                             .inversePrimary,
                    // //                         fontFamily: "drawerbody"),
                    // //                     timeLabelPadding: 0,
                    // //                   );
                    // //                 })
                    // //                 : ProgressBar(
                    // //               progress: Duration.zero,
                    // //               // buffered: buffered,
                    // //               total: Duration.zero,
                    // //               onSeek: (duration) {
                    // //                 player.seek(duration);
                    // //               },
                    // //               barHeight: 5,
                    // //               baseBarColor: theme
                    // //                   .colorScheme.secondary
                    // //                   .withOpacity(0.5),
                    // //               progressBarColor:
                    // //               theme.colorScheme.secondary,
                    // //               bufferedBarColor: theme
                    // //                   .colorScheme.secondary
                    // //                   .withOpacity(0.5),
                    // //               thumbColor: Colors.grey.shade300,
                    // //               barCapShape: BarCapShape.round,
                    // //               thumbRadius: 10,
                    // //               thumbCanPaintOutsideBar: false,
                    // //               timeLabelLocation:
                    // //               TimeLabelLocation.below,
                    // //               timeLabelType:
                    // //               TimeLabelType.totalTime,
                    // //               timeLabelTextStyle: TextStyle(
                    // //                   fontSize: 10,
                    // //                   color: theme.colorScheme
                    // //                       .inversePrimary,
                    // //                   fontFamily: "drawerbody"),
                    // //               timeLabelPadding: 0,
                    // //             ),
                    // //           ),
                    // //         ),
                    // //       ),
                    // //     ],
                    // //   ),
                    // // )
                    // //     : Container(),
                    // //
                    // // //divider
                    // // Padding(
                    // //   padding: const EdgeInsets.symmetric(vertical: 10),
                    // //   child: Container(
                    // //     width: MediaQuery.of(context).size.width - 50,
                    // //     height: 1,
                    // //     decoration: BoxDecoration(
                    // //         color: Colors.grey,
                    // //         borderRadius: BorderRadius.circular(1)
                    // //     ),
                    // //   ),
                    // // ),
                    //
                    // //album
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: Container(
                    //     height: 40,
                    //     child: Row(
                    //       children: [
                    //         Text("Album",
                    //           style: TextStyle(
                    //               color: theme.colorScheme.inversePrimary,
                    //               fontSize: 16,
                    //               fontFamily: "drawerhead"
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: StreamBuilder<DocumentSnapshot>(
                    //     stream: FirebaseFirestore.instance
                    //         .collection("albums")
                    //         .doc(widget.episode["albumId"])
                    //       .snapshots(),
                    //     builder: (context, snapshot) {
                    //
                    //       if(!snapshot.hasData){
                    //         return SizedBox.shrink();
                    //       }
                    //
                    //       return GestureDetector(
                    //
                    //         onTap: (){
                    //           Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    //               AlbumPage(
                    //                 albumId: snapshot.data!["id"],
                    //                 authId: auth.user!.id,
                    //                 fromShare: true,
                    //               )));
                    //           // showModalBottomSheet(
                    //           //   context: context,
                    //           //   isScrollControlled: true,
                    //           //   backgroundColor: Colors.transparent,
                    //           //   builder: (context) => Padding(
                    //           //     padding: EdgeInsets.only(top: 100),
                    //           //     child: AlbumPage(
                    //           //       albumId: snapshot.data!["id"],
                    //           //       authId: auth.user!.id,
                    //           //       fromShare: false,
                    //           //     ),
                    //           //   ),
                    //           // );
                    //         },
                    //
                    //         child: Container(
                    //           height: 75,
                    //           child: Row(
                    //             children: [
                    //
                    //               //image
                    //               Container(
                    //                 width: 60,
                    //                 height: 60,
                    //                 decoration: BoxDecoration(
                    //                     color: Colors.transparent,
                    //                     border: Border.all(
                    //                         width: 1,
                    //                         color: snapshot.data!["image"].isEmpty ? Colors.grey : Colors.transparent
                    //                     ),
                    //                     borderRadius: BorderRadius.circular(10)
                    //                 ),
                    //                 child: ClipRRect(
                    //                   borderRadius: BorderRadius.circular(10),
                    //                   child: snapshot.data!["image"].toString().isEmpty ?
                    //                   Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                    //                   Image.network(snapshot.data!["image"], fit: BoxFit.cover,),
                    //                 ),
                    //               ),
                    //
                    //               //data
                    //               Padding(
                    //                 padding: const EdgeInsets.only(left: 10),
                    //                 child: Container(
                    //                   height: 60,
                    //                   child: Column(
                    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                     crossAxisAlignment: CrossAxisAlignment.start,
                    //                     children: [
                    //                       SizedBox(),
                    //                       Text(snapshot.data!["title"],style: TextStyle(fontSize: 16),),
                    //                       Text(snapshot.data!["authorName"],style: TextStyle(fontSize: 12),),
                    //                       Text("${snapshot.data!["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),),
                    //                       SizedBox(),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //               Expanded(child: Container()),
                    //
                    //               Icon(Icons.arrow_forward_ios, color: theme.colorScheme.secondary, size: 23,),
                    //               SizedBox(width: 5,)
                    //             ],
                    //           ),
                    //         ),
                    //       );
                    //     }
                    //   ),
                    // ),

                    //divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 1,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(1)
                        ),
                      ),
                    ),

                    //author
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 40,
                        child: Row(
                          children: [
                            Text("Author Profile",
                              style: TextStyle(
                                  color: theme.colorScheme.inversePrimary,
                                  fontSize: 16,
                                  fontFamily: "drawerhead"
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(

                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              ExternalProfilePage(user: author!)
                          ));
                        },

                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 75,
                          child: Row(
                            children: [

                              //image
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                        width: 1,
                                        color: author!.userProfile!.profileImage!.isEmpty ? Colors.grey : Colors.transparent
                                    ),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: author!.userProfile!.profileImage!.isEmpty ?
                                  Center(child: Image.asset("assets/images/logo.png", width: 30, height: 30,)) :
                                  Image.network(author!.userProfile!.profileImage!, fit: BoxFit.cover,),
                                ),
                              ),

                              //data
                              Expanded(
                                child: Container(
                                  height: 60,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(),
                                        SizedBox(),
                                        Text(author!.name,style: TextStyle(fontSize: 16),),
                                        Text(author!.userName,style: TextStyle(fontSize: 12),),
                                        SizedBox(),
                                        SizedBox(),

                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              //play
                              Icon(Icons.arrow_forward_ios, color: theme.colorScheme.secondary, size: 23,),
                              SizedBox(width: 5,)
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 200,)

                  ],
                ),
              ),
            ),

            SlidupPanel()

          ],
        ),
      ),

    );
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

Future<bool?> confirmDialogEpisode(BuildContext context, TextStyle h2) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final theme = Theme.of(context);
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
                constraints: BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete this episode?',
                      style: h2.copyWith(
                        fontSize: 15.sp,
                        color: theme.colorScheme.inversePrimary,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.secondary),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            "Cancel",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.secondary),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            "Delete",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.white,
                            ),
                          ),
                        )
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
