import 'dart:core';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/PageSinglePost.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/albums/SinglePodcastPlay.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:fostr/pages/user/AllLandingPage.dart';
import 'package:fostr/pages/user/ISBNPage.dart';
import 'package:fostr/pages/user/userActivity/UserRecordings.dart';
import 'package:fostr/reviews/goToReviews.dart';
import 'package:fostr/services/SearchServices.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ToastMessege.dart';

class CollectionPage extends StatefulWidget {
  final String bookname;
  const CollectionPage({Key? key, required this.bookname}) : super(key: key);

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {

  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> albums = [];
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> recordings = [];
  bool loading = true;

  bool showMore = false;

  String image = "";
  String author = "";
  String link = "";
  String description = "";

  @override
  void initState() {
    getBookInfo();
    getData();
    super.initState();
  }

  @override
  void dispose() {
    reviews.clear();
    recordings.clear();
    albums.clear();
    posts.clear();
    super.dispose();
  }

  void getData() async {
              SearchServices().getActivitesByBookName(widget.bookname).then((data){
                // print("data $data");
                setState(() {
                  data["data"].forEach((element){

                    if(element["activitytype"] == SearchType.review.name){
                      reviews.add({
                        "id" : element["activityid"],
                        "uid" : element["creatorid"]
                      });
                      loading = false;
                    } else if(element["activitytype"] == SearchType.recording.name){
                      recordings.add({
                        "id" : element["activityid"],
                        "uid" : element["creatorid"]
                      });
                      loading = false;
                    } else if(element["activitytype"] == SearchType.post.name){
                      posts.add({
                        "id" : element["activityid"],
                        "uid" : element["creatorid"]
                      });
                      loading = false;
                    } else if(element["activitytype"] == SearchType.album.name){
                      albums.add({
                        "id" : element["activityid"],
                        "uid" : element["creatorid"]
                      });
                      loading = false;
                    }
                  });
                });
              });
              Future.delayed(Duration(seconds: 2)).then((value){
                setState(() {
                  loading = false;
                });
              });
  }

  void getBookInfo() async {
    try{
      await FirebaseFirestore.instance
          .collection("booksearch")
          .doc(widget.bookname)
          .get()
          .then((book){
           setState(() {
             author = book["author"].toString().split("[")[1].split("]")[0];
             image = book["image"];
             link = book["url"];
             description = book["description"];
           });
      });
    } catch(e){}
  }

  @override
  Widget build(BuildContext buildContext) {
    final theme = Theme.of(buildContext);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Text(widget.bookname,
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'drawerbody'
          ),),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios,)
        ),
        actions: [
          Image.asset(
            "assets/images/logo.png",
            width: 50,
          )
        ],
      ),

      body: Stack(
        children: [

          //image
          image.isNotEmpty ?
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width - 150,
              height: MediaQuery.of(context).size.width - 150,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.grey,width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Image.network(image, fit: BoxFit.contain,),
                ),
              ),
            ),
          ) : SizedBox.shrink(),

          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(top: image.isNotEmpty ? MediaQuery.of(context).size.width - 250 : 0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [

                          image.isNotEmpty ?
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Colors.transparent, Colors.white10, theme.colorScheme.primary],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter
                                )
                            ),
                          ) : SizedBox.shrink(),

                          Container(
                            color: theme.colorScheme.primary,
                            child: Column(
                              children: [

                                /// title
                                image.isNotEmpty ?
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(widget.bookname,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "drawerhead"
                                    )
                                    ,),
                                ) : SizedBox.shrink(),
                                image.isNotEmpty ?
                                SizedBox(height: 5,) : SizedBox.shrink(),


                                ///author
                                author.isNotEmpty ?
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text("by $author",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: "drawerbody"
                                    )
                                    ,),
                                ) : SizedBox.shrink(),
                                author.isNotEmpty ?
                                SizedBox(height: 20,) : SizedBox.shrink(),


                                ///description
                                description.isNotEmpty ?
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text("Description -",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: "drawerhead"
                                    ),textAlign: TextAlign.justify
                                    ,),
                                ) : SizedBox.shrink(),
                                description.isNotEmpty ?
                                SizedBox(height: 5,) : SizedBox.shrink(),
                                description.isNotEmpty ?
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: showMore ?
                                  Text(description,
                                    style: TextStyle(
                                      fontFamily: "drawerbody",
                                    ),textAlign: TextAlign.justify,
                                  ) :
                                  Text(description,
                                    style: TextStyle(
                                      fontFamily: "drawerbody",
                                    ),
                                    textAlign: TextAlign.justify,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ) : SizedBox.shrink(),
                                description.isNotEmpty ?
                                SizedBox(height: 5,) : SizedBox.shrink(),

                                ///see more/less
                                description.isNotEmpty ?
                                GestureDetector(

                                  onTap: (){
                                    setState(() {
                                      showMore = !showMore;
                                    });
                                  },

                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        Text(showMore ? "show less" : "show more",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              fontFamily: "drawerbody",
                                              fontStyle: FontStyle.italic
                                          )
                                          ,),
                                        SizedBox(width: 3,),
                                        Icon(
                                          !showMore ?
                                          Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded
                                          , size: 20, color: Colors.blue,
                                        )
                                      ],
                                    ),
                                  ),
                                ): SizedBox.shrink(),

                                ///create new content text
                                                (reviews.isEmpty &&
                                                    posts.isEmpty &&
                                                    recordings.isEmpty &&
                                                    albums.isEmpty && !loading) ?
                                                Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 50),
                                                    child: Text(
                                                      "create now",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                          fontStyle: FontStyle.italic,
                                                          fontFamily: "drawerbody"
                                                      ),textAlign: TextAlign.center
                                                      ,),
                                                  ),
                                                ) :
                                                    SizedBox.shrink(),

                                                ///loading
                                                loading ?
                                                    AppLoading() :
                                                    SizedBox.shrink(),

                                                ///searching bits
                                                reviews.length > 0?
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10, top: 10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        reviews.length > 0 ? "Reviews" : "",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                    : SizedBox.shrink(),
                                                reviews.length > 0
                                                    ? ListView.builder(
                                                        itemCount: reviews.length,
                                                        padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics: ClampingScrollPhysics(),
                                                        itemBuilder: (context, index) {

                                                          if(index >= reviews.length){
                                                            return SizedBox.shrink();
                                                          }

                                                          // print(reviews[index]);

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

                                                ///searching recordings
                                                recordings.length > 0?
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10, top: 10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        recordings.length > 0 ? "Recordings" : "",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                    : SizedBox.shrink(),
                                                recordings.length > 0
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

                                                                        // List list = [];
                                                                        // await FirebaseFirestore.instance
                                                                        // .collection("recordings")
                                                                        // .get()
                                                                        // .then((value){
                                                                        //
                                                                        //   for(int i=0; i<value.docs.length; i++){
                                                                        //     // print(i);
                                                                        //     if(value.docs[i].id == recordings[index]["id"]){
                                                                        //       int INDEX = i;
                                                                        //       // print(value.docs[i].id);
                                                                        //       // print(recordings[index]["id"]);
                                                                        //       Navigator.push(
                                                                        //         context,
                                                                        //         new MaterialPageRoute(
                                                                        //           builder: (context) =>
                                                                        //               UserRecorings(
                                                                        //                   page: 0
                                                                        //               ),
                                                                        //         ),
                                                                        //       );
                                                                        //     }
                                                                        //   }
                                                                        // });
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
                                                albums.length > 0?
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10, top: 10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        albums.length > 0 ? "Albums" : "",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                    : SizedBox.shrink(),
                                                albums.length > 0
                                                    ? GridView.builder(
                                                        itemCount: albums.length,
                                                        shrinkWrap: true,
                                                        padding: EdgeInsets.zero,
                                                        physics: ClampingScrollPhysics(),
                                                        scrollDirection: Axis.vertical,
                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
                                                        itemBuilder: (context, index){
                                                          return StreamBuilder<DocumentSnapshot>(
                                                            stream: FirebaseFirestore.instance
                                                              .collection("albums")
                                                              .doc(albums[index]["id"])
                                                              .snapshots(),
                                                            builder: (context, album) {

                                                              if(!album.hasData){
                                                                return SizedBox.shrink();
                                                              }

                                                              return GestureDetector(

                                                                onTap: (){

                                                                  if(album.data!["isActive"]){
                                                                    Navigator.push(context,
                                                                        MaterialPageRoute(builder: (context) =>
                                                                            AlbumPage(
                                                                              albumId: albums[index]["id"],
                                                                              authId: album.data!["authorId"],
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
                                                                    //       albumId: albums[index]["id"],
                                                                    //       authId: album.data!["authorId"],
                                                                    //       fromShare: false,
                                                                    //     ),
                                                                    //   ),
                                                                    // );
                                                                  } else {
                                                                    ToastMessege("This Album has been deleted", context: context);
                                                                  }
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

                                                ///searching posts
                                                posts.length > 0
                                                    ? Padding(
                                                  padding: const EdgeInsets.only(left: 10, top: 10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        posts.length > 0 ? "Posts" : "",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                    : SizedBox.shrink(),
                                                posts.length > 0
                                                    ? GridView.builder(
                                                        itemCount: posts.length,
                                                        shrinkWrap: true,
                                                    physics: ClampingScrollPhysics(),
                                                        padding: EdgeInsets.zero,
                                                        scrollDirection: Axis.vertical,
                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
                                                        itemBuilder: (context, index){
                                                          return StreamBuilder<DocumentSnapshot>(
                                                              stream: FirebaseFirestore.instance
                                                                  .collection("posts")
                                                                  .doc(posts[index]["id"])
                                                                  .snapshots(),
                                                              builder: (context, post) {

                                                                if(!post.hasData){
                                                                  return SizedBox.shrink();
                                                                }

                                                                return GestureDetector(

                                                                  onTap: (){

                                                                    if(post.data!["isActive"]){
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
                                                                    } else {
                                                                      ToastMessege("This Reading has been deleted.", context: context);
                                                                    }
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
                                                                                  color: post.data!["image"].isEmpty ? Colors.grey : Colors.transparent
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(10)
                                                                          ),
                                                                          child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            child: post.data!["image"].toString().isEmpty ?
                                                                            Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                                                                            Image.network(post.data!["image"], fit: BoxFit.cover,),
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
                                                                                Text(post.data!["bookName"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
                                                                                Text(post.data!["username"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
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

                                SizedBox(height: 100,),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
      // Container(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   child: SingleChildScrollView(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         Container(
      //           height: MediaQuery.of(buildContext).size.height - 125,
      //           padding: EdgeInsets.symmetric(
      //               horizontal: MediaQuery.of(buildContext).size.width * 0.05),
      //           child: SingleChildScrollView(
      //             child: Column(
      //               children: [
      ///
      //                 ///create new content text
      //                 (reviews.isEmpty &&
      //                     posts.isEmpty &&
      //                     recordings.isEmpty &&
      //                     albums.isEmpty && !loading) ?
      //                 Container(
      //                   width: MediaQuery.of(context).size.width,
      //                   child: Padding(
      //                     padding: const EdgeInsets.only(top: 50),
      //                     child: Text(
      //                       "create now",
      //                       style: TextStyle(
      //                           fontSize: 14,
      //                           color: Colors.grey,
      //                           fontStyle: FontStyle.italic,
      //                           fontFamily: "drawerbody"
      //                       ),textAlign: TextAlign.center
      //                       ,),
      //                   ),
      //                 ) :
      //                     SizedBox.shrink(),
      //
      //                 ///loading
      //                 loading ?
      //                     AppLoading() :
      //                     SizedBox.shrink(),
      //
      //                 ///searching bits
      //                 reviews.length > 0?
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 10, top: 10),
      //                   child: Row(
      //                     children: [
      //                       Text(
      //                         reviews.length > 0 ? "Reviews" : "",
      //                         style: TextStyle(
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 )
      //                     : SizedBox.shrink(),
      //                 reviews.length > 0
      //                     ? ListView.builder(
      //                         itemCount: reviews.length,
      //                         padding: EdgeInsets.zero,
      //                     shrinkWrap: true,
      //                     physics: ClampingScrollPhysics(),
      //                         itemBuilder: (context, index) {
      //
      //                           if(index >= reviews.length){
      //                             return SizedBox.shrink();
      //                           }
      //
      //                           // print(reviews[index]);
      //
      //                           return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
      //                             stream: FirebaseFirestore.instance
      //                               .collection("reviews")
      //                               .doc(reviews[index]["id"])
      //                               .snapshots(),
      //                             builder: (context, snapshot) {
      //                               if(!snapshot.hasData){
      //                                 return SizedBox.shrink();
      //                               }
      //                               return BitTile(bit: snapshot.data!.data()!, authId: snapshot.data!["editorId"]);
      //                             }
      //                           );
      //                         })
      //                     : SizedBox.shrink(),
      //
      //                 ///searching recordings
      //                 recordings.length > 0?
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 10, top: 10),
      //                   child: Row(
      //                     children: [
      //                       Text(
      //                         recordings.length > 0 ? "Recordings" : "",
      //                         style: TextStyle(
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 )
      //                     : SizedBox.shrink(),
      //                 recordings.length > 0
      //                     ? ListView.builder(
      //                         itemCount: recordings.length,
      //                         padding: EdgeInsets.zero,
      //                     shrinkWrap: true,
      //                     physics: ClampingScrollPhysics(),
      //                         itemBuilder: (context, index) {
      //
      //                           if(index >= recordings.length){
      //                             return SizedBox.shrink();
      //                           }
      //
      //                           return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
      //                               stream: FirebaseFirestore.instance
      //                                   .collection("recordings")
      //                                   .doc(recordings[index]["id"])
      //                                   .snapshots(),
      //                               builder: (context, snapshot) {
      //                                 if(!snapshot.hasData){
      //                                   return SizedBox.shrink();
      //                                 }
      //                                 return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
      //                                   stream: FirebaseFirestore.instance
      //                                       .collection("rooms")
      //                                       .doc(snapshot.data!["userId"])
      //                                       .collection("rooms")
      //                                       .doc(snapshot.data!["roomId"])
      //                                     .snapshots(),
      //                                   builder: (context, room){
      //                                     if(!room.hasData){
      //                                       return SizedBox.shrink();
      //                                     }
      //
      //                                     return GestureDetector(
      //
      //                                       onTap: () async {
      //
      //                                         Navigator.push(
      //                                           context,
      //                                           new MaterialPageRoute(
      //                                             builder: (context) =>
      //                                                 SinglePodcastPlay(recId: recordings[index]["id"]),
      //                                           ),
      //                                         );
      //
      //                                         // List list = [];
      //                                         // await FirebaseFirestore.instance
      //                                         // .collection("recordings")
      //                                         // .get()
      //                                         // .then((value){
      //                                         //
      //                                         //   for(int i=0; i<value.docs.length; i++){
      //                                         //     // print(i);
      //                                         //     if(value.docs[i].id == recordings[index]["id"]){
      //                                         //       int INDEX = i;
      //                                         //       // print(value.docs[i].id);
      //                                         //       // print(recordings[index]["id"]);
      //                                         //       Navigator.push(
      //                                         //         context,
      //                                         //         new MaterialPageRoute(
      //                                         //           builder: (context) =>
      //                                         //               UserRecorings(
      //                                         //                   page: 0
      //                                         //               ),
      //                                         //         ),
      //                                         //       );
      //                                         //     }
      //                                         //   }
      //                                         // });
      //                                       },
      //
      //                                       child: PodcastTile(
      //                                             podImage: room.data!["image"],
      //                                             podTitle: room.data!["title"],
      //                                             podAuthor: room.data!["roomCreator"],
      //                                             podId: recordings[index]["id"]
      //                                         ),
      //                                     );
      //                                   }
      //                                 );
      //                               }
      //                           );
      //                         })
      //                     : SizedBox.shrink(),
      //
      //                 ///searching albums
      //                 albums.length > 0?
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 10, top: 10),
      //                   child: Row(
      //                     children: [
      //                       Text(
      //                         albums.length > 0 ? "Albums" : "",
      //                         style: TextStyle(
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 )
      //                     : SizedBox.shrink(),
      //                 albums.length > 0
      //                     ? GridView.builder(
      //                         itemCount: albums.length,
      //                         shrinkWrap: true,
      //                         padding: EdgeInsets.zero,
      //                         physics: ClampingScrollPhysics(),
      //                         scrollDirection: Axis.vertical,
      //                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
      //                         itemBuilder: (context, index){
      //                           return StreamBuilder<DocumentSnapshot>(
      //                             stream: FirebaseFirestore.instance
      //                               .collection("albums")
      //                               .doc(albums[index]["id"])
      //                               .snapshots(),
      //                             builder: (context, album) {
      //
      //                               if(!album.hasData){
      //                                 return SizedBox.shrink();
      //                               }
      //
      //                               return GestureDetector(
      //
      //                                 onTap: (){
      //
      //                                   if(album.data!["isActive"]){
      //                                     Navigator.push(context,
      //                                         MaterialPageRoute(builder: (context) =>
      //                                             AlbumPage(
      //                                               albumId: albums[index]["id"],
      //                                               authId: album.data!["authorId"],
      //                                               fromShare: true,
      //                                             )
      //                                         ));
      //                                     // showModalBottomSheet(
      //                                     //   context: context,
      //                                     //   isScrollControlled: true,
      //                                     //   backgroundColor: Colors.transparent,
      //                                     //   builder: (context) => Padding(
      //                                     //     padding: EdgeInsets.only(top: 100),
      //                                     //     child: AlbumPage(
      //                                     //       albumId: albums[index]["id"],
      //                                     //       authId: album.data!["authorId"],
      //                                     //       fromShare: false,
      //                                     //     ),
      //                                     //   ),
      //                                     // );
      //                                   } else {
      //                                     ToastMessege("This Album has been deleted", context: context);
      //                                   }
      //                                 },
      //
      //                                 child: Container(
      //                                   height: 220,
      //                                   child: Column(
      //                                     children: [
      //                                       Expanded(child: Container()),
      //
      //                                       //image
      //                                       Container(
      //                                         width: 140,
      //                                         height: 140,
      //                                         decoration: BoxDecoration(
      //                                             color: Colors.transparent,
      //                                             border: Border.all(
      //                                                 width: 1,
      //                                                 color: album.data!["image"].isEmpty ? Colors.grey : Colors.transparent
      //                                             ),
      //                                             borderRadius: BorderRadius.circular(10)
      //                                         ),
      //                                         child: ClipRRect(
      //                                           borderRadius: BorderRadius.circular(10),
      //                                           child: album.data!["image"].toString().isEmpty ?
      //                                           Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
      //                                           Image.network(album.data!["image"], fit: BoxFit.fill,),
      //                                         ),
      //                                       ),
      //
      //                                       //data
      //                                       Padding(
      //                                         padding: const EdgeInsets.only(left: 0),
      //                                         child: Container(
      //                                           height: 60,
      //                                           width: 130,
      //                                           child: Column(
      //                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                             crossAxisAlignment: CrossAxisAlignment.start,
      //                                             children: [
      //                                               SizedBox(),
      //                                               Text(album.data!["title"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
      //                                               Text(album.data!["authorName"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
      //                                               Text("${album.data!["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
      //                                               SizedBox(),
      //                                             ],
      //                                           ),
      //                                         ),
      //                                       )
      //                                     ],
      //                                   ),
      //                                 ),
      //                               );
      //                             }
      //                           );
      //                         }
      //                     )
      //                     : SizedBox.shrink(),
      //
      //                 ///searching posts
      //                 posts.length > 0
      //                     ? Padding(
      //                   padding: const EdgeInsets.only(left: 10, top: 10),
      //                   child: Row(
      //                     children: [
      //                       Text(
      //                         posts.length > 0 ? "Posts" : "",
      //                         style: TextStyle(
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 )
      //                     : SizedBox.shrink(),
      //                 posts.length > 0
      //                     ? GridView.builder(
      //                         itemCount: posts.length,
      //                         shrinkWrap: true,
      //                     physics: ClampingScrollPhysics(),
      //                         padding: EdgeInsets.zero,
      //                         scrollDirection: Axis.vertical,
      //                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
      //                         itemBuilder: (context, index){
      //                           return StreamBuilder<DocumentSnapshot>(
      //                               stream: FirebaseFirestore.instance
      //                                   .collection("posts")
      //                                   .doc(posts[index]["id"])
      //                                   .snapshots(),
      //                               builder: (context, post) {
      //
      //                                 if(!post.hasData){
      //                                   return SizedBox.shrink();
      //                                 }
      //
      //                                 return GestureDetector(
      //
      //                                   onTap: (){
      //
      //                                     if(post.data!["isActive"]){
      //                                       Navigator.push(
      //                                         context,
      //                                         CupertinoPageRoute(
      //                                           builder: (context) {
      //                                             return PageSinglePost(
      //                                               postId: post.data!["id"],
      //                                               dateTime: post.data!["dateTime"],
      //                                               userid: post.data!["userid"],
      //                                               userProfile: post.data!["userProfile"],
      //                                               username: post.data!["username"],
      //                                               image: post.data!["image"],
      //                                               caption: post.data!["caption"],
      //                                               likes: post.data!["likes"].toString(),
      //                                               comments: post.data!["comments"].toString(),
      //                                             );
      //                                           },
      //                                         ),
      //                                       );
      //                                     } else {
      //                                       ToastMessege("This Reading has been deleted.", context: context);
      //                                     }
      //                                   },
      //
      //                                   child: Container(
      //                                     height: 220,
      //                                     child: Column(
      //                                       children: [
      //                                         Expanded(child: Container()),
      //
      //                                         //image
      //                                         Container(
      //                                           width: 140,
      //                                           height: 140,
      //                                           decoration: BoxDecoration(
      //                                               color: Colors.transparent,
      //                                               border: Border.all(
      //                                                   width: 1,
      //                                                   color: post.data!["image"].isEmpty ? Colors.grey : Colors.transparent
      //                                               ),
      //                                               borderRadius: BorderRadius.circular(10)
      //                                           ),
      //                                           child: ClipRRect(
      //                                             borderRadius: BorderRadius.circular(10),
      //                                             child: post.data!["image"].toString().isEmpty ?
      //                                             Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
      //                                             Image.network(post.data!["image"], fit: BoxFit.cover,),
      //                                           ),
      //                                         ),
      //
      //                                         //data
      //                                         Padding(
      //                                           padding: const EdgeInsets.only(left: 0),
      //                                           child: Container(
      //                                             height: 60,
      //                                             width: 130,
      //                                             child: Column(
      //                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                               crossAxisAlignment: CrossAxisAlignment.start,
      //                                               children: [
      //                                                 SizedBox(),
      //                                                 Text(post.data!["bookName"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
      //                                                 Text(post.data!["username"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
      //                                                 SizedBox(),
      //                                               ],
      //                                             ),
      //                                           ),
      //                                         )
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 );
      //                               }
      //                           );
      //                         }
      //                     )
      //                     : SizedBox.shrink(),
      //               ],
      //             ),
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: GestureDetector(

        onTap: (){
          showModalBottomSheet(context: context,
              // transitionAnimationController: _controller,
              enableDrag: true,
              elevation: 10,
              // context: context,
              builder: (context) {
                return CreateContent(
                  bookname: '',
                  authorname: '',
                  description: '',
                  image: '',
                );
              });
        },

        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: const Offset(
                    5.0,
                    5.0,
                  ),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: Center(
              child: Text("+",
                style: TextStyle(
                    fontSize: 30,
                    fontFamily: "drawerbody",
                    color: Colors.white
                ),),
            ),
          ),
        ),
        // Container(
        //   width: 200,
        //   height: 35,
        //   decoration: BoxDecoration(
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.grey,
        //           offset: const Offset(
        //             5.0,
        //             5.0,
        //           ),
        //           blurRadius: 10.0,
        //           spreadRadius: 2.0,
        //         ),
        //       ],
        //       color: theme.colorScheme.secondary,
        //       borderRadius: BorderRadius.circular(20)
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        //     child: Center(
        //       child: Text("Create Content",
        //         style: TextStyle(
        //             fontSize: 18,
        //             fontStyle: FontStyle.italic,
        //             fontFamily: "drawerbody",
        //             color: Colors.white
        //         ),),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
