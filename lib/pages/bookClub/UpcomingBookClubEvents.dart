import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/models/UserModel/User.dart' as nUser;
import 'package:fostr/pages/rooms/RoomInfo.dart';
import 'package:fostr/pages/rooms/TheatreInfo.dart';
import 'package:fostr/providers/AuthProvider.dart';
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

class UpcomingBookClubEvents extends StatefulWidget {
  final BookClubModel bookClubModel;
  const UpcomingBookClubEvents({Key? key, required this.bookClubModel})
      : super(key: key);

  @override
  State<UpcomingBookClubEvents> createState() => _UpcomingBookClubEventsState();
}

class _UpcomingBookClubEventsState extends State<UpcomingBookClubEvents> {
  UserService userServices = GetIt.I<UserService>();

  void updateProfile(Map<String, dynamic> data) async {
    await userServices.updateUserField(data);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
    });
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

  Event buildEvent(DateTime dateTime) {
    return Event(
      title: 'Room Event',
      description: '',
      location: 'Foster Reads',
      startDate: dateTime,
      endDate: dateTime.add(Duration(minutes: 90)),
      iosParams: IOSParams(),
      androidParams: AndroidParams(),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getEventsForDay(String id) async {
    return FirebaseFirestore.instance
        .collection("rooms")
        .doc(id)
        .collection("rooms")
        .where("isUpcoming", isEqualTo: true)
        .where("isActive", isEqualTo: true)
        .where("bookClubId", isEqualTo: widget.bookClubModel.id)
        .get();
  }

  final DateTime focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Material(
      color: theme.colorScheme.primary,
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          shrinkWrap: true,
          children: [
            FutureBuilder(
              future: getEventsForDay(auth.user!.id),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text("error");
                }

                if (!snapshot.hasData) {
                  return const Text("No events found");
                }

                print(snapshot.data);

                final data = snapshot.data?.docs.map((e) => e.data()).toList();

                if (data == null) {
                  return const Text("No events found");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    bool active = data[index]["isActive"];
                    return active
                        ? Container(
                          constraints: BoxConstraints(minHeight: 200),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: data[index]["image"] == ''
                                        ? Image.asset(IMAGES + "logo_white.png")
                                            .image
                                        : NetworkImage(data[index]['image'])),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    gradientBottom,
                                    gradientTop,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12)),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          data[index]['title'],
                                          overflow: TextOverflow.fade,
                                          maxLines: 2,
                                          softWrap: false,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
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
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                        child: Text(data[index]['genre'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  //author
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "by " + data[index]['roomCreator'],
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
                                                    data: data[index],
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

                                  if (data[index]['followersOnly'] == true ||
                                      data[index]['inviteOnly'] == true) ...[
                                    Chip(
                                      label: Text(
                                          data[index]['inviteOnly'] == true
                                              ? 'Invite Only'
                                              : 'Followers Only'),
                                      backgroundColor:
                                          Colors.grey[300]!.withOpacity(.5),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                  ],

                                  //datetime
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat.yMMMd().add_jm().format(
                                            data[index]['dateTime']
                                                .toDate()
                                                .toLocal()),
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      Expanded(child: Container()),
                                      GestureDetector(
                                        onTap: () async {
                                          Add2Calendar.addEvent2Cal(buildEvent(
                                              data[index]['dateTime']
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
                                          Share.share(await DynamicLinksApi
                                              .inviteOnlyRoomLink(
                                            data[index]["roomID"],
                                            data[index]["id"],
                                            roomName: data[index]["title"],
                                            imageUrl: data[index]["image"],
                                          ));
                                        },
                                        child: Icon(
                                          Icons.share_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      data[index]['id'] == auth.user!.id
                                          ? GestureDetector(
                                              onTap: () async {
                                                // _roomService
                                                //     .updateIsActive(data[index]);
                                                await roomCollection
                                                    .doc(data[index]['id'])
                                                    .collection("rooms")
                                                    .doc(data[index]['roomID'])
                                                    .update(
                                                        {'isActive': false});
                                                await FirebaseFirestore.instance
                                                    .collection("feeds")
                                                    .doc(data[index]['roomID'])
                                                    .delete();
                                                setState(() {
                                                  active = false;
                                                });
                                              },
                                              child: Icon(
                                                Icons.delete_outline_outlined,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
