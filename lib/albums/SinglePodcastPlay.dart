import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:provider/provider.dart';

import '../pages/user/userActivity/UserRecordings.dart';

class SinglePodcastPlay extends StatefulWidget {
  final String recId;
  const SinglePodcastPlay({Key? key, required this.recId}) : super(key: key);

  @override
  State<SinglePodcastPlay> createState() => _SinglePodcastPlayState();
}

class _SinglePodcastPlayState extends State<SinglePodcastPlay> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Text("Recording",
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'drawerbody'
          ),),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios,)
        ),
        actions: [
          Image.asset(
            "assets/images/logo.png",
            width: 50,
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: theme.colorScheme.primary,
        child: StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
          stream: FirebaseFirestore.instance
            .collection("recordings")
            .doc(widget.recId)
            .snapshots(),
          builder: (context, snapshot) {

            if(!snapshot.hasData){
              return SizedBox.shrink();
            }

            return RoomTile(
              authId: auth.user!.id,
              last: false,
              single: true,
              index: 0,
              roomData: [
                {
                  "id": widget.recId,
                  ...snapshot.data!.data()!,
                }
              ],
            );
          }
        ),
      ),
    );
  }
}
