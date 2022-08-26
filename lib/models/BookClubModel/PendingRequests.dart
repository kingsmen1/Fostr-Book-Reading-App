import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/BookClubServices.dart';
import 'package:fostr/services/InAppNotificationService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/Layout.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class PendingRequests extends StatefulWidget {
  final BookClubModel club;
  const PendingRequests({
    Key? key,
    required this.club,
  }) : super(key: key);

  @override
  _PendingRequestsState createState() => _PendingRequestsState();
}

class _PendingRequestsState extends State<PendingRequests> with FostrTheme {
  final userService = GetIt.I<UserService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Layout(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back_ios)),
                      ),
                      Text(
                        "Pending Requests",
                        style: h1.copyWith(
                            fontSize: 20.sp, color: GlobalColors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("bookclubs")
                        .doc(widget.club.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Container();
                      }

                      if (!snapshot.hasData) {
                        return AppLoading();
                      }

                      if (snapshot.data == null) {
                        return Container();
                      }
                      final users =
                          snapshot.data?.data()?["pendingMembers"] ?? [];

                      if (users.length == 0) {
                        return SizedBox(
                          height: 250,
                          child: Center(
                            child: Text(
                              "No pending requests",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }

                      return Expanded(
                        child: ListView.builder(
                            itemBuilder: (context, index) {
                              return PendingRequestCard(
                                clubId: widget.club.id,
                                userId: users[index],
                                clubName: widget.club.bookClubName,
                                onRemove: () {},
                              );
                            },
                            itemCount: users.length,
                            shrinkWrap: true),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PendingRequestCard extends StatefulWidget {
  final String clubId;
  final String clubName;
  final String userId;
  final VoidCallback onRemove;

  const PendingRequestCard(
      {Key? key,
      required this.clubId,
      required this.userId,
      required this.clubName,
      required this.onRemove})
      : super(key: key);

  @override
  State<PendingRequestCard> createState() => _PendingRequestCardState();
}

class _PendingRequestCardState extends State<PendingRequestCard>
    with FostrTheme {
  final UserService userService = GetIt.I<UserService>();
  final BookClubServices _bookClubServices = GetIt.I<BookClubServices>();
  final InAppNotificationService _inAppNotificationService =
      GetIt.I<InAppNotificationService>();

  Future<User?> getUser() {
    return userService.getUserById(widget.userId);
  }

  Future<void> removeFromPending() async {
    await FirebaseFirestore.instance
        .collection("bookclubs")
        .doc(widget.clubId)
        .update({
      "pendingMembers": FieldValue.arrayRemove([widget.userId])
    });
  }

  Future<void> sendAcceptedOrRejectedNotification(String title) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token =
        await _inAppNotificationService.getNotificationToken(widget.userId);
    if (token == null) return;

    _inAppNotificationService.sendNotification(NotificationPayload(
      type: NotificationType.BookclubInvitationAccepted,
      tokens: [token],
      data: {
        "title": title,
        "senderUserId": auth.user!.id,
        "senderUserName": auth.user!.name,
        "recipientUserId": widget.userId,
        "payload": {
          "senderUserId": auth.user!.id,
          "senderUserName": auth.user!.name,
          "recipientUserId": widget.userId,
          "body": title,
        }
      },
    ));
  }

  Future<void> removeFromNotifications(String userId) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .where("senderUserId", isEqualTo: widget.userId)
        .get()
        .then((value) {
      for (var i = 0; i < value.docs.length; i++) {
        final doc = value.docs[i];
        final data = doc.data();

        if (data["payload"]["bookclubId"] == widget.clubId) {
          doc.reference.update({
            "read": true,
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return FutureBuilder<User?>(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Container();
          }

          if (!snapshot.hasData) {
            return AppLoading();
          }

          if (snapshot.data == null) {
            return Container();
          }
          final user = snapshot.data!;
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) {
                  return ExternalProfilePage(
                    user: user,
                  );
                },
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                // height: 65,
                constraints: BoxConstraints(minHeight: 80),
                width: 80.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffffffff),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 15.w,
                      width: 15.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: (user.userProfile != null)
                                ? (user.userProfile?.profileImage != null)
                                    ? FosterImageProvider(
                                        imageUrl:
                                            user.userProfile!.profileImage!,
                                      )
                                    : Image.asset(IMAGES + "profile.png").image
                                : Image.asset(IMAGES + "profile.png").image),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (user.name.isNotEmpty)
                              ? Text(
                                  user.name,
                                  style: h1.copyWith(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold),
                                )
                              : SizedBox.shrink(),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () async {
                        try {
                          final tokenID = await auth.firebaseUser!.getIdToken();

                          _bookClubServices.subscribeBookClub(
                              widget.clubId, widget.userId, tokenID);
                          await removeFromPending();
                          await FirebaseFirestore.instance
                              .collection("subscribedBookClubs")
                              .doc(widget.userId)
                              .set({
                            "subscribedBookClubs":
                                FieldValue.arrayUnion([widget.clubId])
                          }, SetOptions(merge: true));
                          sendAcceptedOrRejectedNotification(
                            "${auth.user!.userName} has accepted your invitation to join ${widget.clubName}",
                          );
                          removeFromNotifications(auth.user!.id);
                          widget.onRemove();
                          ToastMessege("Request Accepted", context: context);
                        } catch (e) {}
                      },
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        try {
                          FirebaseFirestore.instance
                              .collection("bookclubs")
                              .doc(widget.clubId)
                              .update({
                            "pendingMembers":
                                FieldValue.arrayRemove([widget.userId])
                          });
                          widget.onRemove();
                          removeFromNotifications(auth.user!.id);
                          sendAcceptedOrRejectedNotification(
                            "${auth.user!.userName} has rejected your invitation to join ${widget.clubName}",
                          );
                          ToastMessege("Request Rejected", context: context);
                        } catch (e) {}
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
