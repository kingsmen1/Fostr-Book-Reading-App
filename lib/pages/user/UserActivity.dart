import 'package:flutter/material.dart';
import 'package:fostr/Posts/AllPosts.dart';
import 'package:fostr/pages/user/UserRooms.dart';
import 'package:fostr/pages/user/userActivity/UserTheatres.dart';
import 'package:fostr/reviews/AllReviews.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:provider/provider.dart';

class UserActivity extends StatefulWidget {
  final ScrollController scrollController;
  const UserActivity({Key? key, required this.scrollController})
      : super(key: key);

  @override
  _UserActivityState createState() => _UserActivityState();
}

class _UserActivityState extends State<UserActivity> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
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
                    color: theme.colorScheme.secondary,
                  )),
                  Tab(
                      icon: Icon(
                    Icons.audiotrack,
                    color: theme.colorScheme.secondary,
                  )),
                  Tab(
                      icon:
                          Icon(Icons.mic, color: theme.colorScheme.secondary)),
                  Tab(
                      icon:
                          Icon(Icons.theaters_rounded,color: theme.colorScheme.secondary)),
                  // Tab(
                  //     icon: Icon(
                  //   FontAwesomeIcons.peopleGroup,
                  // )),
                ],
              ),
              body: TabBarView(
                children: [
                  AllPosts(page: "myActivity"),
                  AllReviews(
                    page: "activity",
                    postsOfUserId: user.id,
                  ),
                  UserRooms(1, user.id),
                  UserTheatres(1, user.id)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
