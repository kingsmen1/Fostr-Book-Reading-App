import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/services/PostService.dart';
import 'package:fostr/services/ReviewService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:get_it/get_it.dart';

import 'AppLoading.dart';

class CommentBoxCommon extends StatefulWidget {
  final String type;
  final String reviewId;
  final String postId;
  final String userId;
  final UserModel.User USER;
  const CommentBoxCommon({
    Key? key,
    required this.type,
    required this.reviewId,
    required this.postId,
    required this.userId,
    required this.USER,
  }) : super(key: key);

  @override
  _CommentBoxCommonState createState() => _CommentBoxCommonState();
}

class _CommentBoxCommonState extends State<CommentBoxCommon> {
  bool posting = false;
  bool postingComment = false;
  late DocumentReference<Map<String, dynamic>> postRef;
  TextEditingController commentController = new TextEditingController();
  UserModel.User user = UserModel.User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });

  void saveReviewComment(String comment) async {
    setState(() {
      posting = true;
    });
    postRef =
        FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId);
    UserService userServices = GetIt.I<UserService>();
    await userServices.getUserById(widget.userId).then((value) async {
      if (value != null) {
        user = value;
        FirebaseAuth.instance.currentUser!.getIdToken().then((token) async {
          await ReviewService()
              .addComment(token, widget.reviewId, user.id, user.userName,
                  user.name, user.userProfile!.profileImage ?? "", comment)
              .then((value) {
            if (value) {
              print("comment posted");
              commentController.clear();
            } else {
              print("comment not posted");
            }
          });
        });

        // await FirebaseDatabase.instance
        //     .ref()
        //     .child('book_review_stats')
        //     .child(widget.postId)
        //     .child("comments")
        //     .push()
        //     .set({
        //   'by': user.id,
        //   'username': user.userName,
        //   'f_name': user.name,
        //   'profile': user.userProfile!.profileImage,
        //   'comment': comment,
        //   'active': true,
        //   'on': DateTime.now().millisecondsSinceEpoch,
        // }).then((value) {
        //   commentController.clear();
        //   postRef.update({
        //     'comments': FieldValue.increment(1),
        //   });
        // });
      } else {
        print("user not found");
      }
    });
    setState(() {
      posting = false;
    });
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ReviewLikesAndComments(
    //           bookName: widget.bookName,
    //           reviewID: widget.postId,))).then((value) {
    //   setState(() {});
    // });
  }

  void savePostComment() async {
    setState(() {
      // postingComment = true;
      posting = true;
    });
    postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    await FirebaseAuth.instance.currentUser!.getIdToken().then((token) {
      PostService()
          .addComment(
              token,
              widget.postId,
              widget.userId,
              widget.USER.userName,
              widget.USER.name,
              widget.USER.userProfile!.profileImage ?? "",
              commentController.text)
          .then((value) {
        if (value) {
          commentController.clear();
        } else {
          print("comment didn't post");
        }
      });
    });
    setState(() {
      // postingComment = false;
      posting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10) +
          const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          //comment
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width - 110,
            child: TextField(
              controller: commentController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 1),
                  filled: true,
                  hintStyle: new TextStyle(color: Colors.grey[600]),
                  hintText: "add a comment",
                  fillColor: Colors.white,
                  border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.grey))),
            ),
          ),
          SizedBox(
            width: 10,
          ),

          //post button
          GestureDetector(
            onTap: () {
              if (commentController.text.isEmpty) {
                Fluttertoast.showToast(
                    msg: "comment can't be empty",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: gradientBottom,
                    textColor: Colors.white,
                    fontSize: 16.0);
              } else {
                if (widget.type == "review") {
                  saveReviewComment(commentController.text);
                } else {
                  savePostComment();
                }
              }
            },
            child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: posting
                        ? Colors.transparent
                        : GlobalColors.signUpSignInButton),
                child: Center(
                  child: posting
                      ? AppLoading(
                          height: 70,
                          width: 70,
                        )
                      :
                      // CircularProgressIndicator(color: GlobalColors.signUpSignInButton) :
                      Icon(Icons.send, size: 18, color: Colors.white),
                )),
          )
        ],
      ),
    );
  }
}
