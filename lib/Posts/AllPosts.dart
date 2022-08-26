import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/FeedPostCard.dart';
import 'package:fostr/Posts/PageSinglePost.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/providers/PostProvider.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ScrollToRefresh.dart';
import 'package:get_it/get_it.dart';
import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:provider/provider.dart';

class AllPosts extends StatefulWidget {
  final String page;
  final String? postsOfUserId;
  final bool? refresh;
  const AllPosts(
      {Key? key, required this.page, this.postsOfUserId, this.refresh})
      : super(key: key);

  @override
  _AllPostsState createState() => _AllPostsState();
}

class _AllPostsState extends State<AllPosts> {
  List posts = [];
  bool loading = true;
  String uid = "";

  UserModel.User user = UserModel.User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  UserService userServices = GetIt.I<UserService>();
  var streambuilder;
  var provider;

  @override
  void initState() {
    super.initState();
    getAuth();
  }

  void getAuth() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    if (widget.page == "externalActivity") {
      uid = widget.postsOfUserId!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    streambuilder = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postsProvider = Provider.of<PostsProvider>(context);
    return Scaffold(

      backgroundColor: theme.colorScheme.primary,

      appBar: widget.page != "home" ?
          PreferredSize(child: SizedBox.shrink(), preferredSize: Size(0,0)) :
      PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 70),
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
                      "Readings",
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 20,
                          fontFamily: 'drawerhead',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.9,0.6),
                child: Container(
                  height: 50,
                  width: 50,
                  child: Center(
                      child: Image.asset("assets/images/logo.png", width: 40, height: 40,)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // AppBar(
      //   backgroundColor: theme.colorScheme.primary,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: Text("Readings",
      //     style: TextStyle(
      //         color: theme.colorScheme.inversePrimary,
      //         fontSize: 20,
      //         fontFamily: "drawerhead"
      //     ),
      //   ),
      //   leading: IconButton(
      //       onPressed: (){
      //         Navigator.pop(context);
      //       },
      //       icon: Icon(Icons.arrow_back_ios,)
      //   ),
      //   actions: [
      //     Image.asset(
      //       "assets/images/logo.png",
      //       fit: BoxFit.contain,
      //       width: 40,
      //       height: 40,
      //     )
      //   ],
      // ),

      body: widget.page == "home"
          ?
          //home
          FutureBuilder<List<Map<String, dynamic>>>(
              future: postsProvider.getPosts(forceRefresh: false),
              builder:
                  (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    height: MediaQuery.of(context).size.height - 250,
                    child: Center(
                      child: AppLoading(
                        height: 150,
                        width: 150,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Text("error occured");
                }

                final data = snapshot.data!.reversed.toList();

                return //ScrollToRefresh(
                    RefreshIndicator(
                  onRefresh: () async {
                    await postsProvider.refreshPosts(true);
                  },
                  color: theme.colorScheme.secondary,
                  backgroundColor: theme.chipTheme.backgroundColor,
                  // ScrollToRefresh(
                  // onRefresh: () async {
                  //   await postsProvider.refreshPosts(true);
                  // },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.separated(
                      addAutomaticKeepAlives: true,
                      itemCount: data.length + 1,
                      itemBuilder: (context, index) {
                        if (index == data.length)
                          return SizedBox(
                            height: 500,
                          );

                        return FeedCard(
                          feed: data[index],
                          feedType: "posts",
                          key: Key(data[index]["id"]),
                        );
                      }, separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            color: Colors.grey,
                          ),
                        );
                    },
                    ),
                  ),
                );
              },
            )
          :

          //activities
          Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .where("isActive", isEqualTo: true)
                      .where("userid", isEqualTo: uid)
                      // .limit(6)
                      .snapshots(),
                  builder: (context, snapshot) {
                    print(snapshot.data);
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Column(
                          children: [
                            AppLoading(),
                          ],
                        );
                      // CircularProgressIndicator(
                      //   color: GlobalColors.signUpSignInButton,
                      // ));
                      default:
                        // print(snapshot.data!.docs.first.get("username"));
                        // print("uid : $uid");
                        if (snapshot.data!.docs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  Text(
                                    "No active readings",
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          snapshot.data!.docs.reversed.forEach((element) {
                            if (element.exists) {
                              posts.add({
                                "postId": element.id,
                                "dateTime": element.get("dateTime"),
                                "userid": element.get("userid"),
                                "userProfile": element.get("userProfile")
                                // .toString()
                                // .replaceAll(
                                //     "https://firebasestorage.googleapis.com",
                                //     "https://ik.imagekit.io/fostrreads")
                                ,
                                "username": element.get("username"),
                                "image": element.get("image")
                                // .toString()
                                // .replaceAll(
                                //     "https://firebasestorage.googleapis.com",
                                //     "https://ik.imagekit.io/fostrreads")
                                ,
                                "caption": element.get("caption"),
                                "likes": element.get("likes"),
                                "comments": element.get("comments"),
                              });

                              // print("============================ activities ===========================");
                              // print(element.data());
                              // print("================================================================");
                            }
                          });
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemCount: posts.length,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    child: GestureDetector(
                                        onTap: () {
                                          print(posts[index]
                                          ["postId"]);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PageSinglePost(
                                                          // key: Key(posts[index]
                                                          //     ["postId"]),
                                                          postId: posts[index]
                                                              ["postId"],
                                                          dateTime: posts[index]
                                                              ["dateTime"],
                                                          userid: posts[index]
                                                              ["userid"],
                                                          userProfile:
                                                              posts[index]
                                                                  ["userProfile"],
                                                          username: posts[index]
                                                              ["username"],
                                                          image: posts[index]
                                                              ["image"],
                                                          caption: posts[index]
                                                              ["caption"],
                                                          likes: posts[index]
                                                                  ["likes"]
                                                              .toString(),
                                                          comments: posts[index]
                                                                  ["comments"]
                                                              .toString())));
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
                                                imageUrl: posts[index]["image"],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )),
                                  );
                                }),
                          );

                          //   ListView.builder(
                          //     shrinkWrap: true,
                          //     physics: ClampingScrollPhysics(),
                          //     itemCount: posts.length,
                          //     itemBuilder: (context, index){
                          //       return SinglePostCard(postID: posts[index]);
                          //     }
                          // );
                        }
                    }
                  }),
            ),
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
    switch (widget.feedType) {
      case "posts":
        return FeedPostCard(
          feed: widget.feed,
          page: 'feed',
        );

      default:
        return Text(
          "",
          style: TextStyle(
            color: Colors.white,
          ),
        );
    }
  }

  @override
  bool get wantKeepAlive => false;
}
