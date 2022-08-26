import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/pages/rooms/ThemePage.dart';
import 'package:fostr/utils/widget_constants.dart';

class TheatreInfo extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? type;
  final bool insideTheatre;
  const TheatreInfo({Key? key, required this.data, this.type, required this.insideTheatre})
      : super(key: key);

  @override
  State<TheatreInfo> createState() => _TheatreInfoState();
}

class _TheatreInfoState extends State<TheatreInfo> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: theme.colorScheme.primary,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.colorScheme.primary,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text("Theatre Info",
                style: TextStyle(fontFamily: "drawerhead", fontSize: 18)),
            leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                )),
            actions: [
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              )
            ],
          ),
          body: Stack(
            children: [
              //image
              Align(
                alignment: Alignment(0, -1),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: widget.data["image"] == ''
                              ? Image.asset(
                                  "assets/images/logo.png",
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width,
                                )
                              : Image.network(
                                  widget.data['image'],
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width,
                                ),
                        ),

                        // //members count
                        // Align(
                        //   alignment: Alignment(-0.9, 0.8),
                        //   child: Container(
                        //     width: 60,
                        //     decoration: BoxDecoration(
                        //         color: Colors.black26,
                        //         border:
                        //             Border.all(color: Colors.black, width: 0.5),
                        //         borderRadius: BorderRadius.circular(20)),
                        //     child: Row(
                        //       children: [
                        //         Padding(
                        //           padding: const EdgeInsets.all(5),
                        //           child: Icon(
                        //             Icons.mic,
                        //             color: Colors.white,
                        //             size: 20,
                        //           ),
                        //         ),
                        //         StreamBuilder(
                        //           stream: roomCollection
                        //               .doc(widget.data['createdBy'])
                        //               .collection("amphitheatre")
                        //               .doc(widget.data['theatreId'])
                        //               .collection("users")
                        //               .where("isActiveInRoom", isEqualTo: true)
                        //               .snapshots(),
                        //           builder: (BuildContext context,
                        //               AsyncSnapshot<
                        //                       QuerySnapshot<
                        //                           Map<String, dynamic>>>
                        //                   snapshot) {
                        //             if (snapshot.hasData) {
                        //               return Text(
                        //                 snapshot.data!.docs.length.toString(),
                        //                 // style: TextStyle(color: Colors.white),
                        //               );
                        //             } else {
                        //               return Text("");
                        //             }
                        //           },
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // )
                      ],
                    )),
              ),

              //info
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          // border: Border(top : BorderSide(color: GlobalColors.signUpSignInButton, width: 0.5)),
                        ),
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              (MediaQuery.of(context).size.width + 90),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              //title
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  widget.data['title'],
                                  style: TextStyle(
                                      color: theme.colorScheme.inversePrimary,
                                      fontSize: 26,
                                      fontFamily: "drawerhead"),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),

                              //by
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  "by ${widget.data['creatorUsername']}",
                                  style: TextStyle(
                                      color: theme.colorScheme.inversePrimary,
                                      fontSize: 12,
                                      fontFamily: "drawerbody"),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),

                              //genre
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  "Genre: ${widget.data['genre']}",
                                  style: TextStyle(
                                      color: theme.colorScheme.inversePrimary,
                                      fontSize: 16,
                                      fontFamily: "drawerbody"),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),

                              //chips
                              if (widget.data['followersOnly'] == true ||
                                  widget.data['inviteOnly'] == true) ...[
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                          widget.data['inviteOnly'] == true
                                              ? 'Invite Only'
                                              : 'Followers Only'),
                                      backgroundColor:
                                          Colors.grey[700]!.withOpacity(.5),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(
                                height: 10,
                              ),

                              //summary
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  "Summary:",
                                  style: TextStyle(
                                      color: theme.colorScheme.inversePrimary,
                                      fontSize: 16,
                                      fontFamily: "drawerbody"),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  widget.data['summary'] == ""
                                      ? "Description not provided"
                                      : widget.data['summary'],
                                  style: TextStyle(
                                      color: widget.data['summary'] == ""
                                          ? Colors.grey
                                          : theme.colorScheme.inversePrimary,
                                      fontSize: 12,
                                      fontFamily: "drawerbody",
                                      fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),

                              //peek in

                              if (!widget.data["isUpcoming"])
                                if (widget.data["id"] ==
                                        FirebaseAuth
                                            .instance.currentUser!.uid ||
                                    widget.data['inviteOnly'] != true)
                                  widget.type != "activity" && !widget.insideTheatre
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ThemePage(
                                                  room: Room.fromJson(
                                                      widget.data,
                                                      // widget.type == "all"
                                                      // ?
                                                      "change"
                                                      // : ""
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                10,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                              child: Text(
                                                'Peek In',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "drawerbody"),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink()
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
