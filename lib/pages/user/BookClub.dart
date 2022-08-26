import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/BookClubModel/PendingRequests.dart';
import 'package:fostr/pages/bookClub/BookClubActivity.dart';
import 'package:fostr/pages/bookClub/UpcomingBookClubEvents.dart';
import 'package:fostr/pages/rooms/EnterBookClubRoomDetails.dart';
import 'package:fostr/pages/user/BookClubRooms.dart';
import 'package:fostr/pages/user/SelectBookCLubGenre.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/BookClubSettings.dart';
import 'package:fostr/screen/Subscribers.dart';
import 'package:fostr/services/BookClubServices.dart';
import 'package:fostr/services/InAppNotificationService.dart';
import 'package:fostr/widgets/BookClub/PendingRequestsBell.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class BookClub extends StatefulWidget {
  final BookClubModel bookClub;
  const BookClub({
    Key? key,
    required this.bookClub,
  }) : super(key: key);

  @override
  _BookClubState createState() => _BookClubState();
}

class _BookClubState extends State<BookClub> {
  bool isSubscribed = false;
  bool isInvited = false;
  bool isOwner = false;
  String tokenID = '';
  String userID = '';
  List<dynamic> subscribers = [];

  late int memberCount;

  BookClubModel? bookClub;

  bool scrolled = false;
  bool isInviteOnly = false;
  ScrollController scrollController = ScrollController();
  final BookClubServices _bookClubServices = GetIt.I<BookClubServices>();
  final InAppNotificationService _inAppNotificationService =
      GetIt.I<InAppNotificationService>();

  @override
  void initState() {
    super.initState();
    checkAuthor();
    setState(() {
      bookClub = widget.bookClub;
      memberCount = widget.bookClub.membersCount;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (mounted) {
      setState(() {
        isInvited = widget.bookClub.pendingMembers.contains(auth.user!.id);
      });
    }
  }

  void checkAuthor() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user!.id == widget.bookClub.createdBy) {
      setState(() {
        isOwner = true;
      });
    } else {
      setState(() {
        isOwner = false;
      });
    }

    setState(() {
      userID = auth.user!.id;
    });

    List.from(widget.bookClub.members).forEach((element) {
      subscribers.add(element.toString());
      if (element.toString() == userID) {
        setState(() {
          isSubscribed = true;
        });
      }
    });
    isInviteOnly = widget.bookClub.isInviteOnly;

    await FirebaseAuth.instance.currentUser!.getIdToken().then((value) {
      tokenID = value;
    });
  }

  void addAsSubscriber() async {
    await FirebaseFirestore.instance
        .collection("subscribedBookClubs")
        .doc(userID)
        .set({
      "subscribedBookClubs": FieldValue.arrayUnion([widget.bookClub.id])
    }, SetOptions(merge: true));
  }

  void removeAsSubscriber() async {
    await FirebaseFirestore.instance
        .collection("subscribedBookClubs")
        .doc(userID)
        .set(
            {
          "subscribedBookClubs": FieldValue.arrayRemove([widget.bookClub.id])
        },
            SetOptions(
              merge: true,
            ));
  }

  void sendInviteNotification() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = await _inAppNotificationService
        .getNotificationToken(widget.bookClub.adminUsers.first);
    if (token != null) {
      _inAppNotificationService.sendNotification(
        NotificationPayload(
          type: NotificationType.BookclubInvitationRequest,
          tokens: [token],
          data: {
            "senderUserId": auth.user!.id,
            "senderUserName": auth.user!.userName,
            "recipientUserId": widget.bookClub.adminUsers.first,
            "bookclubId": widget.bookClub.id,
            "bookclubName": widget.bookClub.bookClubName,
            "title":
                "${auth.user!.userName} sent you a request to join ${widget.bookClub.bookClubName}.",
            "payload": {
              "senderUserId": auth.user!.id,
              "senderUserName": auth.user!.userName,
              "recipientUserId": widget.bookClub.adminUsers.first,
              "bookclubId": widget.bookClub.id,
              "bookclubName": widget.bookClub.bookClubName,
            }
          },
        ),
      );
    }
  }

  void sendInvite() {
    FirebaseFirestore.instance
        .collection("bookclubs")
        .doc(widget.bookClub.id)
        .update({
      "pendingMembers": FieldValue.arrayUnion([userID])
    });
    sendInviteNotification();
  }

  void removeInvite() {
    FirebaseFirestore.instance
        .collection("bookclubs")
        .doc(widget.bookClub.id)
        .update({
      "pendingMembers": FieldValue.arrayRemove([userID])
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250,
              backgroundColor: theme.colorScheme.primary,
              automaticallyImplyLeading: false,
              elevation: 0,
              floating: false,
              pinned: true,
              //back
              leading: GestureDetector(
                child: Icon(
                  Icons.arrow_back_ios,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),

              //settings or logo
              actions: [
                isOwner
                    ? PendingRequestBell(bookClub: widget.bookClub)
                    : Container(),
                isOwner
                    ? Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookClubSettings(
                                    bookClubModel: bookClub!,
                                  ),
                                ),
                              ).then((value) => setState(() => {}));
                            },
                            child:
                                SvgPicture.asset("assets/icons/settings.svg")),
                      )
                    : Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      )
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  bookClub!.bookClubName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.inversePrimary,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: bookClub!.bookClubProfile != null &&
                              bookClub!.bookClubProfile!.isNotEmpty
                          ? FosterImage(
                              imageUrl: bookClub!.bookClubProfile!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                    Align(
                      alignment: Alignment(0, 1),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.0),
                              theme.colorScheme.primary.withOpacity(0.5),
                              theme.colorScheme.primary.withOpacity(0.8),
                              theme.colorScheme.primary.withOpacity(1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ];
        },
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.inversePrimary,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  bookClub!.bookClubBio ?? "",
                ),

                //owner row
                // Row(
                //   children: [
                //     //owner
                //     Padding(
                //       padding: const EdgeInsets.only(left: 10, top: 10),
                //       child: GestureDetector(
                //         onTap: () async {
                //           us.User user = us.User.fromJson({
                //             "name": "user",
                //             "userName": "user",
                //             "id": "userId",
                //             "userType": "USER",
                //             "createdOn": DateTime.now().toString(),
                //             "lastLogin": DateTime.now().toString(),
                //             "invites": 10,
                //           });
                //           final UserService userService =
                //               GetIt.I<UserService>();
                //           await userService
                //               .getUserById(bookClub!.createdBy)
                //               .then((value) => {
                //                     if (value != null)
                //                       {
                //                         setState(() {
                //                           user = value;
                //                           authorImage = value
                //                               .userProfile!
                //                               .profileImage!;
                //                         })
                //                       }
                //                   });
                //           Navigator.push(context, CupertinoPageRoute(
                //             builder: (context) {
                //               return ExternalProfilePage(
                //                 user: user,
                //               );
                //             },
                //           ));
                //         },
                //         child: Column(
                //           children: [
                //             Container(
                //               height: 50,
                //               width: 50,
                //               child: Center(
                //                 child: Container(
                //                   width: 35,
                //                   height: 35,
                //                   child: ClipRRect(
                //                     borderRadius:
                //                         BorderRadius.circular(15),
                //                     child: authorImage != null &&
                //                             authorImage!.isNotEmpty
                //                         ? FosterImage(
                //                             imageUrl: authorImage!,
                //                             fit: BoxFit.cover,
                //                           )
                //                         : Image.asset(
                //                             'assets/images/logo.png',
                //                             fit: BoxFit.cover,
                //                           ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.only(top: 8.0),
                //               child: Container(
                //                   child: Text(
                //                 "Owner",
                //                 style: TextStyle(
                //                     fontSize: 12,
                //                     color: theme
                //                         .colorScheme.inversePrimary),
                //                 overflow: TextOverflow.ellipsis,
                //               )),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),

                //     //subscribers
                // (isOwner)
                //     ? GestureDetector(
                //         child: Container(
                //           margin:
                //               EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                //           width: 90.w,
                //           height: 40,
                //           decoration: BoxDecoration(
                //             color: theme.colorScheme.secondary,
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Center(
                //             child: Row(
                //               children: [
                //                 Icon(Icons.notifications_active),
                //                 Text(
                //                   "Pending Requests",
                //                   style: TextStyle(
                //                       color: Colors.white,
                //                       fontFamily: 'text',
                //                       fontSize: 16),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         onTap: () {},
                //       )
                //     : SizedBox.shrink(),
                //     Expanded(child: Container()),

                //     //share invite
                //     isOwner
                //         ?
                //         //false ?
                //         Padding(
                //             padding: const EdgeInsets.only(
                //                 top: 10, right: 10),
                //             child: GestureDetector(
                //               onTap: () {},
                //               child: Column(
                //                 children: [
                //                   Container(
                //                       width: 50,
                //                       height: 50,
                //                       child: Center(
                //                           child: Icon(
                //                         Icons.arrow_circle_up_sharp,
                //                       ))),
                //                   Padding(
                //                     padding:
                //                         const EdgeInsets.only(top: 8.0),
                //                     child: Container(
                //                         child: Text(
                //                       "share invite",
                //                       style: TextStyle(
                //                         fontSize: 12,
                //                         color: theme
                //                             .colorScheme.inversePrimary,
                //                       ),
                //                       overflow: TextOverflow.ellipsis,
                //                     )),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           )
                //         : Container(),

                //     //invite only

                //     //image
                //     // Padding(
                //     //   padding: const EdgeInsets.only(right: 10, top: 10),
                //     //   child: Column(
                //     //     children: [
                //     //       Container(
                //     //         height: 50,
                //     //         width: 50,
                //     //         child: Center(
                //     //           child: Container(
                //     //             width: 35,
                //     //             height: 35,
                //     //             child: ClipRRect(
                //     //               borderRadius: BorderRadius.circular(15),
                //     //               child: clubImage.isNotEmpty ?
                //     //               Image.network(clubImage, fit: BoxFit.cover,):
                //     //               Image.asset('assets/images/logo.png', fit: BoxFit.cover,),
                //     //             ),
                //     //           ),
                //     //         ),
                //     //       ),
                //     //       Padding(
                //     //         padding: const EdgeInsets.only(top:8.0),
                //     //         child: Container(
                //     //             child: Text(clubName, style: TextStyle(fontSize: 12),overflow: TextOverflow.ellipsis,)
                //     //         ),
                //     //       ),
                //     //     ],
                //     //   ),
                //     // )
                //   ],
                // ),

                !isOwner
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Members"),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "$memberCount",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Rooms Hosted"),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${bookClub!.roomsCount}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),

                !isOwner && isInviteOnly && !isSubscribed
                    ? GestureDetector(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          width: 90.w,
                          height: 40,
                          decoration: BoxDecoration(
                              color: isInvited
                                  ? Colors.grey
                                  : theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isInvited
                                      ? Colors.white12
                                      : Colors.transparent,
                                  width: 1)),
                          child: Center(
                            child: Text(
                              isInvited ? "Remove Request" : "Send Request",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'text',
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        onTap: () {
                          if (isInvited) {
                            removeInvite();
                            ToastMessege("Request Removed", context: context);
                          } else {
                            sendInvite();
                            ToastMessege("Request sent", context: context);
                          }
                          setState(() {
                            isInvited = !isInvited;
                          });
                        },
                      )
                    : Container(),

                //subscribe button
                !isOwner && !isInviteOnly && !isSubscribed
                    ? GestureDetector(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          width: 90.w,
                          height: 40,
                          decoration: BoxDecoration(
                              color: isSubscribed
                                  ? Colors.grey
                                  : theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isSubscribed
                                      ? Colors.white12
                                      : Colors.transparent,
                                  width: 1)),
                          child: Center(
                            child: Text(
                              isSubscribed ? "Unsubscribe" : "Subscribe",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'text',
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        onTap: () {
                          if (!isSubscribed) {
                            _bookClubServices.subscribeBookClub(
                                bookClub!.id, userID, tokenID);
                            addAsSubscriber();
                            setState(() {
                              memberCount++;
                            });
                          } else {
                            _bookClubServices.unsubscribeBookClub(
                                bookClub!.id, userID, tokenID);
                            removeAsSubscriber();
                            setState(() {
                              memberCount--;
                            });
                          }
                          setState(() {
                            isSubscribed = !isSubscribed;
                          });
                        },
                      )
                    : Container(),
                !isOwner && isSubscribed
                    ? GestureDetector(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          width: 90.w,
                          height: 40,
                          decoration: BoxDecoration(
                              color: isSubscribed
                                  ? Colors.grey
                                  : theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isSubscribed
                                      ? Colors.white12
                                      : Colors.transparent,
                                  width: 1)),
                          child: Center(
                            child: Text(
                              isSubscribed ? "Unsubscribe" : "Subscribe",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'text',
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        onTap: () {
                          if (!isSubscribed) {
                            _bookClubServices.subscribeBookClub(
                                bookClub!.id, userID, tokenID);
                            addAsSubscriber();
                            setState(() {
                              memberCount++;
                            });
                          } else {
                            _bookClubServices.unsubscribeBookClub(
                                bookClub!.id, userID, tokenID);
                            removeAsSubscriber();
                            setState(() {
                              memberCount--;
                            });
                          }
                          setState(() {
                            isSubscribed = !isSubscribed;
                          });
                        },
                      )
                    : Container(),

                //genres
                Row(
                  children: [
                    Text(
                      "Genres",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.inversePrimary,
                      ),
                    ),
                    isOwner
                        ? IconButton(
                            icon: FaIcon(FontAwesomeIcons.edit),
                            iconSize: 14,
                            onPressed: () async {
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectBookClubGenre(
                                    bookClubId: bookClub!.id,
                                  ),
                                ),
                              );
                              setState(() {
                                bookClub!.genres = res;
                              });
                            },
                          )
                        : SizedBox(
                            height: 30,
                          ),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: bookClub!.genres.isNotEmpty
                          ? ListView(
                              //shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(bookClub!.genres.length,
                                  (index) {
                                final genre = bookClub!.genres[index];
                                return Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            right: 10, left: 10),
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: (genre ==
                                                  "Action and Adventure")
                                              ? Image.asset(
                                                  "assets/images/Genre_A&A.png",
                                                  fit: BoxFit.cover,
                                                )
                                              : (genre ==
                                                      "Biographies and Autobiographies")
                                                  ? Image.asset(
                                                      "assets/images/Genre_B&A.png",
                                                      fit: BoxFit.cover,
                                                    )
                                                  : (genre == "Classics")
                                                      ? Image.asset(
                                                          "assets/images/Genre_Classics.png",
                                                          fit: BoxFit.cover,
                                                        )
                                                      : (genre == "Comic Book")
                                                          ? Image.asset(
                                                              "assets/images/Genre_Comic.png",
                                                              fit: BoxFit.cover,
                                                            )
                                                          : (genre ==
                                                                  "Cookbooks")
                                                              ? Image.asset(
                                                                  "assets/images/Genre_Cooking.png",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : (genre ==
                                                                      "Detective and Mystery")
                                                                  ? Image.asset(
                                                                      "assets/images/Genre_D&M.png",
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : (genre ==
                                                                          "Essays")
                                                                      ? Image
                                                                          .asset(
                                                                          "assets/images/Genre_Essay.png",
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )
                                                                      : (genre ==
                                                                              "Fantasy")
                                                                          ? Image
                                                                              .asset(
                                                                              "assets/images/Genre_Fantasy.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : (genre == "Historical Fiction")
                                                                              ? Image.asset(
                                                                                  "assets/images/Genre_HF.png",
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : (genre == "Horror")
                                                                                  ? Image.asset(
                                                                                      "assets/images/Genre_Horror.png",
                                                                                      fit: BoxFit.cover,
                                                                                    )
                                                                                  : (genre == "Literary Fiction")
                                                                                      ? Image.asset(
                                                                                          "assets/images/Genre_LF.png",
                                                                                          fit: BoxFit.cover,
                                                                                        )
                                                                                      : (genre == "Memoir")
                                                                                          ? Image.asset(
                                                                                              "assets/images/Genre_Memoir.png",
                                                                                              fit: BoxFit.cover,
                                                                                            )
                                                                                          : (genre == "Poetry")
                                                                                              ? Image.asset(
                                                                                                  "assets/images/Genre_Poetry.png",
                                                                                                  fit: BoxFit.cover,
                                                                                                )
                                                                                              : (genre == "Romance")
                                                                                                  ? Image.asset(
                                                                                                      "assets/images/Genre_Romance.png",
                                                                                                      fit: BoxFit.cover,
                                                                                                    )
                                                                                                  : (genre == "Science Fiction (Sci-Fi)")
                                                                                                      ? Image.asset(
                                                                                                          "assets/images/Genre_SciFi.png",
                                                                                                          fit: BoxFit.cover,
                                                                                                        )
                                                                                                      : (genre == "Short Stories")
                                                                                                          ? Image.asset(
                                                                                                              "assets/images/Genre_SS.png",
                                                                                                              fit: BoxFit.cover,
                                                                                                            )
                                                                                                          : (genre == "Suspense and Thrillers")
                                                                                                              ? Image.asset(
                                                                                                                  "assets/images/Genre_S&T.png",
                                                                                                                  fit: BoxFit.cover,
                                                                                                                )
                                                                                                              : (genre == "Self-Help")
                                                                                                                  ? Image.asset(
                                                                                                                      "assets/images/Genre_Self.png",
                                                                                                                      fit: BoxFit.cover,
                                                                                                                    )
                                                                                                                  : (genre == "True Crime")
                                                                                                                      ? Image.asset(
                                                                                                                          "assets/images/Genre_TC.png",
                                                                                                                          fit: BoxFit.cover,
                                                                                                                        )
                                                                                                                      : (genre == "Women's Fiction")
                                                                                                                          ? Image.asset(
                                                                                                                              "assets/images/Genre_WF.png",
                                                                                                                              fit: BoxFit.cover,
                                                                                                                            )
                                                                                                                          : Image.asset(
                                                                                                                              "assets/images/quiz.png",
                                                                                                                              fit: BoxFit.cover,
                                                                                                                            ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            )
                          : Center(
                              child: Text(
                              'No genres added',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'acumin-pro',
                                fontSize: 15,
                                color: theme.colorScheme.inversePrimary,
                              ),
                            )),
                    ),
                  ),
                ),
                BookClubActivity(
                  bookClub: widget.bookClub,
                  isSubscribed: isSubscribed,
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              backgroundColor: theme.colorScheme.secondary,
              child: Icon(Icons.add_box_outlined,color: Colors.white,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EnterBookClubRoomDetails(clubID: bookClub!.id),
                  ),
                );
              },
            )
          : Container(),
    );
  }
}
