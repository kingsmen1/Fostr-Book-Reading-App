import 'package:flutter/material.dart';
import 'package:fostr/Posts/AllPosts.dart';
import 'package:fostr/pages/user/UserRooms.dart';
import 'package:fostr/pages/user/userActivity/UserTheatres.dart';
import 'package:fostr/reviews/AllReviews.dart';

class ExternalUserActivity extends StatefulWidget {
  final String userId;
  final ScrollController scrollController;
  const ExternalUserActivity(
      {Key? key, required this.userId, required this.scrollController})
      : super(key: key);

  @override
  _ExternalUserActivityState createState() => _ExternalUserActivityState();
}

class _ExternalUserActivityState extends State<ExternalUserActivity> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 200,
      child: Stack(
        children: [
          DefaultTabController(
            length: 4,
            child: Scaffold(
              backgroundColor: theme.colorScheme.primary,
              appBar: TabBar(
                indicatorColor: theme.colorScheme.secondary,
                tabs: [
                  Tab(
                      icon: Icon(
                    Icons.post_add,
                    color: theme.colorScheme.inversePrimary,
                  )),
                  Tab(
                      icon: Icon(
                    Icons.audiotrack,
                    color: theme.colorScheme.inversePrimary,
                  )),
                  Tab(
                      icon: Icon(
                    Icons.mic,
                    color: theme.colorScheme.inversePrimary,
                  )),
                  Tab(
                      icon: Icon(Icons.theaters_rounded,
                          color: theme.colorScheme.inversePrimary)),
                ],
              ),
              body: TabBarView(
                children: [
                  AllPosts(
                      page: "externalActivity", postsOfUserId: widget.userId),
                  AllReviews(page: "activity", postsOfUserId: widget.userId),
                  UserRooms(1, widget.userId),
                  UserTheatres(1, widget.userId),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: theme.colorScheme.secondary,
              onPressed: () {
                widget.scrollController
                    .jumpTo(widget.scrollController.position.minScrollExtent);
              },
              child: Icon(Icons.arrow_upward),
            ),
          ),
        ],
      ),
    );
  }
}
