import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../widgets/AppLoading.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with TickerProviderStateMixin {
  String currentDate = "";

  UserService userServices = GetIt.I<UserService>();
  User user = User.fromJson({
    "name": "",
    "userName": "",
    "id": "",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
    // "bookClubName": ""
  });
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        user = auth.user!;
      });

      var doc =
          FirebaseFirestore.instance.collection("users").doc(user.id).get();
      doc.then((value) {
        setState(() {
          user.name = value.data()?['name'];
          user.userName = value.data()?['userName'];
          user.userProfile?.bio = value.data()?['userProfile']['bio'];
          user.points = value.data()?['points'];
        });
      });
    });
  }

  DateTime startDate = DateTime(2013),
      endDate = DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        // backgroundColor: Color(0xff121212),
        backgroundColor: theme.colorScheme.primary,
        appBar: AppBar(
          title: Text(
            'Reward History',
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width - 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: MediaQuery.of(context).size.height * 0.15,
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Foster Points',
                                style: TextStyle(
                                  color: theme.colorScheme.inversePrimary,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.points.toString(),
                                style: TextStyle(
                                  color: theme.colorScheme.inversePrimary,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                      // Container(
                      //   width: MediaQuery.of(context).size.width * 0.4,
                      //   height: MediaQuery.of(context).size.height * 0.15,
                      //   padding: EdgeInsets.all(10.0),
                      //   decoration: BoxDecoration(
                      //     color: Colors.black,
                      //     borderRadius: BorderRadius.circular(10.0),
                      //   ),
                      //   child: Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       'Prizes Redeemed',
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 15.0,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     Text(
                      //       "0",
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 30.0,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ],)
                      // )
                    ])),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "History: ",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    // TabBar(
                    //   unselectedLabelColor: Colors.white,
                    //   labelColor: Colors.red,
                    //   tabs: [
                    //     Tab(
                    //       text: '1st tab',
                    //     ),
                    //     Tab(
                    //       text: '2 nd tab',
                    //     )
                    //   ],
                    //   controller: new TabController(length: 2, vsync: this),
                    //   indicatorSize: TabBarIndicatorSize.tab,
                    // ),
                    IconButton(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          lastDate: DateTime(2024),
                          firstDate: new DateTime(2019),
                          // builder: (BuildContext context, Widget ?child) {
                          //   return Theme(
                          //     data: ThemeData(
                          //       primarySwatch: Colors.deepOrange,
                          //       splashColor: Colors.black,
                          //     ),
                          //     child: child ??Text(""),
                          //   );
                          // }
                        );
                        if (picked != null && picked != null) {
                          print(picked);
                          setState(() {
                            startDate = picked.start;
                            endDate = picked.end.add(Duration(days: 1));
                            print("startDate :" + startDate.toString());
                            print("endDate" + endDate.toString());
                          });
                        }
                      },
                      icon: Icon(
                        Icons.filter_list,
                      ),
                    ),
                  ],
                ),
                //SizedBox(height: 20,),
                Container(
                  // color: Colors.red,
                  child: StreamBuilder<QuerySnapshot>(
                    //final Stream<QuerySnapshot> _logStream = FirebaseFirestore.instance.collection('activityLog').where('dateTime', isGreaterThanOrEqualTo: startDate).where('dateTime', isLessThanOrEqualTo: endDate).orderBy('dateTime', descending: true).snapshots();
                    stream: FirebaseFirestore.instance
                        .collection('activityLog')
                        .where('dateTime',
                            isGreaterThanOrEqualTo:
                                startDate.add(Duration(hours: 5, minutes: 30)))
                        .where('dateTime',
                            isLessThanOrEqualTo:
                                endDate.add(Duration(hours: 5, minutes: 30)))
                        .orderBy('dateTime', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          // color: Color(0xff121212),
                          child: Center(
                              child: AppLoading(
                            height: 70,
                            width: 70,
                          )
                              // CircularProgressIndicator(
                              //   backgroundColor: Colors.white,
                              //   valueColor: AlwaysStoppedAnimation<Color>(gradientTop),
                              // ),
                              ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Text(
                          "No Records Found",
                        );
                      }
                      return Container(
                        // color: Colors.red,
                        // height: MediaQuery.of(context).size.height * 1,
                        // width: MediaQuery.of(context).size.width * 1,
                        child: Column(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            final dateUnformatted = DateTime.parse(
                                data['dateTime'].toDate().toString());
                            String date = DateFormat.yMd().format(
                                dateUnformatted
                                    .subtract(Duration(hours: 5, minutes: 30)));
                            String final_date = DateFormat.yMMMEd().format(
                                dateUnformatted
                                    .subtract(Duration(hours: 5, minutes: 30)));
                            return Center(
                                child: (data['userId'] == user.id)
                                    ? Column(
                                        children: [
                                          // if(currentDate!=date) ...[
                                          //   Text("${final_date}", style: TextStyle(color: Colors.white),),

                                          // ],
                                          //(currentDate!=date)?Text("$final_date", style: TextStyle(color: Colors.white),):Container(),
                                          Builder(builder: (context) {
                                            if (currentDate != date) {
                                              currentDate = date;
                                              return Column(
                                                children: [
                                                  SizedBox(height: 20.0),
                                                  Text(
                                                    "$final_date",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                                ],
                                              );
                                            }
                                            return Container();
                                          }),
                                          Container(
                                              padding: EdgeInsets.all(5),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color:
                                                      theme.colorScheme.surface,
                                                  border: Border.all(
                                                      color: theme.colorScheme.inversePrimary,
                                                      width: 1)),
                                              margin: EdgeInsets.only(top: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Icon(
                                                    (data['activity_name'] ==
                                                            "create_room")
                                                        ? Icons.mic
                                                        : (data['activity_name'] ==
                                                                "create_review")
                                                            ? Icons.edit
                                                            : (data['activity_name'] ==
                                                                    "create_post")
                                                                ? Icons.post_add
                                                                : Icons
                                                                    .theater_comedy,
                                                    size: 30,
                                                    color: theme.colorScheme.secondary,
                                                  ),
                                                  Text(
                                                    (data['activity_name'] ==
                                                            "create_room")
                                                        ? "Created a Room"
                                                        : (data['activity_name'] ==
                                                                "create_review")
                                                            ? "Posted a Review"
                                                            : (data['activity_name'] ==
                                                                    "create_post")
                                                                ? "Created a Reading"
                                                                : (data['activity_name'] ==
                                                                        "create_theatre")
                                                                    ? "Created an Amphitheatre"
                                                                    : (data['activity_name'] ==
                                                                            "create_referral")
                                                                        ? "Referred FosterReads to a friends"
                                                                        : "Created a bookclub",
                                                    style: TextStyle(
                                                        color: theme.colorScheme.inversePrimary,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "+ ${data['points']} ",
                                                    style: TextStyle(
                                                        color: theme.colorScheme.inversePrimary,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 20,
                                          )
                                        ],
                                      )
                                    : null);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )));
  }
}
