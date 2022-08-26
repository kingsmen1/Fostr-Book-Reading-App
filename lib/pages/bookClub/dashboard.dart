import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/bookClub/BookClubSearch.dart';
import 'package:fostr/pages/bookClub/RecentActivity.dart';
import 'package:fostr/pages/rooms/EnterBookClubDetails.dart';
import 'package:fostr/pages/user/BookClub.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/screen/Subscribers.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class UserBookClubDashboard extends StatefulWidget {
  const UserBookClubDashboard({Key? key}) : super(key: key);

  @override
  State<UserBookClubDashboard> createState() => _UserBookClubDashboardState();
}

class _UserBookClubDashboardState extends State<UserBookClubDashboard> {
  Stream<QuerySnapshot<Map<String, dynamic>>> getBookClubs(String id) {
    if (all) {
      return FirebaseFirestore.instance
          .collection('bookclubs')
          .where('isActive', isEqualTo: true)
          .snapshots();
    } else if (subscribed) {
      return FirebaseFirestore.instance
          .collection('bookclubs')
          .where('id', whereIn: subscribedBookclubs)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('bookclubs')
          .where('createdBy', isEqualTo: id)
          .where('isActive', isEqualTo: true)
          .snapshots();
    }
  }

  List<String> subscribedBookclubs = ["1"];
  StreamSubscription? _subscribeBookclubsubscription;
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _subscribeBookclubsubscription = FirebaseFirestore.instance
        .collection("subscribedBookClubs")
        .doc(auth.user!.id)
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        setState(() {
          subscribedBookclubs =
              List<String>.from(doc.data()?['subscribedBookClubs']);
          if (subscribedBookclubs.isEmpty) {
            subscribedBookclubs = ["1"];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscribeBookclubsubscription?.cancel();
    super.dispose();
  }

  bool all = true;
  bool subscribed = false;
  bool my = false;

  String bodyName = "";
  String topLine = "";
  ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          "Book Club",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => BookClubSearchPage()));
            },
            icon: Icon(Icons.search_rounded),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _controller,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        all = true;
                        subscribed = false;
                        my = false;
                      });
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: all
                            ? theme.colorScheme.secondary
                            : theme.chipTheme.backgroundColor,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "   All   ",
                            style: TextStyle(
                                color: all
                                    ? Colors.white
                                    : theme.colorScheme.secondary,
                                fontFamily: "drawerbody"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),

                  //bits
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        all = false;
                        subscribed = true;
                        my = false;
                      });
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: subscribed
                            ? theme.colorScheme.secondary
                            : theme.chipTheme.backgroundColor,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "   Subscribed   ",
                            style: TextStyle(
                                color: subscribed
                                    ? Colors.white
                                    : theme.colorScheme.secondary,
                                fontFamily: "drawerbody"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),

                  //rooms
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        all = false;
                        subscribed = false;
                        my = true;
                      });
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: my
                            ? theme.colorScheme.secondary
                            : theme.chipTheme.backgroundColor,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            " My Bookclubs ",
                            style: TextStyle(
                                color: my
                                    ? Colors.white
                                    : theme.colorScheme.secondary,
                                fontFamily: "drawerbody"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),

                  // SizedBox(width: 20,),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getBookClubs(auth.user!.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error");
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: AppLoading(),
                  );
                }

                final myClubs = snapshot.data?.docs.map((e) {
                  return BookClubModel.fromJson({
                    ...e.data(),
                    "id": e.id,
                  });
                }).toList();

                if (myClubs == null || myClubs.isEmpty) {
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          (subscribed)
                              ? "Subscribe some awesome bookclubs"
                              : "Create your own Book Clubs using the + icon",
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: myClubs.length,
                    itemBuilder: (context, index) {
                      final bookClub = myClubs[index];
                      return BookClubCard(bookClub: bookClub);
                    },
                  ),
                );
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EnterBookClubDetails()),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class BookClubCard extends StatefulWidget {
  final BookClubModel bookClub;
  const BookClubCard({Key? key, required this.bookClub}) : super(key: key);

  @override
  State<BookClubCard> createState() => _BookClubCardState();
}

class _BookClubCardState extends State<BookClubCard> {
  String getDate(DateTime startTime) {
    var format = new DateFormat('d MMM y');
    return format.format(startTime);
  }

  final UserService _userService = GetIt.I<UserService>();

  User? user;

  @override
  void initState() {
    super.initState();
    _userService.getUserById(widget.bookClub.createdBy).then((value) {
      if (value != null && mounted) {
        setState(() {
          user = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      constraints: BoxConstraints(maxHeight: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 12,
            color: Colors.black.withOpacity(0.25),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookClub(
                bookClub: widget.bookClub,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundedImage(
                      shape: BoxShape.rectangle,
                      height: 100,
                      width: 100,
                      borderRadius: 8,
                      path: 'assets/images/logo.png',
                      url: widget.bookClub.bookClubProfile,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.bookClub.bookClubName,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (user?.id == auth.user?.id) {
                                Navigator.of(context).push(
                                    CupertinoPageRoute(builder: (context) {
                                  return UserProfilePage();
                                }));
                                return;
                              }
                              Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return ExternalProfilePage(user: user!);
                              }));
                            },
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(text: "By"),
                                TextSpan(
                                  text: " ${user?.userName ?? "Unknown"}",
                                ),
                              ]),
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Created On ${getDate(widget.bookClub.createdOn)}",
                            style: TextStyle(fontSize: 14),
                          ),
                          Row(
                            children: [
                              (widget.bookClub.twitter != null)
                                  ? IconButton(
                                      icon: SvgPicture.asset(
                                        "assets/icons/twitter.svg",
                                        height: 35,
                                      ),
                                      color: Colors.teal[800],
                                      iconSize: 35,
                                      onPressed: () {
                                        try {
                                          var twitter =
                                              widget.bookClub.twitter!;
                                          if (twitter.isNotEmpty &&
                                              twitter[0] == '@') {
                                            twitter = twitter.substring(1);
                                          }
                                          url.launchUrl(Uri.parse(
                                              "https://twitter.com/$twitter"));
                                        } catch (e) {
                                          ToastMessege(
                                              "Error opening twitter page",
                                              context: context);
                                        }
                                      })
                                  : SizedBox.shrink(),
                              (widget.bookClub.instagram != null)
                                  ? IconButton(
                                      icon: SvgPicture.asset(
                                        "assets/icons/instagram.svg",
                                        height: 35,
                                      ),
                                      iconSize: 35,
                                      onPressed: () {
                                        try {
                                          var instagram =
                                              widget.bookClub.instagram!;
                                          if (instagram.isNotEmpty &&
                                              instagram[0] == '@') {
                                            instagram = instagram.substring(1);
                                          }
                                          url.launchUrl(Uri.parse(
                                              "http://instagram.com/$instagram"));
                                        } catch (e) {
                                          ToastMessege(
                                              "Error opening instagram page",
                                              context: context);
                                        }
                                      })
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    widget.bookClub.bookClubBio ?? "",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 100,
                  child: GridView(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 0.5,
                      // crossAxisSpacing: 2,
                      mainAxisSpacing: 5,
                    ),
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Subscribers(
                                items: widget.bookClub.members,
                                clubID: widget.bookClub.id,
                                title: "Members",
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Members"),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${widget.bookClub.members.length}",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Rooms Hosted"),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${widget.bookClub.roomsCount}",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: -13,
              top: -15,
              child: Tooltip(
                message: "Recent activities",
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => RecentActivity(
                          bookClubModel: widget.bookClub,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.local_activity_outlined),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
