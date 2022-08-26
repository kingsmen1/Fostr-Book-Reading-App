import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/PageSinglePost.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/albums/SinglePodcastPlay.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/AllLandingPage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/goToReviews.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:provider/provider.dart';

class BookMarkedActivties extends StatefulWidget {
  final String authId;
  const BookMarkedActivties({
    Key? key,
    required this.authId
  }) : super(key: key);

  @override
  State<BookMarkedActivties> createState() => _BookMarkedActivtiesState();
}

class _BookMarkedActivtiesState extends State<BookMarkedActivties> {

  List posts = [];
  List<Map<String, dynamic>> podcasts = [];
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> recordings = [];
  bool loading = true;

  @override
  void initState() {
    getReviews();
    getPosts();
    getRecordings();
    getPodcasts();
    super.initState();
  }

  void getReviews() async {
    try{
      await FirebaseFirestore.instance
          .collection("reviews")
          .where("isActive", isEqualTo: true)
          .where("bookmark",arrayContains: widget.authId)
          .get()
          .then((value){
        value.docs.forEach((element) {
          setState(() {
            reviews.add({
              "id" : element.id
            });
          });
        });
      });
    } catch(e) {}
  }

  void getPosts() async {
    List list = [];

    await FirebaseFirestore.instance
    .collection("posts")
    .where("isActive", isEqualTo: true)
    .get()
    .then((value){

      value.docs.forEach((p) async {
        try{
          await FirebaseDatabase.instance
              .ref()
              .child('Posts')
              .child(p.id.replaceAll(" ", "_").replaceAll(".", "_"))
              .child('likes')
              .get()
              .then((value) {
            value.children.forEach((element) {
              if ((element.value as Map)['liked'] == true) {
                if(!posts.contains(p.id)){
                  setState(() {
                    posts.add(p.id);
                  });
                }
              }
            });
          });
        } catch(e) {}
      });
    });
  }

  void getRecordings() async {
    try{
      await FirebaseFirestore.instance
          .collection("recordings")
          .where("isActive", isEqualTo: true)
          .where("bookmark",arrayContains: widget.authId)
          .get()
          .then((value){
        value.docs.forEach((element) {
          setState(() {
            recordings.add({
              "id" : element.id
            });
          });
        });
      });
    } catch(e) {}
  }

  void getPodcasts() async {
    try{
      await FirebaseFirestore.instance
          .collection("albums")
          .where("isActive", isEqualTo: true)
          .where("bookmark",arrayContains: widget.authId)
          .get()
          .then((value){
        value.docs.forEach((element) {
          setState(() {
            podcasts.add({
              "id" : element.id
            });
          });
        });
      });
    } catch(e) {}
  }

  int selectedIndex = 0;
  final genres = [
    'Reviews',
    'Readings',
    'Recordings',
    'Podcasts',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,

      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 50),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                dark_blue,
                theme.colorScheme.primary
                //Color(0xFF2E3170)
              ],
              begin : Alignment.topCenter,
              end : Alignment(0,0.8),
              // stops: [0,1]
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment(-0.9,0.6),
                child: Container(
                  height: 50,
                  width: 20,
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios,color: Colors.black,),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0,0.6),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Bookmarked Activities',
                      style: TextStyle(fontSize: 20,color: Colors.black,fontFamily: "drawerhead"),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.95,0.6),
                child: Container(
                  height: 50,
                  width: 50,
                  child: Center(
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [

            //chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, top: 16),
                    height: 51,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: ClampingScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = i;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                  color: i == selectedIndex
                                      ? dark_blue
                                      : Colors.white,
                                  border: Border.all(width: 0.5,color: dark_blue),
                                  borderRadius: BorderRadius.circular(24)),
                              child: Center(
                                child: Text(
                                  genres[i],
                                  style: TextStyle(
                                      color: i == selectedIndex
                                          ? Colors.white
                                          : dark_blue,
                                      fontFamily: "drawerbody"),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),

            //data
            Padding(
              padding: const EdgeInsets.only(top: 50) + EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: MediaQuery.of(context).size.height - 125,
                width: MediaQuery.of(context).size.width - 20,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                          SizedBox(height: 20,),

                          reviews.length > 0 && selectedIndex == 0
                              ? ListView.builder(
                              itemCount: reviews.length,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {

                                if(index >= reviews.length){
                                  return SizedBox.shrink();
                                }

                                return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection("reviews")
                                        .doc(reviews[index]["id"])
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if(!snapshot.hasData){
                                        return SizedBox.shrink();
                                      }
                                      return BitTile(bit: snapshot.data!.data()!, authId: snapshot.data!["editorId"]);
                                    }
                                );
                              })
                              : SizedBox.shrink(),

                          ///searching posts
                          posts.length > 0 && selectedIndex == 1
                              ? GridView.builder(
                              itemCount: posts.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                              itemBuilder: (context, index){

                                return StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("posts")
                                        .doc(posts[index])
                                        .snapshots(),
                                    builder: (context, post) {

                                      if(!post.hasData){
                                        return SizedBox.shrink();
                                      }

                                      String title = "";
                                      try{
                                        title = post.data!["bookName"] ?? "";
                                      } catch(e){}

                                      return GestureDetector(

                                        onTap: (){

                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) {
                                                  return PageSinglePost(
                                                    postId: post.data!["id"],
                                                    dateTime: post.data!["dateTime"],
                                                    userid: post.data!["userid"],
                                                    userProfile: post.data!["userProfile"],
                                                    username: post.data!["username"],
                                                    image: post.data!["image"],
                                                    caption: post.data!["caption"],
                                                    likes: post.data!["likes"].toString(),
                                                    comments: post.data!["comments"].toString(),
                                                  );
                                                },
                                              ),
                                            );
                                        },

                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                              child: FosterImage(
                                                  imageUrl: post.data!["image"],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                );
                              }
                          )
                              : SizedBox.shrink(),
                          posts.length == 0 && selectedIndex == 1
                              ? AppLoading(width: 70, height: 70,)
                              : SizedBox.shrink(),

                          ///searching recordings
                          recordings.length > 0 && selectedIndex == 2
                              ? ListView.builder(
                              itemCount: recordings.length,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, index) {

                                if(index >= recordings.length){
                                  return SizedBox.shrink();
                                }

                                return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection("recordings")
                                        .doc(recordings[index]["id"])
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if(!snapshot.hasData){
                                        return SizedBox.shrink();
                                      }
                                      return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                                          stream: FirebaseFirestore.instance
                                              .collection("rooms")
                                              .doc(snapshot.data!["userId"])
                                              .collection("rooms")
                                              .doc(snapshot.data!["roomId"])
                                              .snapshots(),
                                          builder: (context, room){
                                            if(!room.hasData){
                                              return SizedBox.shrink();
                                            }

                                            return GestureDetector(

                                              onTap: () async {

                                                Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                    builder: (context) =>
                                                        SinglePodcastPlay(recId: recordings[index]["id"]),
                                                  ),
                                                );
                                              },

                                              child: PodcastTile(
                                                  podImage: room.data!["image"],
                                                  podTitle: room.data!["title"],
                                                  podAuthor: room.data!["roomCreator"],
                                                  podId: recordings[index]["id"]
                                              ),
                                            );
                                          }
                                      );
                                    }
                                );
                              })
                              : SizedBox.shrink(),

                          ///searching albums
                          podcasts.length > 0 && selectedIndex == 3
                              ? GridView.builder(
                              itemCount: podcasts.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
                              itemBuilder: (context, index){
                                return StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("albums")
                                        .doc(podcasts[index]["id"])
                                        .snapshots(),
                                    builder: (context, album) {

                                      if(!album.hasData){
                                        return SizedBox.shrink();
                                      }

                                      return GestureDetector(

                                        onTap: (){

                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) =>
                                                    AlbumPage(
                                                      albumId: podcasts[index]["id"],
                                                      authId: album.data!["authorId"],
                                                      fromShare: true,
                                                    )
                                                ));
                                        },

                                        child: Container(
                                          height: 220,
                                          child: Column(
                                            children: [
                                              Expanded(child: Container()),

                                              //image
                                              Container(
                                                width: 140,
                                                height: 140,
                                                decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    border: Border.all(
                                                        width: 1,
                                                        color: album.data!["image"].isEmpty ? Colors.grey : Colors.transparent
                                                    ),
                                                    borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: album.data!["image"].toString().isEmpty ?
                                                  Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                                                  Image.network(album.data!["image"], fit: BoxFit.fill,),
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
                                                      Text(album.data!["title"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
                                                      Text(album.data!["authorName"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
                                                      Text("${album.data!["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
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
                          )
                              : SizedBox.shrink(),

                          SizedBox(height: 50,)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      );
  }
}
