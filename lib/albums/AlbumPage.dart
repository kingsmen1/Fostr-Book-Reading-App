import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/albums/BookMarkedList.dart';
import 'package:fostr/albums/EnterEpisodeDetails.dart';
import 'package:fostr/albums/EpisodePage.dart';
import 'package:fostr/albums/SingleEpisodePlay.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/SlidupPanel.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/AudioPlayerService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import '../pages/user/userActivity/UserRecordings.dart';
import '../utils/theme.dart';

class AlbumPage extends StatefulWidget {
  final String albumId;
  final String authId;
  final bool fromShare;
  const AlbumPage({
    Key? key,
    required this.albumId,
    required this.authId,
    required this.fromShare
  }) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> with FostrTheme {

  Map<String, dynamic> album = {
    "episodes" : 0,
    "authorId" : "",
    "authorName" : "",
    "authorUserName" : "",
    "authorProfile" : "",
    "id" : "",
    "title" : "",
    "description" : "",
    "genre" : "",
    "image" : "",
    "playCount" : 0,
    "bookmarkCount" : 0,
    "isActive" : true,
    "dateTime" : DateTime.now().toUtc()
  };

  bool followed = false;
  bool bookmarked = false;
  int bookm_count = 0;
  int share_count = 0;
  List bookmarkUsers = [];

  @override
  void initState() {
    getAlbumData();
    checkIfBookmarked();
    checkShareCount();
    super.initState();
  }

  void getAlbumData() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .get()
        .then((value) async {
          setState(() {
            album = value.data()!;
          });
    });
}

  void followUnfollowAlbum(bool followed) async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .update({
      "followers" : !followed ? FieldValue.arrayUnion([widget.authId]) : FieldValue.arrayRemove([widget.authId])
    });
  }

  void updateContinuePlaying() async {
    await FirebaseFirestore.instance
        .collection("album_continue_playing")
        .doc(widget.authId)
        .collection("album_continue_playing")
        .doc(widget.albumId)
        .set({
      "albumId" : widget.albumId,
      "dateTime" : DateTime.now(),
      "isActive" : true
    },SetOptions(merge: true));
  }

  void share() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .set({
          "shareCount" : FieldValue.increment(1)
        }, SetOptions(merge: true)).then((value) {
          setState(() {
            share_count++;
          });
        });
  }

  void checkShareCount() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
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

  void bookmark(String authId) async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .set({
          "bookmark" : !bookmarked ? FieldValue.arrayRemove([authId]) : FieldValue.arrayUnion([authId])
        }, SetOptions(merge: true)).then((value){
          setState(() {
            !bookmarked ? bookm_count-- : bookm_count++;
          });
        });
  }

  void checkIfBookmarked() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .get()
        .then((value){
        try {
          List list = value["bookmark"].toList();
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
  }

  void deleteAlbum() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .update({
      "isActive" : false
    });
    try{
      await FirebaseFirestore.instance
          .collection('booksearch')
          .doc(album["title"].toString().toLowerCase().trim())
          .collection("activities")
          .doc(widget.albumId)
          .delete();
    } catch(e) {}
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(60)
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: Colors.orange.shade200,
        //   centerTitle: true,
        //   title: Text(album["genre"], style: TextStyle(fontSize: 18,
        //       color: Colors.black),),
        //   automaticallyImplyLeading: false,
        //   leading: IconButton(
        //       onPressed: (){
        //     Navigator.pop(context);
        //   },
        //       icon: Icon(Icons.arrow_back_ios,
        //           color: Colors.black)
        //  ),
        //   actions: [
        //     Image.asset("assets/images/logo.png", width: 45, height: 45,),
        //   ],
        // ),

        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color: Colors.orange.shade200,
              borderRadius: BorderRadius.circular(60)
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  !widget.fromShare?
                  SizedBox(height: 30,)
                      :SizedBox.shrink(),

                  widget.fromShare?
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 20,
                      height: 70,
                      color: Colors.orange.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        IconButton(
                              onPressed: (){
                            Navigator.pop(context);
                          },
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Colors.black)
                         ),
                          Image.asset("assets/images/logo.png", width: 45, height: 45,),
                        ],
                      ),
                    ),
                  )
                  :SizedBox.shrink(),

                  //share,image,bookmark
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        //share
                        Container(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  share();
                                  final url = await DynamicLinksApi.fosterAlbumsLink(
                                  widget.authId,
                                  widget.albumId);
                                  Share.share(url);
                                },
                                  child: SvgPicture.asset("assets/icons/blue_share.svg",width: 30, height: 30,),
                                  // Icon(Icons.share,color: Colors.black, size: 28,)
                              ),
                            ],
                          ),
                        ),

                        Expanded(child: Container(),),
                        Container(
                          width: 200,
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: album['image'].toString().isEmpty ?
                                Center(child: Image.asset("assets/images/logo.png", width: 100, height: 100,)) :
                            Image.network(album['image'], fit: BoxFit.cover,),
                          ),
                        ),
                        Expanded(child: Container(),),

                        //bookmark
                        Container(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      bookmarked = !bookmarked;
                                    });
                                    bookmark(widget.authId);
                                  },
                                  child: bookmarked ?
                                  Icon(Icons.bookmark, size: 30,color: theme.colorScheme.secondary,) :
                                  Icon(Icons.bookmark_border_rounded, size: 30,color: theme.colorScheme.secondary,),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),

                  //title
                  Container(
                    width: MediaQuery.of(context).size.width-40,
                    child: Text(album['title'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontFamily: "drawerhead"
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10,),

                  //author
                  Container(
                    width: MediaQuery.of(context).size.width-40,
                    child: Text("by ${album['authorName']}",
                      style: TextStyle(
                      color: Colors.black,
                          fontSize: 13,
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
                              .doc(widget.albumId)
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
                  SizedBox(height: 10,),

                  //desc
                  Container(
                    width: MediaQuery.of(context).size.width-40,
                    child: Text(album['description'],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: "drawerbody"
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10,),
                  // Expanded(child: Container(color: theme.colorScheme.primary,)),

                  //episodes
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        // color: theme.colorScheme.primary,
                          gradient: LinearGradient(
                            colors: [
                              dark_blue,
                              theme.colorScheme.primary
                              //Color(0xFF2E3170)
                            ],
                            begin : Alignment.topCenter,
                            end : Alignment(0,-0.7),
                            // stops: [0,1]
                          ),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 20,),
                            Container(
                              height: 40,
                              child: Row(
                                children: [
                                  Text("All Episodes",
                                    style: TextStyle(
                                        color: theme.colorScheme.inversePrimary,
                                        fontSize: 16,
                                        fontFamily: "drawerhead"
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  auth.user!.id == album["authorId"] ?
                                      IconButton(
                                        onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                              EnterEpisodeDetails(
                                                albumId: album["id"],
                                                albumImage: album['image'],
                                                authorId: album["authorId"],
                                              )
                                          ));
                                        },

                                        icon: Icon(Icons.add,color: theme.colorScheme.secondary, size: 30,),
                                      ) :
                                      SizedBox.shrink(),

                                  auth.user!.id == album["authorId"] ?
                                  IconButton(
                                    onPressed: () async {
                                      final delete = await confirmDialogAlbum(context, h2);
                                      if (delete != null && delete) {
                                        deleteAlbum();
                                        Navigator.pop(context);
                                      }
                                    },

                                    icon: Icon(Icons.delete,color: theme.colorScheme.secondary, size: 28,),
                                  ) :
                                  SizedBox.shrink(),

                                      //follow button
                                      // GestureDetector(
                                      //
                                      //   onTap: () {
                                      //     followUnfollowAlbum(followed);
                                      //     setState(() {
                                      //       followed = !followed;
                                      //     });
                                      //   },
                                      //
                                      //   child: Container(
                                      //     width: 100,
                                      //     height: 30,
                                      //     decoration: BoxDecoration(
                                      //       color: followed ? Colors.transparent : theme.colorScheme.secondary,
                                      //       border: Border.all(
                                      //         width: 1,
                                      //         color: theme.colorScheme.secondary
                                      //       ),
                                      //       borderRadius: BorderRadius.circular(15)
                                      //     ),
                                      //     child: Center(
                                      //       child: Text(followed ? "unfollow" : "follow",
                                      //         style: TextStyle(
                                      //           color: followed ? theme.colorScheme.secondary : Colors.white
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // )
                                ],
                              ),
                            ),

                            Expanded(
                              child: Container(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                    .collection("albums")
                                    .doc(widget.albumId)
                                    .collection("episodes")
                                    .where("isActive", isEqualTo: true)
                                    .orderBy("dateTime", descending: true)
                                    .snapshots(),

                                  builder: (context, snapshot) {

                                    if(!snapshot.hasData){
                                      return Text("No episodes yet");
                                    }

                                    return ListView.separated(
                                        itemCount: snapshot.data!.docs.length + 1,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        scrollDirection: Axis.vertical,
                                        physics: ClampingScrollPhysics(),
                                        itemBuilder: (context, index) {

                                          if(index == snapshot.data!.docs.length){
                                            return SizedBox(height: 200,);
                                          }

                                          return EpisodeTile(
                                            authId: widget.authId,
                                              albumId: widget.albumId,
                                              episodeId: snapshot.data!.docs[index].id,
                                            audio: snapshot.data!.docs[index]['audio'],
                                            title: snapshot.data!.docs[index]['title'],
                                            username: album['authorUserName'],
                                          );
                                        },
                                      separatorBuilder: (BuildContext context, int index) {
                                          return //divider
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 3),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width - 20,
                                                height: 1,
                                                color: Colors.grey,
                                              ),
                                            );
                                      },
                                    );
                                  }
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  )

                ],
              ),

              // Align(
              //   alignment: Alignment.topCenter,
              //   child: Container(
              //     width: MediaQuery.of(context).size.width,
              //     height: MediaQuery.of(context).size.height,
              //     color: Colors.transparent,
              //     child: SingleChildScrollView(
              //       physics: BouncingScrollPhysics(),
              //       child: Padding(
              //         padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5),
              //         child: Expanded(
              //           child: Container(
              //                 decoration: BoxDecoration(
              //                   // color: theme.colorScheme.primary,
              //                     gradient: LinearGradient(
              //                       colors: [
              //                         dark_blue,
              //                         theme.colorScheme.primary
              //                         //Color(0xFF2E3170)
              //                       ],
              //                       begin : Alignment.topCenter,
              //                       end : Alignment(0,-0.7),
              //                       // stops: [0,1]
              //                     ),
              //                   borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))
              //                 ),
              //             child: Padding(
              //               padding: const EdgeInsets.symmetric(horizontal: 10),
              //               child: Column(
              //                 mainAxisAlignment: MainAxisAlignment.start,
              //                 children: [
              //                   SizedBox(height: 20,),
              //                   Container(
              //                     height: 40,
              //                     child: Row(
              //                       children: [
              //                         Text("All Episodes",
              //                           style: TextStyle(
              //                               color: theme.colorScheme.inversePrimary,
              //                               fontSize: 16,
              //                               fontFamily: "drawerhead"
              //                           ),
              //                         ),
              //                         Expanded(child: Container()),
              //                         auth.user!.id == album["authorId"] ?
              //                         IconButton(
              //                           onPressed: (){
              //                             Navigator.push(context, MaterialPageRoute(builder: (context) =>
              //                                 EnterEpisodeDetails(
              //                                   albumId: album["id"],
              //                                   albumImage: album['image'],
              //                                   authorId: album["authorId"],
              //                                 )
              //                             ));
              //                           },
              //
              //                           icon: Icon(Icons.add,color: theme.colorScheme.secondary, size: 30,),
              //                         ) :
              //                         SizedBox.shrink(),
              //
              //                         auth.user!.id == album["authorId"] ?
              //                         IconButton(
              //                           onPressed: () async {
              //                             final delete = await confirmDialogAlbum(context, h2);
              //                             if (delete != null && delete) {
              //                               deleteAlbum();
              //                               Navigator.pop(context);
              //                             }
              //                           },
              //
              //                           icon: Icon(Icons.delete,color: theme.colorScheme.secondary, size: 28,),
              //                         ) :
              //                         SizedBox.shrink(),
              //
              //                         //follow button
              //                         // GestureDetector(
              //                         //
              //                         //   onTap: () {
              //                         //     followUnfollowAlbum(followed);
              //                         //     setState(() {
              //                         //       followed = !followed;
              //                         //     });
              //                         //   },
              //                         //
              //                         //   child: Container(
              //                         //     width: 100,
              //                         //     height: 30,
              //                         //     decoration: BoxDecoration(
              //                         //       color: followed ? Colors.transparent : theme.colorScheme.secondary,
              //                         //       border: Border.all(
              //                         //         width: 1,
              //                         //         color: theme.colorScheme.secondary
              //                         //       ),
              //                         //       borderRadius: BorderRadius.circular(15)
              //                         //     ),
              //                         //     child: Center(
              //                         //       child: Text(followed ? "unfollow" : "follow",
              //                         //         style: TextStyle(
              //                         //           color: followed ? theme.colorScheme.secondary : Colors.white
              //                         //         ),
              //                         //       ),
              //                         //     ),
              //                         //   ),
              //                         // )
              //                       ],
              //                     ),
              //                   ),
              //
              //                   Container(
              //                     child: StreamBuilder<QuerySnapshot>(
              //                         stream: FirebaseFirestore.instance
              //                             .collection("albums")
              //                             .doc(widget.albumId)
              //                             .collection("episodes")
              //                             .where("isActive", isEqualTo: true)
              //                             .orderBy("dateTime", descending: true)
              //                             .snapshots(),
              //
              //                         builder: (context, snapshot) {
              //
              //                           if(!snapshot.hasData){
              //                             return Text("No episodes yet");
              //                           }
              //
              //                           return ListView.separated(
              //                             itemCount: snapshot.data!.docs.length,
              //                             shrinkWrap: true,
              //                             padding: EdgeInsets.zero,
              //                             scrollDirection: Axis.vertical,
              //                             physics: ClampingScrollPhysics(),
              //                             itemBuilder: (context, index) {
              //
              //                               return EpisodeTile(
              //                                 authId: widget.authId,
              //                                 albumId: widget.albumId,
              //                                 episodeId: snapshot.data!.docs[index].id,
              //                                 audio: snapshot.data!.docs[index]['audio'],
              //                                 title: snapshot.data!.docs[index]['title'],
              //                                 username: album['authorUserName'],
              //                               );
              //                             },
              //                             separatorBuilder: (BuildContext context, int index) {
              //                               return //divider
              //                                 Padding(
              //                                   padding: const EdgeInsets.only(bottom: 3),
              //                                   child: Container(
              //                                     width: MediaQuery.of(context).size.width - 20,
              //                                     height: 1,
              //                                     color: Colors.grey,
              //                                   ),
              //                                 );
              //                             },
              //                           );
              //                         }
              //                     ),
              //                   )
              //
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              SlidupPanel()
            ],
          ),
        ),

      ),
    );
  }
}

class EpisodeTile extends StatefulWidget {
  final String authId;
  final String albumId;
  final String episodeId;
  final String audio;
  final String title;
  final String username;
  const EpisodeTile({
    Key? key,
    required this.authId,
    required this.albumId,
    required this.episodeId,
    required this.audio,
    required this.title,
    required this.username
  }) : super(key: key);

  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {

  late Timestamp datetime;
  String finalDateTime = "";
  AudioPlayer player = AudioPlayer();
  final AudioPlayerService _audioPlayerService = GetIt.I<AudioPlayerService>();

  bool bookmarked = false;
  int share_count = 0;
  int bookm_count = 0;

  List episodeList = [];
  List episodeNames = [];
  int episodeIndex = 0;

  @override
  void initState() {
    player = _audioPlayerService.player;
    // print("line 622 albumPage ${_audioPlayerService.player.state.name}");
    getEpisodeList();
    checkIfBookmarked();
    checkShareCount();
    super.initState();
  }

  void getEpisodeList() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
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
    }).then((value){
      print(episodeList);
      print(episodeNames);
    });
  }

  void play() async {
    await player.setUrl(widget.audio).then((value) async {
      await player.resume().then((value){
        setState(() {
          _audioPlayerService;
        });
      });
    });
  }

  void updateContinuePlaying() async {
    await FirebaseFirestore.instance
        .collection("album_continue_playing")
        .doc(widget.authId)
        .collection("album_continue_playing")
        .doc(widget.albumId)
        .set({
      "albumId" : widget.albumId,
      "dateTime" : DateTime.now(),
      "isActive" : true
    },SetOptions(merge: true));
  }

  void bookmark(String authId) async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .collection("episodes")
        .doc(widget.episodeId)
        .set({
      "bookmark" : !bookmarked ? FieldValue.arrayRemove([authId]) : FieldValue.arrayUnion([authId])
    }, SetOptions(merge: true));
  }

  void checkIfBookmarked() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .collection("episodes")
        .doc(widget.episodeId)
        .get()
        .then((value){
      try {
        List list = value["bookmark"].toList();
          setState(() {
            bookmarked = list.contains(widget.authId) ? true : false;
            bookm_count = list.length;
          });
      } catch (e) {
        setState(() {
          bookmarked = false;
        });
      }
    });
  }

  void share() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .collection("episodes")
        .doc(widget.episodeId)
        .set({
          "shareCount" : FieldValue.increment(1)
        }, SetOptions(merge: true));
  }

  void checkShareCount() async {
    await FirebaseFirestore.instance
        .collection("albums")
        .doc(widget.albumId)
        .collection("episodes")
        .doc(widget.episodeId)
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

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("albums")
            .doc(widget.albumId)
            .collection("episodes")
            .doc(widget.episodeId)
            .snapshots(),

        builder: (context, episode) {

          if(!episode.hasData){
            return SizedBox.shrink();
          }

          if (episode.data!["dateTime"].runtimeType != Timestamp) {
            int seconds = int.parse(
                episode.data!["dateTime"].toString().split("_seconds: ")[1].split(", _")[0]);
            int nanoseconds = int.parse(
                episode.data!["dateTime"].toString().split("_nanoseconds: ")[1].split("}")[0]);
            datetime = Timestamp(seconds, nanoseconds);
          } else {
            datetime = episode.data!["dateTime"];
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

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(

              onTap: (){
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => EpisodePage(
                        episode: episode.data!.data()!,
                      authorUsername: widget.username,
                    ),
                  ),
                );
              },

              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [

                    //image and title
                    Row(
                      children: [

                        //image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  width: 1,
                                  color: episode.data!["image"].toString().isEmpty ? Colors.grey : Colors.transparent
                              ),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: episode.data!["image"].toString().isEmpty ?
                            Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                            Image.network(episode.data!["image"], fit: BoxFit.fill,),
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
                                  Text(episode.data!["title"],style: TextStyle(fontSize: 16),),
                                  //share and bookmark count
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [

                                      share_count < 1 ?
                                      SizedBox.shrink() :
                                      Row(
                                        children: [
                                          SvgPicture.asset("assets/icons/blue_share.svg",width: 18, height: 18,),
                                          // Icon(Icons.share, size: 15,color: theme.colorScheme.inversePrimary,),
                                          SizedBox(width: 5,),
                                          Text(
                                            "${share_count}" ,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme.inversePrimary,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "drawerhead"),
                                          ),
                                          SizedBox(width: 10,),
                                        ],
                                      ),

                                      bookm_count < 1 ?
                                      SizedBox.shrink() :
                                      Row(
                                        children: [
                                          Icon(Icons.bookmark_border_rounded, size: 17,color: theme.colorScheme.secondary,),
                                          SizedBox(width: 5,),
                                          Text(
                                            "${bookm_count}" ,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme.inversePrimary,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "drawerhead"),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(),

                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),

                    //description
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                          child: Text(episode.data!["description"],
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            textAlign: TextAlign.left,
                          )),
                    ),

                    //date
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Text(finalDateTime,style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),),
                        ],
                      ),
                    ),

                    //icons
                    Row(
                      children: [
                        //share
                        GestureDetector(
                          onTap: () async {
                            share();
                            final url = await DynamicLinksApi.fosterEpisodeLink(
                              widget.episodeId, widget.albumId, widget.username
                            );
                            Share.share(url);
                          },
                            child: SvgPicture.asset("assets/icons/blue_share.svg"),
                            // Icon(Icons.share, color: theme.colorScheme.inversePrimary, size: 25,)
                        ),
                        SizedBox(width: 20,),

                        //bookmark
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              bookmarked = !bookmarked;
                            });
                            bookmark(widget.authId);
                          },
                            child: bookmarked ?
                            Icon(Icons.bookmark, size: 25,color: theme.colorScheme.secondary,) :
                            Icon(Icons.bookmark_border_rounded, size: 25,color: theme.colorScheme.secondary,),
                        ),
                        Expanded(child: Container()),

                        //play
                        GestureDetector(
                          onTap: (){
                            if(audioPlayerData.mediaMeta.audioId == widget.episodeId &&
                                _audioPlayerService.player.state.name == "PLAYING") {
                              setState((){
                                _audioPlayerService.player.pause();
                                player.pause();
                              });

                            }
                            else if (audioPlayerData.mediaMeta.audioId == widget.episodeId &&
                                _audioPlayerService.player.state.name != "PLAYING"){
                              setState(() {
                                _audioPlayerService.player.resume();
                                player.resume();
                              });

                            }
                            else if (audioPlayerData.mediaMeta.audioId != widget.episodeId){
                              getEpisodeList();
                              setState(() {
                                audioPlayerData.setMediaMeta(
                                    MediaMeta(
                                        audioId: widget.episodeId,
                                        audioName: widget.title,
                                        albumId: widget.albumId,
                                        userName: widget.username,
                                        episodeList: episodeList,
                                        episodeNames: episodeNames,
                                        episodeIndex: episodeList.indexOf(widget.episodeId),
                                        rawData: {
                                          "episode" : episode.data!.data()
                                        },
                                        mediaType: MediaType.episode
                                    ), shouldNotify: true);
                              });
                              play();
                              updateContinuePlaying();
                            }
                            // print("line 949 albumPage ${_audioPlayerService.player.state.name}");
                          },
                            child:
                            (audioPlayerData.mediaMeta.audioId == widget.episodeId &&
                            _audioPlayerService.player.state == PlayerState.PLAYING ||
                                _audioPlayerService.player.state == PlayerState.COMPLETED) ?
                            Icon(Icons.pause_circle_outline_rounded, color: Colors.deepOrange, size: 35,) :
                            Icon(Icons.play_circle_outline_rounded, color: theme.colorScheme.secondary, size: 35,)),
                        SizedBox(width: 5,)
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}

Future<bool?> confirmDialogAlbum(BuildContext context, TextStyle h2) async {
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
                      'Are you sure you want to delete this album?',
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
