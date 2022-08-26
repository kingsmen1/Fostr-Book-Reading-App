import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/AllPosts.dart';
import 'package:fostr/Posts/PageSinglePost.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:get_it/get_it.dart';
import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class HighlightPostCard extends StatefulWidget {
  final Map<String, dynamic> feed;
  const HighlightPostCard({Key? key, required this.feed}) : super(key: key);

  @override
  State<HighlightPostCard> createState() => _HighlightPostCardState();
}

class _HighlightPostCardState extends State<HighlightPostCard> {
  UserModel.User user = UserModel.User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  UserService userServices = GetIt.I<UserService>();

  bool isActive = true;
  String authorID = "";
  String userID = "";
  String? profile = "";
  var username = "";
  late String likes;
  late String comments;
  late Timestamp dateTime;
  late String dateString;

  @override
  void initState() {
    super.initState();
    checkIsActive();
  }

  void checkIsActive() {
    isActive = widget.feed["isActive"];
    authorID = widget.feed["userid"];
    userID = FirebaseAuth.instance.currentUser!.uid;
    userServices.getUserById(authorID).then((value) {
      if (mounted) {
        setState(() {
          user = value!;
          profile = user.userProfile!.profileImage;
          username = user.userName;
        });
      }
    });

    likes = widget.feed["likes"].toString();
    comments = widget.feed["comments"].toString();

      int seconds = int.parse(widget.feed["dateTime"]
          .toString()
          .split("_seconds: ")[1]
          .split(", _")[0]);
      int nanoseconds = int.parse(widget.feed["dateTime"]
          .toString()
          .split("_nanoseconds: ")[1]
          .split("}")[0]);
      dateTime = Timestamp(seconds, nanoseconds);

    var dateObject =
    DateTime.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch);
    var dateDiff = DateTime.now().difference(dateObject);
    if (dateDiff.inDays >= 1) {
      dateString = DateFormat.yMMMd()
          .addPattern(" | ")
          .add_jm()
          .format(dateObject)
          .toString();
    } else {
      dateString = timeago.format(dateObject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isActive ?
    Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        width: 120,
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //image
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PageSinglePost(
                                postId: widget.feed['id'],
                                dateTime: dateTime,
                                userid: widget.feed['userid'],
                                userProfile: widget.feed['userProfile'],
                                username: username,
                                image: widget.feed['image'],
                                caption: widget.feed['caption'],
                                likes: likes,
                                comments: comments
                            )
                    ));
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60)
                  ),
                  border: Border.all(color: Colors.grey, width: 0.5)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60)
                  ),
                  child: FosterImage(
                    imageUrl: widget.feed['image'],
                    cachedKey: widget.feed['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 5,),

            //username
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ExternalProfilePage(user: user)
                    ));
              },
              child: Text(
                "by ${user.name}",
                style: TextStyle(
                  fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: "drawerbody",
                    fontWeight: FontWeight.bold
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    )
    : SizedBox.shrink();
  }
}
