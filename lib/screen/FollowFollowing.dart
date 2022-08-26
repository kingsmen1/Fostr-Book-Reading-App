import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../widgets/AppLoading.dart';

class FollowFollowing extends StatefulWidget {
  final List<String>? items;
  final String title;
  FollowFollowing({Key? key, this.items, required this.title})
      : super(key: key);

  @override
  State<FollowFollowing> createState() => _FollowFollowingState();
}

class _FollowFollowingState extends State<FollowFollowing> with FostrTheme {
  final userService = GetIt.I<UserService>();
  List<String> users = [];

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    userService.getUserById(auth.user!.id).then((user) {
      if (user != null) {
        setState(() {
          auth.refreshUser(user);
          if (widget.title == "Following") {
            users = user.followings ?? [];
          } else if (widget.title == "Followers") {
            users = user.followers ?? [];
          } else if (widget.title == "Subscribers") {
            users = widget.items ?? [];
          }
        });
      } else {
        users = widget.items ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(

        appBar: PreferredSize(
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
                        widget.title,
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
        backgroundColor: theme.colorScheme.primary,
        body: Padding(
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(top: 10.0),
              //   child: Row(
              //     children: [
              //       Align(
              //         alignment: Alignment.centerLeft,
              //         child: IconButton(
              //             onPressed: () {
              //               Navigator.of(context).pop();
              //             },
              //             icon: Icon(
              //               Icons.arrow_back_ios,
              //             )),
              //       ),
              //       Text(
              //         widget.title,
              //         style: h1.copyWith(
              //             fontSize: 20.sp,
              //             fontFamily: 'drawerhead',
              //             color: theme.colorScheme.inversePrimary),
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
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
    final theme = Theme.of(context);
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
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                                  imageUrl: user.userProfile!.profileImage!
                                  // .toString()
                                  // .replaceAll(
                                  //     "https://firebasestorage.googleapis.com",
                                  //     "https://ik.imagekit.io/fostrreads")
                                  ,
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
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 5,
                    ),
                    (user.bookClubName != null && user.bookClubName!.isNotEmpty)
                        ? Text(
                            user.bookClubName!,
                            style: h1.copyWith(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "@" + user.userName,
                      style: h1.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// (!widget.isFollower)
//                 ? InkWell(
//                     onTap: () async {
//                       try {
//                         if (!widget.isFollower) {
//                           if (!followed) {
//                             var newUser =
//                                 await userService.followUser(auth.user!, user);
//                             setState(() {
//                               followed = true;
//                             });
//                             auth.refreshUser(newUser);
//                             Fluttertoast.showToast(
//                                 msg: "Followed Successfully!",
//                                 toastLength: Toast.LENGTH_SHORT,
//                                 gravity: ToastGravity.BOTTOM,
//                                 timeInSecForIosWeb: 1,
//                                 backgroundColor: gradientBottom,
//                                 textColor: Colors.white,
//                                 fontSize: 16.0);
//                           } else {
//                             var newUser = await userService.unfollowUser(
//                                 auth.user!, user);
//                             setState(() {
//                               followed = false;
//                             });
//                             auth.refreshUser(newUser);
//                             Fluttertoast.showToast(
//                                 msg: "Unfollowed Successfully!",
//                                 toastLength: Toast.LENGTH_SHORT,
//                                 gravity: ToastGravity.BOTTOM,
//                                 timeInSecForIosWeb: 1,
//                                 backgroundColor: gradientBottom,
//                                 textColor: Colors.white,
//                                 fontSize: 16.0);
//                           }
//                         }
//                       } catch (e) {
//                         print(e);
//                       }
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.all(10),
//                       padding: const EdgeInsets.all(10),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: h2.color,
//                       ),
//                       child: Text(
//                         (widget.isFollower)
//                             ? ""
//                             : (followed)
//                                 ? "Unfollow"
//                                 : "Follow",
//                         style: h2.copyWith(color: Colors.white),
//                       ),
//                     ),
//                   )
//                 : Container()
