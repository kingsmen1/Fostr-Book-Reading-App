import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/albums/EnterAlbumDetails.dart';
import 'package:fostr/pages/user/AllLandingPage.dart';
import 'package:fostr/pages/user/userActivity/UserRecordings.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:provider/provider.dart';

class PodcastPage extends StatefulWidget {
  final bool enroute;
  const PodcastPage({Key? key, required this.enroute}) : super(key: key);

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {

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
    {
      "i" : 3, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 4, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 5, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 6, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 7, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 8, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 9, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
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
    {
      "i" : 3, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 4, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 5, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 6, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 7, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 8, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
    {
      "i" : 9, "podIds" : "", "podData" : {}, "podImages" : "", "podTitles" : "", "podAuthors" : "", "sharecnt" : 0, "bookmcnt" : 0,
    },
  ];

  // List podIds = ['','',''];
  // List podData = [{},{},{}];
  // List podImages = ['','',''];
  // List podTitles = ['','',''];
  // List podAuthors = ['','',''];
  // List sharecnt = [0,0,0];
  // List bookmcnt = [0,0,0];

  @override
  void initState() {
    getTrendingPodcasts();
    super.initState();
  }

  void getTrendingPodcasts() async {
    await FirebaseFirestore.instance
        .collection("recordings")
        .where("isActive", isEqualTo: true)
        .orderBy("dateTime", descending: true)
        .limit(10)
        .get()
        .then((value){

      for(int i = 0; i<10 ;i++){
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
        pods2[2]["sharecnt"] == 0 &&
        pods2[3]["sharecnt"] == 0 &&
        pods2[4]["sharecnt"] == 0 &&
        pods2[5]["sharecnt"] == 0 &&
        pods2[6]["sharecnt"] == 0 &&
        pods2[7]["sharecnt"] == 0 &&
        pods2[8]["sharecnt"] == 0 &&
        pods2[9]["sharecnt"] == 0) {
      setState(() {
        pods2.sort((a, b) => (b["bookmcnt"]).compareTo(a["bookmcnt"]));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    sortPodsByBookmarkCount();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Container(
            height: 50,
            child: TabBar(
              indicatorColor: Colors.white,
              labelStyle: TextStyle(
                  color: theme.colorScheme.inversePrimary,
                  fontSize: 16,
                  fontFamily: "drawerbody"),
              tabs: [
                Tab(
                  child: Text(
                    "Recordings",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "drawerhead"
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Podcasts",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "drawerhead"
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15) +
              const EdgeInsets.only(bottom: 10),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: new BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: new BorderRadius.circular(10),
              // only(
              //   topLeft: const Radius.circular(10),
              //   topRight: const Radius.circular(10),
              // ),
            ),
            child: TabBarView(
              children: [

                ///recordings
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [

                          //trending
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [

                                Text("Trending",
                                  style: TextStyle(
                                      color: theme.colorScheme.inversePrimary,
                                      fontSize: 16,
                                      fontFamily: 'drawerhead',
                                      fontWeight: FontWeight.bold
                                  ),),
                                Expanded(child: Container()),

                                //goto
                                IconButton(
                                    onPressed: (){
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => UserRecorings(page: 0,),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.arrow_forward_ios_rounded,color: theme.colorScheme.secondary, size: 20,)
                                ),

                              ],
                            ),
                          ),
                          ListView.builder(
                              itemCount: pods2.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {

                                print("podcasts length ------------------ ${pods2.length}");
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GestureDetector(

                                    onTap: (){

                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => UserRecorings(page: index
                                          // index == 0 ?
                                          // pods2[0]["i"] :
                                          // index == 1 ?
                                          // pods2[1]["i"] :
                                          // pods2[2]["i"]
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
                          Divider(),

                        ],
                      ),
                    ),
                  ),
                ),


                ///podcasts
                SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [

                        //Trending
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [

                              Text("Trending",
                                style: TextStyle(
                                    color: theme.colorScheme.inversePrimary,
                                    fontSize: 16,
                                    fontFamily: 'drawerhead',
                                    fontWeight: FontWeight.bold
                                ),),
                              Expanded(child: Container(height: 50,)),

                              //goto
                              // IconButton(
                              //     onPressed: (){
                              //
                              //     },
                              //     icon: Icon(Icons.arrow_forward_ios_rounded,color: theme.colorScheme.secondary, size: 20,)
                              // ),

                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 50,
                              constraints: BoxConstraints(
                                  minHeight: 50,
                                  maxHeight: 190
                              ),
                              child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("albums")
                                        // .orderBy("dateTime", descending: true)
                                        .orderBy("episodes", descending: true)
                                        .where("isActive", isEqualTo: true)
                                        .limit(4)
                                        .snapshots(),
                                    builder: (context, snapshot) {

                                      if(!snapshot.hasData || snapshot.data!.docs.length==0){
                                        return Text("Checkout new albums",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                          itemCount: 4,
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {

                                            if(index == 3){
                                              return Container(width: 40,);
                                            }

                                            // if(index != snapshot.data!.docs.length)
                                            return StreamBuilder<DocumentSnapshot>(
                                                stream: FirebaseFirestore.instance
                                                    .collection("albums")
                                                    .doc(snapshot.data!.docs[index].id)
                                                    .snapshots(),
                                                builder: (context, snap) {

                                                  if(!snap.hasData){
                                                    return SizedBox.shrink();
                                                  }

                                                  return snap.data!["isActive"] ?
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 10),
                                                    child: GestureDetector(

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
                                                        //       albumId: snapshot.data!.docs[index].id,
                                                        //       authId: auth.user!.id,
                                                        //       fromShare: false,
                                                        //     ),
                                                        //   ),
                                                        // );
                                                      },

                                                      child: SizedBox(
                                                        width: 130,
                                                        height: 180,
                                                        child: Column(
                                                          children: [

                                                            //image
                                                            Container(
                                                              width: 120,
                                                              height: 120,
                                                              decoration: BoxDecoration(
                                                                  color: Colors.grey,
                                                                  borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(10),
                                                                child: snap.data!['image'].toString().isEmpty ?
                                                                Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                                                                Image.network(snap.data!["image"], fit: BoxFit.cover,),
                                                              ),
                                                            ),

                                                            //data
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: Container(
                                                                height: 60,
                                                                width: 120,
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    SizedBox(),
                                                                    Text(snap.data!["title"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis,),
                                                                    Text("by ${snap.data!["authorName"]}",style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
                                                                    Text("${snap.data!["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
                                                                    SizedBox(),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ) :
                                                  SizedBox.shrink();
                                                }
                                            );

                                            // return SizedBox.shrink();
                                          }
                                      );
                                    }
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),

                        //Recently Played
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [

                              Text("Recently Played",
                                style: TextStyle(
                                    color: theme.colorScheme.inversePrimary,
                                    fontSize: 16,
                                    fontFamily: 'drawerhead',
                                    fontWeight: FontWeight.bold
                                ),),
                              Expanded(child: Container(height: 50,)),

                              //goto
                              // IconButton(
                              //     onPressed: (){
                              //
                              //     },
                              //     icon: Icon(Icons.arrow_forward_ios_rounded,color: theme.colorScheme.secondary, size: 20,)
                              // ),

                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 50,
                              constraints: BoxConstraints(
                                  minHeight: 50,
                                  maxHeight: 190
                              ),
                              child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("album_continue_playing")
                                        .doc(auth.user!.id)
                                        .collection("album_continue_playing")
                                        .orderBy("dateTime", descending: true)
                                        .where("isActive", isEqualTo: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {

                                      if(!snapshot.hasData || snapshot.data!.docs.length==0){
                                        return Text("Checkout new albums",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                          itemCount: snapshot.data!.docs.length + 1,
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {

                                            if(index == snapshot.data!.docs.length){
                                              return Container(width: 40,);
                                            }

                                            // if(index != snapshot.data!.docs.length)
                                            return StreamBuilder<DocumentSnapshot>(
                                                stream: FirebaseFirestore.instance
                                                    .collection("albums")
                                                    .doc(snapshot.data!.docs[index].id)
                                                    .snapshots(),
                                                builder: (context, snap) {

                                                  if(!snap.hasData){
                                                    return SizedBox.shrink();
                                                  }

                                                  return snap.data!["isActive"] ?
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 10),
                                                    child: GestureDetector(

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
                                                        //       albumId: snapshot.data!.docs[index].id,
                                                        //       authId: auth.user!.id,
                                                        //       fromShare: false,
                                                        //     ),
                                                        //   ),
                                                        // );
                                                      },

                                                      child: SizedBox(
                                                        width: 130,
                                                        height: 180,
                                                        child: Column(
                                                          children: [

                                                            //image
                                                            Container(
                                                              width: 120,
                                                              height: 120,
                                                              decoration: BoxDecoration(
                                                                  color: Colors.grey,
                                                                  borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(10),
                                                                child: snap.data!['image'].toString().isEmpty ?
                                                                Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                                                                Image.network(snap.data!["image"], fit: BoxFit.cover,),
                                                              ),
                                                            ),

                                                            //data
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: Container(
                                                                height: 60,
                                                                width: 120,
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    SizedBox(),
                                                                    Text(snap.data!["title"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis,),
                                                                    Text("by ${snap.data!["authorName"]}",style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
                                                                    Text("${snap.data!["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
                                                                    SizedBox(),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ) :
                                                  SizedBox.shrink();
                                                }
                                            );

                                            // return SizedBox.shrink();
                                          }
                                      );
                                    }
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),

                        //Podcasts
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [

                              Text("Podcasts",
                                style: TextStyle(
                                    color: theme.colorScheme.inversePrimary,
                                    fontSize: 16,
                                    fontFamily: 'drawerhead',
                                    fontWeight: FontWeight.bold
                                ),),
                              Expanded(child: Container(height: 50,)),

                              //goto
                              // IconButton(
                              //     onPressed: (){
                              //
                              //     },
                              //     icon: Icon(Icons.arrow_forward_ios_rounded,color: theme.colorScheme.secondary, size: 20,)
                              // ),

                            ],
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("albums")
                                .orderBy("dateTime", descending: true)
                                .where("isActive", isEqualTo: true)
                                .snapshots(),
                            builder: (context, snapshot) {

                              if(!snapshot.hasData){
                                return Text("no albums available");
                              }

                              return GridView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
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
                                        //       albumId: snapshot.data!.docs[index].id,
                                        //       authId: auth.user!.id,
                                        //       fromShare: false,
                                        //     ),
                                        //   ),
                                        // );
                                      },

                                      child: SizedBox(
                                        height: 220,
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
                                                    Text(snapshot.data!.docs[index]["authorName"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
                                                    Text("${snapshot.data!.docs[index]["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
                                                    SizedBox(),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
