import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class PanelEpisodeCard extends StatefulWidget {
  final Map<String,dynamic> episode;
  const PanelEpisodeCard({Key? key,
    required this.episode}) : super(key: key);

  @override
  State<PanelEpisodeCard> createState() => _PanelEpisodeCardState();
}

class _PanelEpisodeCardState extends State<PanelEpisodeCard> {

  User? author = User.fromJson({
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

  late Timestamp datetime;
  String finalDateTime = "";

  @override
  void initState() {
    getAuthor();

    if (widget.episode["dateTime"].runtimeType != Timestamp) {
      int seconds = int.parse(
          widget.episode["dateTime"].toString().split("_seconds: ")[1].split(", _")[0]);
      int nanoseconds = int.parse(
          widget.episode["dateTime"].toString().split("_nanoseconds: ")[1].split("}")[0]);
      datetime = Timestamp(seconds, nanoseconds);
    } else {
      datetime = widget.episode["dateTime"];
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
    UserService().getUserById(widget.episode["authorId"])
        .then((value){
      setState(() {
        author = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(height: 70,),

            //image
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.episode['image'].toString().isEmpty ?
                Center(child: Image.asset("assets/images/logo.png", width: 100, height: 100,)) :
                Image.network(widget.episode['image'], fit: BoxFit.cover,),
              ),
            ),
            SizedBox(height: 10,),

            //title
            Text(widget.episode['title'],
              style: TextStyle(
                  color: theme.colorScheme.inversePrimary,
                  fontSize: 26,
                  fontFamily: "drawerhead"
              ),
            ),
            SizedBox(height: 10,),

            //datetime
            Container(
              width: MediaQuery.of(context).size.width-40,
              child: Text(finalDateTime,
                style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 13,
                    fontFamily: "drawerbody"
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 5,),

            //desc
            Container(
              width: MediaQuery.of(context).size.width-40,
              child: Text(widget.episode['description'],
                style: TextStyle(
                    color: theme.colorScheme.inversePrimary,
                    fontSize: 13,
                    fontFamily: "drawerbody"
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10,),

            //divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: MediaQuery.of(context).size.width - 100,
                height: 1,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(1)
                ),
              ),
            ),

            //author
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 40,
                child: Row(
                  children: [
                    Text("Author Profile",
                      style: TextStyle(
                          color: theme.colorScheme.inversePrimary,
                          fontSize: 16,
                          fontFamily: "drawerhead"
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(

                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      ExternalProfilePage(user: author!)
                  ));
                },

                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  child: Row(
                    children: [

                      //image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                width: 1,
                                color: author!.userProfile!.profileImage!.isEmpty ? Colors.grey : Colors.transparent
                            ),
                            borderRadius: BorderRadius.circular(30)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: author!.userProfile!.profileImage!.isEmpty ?
                          Center(child: Image.asset("assets/images/logo.png", width: 30, height: 30,)) :
                          Image.network(author!.userProfile!.profileImage!, fit: BoxFit.cover,),
                        ),
                      ),

                      //data
                      Expanded(
                        child: Container(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(),
                                SizedBox(),
                                Text(author!.name,style: TextStyle(fontSize: 16),),
                                Text(author!.userName,style: TextStyle(fontSize: 12),),
                                SizedBox(),
                                SizedBox(),

                              ],
                            ),
                          ),
                        ),
                      ),

                      //play
                      Icon(Icons.arrow_forward_ios, color: theme.colorScheme.secondary, size: 25,),
                      SizedBox(width: 5,)
                    ],
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
