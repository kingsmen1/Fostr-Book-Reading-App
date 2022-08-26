import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'AppLoading.dart';

class LikesList extends StatefulWidget {
  final List likeIDs;
  final String type;
  const LikesList({
    Key? key,
    required this.likeIDs,
    required this.type,
  }) : super(key: key);

  @override
  _LikesListState createState() => _LikesListState();
}

class _LikesListState extends State<LikesList> {
  bool likesTab = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: widget.likeIDs.length > 0
            ? ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: widget.likeIDs.length,
                itemBuilder: (context, index) {
                  // print("${users.length} ddjd");
                  if (widget.likeIDs.length > 0) {
                    return LikesUserCard(
                      id: widget.likeIDs[index],
                    );
                  } else {
                    return Center(
                      child: AppLoading(
                        height: 70,
                        width: 70,
                      ),
                      // CircularProgressIndicator(
                      //   color: GlobalColors.signUpSignInButton,
                      // ),
                    );
                  }
                },
              )
            : Center(
              child: Text(
                  widget.type == "bookmark"
                      ? "No one has bookmarked yet"
                      : "No likes yet",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: "drawerbody"),
                ),
            ));
  }
}

class LikesUserCard extends StatefulWidget {
  final String id;
  const LikesUserCard({Key? key, required this.id}) : super(key: key);

  @override
  State<LikesUserCard> createState() => _LikesUserCardState();
}

class _LikesUserCardState extends State<LikesUserCard> with FostrTheme {
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
  bool authorActive = true;
  bool isBlocked = false;
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

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: widget.id)
        .where('accDeleted', isEqualTo: true)
        .limit(1)
        .get()
        .then((value){
      if(value.docs.length == 1){
        if(value.docs.first['accDeleted']){
          setState(() {
            authorActive = false;
          });
        }
      }
    });
  }

  void checkIfUserIsBlocked(String authId) async {
    await FirebaseFirestore.instance
        .collection("block tracking")
        .doc(authId)
        .collection('block_list')
        .where('blockedId', isEqualTo: widget.id)
        .limit(1)
        .get()
        .then((value){
      if(value.docs.length == 1){
        if(value.docs.first['isBlocked']){
          setState(() {
            isBlocked = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    checkIfUserIsInactive();
    checkIfUserIsBlocked(auth.user!.id);

    return authorActive && !isBlocked ?
    GestureDetector(
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
              color: Color(0xffffffff), borderRadius: BorderRadius.circular(10)
              // boxShadow: [
              //   BoxShadow(
              //     offset: Offset(0, 4),
              //     blurRadius: 10,
              //     color: Colors.black.withOpacity(0),
              //   )
              // ],
              ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 12.w,
                width: 12.w,
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
                                fontFamily: "drawerhead"),
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
                      style:
                          h1.copyWith(fontSize: 12, fontFamily: "drawerbody"),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ) :
    SizedBox.shrink();
  }
}
