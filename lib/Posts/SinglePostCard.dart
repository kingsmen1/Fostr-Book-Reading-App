import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/FeedPostCard.dart';
import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:fostr/services/UserService.dart';
import 'package:get_it/get_it.dart';

class SinglePostCard extends StatefulWidget {
  final String postID;
  const SinglePostCard({Key? key, required this.postID}) : super(key: key);

  @override
  _SinglePostCardState createState() => _SinglePostCardState();
}

class _SinglePostCardState extends State<SinglePostCard> {
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
  late DocumentReference<Map<String, dynamic>> postRef;
  bool isActive = true;
  String authorID = "";
  String userID = "";
  var streamBuilder;

  @override
  void initState() {
    super.initState();
    checkIsActive();
  }

  void checkIsActive() {
    postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postID);
    postRef.get().then((value) {
      setState(() {
        isActive = value.get("isActive");
        authorID = value.get("userid");
        userID = FirebaseAuth.instance.currentUser!.uid;
        userServices.getUserById(authorID).then((value) {
          user = value!;
        });
      });
    });
  }

  void deletePost() async {
    postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postID);
    postRef.update({
      'isActive': false,
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(widget.postID)
          .delete();
      setState(() {
        isActive = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isActive
        ? StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("posts")
                .doc(widget.postID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text("");
                default:
                
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new Text("");
                    default:
                   
                      Map<String, dynamic> feed = {
                        'id': widget.postID,
                        'caption': snapshot.data!.get("caption"),
                        'comments': snapshot.data!.get("comments"),
                        'dateTime': snapshot.data!.get("dateTime"),
                        'image': snapshot.data!.get("image"),
                        'isActive': snapshot.data!.get("isActive"),
                        'likes': snapshot.data!.get("likes"),
                        'userProfile': snapshot.data!.get("userProfile"),
                        'username': snapshot.data!.get("username"),
                        'userid': snapshot.data!.get("userid"),
                      };

                      return FeedPostCard(feed: feed);
                  }
              }
            },
          )
        : SizedBox.shrink();
  }
}