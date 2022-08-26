import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/Layout.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../utils/widget_constants.dart';
import '../widgets/AppLoading.dart';

class ParticipantsList extends StatefulWidget {
  final String title;
  final Room room;

  ParticipantsList({
    Key? key,
    required this.title,
    required this.room,
  }) : super(key: key);

  @override
  State<ParticipantsList> createState() => _ParticipantsListState();
}

class _ParticipantsListState extends State<ParticipantsList> with FostrTheme {
  final userService = GetIt.I<UserService>();
  List<String> users = [];

  @override
  void initState() {
    super.initState();

    // final auth = Provider.of<AuthProvider>(context, listen: false);
    // userService.getUserById(auth.user!.id).then((user) {
    //   if (user != null) {
    //     setState(() {
    //       auth.refreshUser(user);
    //       if (widget.title == "Followings") {
    //         users = user.followings ?? [];
    //       } else if (widget.title == "Followers") {
    //         users = user.followers ?? [];
    //       }
    //     });
    //   } else {
    //     users = widget.items ?? [];
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Layout(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  color: Colors.white,
                  boxShadow: boxShadow,
                ),
                child: Text(
                  widget.title,
                  style: h1.copyWith(fontSize: 26.sp),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: StreamBuilder(
                    stream: roomCollection
                        .doc(widget.room.id)
                        .collection("rooms")
                        .doc(widget.room.title)
                        .collection("participants")
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          var rawDocs = snapshot.data!;
                          var docs = rawDocs.docs.map((e) => e.data()).toList();

                          if (docs.isEmpty) {
                            return Center(
                              child: Text(
                                "No active participants",
                                style: h1.copyWith(fontSize: 20.sp),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, idx) {
                              return UserCard(
                                key: Key(docs[idx]['username']),
                                id: docs[idx]['username'],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("There might be some error"));
                        }
                      }
                      return Center(
                          child: AppLoading(
                        height: 70,
                        width: 70,
                      )
                          // CircularProgressIndicator(color:GlobalColors.signUpSignInButton)
                          );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final String id;

  const UserCard({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> with FostrTheme {
  User user = User.fromJson({
    "name": "",
    "userName": "",
    "id": "",
    "userType": "",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  bool followed = true;
  final UserService userService = GetIt.I<UserService>();

  @override
  void initState() {
    super.initState();
    userService.getUserByField("userName", widget.id).then((value) => {
          if (value != null)
            {
              setState(() {
                user = value;
              })
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) {
            if (auth.user!.id == user.id) {
              return UserProfilePage();
            } else {
              return ExternalProfilePage(
                user: user,
              );
            }
          },
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        // height: 65,
        constraints: BoxConstraints(minHeight: 100),
        width: 80.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          color: Color(0xffffffff),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 16,
              color: Colors.black.withOpacity(0.25),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (user.name.isNotEmpty)
                    ? Text(
                        user.name,
                        style: h1.copyWith(
                            fontSize: 14.sp, fontWeight: FontWeight.bold),
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 5,
                ),
                (user.bookClubName != null && user.bookClubName!.isNotEmpty)
                    ? Text(
                        user.bookClubName!,
                        style: h1.copyWith(
                            fontSize: 14.sp, fontWeight: FontWeight.bold),
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "@" + user.userName,
                  style: h2.copyWith(fontSize: 14),
                )
              ],
            ),
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
                                imageUrl: user.userProfile!.profileImage!,
                              )
                            : Image.asset(IMAGES + "profile.png").image
                        : Image.asset(IMAGES + "profile.png").image),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
