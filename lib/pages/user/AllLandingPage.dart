import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/Posts/AllPosts.dart';
import 'package:fostr/Posts/FeedPostCard.dart';
import 'package:fostr/Posts/HighlightPostCard.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/albums/AllAlbums.dart';
import 'package:fostr/albums/PodcastEnrote.dart';
import 'package:fostr/albums/PodcastPage.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/widgets/SwipeCardWidget.dart';
import 'package:fostr/pages/user/liveRooms.dart';
import 'package:fostr/pages/user/userActivity/UserRecordings.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/FeedProvider.dart';
import 'package:fostr/reviews/FeedReviewCard.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/InAppNotificationService.dart';
import 'package:fostr/services/NotificationService.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/theatre/TheatreHomePage.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/rooms/Profile.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as prf;
import 'package:swipe_cards/swipe_cards.dart';

class AllLandingPage extends StatefulWidget {
  final bool? refresh;
  final List newUsers;
  const AllLandingPage({Key? key, this.refresh, required this.newUsers}) : super(key: key);

  @override
  _AllLandingPageState createState() => _AllLandingPageState();
}

class _AllLandingPageState extends State<AllLandingPage> {
  final prf.RefreshController _refreshController =
      prf.RefreshController(initialRefresh: false);

  List<Map<String,dynamic>> pods = [
    {
      "i" : 0, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 1, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 2, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
  ];

  List<Map<String,dynamic>> pods2 = [
    {
      "i" : 0, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 1, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 2, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
  ];

  // List podIds = ['','',''];
  // List podData = [{},{},{}];
  // List podImages = ['','',''];
  // List podTitles = ['','',''];
  // List podAuthors = ['','',''];
  // List sharecnt = [0,0,0];
  // List bookmcnt = [0,0,0];
  // List newUsers = [];
  //
  //
  // void getNewUsers() async {
  //
  //   dynamic list = await UserService().getRecentUser();
  //   list.forEach((element) {
  //     setState(() {
  //       newUsers.add(element);
  //     });
  //   });
  //
  //   // await FirebaseFirestore.instance
  //   //     .collection("users")
  //   //     .orderBy("createdOn", descending: true)
  //   //     .where("createdOn", isGreaterThan: DateTime.now().subtract(Duration(days: 10)).toIso8601String())
  //   //     .get()
  //   //     .then((value){
  //   //       value.docs.forEach((element) {
  //   //         setState(() {
  //   //           newUsers.add(element.id);
  //   //         });
  //   //       });
  //   // });
  // }

  ScrollController scrollController = new ScrollController();
  bool show = false;

  @override
  void initState() {

    scrollController.addListener(() {
      if(scrollController.offset > 100){
        setState(() {
          show = true;
        });
      } else {
        setState(() {
          show = false;
        });
      }
    });

    // getNewUsers();
    getTrendingPodcasts();
    super.initState();
  }

  void getTrendingPodcasts() async {
    await FirebaseFirestore.instance
        .collection("recordings")
        .where("isActive", isEqualTo: true)
        .orderBy("dateTime", descending: true)
        .limit(3)
        .get()
        .then((value){

      for(int i = 0; i<3 ;i++){
        value.docs[i]["type"] == "ROOM" ?
        RoomService().getRoomById(
            value.docs[i]["roomId"],
            value.docs[i]["userId"]
        ).then((room) {
          setState((){
            pods[i]["podIds"] = (value.docs[i].id);
            pods[i]["podData"] = (value.docs[i].data());
            pods[i]["podImages"] = (room!.imageUrl);
            pods[i]["podTitles"] = (room.title);
            pods[i]["podAuthors"] = (room.roomCreator);
            getCounts(i);
          });
        }) :
        TheatreService().getTheatreById(
            value.docs[i]["roomId"],
            value.docs[i]["userId"]
        ).then((theatre){
          setState((){
            pods[i]["podIds"] = (value.docs[i].id);
            pods[i]["podData"] = (value.docs[i].data());
            pods[i]["podImages"] = (theatre!.imageUrl);
            pods[i]["podTitles"] = (theatre.title);
            pods[i]["podAuthors"] = (theatre.creatorUsername);
            getCounts(i);
          });
        });
      }
    });
  }

  void getCounts(int index) async {
    await FirebaseFirestore.instance
        .collection("recordings")
        .doc(pods[index]["podIds"])
        .get()
        .then((value){
      List bcnt = [];
      int scnt = 0;
      try{
        bcnt = value["bookmark"].toList();
        setState(() {
          pods[index]["bookmcnt"] = bcnt.length;
          // sortPodsByShareCount();
          // sortPodsByBookmarkCount();
        });
      } catch (e) {
        setState(() {
          pods[index]["bookmcnt"] = 0;
          // sortPodsByShareCount();
          // sortPodsByBookmarkCount();
        });
      }

      try{
        scnt = value["shareCount"];
        setState(() {
          pods[index]["sharecnt"] = scnt;
          sortPodsByShareCount();
          // sortPodsByBookmarkCount();
        });
      } catch (e) {
        setState(() {
          pods[index]["sharecnt"] = 0;
          sortPodsByShareCount();
          // sortPodsByBookmarkCount();
        });
      }
    });

  }

  void sortPodsByShareCount() async {
    setState(() {
      pods.sort((a, b) => (b["sharecnt"]).compareTo(a["sharecnt"]));
      pods2 = pods;
    });
  }

  void sortPodsByBookmarkCount() async {
    if(pods2[0]["sharecnt"] == 0 &&
        pods2[1]["sharecnt"] == 0 &&
        pods2[2]["sharecnt"] == 0) {
      setState(() {
        pods2.sort((a, b) => (b["bookmcnt"]).compareTo(a["bookmcnt"]));
      });
    }
    // if(pods[0]["sharecnt"] == 0 &&
    // pods[1]["sharecnt"] == 0 &&
    // pods[2]["sharecnt"] == 0) {
    //   setState(() {
    //     pods.sort((a, b) => (b["bookmcnt"]).compareTo(a["bookmcnt"]));
    //     pods2 = pods;
    //   });
    // }
    ///
    // else if (pods[0]["sharecnt"] == 0 &&
    //     pods[1]["sharecnt"] == 0) {
    //   setState(() {
    //     pods2[0].addAll(pods[2]);
    //     pods2[1].addAll(pods[0]);
    //     pods2[2].addAll(pods[1]);
    //   });
    // } else if (pods[0]["sharecnt"] == 0 &&
    //     pods[2]["sharecnt"] == 0) {
    //   setState(() {
    //     pods2[0].addAll(pods[1]);
    //     pods2[1].addAll(pods[0]);
    //     pods2[2].addAll(pods[2]);
    //   });
    // } else if (pods[1]["sharecnt"] == 0 &&
    //     pods[2]["sharecnt"] == 0) {
    //   setState(() {
    //     pods2[0].addAll(pods[0]);
    //     pods2[1].addAll(pods[1]);
    //     pods2[2].addAll(pods[2]);
    //   });
    // } else if(pods[0]["sharecnt"] == 0)
    // {
    //   setState(() {
    //     if(pods[1]["sharecnt"] > pods[2]["sharecnt"]){
    //       pods2[0].addAll(pods[1]);
    //       pods2[1].addAll(pods[2]);
    //     } else {
    //       pods2[0].addAll(pods[2]);
    //       pods2[1].addAll(pods[1]);
    //     }
    //     pods2[2].addAll(pods[0]);
    //   });
    // } else if(pods[1]["sharecnt"] == 0)
    // {
    //   setState(() {
    //     if(pods[0]["sharecnt"] > pods[2]["sharecnt"]){
    //       pods2[0].addAll(pods[0]);
    //       pods2[1].addAll(pods[2]);
    //     } else {
    //       pods2[0].addAll(pods[2]);
    //       pods2[1].addAll(pods[0]);
    //     }
    //     pods2[2].addAll(pods[1]);
    //   });
    // } else if(pods[2]["sharecnt"] == 0)
    // {
    //   setState(() {
    //     if(pods[1]["sharecnt"] > pods[2]["sharecnt"]){
    //       pods2[0].addAll(pods[1]);
    //       pods2[1].addAll(pods[0]);
    //     } else {
    //       pods2[0].addAll(pods[0]);
    //       pods2[1].addAll(pods[1]);
    //     }
    //     pods2[2].addAll(pods[2]);
    //   });
    // }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final feedsProvider = Provider.of<FeedProvider>(context);
    sortPodsByBookmarkCount();

    return Stack(
      children: [

        AnimatedPositioned(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          top: show ? 0 : MediaQuery.of(context).size.width * 0.5,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 500),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              )
            ),
          ),
        ),

        Positioned.fill(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [

                //swipe cards
                // StreamBuilder<QuerySnapshot>(
                //   stream: FirebaseFirestore.instance
                //     .collection("feeds")
                //     .where("idType", isEqualTo: "reviews")
                //     .where("isActive", isEqualTo: true)
                //     .orderBy("dateTime", descending: true)
                //     // .limit(7)
                //     .snapshots(),
                //   builder: (context, snapshot) {
                //     if(!snapshot.hasData){
                //       return SizedBox.shrink();
                //     }
                //
                //     List list = [];
                //     snapshot.data!.docs.forEach((element) {
                //       list.add(element.id);
                //     });
                //
                //     return SwipeCardWidget(bitIds: list);
                //
                //   }
                // ),
                SizedBox(height: 20,),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: RotationTransition(
                        turns: new AlwaysStoppedAnimation(-7 / 360),
                        child: Container(
                          width: 350,
                          height: 350,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.secondary,
                                      dark_blue
                                      //Color(0xFF2E3170)
                                    ],
                                    begin : Alignment.topCenter,
                                    end : Alignment.bottomCenter,
                                    stops: [0,0.92]
                                ),
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                        child: SwipeCardWidget()),
                  ],
                ),
                SizedBox(height: 20,),

                //daily highlights
                Row(
                  children: [
                    SizedBox(width: 15,),
                    Text("Daily Highlights",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'drawerhead'
                      ),),
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AllPosts(page: "home")
                            ));
                      },
                      icon: Icon(Icons.arrow_forward_ios,size: 20,color: Colors.black,),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                FutureBuilder<FeedResponse>(
                  future: feedsProvider.getFeed(),
                  builder: (context, AsyncSnapshot<FeedResponse> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        height: MediaQuery.of(context).size.height - 350,
                        child: Center(
                          child: AppLoading(
                            height: 150,
                            width: 150,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        "error occured",
                      );
                    }

                    final data = snapshot.data!;
                    if (data.feeds.length == 0) {
                      return Container(
                        height: MediaQuery.of(context).size.height - 350,
                        child: Center(
                          child: Text(
                            "No Feeds Available",
                          ),
                        ),
                      );
                    }

                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 160,
                      // height: MediaQuery.of(context).size.height,
                      // width: MediaQuery.of(context).size.width,
                      // child: RefreshIndicator(
                      //   onRefresh: () async {
                      //     await feedsProvider.refreshFeed(true);
                      //     _refreshController.refreshCompleted();
                      //   },
                      //   color: theme.colorScheme.secondary,
                      //   backgroundColor: theme.colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          itemCount: data.length + 1,
                          scrollDirection: Axis.horizontal,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == data.length)
                              return GestureDetector(

                                onTap: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AllPosts(page: "home")
                                      ));
                                },

                                child: Container(height:80,child: Center(child: Row(
                                  children: [
                                    Text("see all",style: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey),),
                                    SizedBox(width: 3,),
                                    Icon(Icons.arrow_forward_ios,size: 15,color: theme.colorScheme.secondary,)
                                  ],
                                ))),
                              );
                            final type = data.feeds[index]["type"];
                            final feed = data.feeds[index]["data"];
                            String id = feed["id"] ?? "";
                            if (type == "room") {
                              id = feed["roomID"];
                            } else if (type == "theatre") {
                              id = feed["theatreId"];
                            }

                            return FeedCard(
                              feed: feed,
                              feedType: type,
                              key: Key(id),
                            );
                          },
                        ),
                      ),
                      // ),
                    );
                  },
                ),
                SizedBox(height: 10,),

                //From the community
                Row(
                  children: [
                    SizedBox(width: 15,),
                    Text("From the community",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'drawerhead'
                      ),),
                  ],
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 170,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 140,
                          child: ListView.builder(
                            itemCount: widget.newUsers.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (context, index) {

                              return NewUserCard(
                                id: widget.newUsers[index],
                                index: index,
                              );
                            },
                            // separatorBuilder: (BuildContext context, int index) {
                            //   return Padding(
                            //     padding: const EdgeInsets.symmetric(horizontal: 10),
                            //     child: Container(
                            //       width: 1,
                            //       height: 110,
                            //       color: Colors.grey,
                            //     ),
                            //   );
                            // },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10,),

                //Recordings
                Row(
                  children: [
                    SizedBox(width: 15,),
                    Text("Recordings",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'drawerhead'
                      ),),
                    Expanded(child: Container()),
                    IconButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => UserRecorings(page: 0,),
                            ),
                          );
                        },
                        icon: Icon(Icons.arrow_forward_ios_rounded,color: Colors.black, size: 20,)
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ListView.builder(
                      itemCount: pods2.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(

                            onTap: (){

                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => UserRecorings(page:
                                  index == 0 ?
                                  pods2[0]["i"] :
                                  index == 1 ?
                                  pods2[1]["i"] :
                                  pods2[2]["i"]
                                    ,),
                                ),
                              );

                            },

                            child: PodcastTile(
                                podImage: pods2[index]["podImages"],
                                podTitle: pods2[index]["podTitles"],
                                podAuthor: pods2[index]["podAuthors"],
                                podId: pods2[index]["podIds"]
                            ),
                          ),
                        );
                      }
                  ),
                ),
                SizedBox(height: 10,),

                //Suggested Podcasts
                Row(
                  children: [
                    SizedBox(width: 15,),
                    Text("Suggested Podcasts",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'drawerhead'
                      ),),
                    Expanded(child: Container()),
                    IconButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => AllAlbums(),
                            ),
                          );
                        },
                        icon: Icon(Icons.arrow_forward_ios_rounded,color: Colors.black, size: 20,)
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("albums")
                          .orderBy("dateTime", descending: true)
                          .where("isActive", isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {

                        if(!snapshot.hasData){
                          return Text("no albums available");
                        }

                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (context, index){
                              return GestureDetector(

                                onTap: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          AlbumPage(
                                            albumId: snapshot.data!.docs[index].id,
                                            authId: auth.user!.id,
                                            fromShare: true,
                                          )
                                      ));
                                  // showModalBottomSheet(
                                  //   context: context,
                                  //   isScrollControlled: true,
                                  //   backgroundColor: Colors.transparent,
                                  //   builder: (context) => Padding(
                                  //     padding: EdgeInsets.only(top: 100),
                                  //     child: AlbumPage(
                                  //       albumId: snapshot.data!.docs[index]["id"],
                                  //       authId: auth.user!.id,
                                  //       fromShare: false,
                                  //     ),
                                  //   ),
                                  // );
                                },

                                child: Padding(
                                  padding: EdgeInsets.only(left: 15,right: snapshot.data!.docs.length-1==index? 15 : 0),
                                  child: Container(
                                    height: 200,
                                    child: Column(
                                      children: [

                                        //image
                                        Container(
                                          width: 140,
                                          height: 140,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                  width: 1,
                                                  color: snapshot.data!.docs[index]["image"].isEmpty ? Colors.grey : Colors.transparent
                                              ),
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: snapshot.data!.docs[index]["image"].toString().isEmpty ?
                                            Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                                            Image.network(snapshot.data!.docs[index]["image"], fit: BoxFit.cover,),
                                          ),
                                        ),

                                        //data
                                        Padding(
                                          padding: const EdgeInsets.only(left: 0),
                                          child: Container(
                                            height: 60,
                                            width: 130,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(),
                                                Text(snapshot.data!.docs[index]["title"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
                                                Text('by ${snapshot.data!.docs[index]["authorName"]}',style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),overflow: TextOverflow.ellipsis),
                                                Text("${snapshot.data!.docs[index]["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
                                                SizedBox(),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        );
                      }
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FeedCard extends StatefulWidget {
  final Map<String, dynamic> feed;
  final String feedType;
  const FeedCard({Key? key, required this.feed, required this.feedType})
      : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final auth = Provider.of<AuthProvider>(context);

    return widget.feedType == "post" ?
    HighlightPostCard(feed: widget.feed) :
    SizedBox.shrink();

    // switch (widget.feedType) {
      // case "review":
      //   return FeedReviewCard(
      //     feed: widget.feed,
      //     page: 'feed',
      //   );

      // case "post":
      //   return
        //   FeedPostCard(
        //   feed: widget.feed,
        //   page: 'feed',
        // );

      // case "room":
      //   return LiveRoomCardSingle(
      //       widget.feed, Room.fromJson(widget.feed, "change"), "all", auth.user!.id);
      //
      // case "theatre":
      //   return TheatreCard(
      //       theatre: Theatre.fromJson(widget.feed, "change"),
      //       userid: auth.user!.id,isInviteOnly: widget.feed["isInviteOnly"] ?? false,);

      // default:
      //   return Text(
      //     "",
      //   );
    // }
  }

  @override
  bool get wantKeepAlive => false;
}

class PodcastTile extends StatefulWidget {
  final String podImage;
  final String podTitle;
  final String podAuthor;
  final String podId;
  const PodcastTile({Key? key,
    required this.podImage,
    required this.podTitle,
    required this.podAuthor,
    required this.podId,
  }) : super(key: key);

  @override
  State<PodcastTile> createState() => _PodcastTileState();
}

class _PodcastTileState extends State<PodcastTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return widget.podId.isEmpty ?
        SizedBox.shrink() :
      Container(
      height: 95,
      child: Row(
        children: [

          //image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                    width: 1,
                    color: widget.podImage.toString().isEmpty ?
                    Colors.grey :
                    Colors.transparent
                ),
                borderRadius: BorderRadius.circular(10)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.podImage.toString().isEmpty ?
              Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
              Image.network(widget.podImage, fit: BoxFit.cover,),
            ),
          ),

          //data
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Text(widget.podTitle.trim(),style: TextStyle(fontSize: 16),)),
                  Text("by ${widget.podAuthor}",style: TextStyle(fontSize: 12),),
                  SizedBox(),
                  Row(
                    children: [
                      SvgPicture.asset("assets/icons/blue_share.svg", width: 15, height: 15,),
                      // Icon(Icons.share, size: 15,),
                      SizedBox(width: 5,),
                      // Text(sharecnt[index].toString(),style: TextStyle(fontSize: 10),),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("recordings")
                              .doc(widget.podId)
                              .snapshots(),
                          builder: (context, snapshot) {

                          int cnt = 0;
                          try{
                            cnt = snapshot.data!["shareCount"];
                          } catch (e) {
                            cnt = 0;
                          }

                          if(!snapshot.hasData){
                            return Text("0",style: TextStyle(fontSize: 10),);
                          }

                          return Text(cnt.toString(),style: TextStyle(fontSize: 10),);
                        }
                      ),

                      SizedBox(width: 10,),

                      Icon(Icons.bookmark,color: theme.colorScheme.secondary, size: 15,),
                      SizedBox(width: 5,),
                      // Text(bookmcnt[index].toString(),style: TextStyle(fontSize: 10)),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("recordings")
                              .doc(widget.podId)
                              .snapshots(),
                          builder: (context, snapshot) {

                            List cnt = [];
                            try{
                              cnt = snapshot.data!["bookmark"].toList();
                            } catch (e) {
                              cnt = [];
                            }

                            if(!snapshot.hasData){
                              return Text("0",style: TextStyle(fontSize: 10),);
                            }

                            return Text(cnt.length.toString(),style: TextStyle(fontSize: 10),);
                          }
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NewUserCard extends StatefulWidget {
  final String id;
  final int index;
  const NewUserCard({Key? key, required this.id, required this.index}) : super(key: key);

  @override
  State<NewUserCard> createState() => _NewUserCardState();
}

class _NewUserCardState extends State<NewUserCard>
    with FostrTheme  {

  UserService userService = GetIt.I<UserService>();
  User usermodel = User.fromJson({
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
  bool isFollowed = false;

  List colors = [
    Colors.pink.shade300,
    Colors.deepPurple.shade400,
    Colors.deepOrange.shade300,
    Colors.indigo,
    Colors.blueAccent,
    Colors.teal,
    Colors.green.shade700,
    Colors.orangeAccent,
    Colors.pinkAccent.shade700
  ];
  final _random = new Random();
  Color color = Colors.grey;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    setState(() {
      color = colors[_random.nextInt(colors.length)];
    });
    userService.getUserById(widget.id).then((value){
      usermodel = value!;
    });
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.user!;
    final InAppNotificationService _inAppNotificationService =
    GetIt.I<InAppNotificationService>();

    if (currentUser.followings != null) {
      if (currentUser.followings!.contains(widget.id)) {
        isFollowed = true;
      }
    }



    return widget.id == currentUser.id
              ? SizedBox.shrink() :
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
              .collection("users")
              .doc(widget.id)
              .snapshots(),
            builder: (context, snapshot) {

              if(!snapshot.hasData){
                return SizedBox.shrink();
              }

              bool dataAvailable = true;
              try{
                String id = snapshot.data!["id"];
                dataAvailable = true;
              } catch (e) {
                dataAvailable = false;
              }

              // print(snapshot.data!["id"]);
              return dataAvailable ?
                snapshot.data!["followers"].contains(auth.user!.id) ?
                  SizedBox.shrink() :
                GestureDetector(

                onTap: (){
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) {
                        {
                          return ExternalProfilePage(
                            user: usermodel,
                          );
                        }
                      },
                    ),
                  );
                },

                child: Row(
                  children: [
                    Container(
                      width: 110,
                      height: 140,
                      child: Column(
                        children: [

                          //image
                          (usermodel.userProfile!.profileImage == null ||
                              usermodel.userProfile!.profileImage == "" ||
                              usermodel.userProfile!.profileImage == "null") ?

                              Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle
                                ),
                                child: Center(
                                  child: Text(snapshot.data!["userName"].toString().characters.first.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontFamily: "drawerbody"
                                  ),),
                                ),
                              ) :

                          RoundedImage(
                            url: usermodel.userProfile!.profileImage,
                            // snapshot.data!["userProfile"]["profileImage"],
                            width: 75,
                            height: 75,
                          ),

                          //username
                          Container(
                            width: 75,
                            height: 20,
                            child: Center(
                              child: Text(snapshot.data!["userName"],
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,),
                            ),
                          ),

                          //follow button
                          InkWell(
                            onTap: () async {
                              if (!isFollowed) {
                                var newUser = await userService.followUser(
                                    auth.user!, usermodel);
                                setState(() {
                                  isFollowed = true;
                                });
                                auth.refreshUser(newUser);
                                List<String> deviceTokens = [];
                                if (usermodel.deviceToken != null) {
                                  deviceTokens.add(usermodel.deviceToken!);
                                }
                                if (usermodel.notificationToken != null &&
                                    deviceTokens.isEmpty) {
                                  deviceTokens.add(usermodel.notificationToken!);
                                }
                                final payload = NotificationPayload(
                                    type: NotificationType.Follow,
                                    tokens: deviceTokens,
                                    data: {
                                      "tokens": deviceTokens,
                                      "senderUserId": currentUser.id,
                                      "senderUserName": currentUser.userName,
                                      "senderToken": currentUser.deviceToken ??
                                          currentUser.notificationToken,
                                      "authToken": "",
                                      "recipientUserId": usermodel.id,
                                      "recipientUserName": usermodel.userName,
                                      "title":
                                      "Your community is growing! ${currentUser.userName} is now following you",
                                      "body": "",
                                      "payload": {
                                        "userId": currentUser.id,
                                      }
                                    });

                                await _inAppNotificationService
                                    .sendNotification(payload);
                                ToastMessege("Followed Successfully!",
                                    context: context);
                              } else {
                                var newUser = await userService.unfollowUser(
                                    auth.user!, usermodel);
                                setState(() {
                                  isFollowed = false;
                                });
                                auth.refreshUser(newUser);
                                ToastMessege("Unfollowed Successfully!",
                                    context: context);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                alignment: Alignment.center,
                                width: 75,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: !isFollowed
                                        ? theme.colorScheme.secondary
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: !isFollowed
                                            ? Colors.white
                                            : Colors.grey,
                                        width: 1)),
                                child: Center(
                                  child: Text(
                                    (!isFollowed) ? "Follow" : "Unfollow",
                                    style: h1.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontFamily: "drawerbody",
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    //divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        width: 1,
                        height: 120,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ) :
              SizedBox.shrink();
            }
          );
  }
}

