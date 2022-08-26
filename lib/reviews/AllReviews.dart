import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/SlidupPanel.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/BitsProvider.dart';
import 'package:fostr/reviews/SingleReviewCard.dart';
import 'package:provider/provider.dart';

import '../widgets/AppLoading.dart';

class AllReviews extends StatefulWidget {
  final String page;
  final String postsOfUserId;
  final bool? refresh;
  const AllReviews(
      {Key? key, required this.page, required this.postsOfUserId, this.refresh})
      : super(key: key);

  @override
  _AllReviewsState createState() => _AllReviewsState();
}

class _AllReviewsState extends State<AllReviews> {
  var provider;
  var stream;

  final ScrollController _controller = ScrollController();

  TextEditingController searchText = TextEditingController();

  int itemsCount = 5;

  @override
  void initState() {
    super.initState();
    print("all reviews initstate called");
    if (widget.page == "activity") {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = Provider.of<AuthProvider>(context).user!.id;
    final bitsProvider = Provider.of<BitsProvider>(context);
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
                      "Reviews",
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
      //   title: Text("Reviews",
      //     style: TextStyle(
      //         color: Colors.black,
      //         fontSize: 20,
      //         fontFamily: "drawerhead"
      //     ),
      //   ),
      //   leading: IconButton(
      //       onPressed: (){
      //         Navigator.pop(context);
      //       },
      //       icon: Icon(Icons.arrow_back_ios,
      //         color: Colors.black,)
      //   ),
      //   actions: [
      //     Image.asset(
      //       "assets/images/logo.png",
      //       width: 50,
      //     )
      //   ],
      // ),

      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: widget.page == "activity"
                ? bitsProvider.getFeedById(widget.postsOfUserId,forceRefresh: false)
                : bitsProvider.getFeed(forceRefresh: false),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return widget.page == "activity"
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Text(
                                "No active bits",
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height - 250,
                        child: Center(
                          child: AppLoading(
                            height: 150,
                            width: 150,
                          ),
                        ),
                      );
              }
              if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: AppLoading(
                      height: 150,
                      width: 150,
                    ),
                  );
                default:
                  if (snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Text(
                              "No active bits",
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return
                        // ScrollToRefresh(
                        // onRefresh: () async {
                        //   await bitsProvider.refreshFeed(true);
                        // },

                        SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child:
                      // RefreshIndicator(
                      //   onRefresh: () async {
                      //     await bitsProvider.refreshFeed(true);
                      //   },
                      //   color: theme.colorScheme.secondary,
                      //   backgroundColor: theme.chipTheme.backgroundColor,
                        // ScrollToRefresh(
                        // onRefresh: () async {
                        //   await postsProvider.refreshPosts(true);
                        // },
                        // child:
                          ListView.separated(
                          controller: _controller,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.only(bottom: 70),
                          itemCount: snapshot.data!.length + 1,
                          itemBuilder: (context, index) {
                            if (index == snapshot.data!.length) {
                              return Container(
                                height: 300,
                              );
                            }

                            return
                                // searchText.text.trim() == "" || searchText.text == null ?
                                SingleReviewCard(
                              key: Key(snapshot.data![index]["id"]!),
                              id: snapshot.data![index]['id'],
                              uid: uid,
                              reviewData: snapshot.data![index],
                            );
                            // :
                            // snapshot.data![index]['bookAuthor'].toString().contains(searchText.text) ?
                            // SingleReviewCard(
                            //   key: Key(snapshot.data![index]["id"]!),
                            //   id: snapshot.data![index]['id'],
                            //   uid: uid,
                            // ) : SizedBox.shrink();
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
                      // ),
                    );
                  }
              }
            },
          ),

          widget.page != "home" ?
              SizedBox.shrink() :
              SlidupPanel()
        ],
      ),
    );
  }
}
