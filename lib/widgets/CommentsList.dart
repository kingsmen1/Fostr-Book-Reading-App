import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sizer/sizer.dart';

class CommentsList extends StatefulWidget {
  final String type;
  final List commentIDs;
  final List comment;
  final List commentUserId;
  final List commentUsername;
  final List commentProfile;
  final List commentDate;
  const CommentsList({
    Key? key,
    required this.type,
    required this.comment,
    required this.commentUserId,
    required this.commentIDs,
    required this.commentDate,
    required this.commentProfile,
    required this.commentUsername,
  }) : super(key: key);

  @override
  _CommentsListState createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: widget.commentIDs.length > 0
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: widget.commentIDs.length,
                itemBuilder: (context, index) {
                  var commentTimestamp = widget.commentDate[index];
                  var dateObject =
                      DateTime.fromMillisecondsSinceEpoch(commentTimestamp);
                  String dateString;
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

                  return CommentTile(
                      comment: widget.comment[index],
                      commentUserId: widget.commentUserId[index],
                      commentUsername: widget.commentUsername[index],
                      commentProfile: widget.commentProfile[index] ?? "https://firebasestorage.googleapis.com/v0/b/fostr2021.appspot.com/o/FCMImages%2Ffostr.jpg?alt=media&token=42c10be6-9066-491b-a440-72e5b25fbef7",
                      dateString: dateString
                  );
                },
              )
            : Center(
              child: Text(
                widget.type == 'comment' ? "No comments yet" : "No comments yet",
                  style: TextStyle(fontSize: 12),
                ),
            ));
  }
}

class CommentTile extends StatefulWidget {
  final String commentProfile;
  final String commentUsername;
  final String dateString;
  final String comment;
  final String commentUserId;
  const CommentTile({Key? key,
  required this.comment,
    required this.commentUserId,
    required this.commentUsername,
    required this.commentProfile,
    required this.dateString,
  }) : super(key: key);

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {

  bool authorActive = true;
  bool isBlocked = false;

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: widget.commentUserId)
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
        .where('blockedId', isEqualTo: widget.commentUserId)
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

    return authorActive && !isBlocked?
    Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(
          vertical: 10.0, horizontal: 10),
      // height: 80,
      width: 80.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                //dp
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 5),
                  child: RoundedImage(
                    width: 25,
                    height: 25,
                    borderRadius: 15,
                    url: widget.commentProfile,
                  ),
                ),

                //username
                Container(
                    child: Row(
                      children: [
                        Text(
                          widget.commentUsername,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: "drawerhead"),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "~ ${widget.dateString}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),

          //comment
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, bottom: 5, right: 10),
              child: Container(
                child: Text(
                  widget.comment,
                  style: TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontFamily: "drawerbody"),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ],
      ),
    ) :
    SizedBox.shrink();
  }
}

