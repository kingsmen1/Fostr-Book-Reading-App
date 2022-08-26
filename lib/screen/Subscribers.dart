import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/Layout.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../widgets/AppLoading.dart';

class Subscribers extends StatefulWidget {
  final List<String>? items;
  final String clubID;
  final String title;
  const Subscribers(
      {Key? key,
      required this.items,
      required this.clubID,
      required this.title})
      : super(key: key);

  @override
  _SubscribersState createState() => _SubscribersState();
}

class _SubscribersState extends State<Subscribers> with FostrTheme {
  final userService = GetIt.I<UserService>();
  List users = [];

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    userService.getUserById(auth.user!.id).then((user) {
      if (user != null) {
        setState(() {
          auth.refreshUser(user);
          users = widget.items ?? [];
        });
      } else {
        users = widget.items ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                        widget.title,
                        style: h1.copyWith(
                            fontSize: 20.sp,
                            color: theme.colorScheme.inversePrimary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.items?.length ?? 0,
                    itemBuilder: (context, index) {
                      // print("${users.length} ddjd");
                      if (users.length > 0) {
                        return UserCard(
                          id: users[index],
                          isFollower: widget.title == "Followers",
                        );
                      } else {
                        return Center(
                            child: AppLoading(
                          height: 70,
                          width: 70,
                        )
                            // CircularProgressIndicator(color:GlobalColors.signUpSignInButton)
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final String id;
  final bool isFollower;
  const UserCard({Key? key, required this.id, required this.isFollower})
      : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> with FostrTheme {
  User user = User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  bool followed = true;
  final UserService userService = GetIt.I<UserService>();

  @override
  void initState() {
    super.initState();
    userService.getUserById(widget.id).then((value) => {
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (auth.user?.id != widget.id) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) {
                return ExternalProfilePage(
                  user: user,
                );
              },
            ),
          );
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) {
                return UserProfilePage();
              },
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        // height: 65,
        width: 80.w,
        decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(10),
            border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.inversePrimary.withOpacity(0.3),
          ),
        )
            // boxShadow: [
            //   BoxShadow(
            //     offset: Offset(0, 4),
            //     blurRadius: 10,
            //     color: Colors.black.withOpacity(0),
            //   )
            // ],
            ),
        padding: const EdgeInsets.all(10),
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
                                imageUrl: user.userProfile!.profileImage!,
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
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.inversePrimary,
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 5,
                  ),
                  (user.bookClubName != null && user.bookClubName!.isNotEmpty)
                      ? Text(
                          user.bookClubName!,
                          style: h1.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.inversePrimary),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "@" + user.userName,
                    style: h2.copyWith(
                        fontSize: 12, color: theme.colorScheme.inversePrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
