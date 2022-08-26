import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/AllPosts.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/FeedProvider.dart';
import 'package:fostr/reviews/AllReviews.dart';
import 'package:fostr/reviews/PageSingleReview.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/floatingMenu.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

class GoToReviews extends StatefulWidget {
  const GoToReviews({Key? key}) : super(key: key);

  @override
  _GoToReviewsState createState() => _GoToReviewsState();
}

class _GoToReviewsState extends State<GoToReviews> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final feedsProvider = Provider.of<FeedProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text("Reviews",
          style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontFamily: 'drawerhead'
          ),),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context)=>
                        AllReviews(page: "home", postsOfUserId: "")));
              },
              icon: Icon(Icons.arrow_forward_ios,
                color: Colors.white,size: 20,)
          ),
          SizedBox(width: 10,)
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15) +
            const EdgeInsets.only(bottom: 10),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: new BorderRadius.circular(10),
            // only(
            //   topLeft: const Radius.circular(10),
            //   topRight: const Radius.circular(10),
            // ),
          ),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [

                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [

                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 60,
                            child: Text("Consider these reviews before you decide upon your next read",
                              style: TextStyle(
                                  color: theme.colorScheme.inversePrimary,
                                  fontSize: 16,
                                  fontFamily: 'drawerbody',
                                  fontStyle: FontStyle.italic
                              ),),
                          ),
                        ),

                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                    stream: FirebaseFirestore.instance
                    .collection("reviews")
                    .where("isActive", isEqualTo: true)
                    .orderBy("dateTime", descending: true)
                    .limit(10)
                    .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          height: MediaQuery.of(context).size.height - 350,
                          child: Center(
                            child: AppLoading(
                              height: 150,
                              width: 150,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(
                          "error occured",
                        );
                      }


                      if (snapshot.data!.docs.length == 0) {
                        return Container(
                          height: MediaQuery.of(context).size.height - 350,
                          child: Center(
                            child: Text(
                              "No Feeds Available",
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {


                          return BitTile(
                            bit: snapshot.data!.docs[index].data(),
                            authId: auth.user!.id,
                          );

                        }
                      );
                    },
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BitTile extends StatefulWidget {
  final Map<String,dynamic> bit;
  final String authId;
  const BitTile({Key? key, required this.bit, required this.authId}) : super(key: key);

  @override
  State<BitTile> createState() => _BitTileState();
}

class _BitTileState extends State<BitTile> {

  User user = User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "userProfile" : {
      "profileImage" : ""
    },
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });
  UserService userServices = GetIt.I<UserService>();
  late Timestamp datetime;
  String finalDateTime = "";
  bool bookmarked = false;
  bool authorActive = true;
  bool isBlocked = false;

  @override
  void initState() {
    checkIfBookmarked();
    getAuthor();

    if (widget.bit["dateTime"].runtimeType != Timestamp) {
      int seconds = int.parse(
          widget.bit["dateTime"].toString().split("_seconds: ")[1].split(", _")[0]);
      int nanoseconds = int.parse(
          widget.bit["dateTime"].toString().split("_nanoseconds: ")[1].split("}")[0]);
      datetime = Timestamp(seconds, nanoseconds);
    } else {
      datetime = widget.bit["dateTime"];
    }

    var dateDiff = DateTime.now().difference(datetime.toDate());
    if (dateDiff.inDays >= 1) {
      finalDateTime = DateFormat.yMMMd()
          .addPattern(" | ")
          .add_jm()
          .format(datetime.toDate())
          .toString();
    } else {
      finalDateTime = timeago.format(datetime.toDate());
    }

    super.initState();
  }

  void getAuthor() async {
    await userServices.getUserById(widget.bit['editorId']).then((value){
      setState(() {
        user = value!;
      });
    });
  }

  void bookmark(bool remove) async {
    await FirebaseFirestore.instance
        .collection("reviews")
        .where("id", isEqualTo: widget.bit['id'])
        .get()
        .then((value){
      value.docs.forEach((element) async {
        await FirebaseFirestore.instance
            .collection("reviews")
            .doc(element.id)
            .set({
          "bookmark" : remove ? FieldValue.arrayRemove([widget.authId]) : FieldValue.arrayUnion([widget.authId])
        }, SetOptions(merge: true));
      });
    });
  }

  void checkIfBookmarked() async {
    await FirebaseFirestore.instance
        .collection("reviews")
        .where("id", isEqualTo: widget.bit['id'])
        .get()
        .then((value){
      value.docs.forEach((element) async {
        try {
          List list = element["bookmark"].toList();
          setState(() {
            bookmarked = list.contains(widget) ? true : false;
          });
        } catch (e) {
          setState(() {
            bookmarked = false;
          });
        }
      });
    });
  }

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: widget.bit['editorId'])
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
        .where('blockedId', isEqualTo: widget.bit['editorId'])
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
    final theme = Theme.of(context);

    checkIfUserIsInactive();
    checkIfUserIsBlocked(widget.authId);

    return authorActive && !isBlocked?
      Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: GestureDetector(

        onTap: (){

          if(widget.bit["isActive"]){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PageSingleReview(
                        url: widget.bit['url'],
                        profile: user.userProfile!.profileImage ?? '',
                        username: user.userName,
                        bookName: widget.bit['bookName'],
                        bookAuthor: widget.bit['bookAuthor'],
                        bookBio: widget.bit['bookNote'],
                        dateTime: finalDateTime,
                        imageUrl: widget.bit['imageUrl'],
                        id: widget.bit['id'],
                        uid: widget.bit['editorId']
                    )));
          } else {
            ToastMessege("This Review has been deleted.", context: context);
          }
        },

        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Row(

            children: [

              //image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.bit['imageUrl'].toString().isEmpty ?
                  Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                  Image.network(widget.bit['imageUrl'] ??
                      "https://firebasestorage.googleapis.com/v0/b/fostr2021.appspot.com/o/FCMImages%2Ffostr.jpg?alt=media&token=42c10be6-9066-491b-a440-72e5b25fbef7", fit: BoxFit.cover,),
                ),
              ),
              SizedBox(width: 10,),

              //data
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Container()),
                      Container(
                        child: Text("${widget.bit['bookName']}",
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "drawerhead"
                        ),overflow: TextOverflow.ellipsis,),
                      ),
                      Container(
                        width: 150,
                        child: Text(widget.bit['bookAuthor'].toString().isNotEmpty ?
                        "by ${widget.bit['bookAuthor']}" : "",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: "drawerbody"
                          ),overflow: TextOverflow.ellipsis,),
                      ),
                      SizedBox(),
                      Text("${user.userName} | $finalDateTime",
                        style: TextStyle(
                            fontSize: 11,
                            fontFamily: "drawerbody"
                        ),),
                      Expanded(child: Container()),
                    ],
                  ),
              )),

              //bookmark
              Container(
                width: 30,
                height: 80,
                child: Align(
                  alignment: Alignment.topCenter,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("reviews")
                          .doc(widget.bit['id'])
                        .snapshots(),
                      builder: (context, snapshot) {

                        try{
                          List list = snapshot.data!["bookmark"].toList();
                          bookmarked = list.contains(widget.authId);
                        } catch (e) {
                          bookmarked =  false;
                        }

                        return IconButton(
                          onPressed: () async {
                            bookmark(bookmarked);
                          },
                          icon: bookmarked ?
                          Icon(Icons.bookmark,color: theme.colorScheme.secondary,) :
                          Icon(Icons.bookmark_border_rounded,color: theme.colorScheme.secondary,),
                        );
                      }
                    )),
              )


            ],

          ),
        ),
      ),
    ) :
    SizedBox.shrink();
  }
}


