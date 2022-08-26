import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/main.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  AuthProvider? user;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return SafeArea(
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
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => UserDashboard(tab: "all",selectDay: DateTime.now())));
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
                        "Notification",
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
        // AppBar(
        //   toolbarHeight: 65,
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   leading: IconButton(
        //     onPressed: () {
        //       if (Navigator.canPop(context)) {
        //         Navigator.pop(context);
        //       } else
        //         Navigator.of(context).pushReplacement(
        //             MaterialPageRoute(builder: (context) => UserDashboard(tab: "all",selectDay: DateTime.now())));
        //     },
        //     color: Colors.black87,
        //     icon: Icon(Icons.arrow_back_ios),
        //   ),
        //   title: Text(
        //     "Notifications",
        //     style: TextStyle(color: Colors.black87),
        //   ),
        // ),
        backgroundColor: Colors.white,
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.user!.id)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Text("I ${data['notifications'][0]["title"]}");
            }

            return Text("loading");
          },
        ),


        ///

        // Padding(
        //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 14),
        //   child: StreamBuilder(
        //       stream: FirebaseFirestore.instance.collection('users').doc(user.uid).get()["notifications"],
        //       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        //         if(!snapshot.hasData){
        //           return Center(
        //             child: CircularProgressIndicator(
        //               color:Color(0xff2A9D8F),
        //             ),
        //           );
        //         }
        //         return ListView(
        //           shrinkWrap: true,
        //           children: snapshot.data!.docs.map((document) {
        //             return Container(
        //               padding: EdgeInsets.symmetric(vertical: 4),
        //               decoration: BoxDecoration(
        //                 border: Border(
        //                   bottom: BorderSide(
        //                       width:0.5,
        //                       color: Colors.grey.shade400),
        //                 )
        //               ),
        //               child: ListTile(
        //                 onTap: ()=>{},
        //                 leading: CircleAvatar(
        //                     radius: 25,
        //                     backgroundColor:Color(0xff2A9D8F),
        //                     foregroundColor:Colors.white,
        //                     child: Icon(
        //                       Icons.calendar_today,
        //                       size: 17,
        //                     )
        //                 ),
        //                 title: Text(document["description"]),
        //               ),
        //             );
        //           }).toList(),
        //         );
        //       }
        //   ),
        // ),
      ),
    );
  }
}
