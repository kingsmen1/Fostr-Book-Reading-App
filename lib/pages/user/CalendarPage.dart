  import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/models/UserModel/User.dart' as nUser;
import 'package:fostr/pages/rooms/RoomInfo.dart';
import 'package:fostr/pages/rooms/TheatreInfo.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ReportContent.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:table_calendar/table_calendar.dart';

// Future<List<Map<String, dynamic>>> getRooms(List<String> followings) async {
//   List<Map<String, dynamic>> rooms = [];
//   followings.forEach((id) async {
//     await roomCollection.doc(id).collection('rooms').get().then((value) {
//       final rawRooms = value.docs.map((e) => e.data()).toList();
//       rooms.addAll(rawRooms);
//     });
//   });
//   return rooms;
// }
// @override
// void initState() {
//   super.initState();
//   final auth = Provider.of<AuthProvider>(context, listen: false);
//   getRooms(auth.user!.followings!).then((value) {
//     setState(() {
//       allRooms = value;
//       print(value);
//       rooms = filterRooms(value, date);
//     });
//   });

class CalendarPage extends StatefulWidget {
  final int? chip;
  final DateTime? selectDay;
  const CalendarPage({Key? key, this.chip, this.selectDay}) : super(key: key);
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<CalendarPage> {
  UserService userServices = GetIt.I<UserService>();
  nUser.User? user;
  int selectedIndex = 0;
  DateTime selectedDay = DateTime.now();

  void updateProfile(Map<String, dynamic> data) async {
    await userServices.updateUserField(data);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        user = auth.user!;
      });
      fetchData();
    });

    setState(() {
      if (widget.chip == 1) {
        selectedIndex = 1;
      }
      if (widget.selectDay.toString().isNotEmpty) {
        selectedDay = widget.selectDay!;
      }
    });
  }

  Future fetchData() async {
    user = await userServices.getUserById(user!.id);
  }

  static const headStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: "drawerhead");
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  final list = [
    'Rooms',
    // 'Theatre',
  ];

  // List todayInfoList = [
  //   {
  //     'imageLink':
  //         'https://daveasprey.com/wp-content/uploads/2015/03/meditation_sun.jpg',
  //     'title': 'Autobiography',
  //     'subtitle': 'by yogi adithynath',
  //   },
  //   {
  //     'imageLink':
  //         'https://daveasprey.com/wp-content/uploads/2015/03/meditation_sun.jpg',
  //     'title': 'Autobiography',
  //     'subtitle': 'by yogi adithynath',
  //   }
  // ];

  Map<DateTime, List<Event>> events = {};

  List<Event> getEventFromDay(DateTime date) {
    return events[date] ?? [];
  }

  Event buildEvent(String eventType, String eventTitle, DateTime dateTime) {
    return Event(
        title: 'Foster Event : $eventTitle',
        description: '',
        location: 'Foster Reads',
        startDate: dateTime,
        endDate: dateTime.add(Duration(minutes: eventType == 'room' ? 45 : 90)),
        iosParams: IOSParams(
          // reminder: Duration(minutes: 40),
        ),
    );
    }

  Future<List> getTheatreForDay(DateTime date) async {
    final res = await FirebaseFirestore.instance
        .collectionGroup('amphitheatre')
        .orderBy('scheduledOn', descending: true)
        .where("isUpcoming", isEqualTo: true)
        .where("isActive", isEqualTo: true)
        .get();
    print(res.size);
    final List<String> d = date.toString().split(" ");
    final List<Map<String, dynamic>> list = [];
    for (final i in res.docs) {
      final data = i.data();
      final dateTime = data['scheduledOn'];
      if (d[0] == dateTime.toDate().toString().substring(0, 10)) {
        list.add(data);
      }
    }
    return list;
  }

  Future<List> getEventsForDay(DateTime date) async {
    final res = await FirebaseFirestore.instance
        .collectionGroup("rooms")
        .where("isUpcoming", isEqualTo: true)
        .where("isActive", isEqualTo: true)
        .get();

    // await FirebaseFirestore.instance
    //     .collection("upcomingRooms")
    //     .get()
    //     .then((value){
    //       value.docs.forEach((element) {
    //         if(!element.get("isAmphitheatre")){
    //           setState(() async {
    //             res = await FirebaseFirestore.instance
    //                 .collection("rooms/${element.get("userId")}/rooms").where("isUpcoming",isEqualTo: true).where("isActive",isEqualTo: true)
    //                 .get().then((value){
    //                   value.docs.forEach((element) {
    //                     print(element);
    //                   });
    //             });
    //             // res.then((value){
    //             //   print(value);
    //             // });
    //           });
    //         }
    //       });
    // });

    // await FirebaseFirestore.instance
    //     .collection("rooms")
    //     .get()
    //     .then((value){
    //       value.docs.forEach((element){
    //         setState(() async {
    //           res = await FirebaseFirestore.instance
    //               .collection("rooms/$element/rooms").where("isUpcoming",isEqualTo: true).where("isActive",isEqualTo: true)
    //               .get();
    //         });
    //       });
    // });

    print(res.size);
    final List<String> d = date.toString().split(" ");
    final List<Map<String, dynamic>> list = [];
    for (final i in res.docs) {
      final data = i.data();
      final dateTime = data['dateTime'];
      if (d[0] == dateTime.toDate().toString().substring(0, 10)) {
        list.add(data);
      }
    }
    return list;
  }

  final DateTime focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      extendBody: true,

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
                        Navigator.pop(context);
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
                      "Schedule",
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
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: Text(
      //     'Schedule',
      //     style:
      //     headStyle.copyWith(color: theme.colorScheme.inversePrimary),
      //   ),
      //   leading: GestureDetector(
      //     onTap: (){
      //       Navigator.pop(context);
      //     },
      //     child: Icon(Icons.arrow_back_ios, color: theme.colorScheme.inversePrimary,),
      //   ),
      //   actions: [
      //     Image.asset("assets/images/logo.png", width: 40, height: 40,)
      //   ],
      // ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Text(
              //   'Schedule',
              //   style:
              //       headStyle.copyWith(color: theme.colorScheme.inversePrimary),
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              //Changed Source Code of Package
              // C:\src\flutter\packages\flutter\lib\src\painting\box_decoration.dart
              Container(
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10)),
                child: TableCalendar(
                  eventLoader: getEventFromDay,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  onDaySelected: (DateTime selectDay, DateTime focusDay) {
                    setState(() {
                      selectedDay = selectDay;
                    });
                    print("selectedday");
                    print(selectDay);
                  },
                  selectedDayPredicate: (DateTime date) {
                    return isSameDay(selectedDay, date);
                  },
                  calendarFormat: CalendarFormat.month,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: selectedDay, // focusedDay
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(fontFamily: "drawerbody"),
                    isTodayHighlighted: true,
                    selectedDecoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    selectedTextStyle: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontFamily: "drawerbody"),
                    // todayDecoration: BoxDecoration(
                    //   color: Colors.blue.shade50,
                    //   shape: BoxShape.rectangle,
                    //   borderRadius: BorderRadius.circular(9.0),
                    // ),
                    defaultDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    weekendDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontFamily: "drawerbody",
                        fontSize: 16),
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.arrow_left,
                      color: theme.colorScheme.inversePrimary,
                      size: 30,
                    ),
                    rightChevronIcon: Icon(
                      Icons.arrow_right,
                      color: theme.colorScheme.inversePrimary,
                      size: 30,
                    ),
                    leftChevronMargin: EdgeInsets.only(left: 50, right: 0),
                    rightChevronMargin: EdgeInsets.only(left: 0, right: 50),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Upcoming events',
                style:
                    headStyle.copyWith(color: theme.colorScheme.inversePrimary),
              ),
              SizedBox(
                height: 20,
              ),
              // Row(
              //   children: [
              //     Container(
              //       padding: const EdgeInsets.only(left: 0,top: 10),
              //       height: 45,
              //       child: ListView.builder(
              //           shrinkWrap: true,
              //           scrollDirection: Axis.horizontal,
              //           itemCount: 1,
              //           itemBuilder: (context, i) {
              //             return GestureDetector(
              //               onTap: (){
              //
              //                 setState(() {
              //                   selectedIndex = i;
              //                 });
              //               },
              //               child: Container(
              //                 margin: const EdgeInsets.symmetric(horizontal: 5),
              //                 padding: const EdgeInsets.symmetric(
              //                     horizontal: 24),
              //                 decoration: BoxDecoration(
              //                     color: i == selectedIndex? GlobalColors.signUpSignInButton:GlobalColors.formBackground,
              //                     border: Border.all(width: 0.5),
              //                     borderRadius: BorderRadius.circular(24)),
              //                 child: Center(
              //                   child: Text(
              //                     list[i],
              //                     style: TextStyle(
              //                         color: i == selectedIndex? Colors.white:GlobalColors.signUpSignInButton, fontFamily: "drawerbody"
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             );
              //           }),
              //     ),
              //   ],
              // ),
              // selectedIndex == 0 ?
///
              //rooms
              FutureBuilder(
                  future: getEventsForDay(selectedDay),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("No events found");
                    }
                    print(snapshot.data);
                    return Column(
                      children: [
                        snapshot.data!.isNotEmpty ?
                        Row(
                          children: [
                            Text("Rooms",
                              style: headStyle.copyWith(color: theme.colorScheme.inversePrimary),)
                          ],
                        ) : SizedBox(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            // if (index == snapshot.data!.length) {
                            //   if (index == 0) {
                            //     return SizedBox.shrink();
                            //   }
                            //   return SizedBox(
                            //     height: 200,
                            //   );
                            // }

                            bool active = snapshot.data![index]["isActive"];
                            return active
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal:
                                              MediaQuery.of(context).size.width *
                                                  0.02),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: snapshot.data![index]
                                                          ["image"] ==
                                                      ''
                                                  ? Image.asset(
                                                          IMAGES + "logo_white.png")
                                                      .image
                                                  : NetworkImage(snapshot
                                                      .data![index]['image'])),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              gradientBottom,
                                              gradientTop,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(24)),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Colors.black.withOpacity(0.2),
                                                Colors.black.withOpacity(0.9)
                                              ],
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft),
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //title
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: Text(
                                                    snapshot.data![index]['title'],
                                                    overflow: TextOverflow.fade,
                                                    maxLines: 2,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                //genre
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black45,
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.black),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24)),
                                                  child: Text(
                                                      snapshot.data![index]
                                                          ['genre'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                            //author
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    "by " +
                                                        snapshot.data![index]
                                                            ['roomCreator'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: "Lato",
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                            builder: (context) =>
                                                                RoomInfo(
                                                              data: snapshot
                                                                  .data?[index]!,
                                                                  insideRoom: false,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Icon(
                                                        Icons.info_outline_rounded,
                                                        color: Colors.white,
                                                      ))
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 24,
                                            ),

                                            if (snapshot.data![index]
                                                        ['followersOnly'] ==
                                                    true ||
                                                snapshot.data![index]
                                                        ['inviteOnly'] ==
                                                    true) ...[
                                              Chip(
                                                label: Text(snapshot.data![index]
                                                            ['inviteOnly'] ==
                                                        true
                                                    ? 'Invite Only'
                                                    : 'Followers Only'),
                                                backgroundColor: Colors.grey[300]!
                                                    .withOpacity(.5),
                                                elevation: 0,
                                                shadowColor: Colors.transparent,
                                              ),
                                            ],

                                            //datetime
                                            Row(
                                              children: [
                                                Text(
                                                  DateFormat.yMMMd()
                                                      .add_jm()
                                                      .format(snapshot.data![index]
                                                              ['dateTime']
                                                          .toDate()
                                                          .toLocal()),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                                Expanded(child: Container()),
                                                GestureDetector(
                                                  onTap: () async {
                                                    Add2Calendar.addEvent2Cal(
                                                        buildEvent(
                                                            'room',
                                                            snapshot.data![index]['title']
                                                            ,snapshot
                                                            .data![index]
                                                        ['dateTime']
                                                            .toDate()));
                                                  },
                                                  child: Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.white,
                                                    size: 25,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    // Opacity will become zero
                                                    // if (!isInviteOnly) return;
                                                    Share.share(
                                                        await DynamicLinksApi
                                                            .inviteOnlyRoomLink(
                                                      snapshot.data![index]
                                                          ["roomID"],
                                                      snapshot.data![index]["id"],
                                                      roomName: snapshot
                                                          .data![index]["title"],
                                                      imageUrl: snapshot
                                                          .data![index]["image"],
                                                    ));
                                                  },
                                                  child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                                                  // Icon(
                                                  //   Icons.share_rounded,
                                                  //   color: Colors.white,
                                                  // ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),

                                                //delete
                                                snapshot.data![index]['id'] ==
                                                        auth.user!.id
                                                    ? GestureDetector(
                                                        onTap: () async {
                                                          // _roomService
                                                          //     .updateIsActive(snapshot.data![index]);
                                                          await roomCollection
                                                              .doc(snapshot
                                                                      .data![index]
                                                                  ['id'])
                                                              .collection("rooms")
                                                              .doc(snapshot
                                                                      .data![index]
                                                                  ['roomID'])
                                                              .update({
                                                            'isActive': false
                                                          });
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection("feeds")
                                                              .doc(snapshot
                                                                      .data![index]
                                                                  ['roomID'])
                                                              .delete();
                                                          setState(() {
                                                            active = false;
                                                          });
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .delete_outline_outlined,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      )
                                                    : SizedBox.shrink(),

                                                //report
                                                snapshot.data![index]['id'] !=
                                                    auth.user!.id
                                                    ? GestureDetector(
                                                  onTap: () async {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ReportContent(
                                                                  contentId: snapshot.data![index]["roomID"],
                                                                  contentType: 'Room',
                                                                  contentOwnerId: snapshot.data![index]["id"],
                                                                )
                                                        ));
                                                  },
                                                  child: Icon(
                                                    Icons
                                                        .flag,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                )
                                                    : SizedBox.shrink(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink();
                          },
                        ),
                      ],
                    );
                  }),
              // :

              //theatres
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: FutureBuilder(
                    future: getTheatreForDay(selectedDay),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("No events found");
                      }
                      print(snapshot.data);

                      bool active = snapshot.data!.isNotEmpty;
                      return active
                          ? Column(
                            children: [
                              Row(
                                children: [
                                  Text("Theatres",
                                  style: headStyle.copyWith(color: theme.colorScheme.inversePrimary),)
                                ],
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == snapshot.data!.length) {
                                      return SizedBox(
                                        height: 200,
                                      );
                                    }

                                    Theatre theatre =
                                        Theatre.fromJson(snapshot.data![index], "");

                                    String name = snapshot.data?[index]
                                            ?['creatorUsername'] ??
                                        "s";

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        decoration: BoxDecoration(
                                    image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: theatre.imageUrl == ""
                                                    ? Image.asset(IMAGES +
                                                            "logo_white.png")
                                                        .image
                                                    : NetworkImage(
                                                        theatre.imageUrl ?? "")),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                gradientBottom,
                                                gradientTop,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(24)),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: [
                                                  Colors.black.withOpacity(0.2),
                                                  Colors.black.withOpacity(0.9)
                                                ],
                                                begin: Alignment.centerRight,
                                                end: Alignment.centerLeft),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  //title
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: Text(
                                                        theatre.title ?? "",
                                                      overflow: TextOverflow.fade,
                                                      maxLines: 2,
                                                      softWrap: false,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  //genre
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black45,
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.black),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            24)),
                                                    child: Text(
                                                        theatre.genre ?? "",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                            FontWeight.bold)),
                                                  ),
                                                ],
                                              ),
                                              //author
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(top: 8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    name != ""
                                                                  ? Text(
                                                                      "by " + name,
                                                                      style: TextStyle(
                                                                          fontSize: 12,
                                                                          color: Colors.white,
                                                                        fontFamily: 'Lato'
                                                                      ),
                                                                    )
                                                                  : SizedBox.shrink(),
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                              builder: (context) =>
                                                              TheatreInfo(
                                                                                          data: snapshot
                                                                                              .data?[index]!,
                                                                insideTheatre: false,
                                                                                        ),
                                                            ),
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.info_outline_rounded,
                                                          color: Colors.white,
                                                        ))
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 24,
                                              ),

                                              if (snapshot.data![index]
                                              ['followersOnly'] ==
                                                  true ||
                                                  snapshot.data![index]
                                                  ['isInviteOnly'] ==
                                                      true) ...[
                                                Chip(
                                                  label: Text(snapshot.data![index]
                                                  ['isInviteOnly'] ==
                                                      true
                                                      ? 'Invite Only'
                                                      : 'Followers Only'),
                                                  backgroundColor: Colors.grey[300]!
                                                      .withOpacity(.5),
                                                  elevation: 0,
                                                  shadowColor: Colors.transparent,
                                                ),
                                              ],

                                              //datetime
                                              Row(
                                                          children: [
                                                            theatre.scheduleOn != null
                                                                ? Text(
                                                                    DateFormat.yMMMd()
                                                                        .add_jm()
                                                                        .format(DateTime
                                                                                .parse(theatre
                                                                                    .scheduleOn
                                                                                    .toString())
                                                                            .toLocal()),
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: Colors.white),
                                                                  )
                                                                : SizedBox.shrink(),
                                                            Expanded(child: Container()),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                Add2Calendar.addEvent2Cal(
                                                                    buildEvent(
                                                                        'theatre',
                                                                        snapshot.data![index]['title']
                                                                        ,snapshot
                                                                        .data![index]
                                                                    ['scheduledOn']
                                                                        .toDate()));
                                                              },
                                                              child: Icon(
                                                                Icons.calendar_today,
                                                                color: Colors.white,
                                                                size: 25,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                // Opacity will become zero
                                                                // if (!isInviteOnly) return;
                                                                print(snapshot.data![index]["theatreId"]);
                                                                Share.share(
                                                                    await DynamicLinksApi
                                                                        .inviteOnlyTheatreLink(
                                                                  snapshot.data![index]
                                                                      ["theatreId"],
                                                                  snapshot.data![index]
                                                                      ["createdBy"],
                                                                  roomName: snapshot
                                                                      .data![index]["title"],
                                                                  imageUrl: snapshot
                                                                      .data![index]["image"],
                                                                ));
                                                              },
                                                              child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                                                              // Icon(
                                                              //   Icons.share_rounded,
                                                              //   color: Colors.white,
                                                              // ),
                                                            ),
                                                            SizedBox(
                                                              width: 1,
                                                            ),

                                                            //delete
                                                            auth.user?.id == theatre.createdBy
                                                                ? IconButton(
                                                                    onPressed: () async {
                                                                      // _roomService.updateIsActive(room);
                                                                      QuerySnapshot _myDoc =
                                                                          await FirebaseFirestore
                                                                              .instance
                                                                              .collection(
                                                                                  "rooms")
                                                                              .doc(theatre
                                                                                  .createdBy)
                                                                              .collection(
                                                                                  "amphitheatre")
                                                                              .doc(theatre
                                                                                  .theatreId)
                                                                              .collection(
                                                                                  "users")
                                                                              .where(
                                                                                  "isActiveInRoom",
                                                                                  isEqualTo:
                                                                                      true)
                                                                              .get();
                                                                      List<DocumentSnapshot>
                                                                          _myDocCount =
                                                                          _myDoc.docs;

                                                                      await roomCollection
                                                                          .doc(theatre
                                                                              .createdBy)
                                                                          .collection(
                                                                              "amphitheatre")
                                                                          .doc(theatre
                                                                              .theatreId)
                                                                          .update({
                                                                        "isActive": false
                                                                      });
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection("feeds")
                                                                          .doc(theatre
                                                                              .theatreId)
                                                                          .delete()
                                                                          .then((value) {
                                                                        setState(() {
                                                                          active = false;
                                                                        });
                                                                      });
                                                                      setState(() {
                                                                        active = false;
                                                                      });
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .delete_outline_outlined,
                                                                      color: Colors.white,
                                                                      size: 30,
                                                                    ))
                                                                : SizedBox.shrink(),

                                                            //report
                                                            auth.user?.id != theatre.createdBy
                                                                ? IconButton(
                                                                onPressed: () async {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ReportContent(
                                                                                contentId: theatre.theatreId!,
                                                                                contentType: 'Theatre',
                                                                                contentOwnerId: theatre.createdBy!,
                                                                              )
                                                                      ));
                                                                },
                                                                icon: Icon(
                                                                  Icons.flag,
                                                                  size: 20,
                                                                  color: Colors.red,
                                                                ))
                                                                : SizedBox.shrink(),
                                                          ],
                                                        ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    //   Padding(
                                    //   padding: const EdgeInsets.only(top: 10),
                                    //   child: Container(
                                    //     margin: EdgeInsets.symmetric(
                                    //         horizontal:
                                    //             MediaQuery.of(context).size.width *
                                    //                 0.02),
                                    //     decoration: BoxDecoration(
                                    //         image: DecorationImage(
                                    //             fit: BoxFit.cover,
                                    //             image: theatre.imageUrl == ""
                                    //                 ? Image.asset(IMAGES +
                                    //                         "logo_white.png")
                                    //                     .image
                                    //                 : NetworkImage(
                                    //                     theatre.imageUrl ?? "")),
                                    //         gradient: LinearGradient(
                                    //           begin: Alignment.topLeft,
                                    //           end: Alignment.bottomRight,
                                    //           colors: [
                                    //             gradientBottom,
                                    //             gradientTop,
                                    //           ],
                                    //         ),
                                    //         borderRadius:
                                    //             BorderRadius.circular(24)),
                                    //     child: Container(
                                    //       padding: const EdgeInsets.all(16),
                                    //       decoration: BoxDecoration(
                                    //         gradient: LinearGradient(
                                    //             colors: [
                                    //               Colors.black.withOpacity(0.2),
                                    //               Colors.black.withOpacity(0.9)
                                    //             ],
                                    //             begin: Alignment.centerRight,
                                    //             end: Alignment.centerLeft),
                                    //         borderRadius: BorderRadius.circular(24),
                                    //       ),
                                    //       child: Column(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.center,
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.start,
                                    //         children: [
                                    //           Row(
                                    //             mainAxisAlignment:
                                    //                 MainAxisAlignment.spaceBetween,
                                    //             children: [
                                    //
                                    //               //title
                                    //               Container(
                                    //                 width: MediaQuery.of(context).size.width - 120,
                                    //                 height: 30,
                                    //                 child: Text(
                                    //                   theatre.title ?? "",
                                    //                   style: TextStyle(
                                    //                       fontSize: 24,
                                    //                       color: Colors.white),
                                    //                   overflow: TextOverflow.ellipsis,
                                    //                 ),
                                    //               ),
                                    //
                                    //               //info icon
                                    //               GestureDetector(
                                    //                   onTap: () {
                                    //                     Navigator.push(
                                    //                       context,
                                    //                       CupertinoPageRoute(
                                    //                         builder: (context) =>
                                    //                             TheatreInfo(
                                    //                           data: snapshot
                                    //                               .data?[index]!,
                                    //                         ),
                                    //                       ),
                                    //                     );
                                    //                   },
                                    //                   child: Icon(
                                    //                     Icons.info_outline_rounded,
                                    //                     color: Colors.white,
                                    //                   ))
                                    //             ],
                                    //           ),
                                    //           name != ""
                                    //               ? Text(
                                    //                   "by " + name,
                                    //                   style: TextStyle(
                                    //                       fontSize: 14,
                                    //                       color: Colors.white),
                                    //                 )
                                    //               : SizedBox.shrink(),
                                    //           // Text(
                                    //           //   theatre.summary ?? "",
                                    //           //   style: TextStyle(
                                    //           //       fontSize: 14,
                                    //           //       color: Colors.white),
                                    //           // ),
                                    //           if (snapshot.data![index]
                                    //                   ['isInviteOnly'] ==
                                    //               true) ...[
                                    //             Chip(
                                    //               label: Text('Invite Only'),
                                    //               backgroundColor: Colors.grey[300]!
                                    //                   .withOpacity(.5),
                                    //               elevation: 0,
                                    //               shadowColor: Colors.transparent,
                                    //             ),
                                    //           ],
                                    //           Row(
                                    //             mainAxisAlignment:
                                    //                 MainAxisAlignment.spaceBetween,
                                    //             children: [
                                    //               theatre.scheduleOn != null
                                    //                   ? Text(
                                    //                       DateFormat.yMMMd()
                                    //                           .add_jm()
                                    //                           .format(DateTime
                                    //                                   .parse(theatre
                                    //                                       .scheduleOn
                                    //                                       .toString())
                                    //                               .toLocal()),
                                    //                       style: TextStyle(
                                    //                           fontSize: 14,
                                    //                           color: Colors.white),
                                    //                     )
                                    //                   : SizedBox.shrink(),
                                    //               Spacer(),
                                    //               GestureDetector(
                                    //                 onTap: () async {
                                    //                   Add2Calendar.addEvent2Cal(
                                    //                       buildEvent(snapshot
                                    //                           .data![index]
                                    //                               ['scheduledOn']
                                    //                           .toDate()));
                                    //                 },
                                    //                 child: Icon(
                                    //                   Icons.calendar_today,
                                    //                   color: Colors.white,
                                    //                   size: 25,
                                    //                 ),
                                    //               ),
                                    //               SizedBox(
                                    //                 width: 10,
                                    //               ),
                                    //               GestureDetector(
                                    //                 onTap: () async {
                                    //                   // Opacity will become zero
                                    //                   // if (!isInviteOnly) return;
                                    //                   print(snapshot.data![index]["theatreId"]);
                                    //                   Share.share(
                                    //                       await DynamicLinksApi
                                    //                           .inviteOnlyTheatreLink(
                                    //                     snapshot.data![index]
                                    //                         ["theatreId"],
                                    //                     snapshot.data![index]
                                    //                         ["createdBy"],
                                    //                     roomName: snapshot
                                    //                         .data![index]["title"],
                                    //                     imageUrl: snapshot
                                    //                         .data![index]["image"],
                                    //                   ));
                                    //                 },
                                    //                 child: Icon(
                                    //                   Icons.share_rounded,
                                    //                   color: Colors.white,
                                    //                 ),
                                    //               ),
                                    //               SizedBox(
                                    //                 width: 10,
                                    //               ),
                                    //               auth.user?.id == theatre.createdBy
                                    //                   ? IconButton(
                                    //                       onPressed: () async {
                                    //                         // _roomService.updateIsActive(room);
                                    //                         QuerySnapshot _myDoc =
                                    //                             await FirebaseFirestore
                                    //                                 .instance
                                    //                                 .collection(
                                    //                                     "rooms")
                                    //                                 .doc(theatre
                                    //                                     .createdBy)
                                    //                                 .collection(
                                    //                                     "amphitheatre")
                                    //                                 .doc(theatre
                                    //                                     .theatreId)
                                    //                                 .collection(
                                    //                                     "users")
                                    //                                 .where(
                                    //                                     "isActiveInRoom",
                                    //                                     isEqualTo:
                                    //                                         true)
                                    //                                 .get();
                                    //                         List<DocumentSnapshot>
                                    //                             _myDocCount =
                                    //                             _myDoc.docs;
                                    //
                                    //                         await roomCollection
                                    //                             .doc(theatre
                                    //                                 .createdBy)
                                    //                             .collection(
                                    //                                 "amphitheatre")
                                    //                             .doc(theatre
                                    //                                 .theatreId)
                                    //                             .update({
                                    //                           "isActive": false
                                    //                         });
                                    //                         await FirebaseFirestore
                                    //                             .instance
                                    //                             .collection("feeds")
                                    //                             .doc(theatre
                                    //                                 .theatreId)
                                    //                             .delete()
                                    //                             .then((value) {
                                    //                           setState(() {
                                    //                             active = false;
                                    //                           });
                                    //                         });
                                    //                         setState(() {
                                    //                           active = false;
                                    //                         });
                                    //                       },
                                    //                       icon: Icon(
                                    //                         Icons
                                    //                             .delete_outline_outlined,
                                    //                         color: Colors.white,
                                    //                         size: 30,
                                    //                       ))
                                    //                   : SizedBox.shrink(),
                                    //             ],
                                    //           )
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ),
                                    // )
                                    ;
                                  },
                                ),
                            ],
                          )
                          : SizedBox.shrink();
                    }),

// //               // ...getEventsForDay(selectedDay).map(
// //               //   (Event event) => Card(
// //               //     child: ListTile(
// //               //       dense: true,
// //               //       isThreeLine: true,
// //               //       contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
// //               //       leading: ClipRRect(
// //               //         borderRadius: BorderRadius.circular(8.0),
// //               //         child: Image(
// //               //           image: NetworkImage(
// //               //             '${todayInfoList[0]['imageLink']}',
// //               //           ),
// //               //         ),
// //               //       ),
// //               //       title: Text(event.title),
// //               //       subtitle: Text('Two lined'),
// //               //     ),
// //               //   ),
// //               // ),
// //             ],
// //           ),
//
//               ),
//               SizedBox(height: 50,)
              ),

              SizedBox(height: 200,)
            ],
          ),
        ),
      ),
    );
  }
}
