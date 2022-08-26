import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ReportContent.dart';
import 'package:fostr/theatre/TheatrePeekInPage.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class TheatreHomePage extends StatefulWidget {
  final String page;
  final String authId;
  const TheatreHomePage({Key? key, required this.page, required this.authId})
      : super(key: key);
  static const headStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);
  @override
  _TheatreHomePageState createState() => _TheatreHomePageState();
}

class _TheatreHomePageState extends State<TheatreHomePage> {
  late PageController _pageController;

  List<String> images = [
    "https://images.wallpapersden.com/image/download/purple-sunrise-4k-vaporwave_bGplZmiUmZqaraWkpJRmbmdlrWZlbWU.jpg",
    "https://wallpaperaccess.com/full/2637581.jpg",
    "https://uhdwallpapers.org/uploads/converted/20/01/14/the-mandalorian-5k-1920x1080_477555-mm-90.jpg"
  ];

  String imageUrl = "";
  // List<String> userIds = [];

  bool hasUpcomingEvent = true;

  // getAllId(){
  //   userIds = [];
  //   var doc = FirebaseFirestore.instance.collection('rooms').get();
  //   doc.then((value){
  //     value.docs.forEach((element) {
  //       userIds.add(element.id);
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // getAllId();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: widget.page == "home"
                  ? FirebaseFirestore.instance
                      .collectionGroup('amphitheatre')
                      .orderBy('scheduledOn', descending: true)
                      .where("isUpcoming", isEqualTo: false)
                      .where("isActive", isEqualTo: true)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collectionGroup('amphitheatre')
                      .orderBy('scheduledOn', descending: true)
                      .where("isUpcoming", isEqualTo: false)
                      .where("isActive", isEqualTo: true)
                      .where("createdBy", isEqualTo: widget.authId)
                      .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: AppLoading(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Text(
                    "No theatre found",
                  );
                }

                final List<Theatre> theatres = snapshot.data?.docs
                        .map(
                          (e) => Theatre.fromJson(e.data(), ""),
                        )
                        .toList() ??
                    [];

                final List<Theatre> filteredTheatres = theatres.where((e) {
                  return e.scheduleOn!.isAfter(DateTime.now()
                          .toUtc()
                          .subtract(Duration(minutes: 90))) &&
                      e.scheduleOn!.isBefore(
                          DateTime.now().toUtc().add(Duration(minutes: 10)));
                }).toList();

                if (filteredTheatres.length == 0) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        "No theatre found",
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: filteredTheatres.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return TheatreCard(
                      theatre: filteredTheatres[index],
                      userid: widget.authId,
                      isInviteOnly:
                          snapshot.data?.docs[index].data()["isInviteOnly"] ??
                              false,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class TheatreCard extends StatefulWidget {
  final Theatre theatre;
  final String userid;
  final isInviteOnly;
  const TheatreCard(
      {Key? key,
      required this.theatre,
      required this.userid,
      required this.isInviteOnly})
      : super(key: key);

  @override
  _TheatreCardState createState() => _TheatreCardState();
}

class _TheatreCardState extends State<TheatreCard> {
  bool active = true;
  bool authorActive = true;
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    checkIfUserIsInactive();
    checkIfUserIsBlocked(widget.userid);
  }

  void checkIfUserIsInactive() async {
    await FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: widget.theatre.createdBy)
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
        .where('blockedId', isEqualTo: widget.theatre.createdBy)
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
    final theme = Theme.of(context);

    return active && authorActive && !isBlocked
        ? Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.015),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: widget.theatre.imageUrl == ""
                        ? Image.asset(IMAGES + "logo_white.png").image
                        : NetworkImage(widget.theatre.imageUrl ?? "")),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradientBottom,
                    gradientTop,
                  ],
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.6)
                ], begin: Alignment.centerRight, end: Alignment.centerLeft),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //title
                  Text(
                    widget.theatre.title ?? "",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(widget.theatre.genre ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),

                  //summary and profile image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 12),
                          child: Text(
                            widget.theatre.summary ?? "",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                      RoundedImage(
                        width: 80,
                        height: 80,
                        borderRadius: 35,
                        url: widget.theatre.userProfileImage,
                      ),
                    ],
                  ),

                  //peek in/ invite only/ report
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: MaterialButton(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            onPressed: (widget.isInviteOnly &&
                                    widget.theatre.createdBy != auth.user?.id)
                                ? null
                                : () async {
                                    var doc = await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(widget.theatre.createdBy)
                                        .get();

                                    String name;
                                    String profileImage = "";
                                    if (doc.data()!["userProfile"] != null) {
                                      if (doc.data()!["userProfile"]
                                              ["profileImage"] !=
                                          null) {
                                        profileImage =
                                            doc.data()!["userProfile"]
                                                ["profileImage"];
                                      }
                                    }
                                    name = doc.data()!["name"];
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (BuildContext context) =>
                                            TheatrePeekInPage(
                                          theatre: widget.theatre,
                                          imageUrl: profileImage,
                                          name: name,
                                        ),
                                      ),
                                    );
                                  },
                            child:
                              (widget.isInviteOnly &&
                                      widget.theatre.createdBy != auth.user?.id) ?

                              Chip(
                                label: Text('Invite Only'),
                                backgroundColor:
                                Colors.grey[300]!.withOpacity(.5),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ) :
                                  // ? 'Invite Only'
                                  // :
                            Text('Peek in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            color: theme.colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      Expanded(child: Container(),),

                      //delete
                      widget.userid == widget.theatre.createdBy
                      ? Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                                onPressed: () async {
                                  // _roomService.updateIsActive(room);
                                  QuerySnapshot _myDoc = await FirebaseFirestore
                                      .instance
                                      .collection("rooms")
                                      .doc(widget.theatre.createdBy)
                                      .collection("amphitheatre")
                                      .doc(widget.theatre.theatreId)
                                      .collection("users")
                                      .where("isActiveInRoom", isEqualTo: true)
                                      .get();
                                  List<DocumentSnapshot> _myDocCount =
                                      _myDoc.docs;
                                  if (_myDocCount.length > 0) {
                                    confirmDialog(
                                        context,
                                        TextStyle(
                                          fontSize: 16,
                                          color:
                                              theme.colorScheme.inversePrimary,
                                          fontFamily: "Lato",
                                        ));
                                  } else {
                                    await roomCollection
                                        .doc(widget.theatre.createdBy)
                                        .collection("amphitheatre")
                                        .doc(widget.theatre.theatreId)
                                        .update({"isActive": false});
                                    await FirebaseFirestore.instance
                                        .collection("feeds")
                                        .doc(widget.theatre.theatreId)
                                        .delete()
                                        .then((value) {
                                      setState(() {
                                        active = false;
                                      });
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.delete_outline_outlined,
                                  size: 30,
                                  color: Colors.white,
                                ))

                      ): SizedBox.shrink(),

                      //share
                      widget.userid == widget.theatre.createdBy
                          ? IconButton(
                          onPressed: () async {

                            Share.share(await DynamicLinksApi
                                .inviteOnlyTheatreLink(
                              widget.theatre.theatreId!,
                              widget.theatre.createdBy!,
                              roomName: widget.theatre.title!,
                              imageUrl: widget.theatre.imageUrl,
                              creatorName: "",
                            ));

                          },
                          icon: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                          // Icon(
                          //   Icons.share,
                          //   color: Colors.white,
                          //   size: 30,
                          // )
                      )
                          : SizedBox.shrink(),

                      //report
      widget.userid != widget.theatre.createdBy
          ? Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ReportContent(
                                            contentId: widget.theatre.theatreId!,
                                            contentType: 'Theatre',
                                            contentOwnerId: widget.theatre.createdBy!,
                                          )
                                  ));
                            },
                            icon: Icon(
                              Icons.flag,
                              size: 20,
                              color: Colors.red,
                            ))

                      ): SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }

  Future<bool?> confirmDialog(BuildContext context, TextStyle h2) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final theme = Theme.of(context);
        return Container(
          height: size.height,
          width: size.width,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Align(
              alignment: Alignment(0, 0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: size.width * 0.9,
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cannot delete the room with speakers inside the room.',
                        textAlign: TextAlign.center,
                        style: h2.copyWith(
                          fontSize: 15.sp,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  theme.colorScheme.secondary),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              "Ok",
                              style: h2.copyWith(
                                fontSize: 17.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
