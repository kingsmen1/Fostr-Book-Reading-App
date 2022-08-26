import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/CalendarPage.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/pages/user/SearchBookBits.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/FeedProvider.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/StorageService.dart';
import 'package:fostr/theatre/EnterTheatreDetails.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../widgets/AppLoading.dart';

class EnterRoomDetails extends StatefulWidget {
  final String? type;
  final String? bookname;
  final String? authorname;
  final String? description;
  final String? image;
  const EnterRoomDetails({
    Key? key,
    this.type,
    this.bookname = "",
    this.authorname = "",
    this.description = "",
    this.image = "",
  }) : super(key: key);

  @override
  _EnterRoomDetailsState createState() => _EnterRoomDetailsState();
}

class _EnterRoomDetailsState extends State<EnterRoomDetails>
    with FostrTheme, TickerProviderStateMixin {
  // String now = DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now().toUtc());
  DateTime now = DateTime.now().toUtc();

  final TextEditingController dateTimeController = TextEditingController(
      text: DateTime.now().add(Duration(minutes: 90)).toString());

  DateTime _dateTime = DateTime.now().add(Duration(minutes: 90));
  Timestamp time = Timestamp.now();
  bool _switchValueScheduleRoom = false;
  int invite = 0;
  bool isInviteOnly = false;
  bool followersOnly = false;
  bool addEvent = false;
  bool isError = false;
  String error = "";

  static const List<String> genres = [
    "Action and Adventure",
    "Biography",
    "Comic Book",
    "Detective and Mystery",
    "Fantasy",
    "Fiction",
    "History",
    "Horror",
    "Romance",
    "Sci-fi",
    "Self help",
    "Suspense",
    "Others"
  ];

  String value1 = genres[0];
  String value2 = genres[1];

  TextEditingController eventNameTextEditingController =
      new TextEditingController();
  TextEditingController searchBookController = new TextEditingController();
  TextEditingController withTextEditingController = new TextEditingController();
  TextEditingController addAuthorTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController =
      new TextEditingController();

  // TextEditingController dateTextEditingController = new TextEditingController();
  // TextEditingController timeTextEditingController = new TextEditingController();
  TextEditingController agendaTextEditingController =
      new TextEditingController();
  TextEditingController summaryTextEditingController =
      new TextEditingController();
  TextEditingController passController = new TextEditingController();
  String image = "Add a Image (378x 224)", imageUrl = "";
  bool isLoading = false,
      scheduling = false,
      isUploaded = false,
      isUploadedAd = false;

  late TabController _tabController =
      new TabController(vsync: this, length: 2, initialIndex: 0);

  List<bool> isOpen = [false];

  String imageUrl2 = "";

  TextEditingController adTitle = new TextEditingController();
  TextEditingController adDescription = new TextEditingController();
  TextEditingController redirectLink = new TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      if(widget.image!.isNotEmpty){
        imageUrl = widget.image!;
        isUploaded = true;
      }
      if(widget.bookname!.isNotEmpty){
        searchBookController.text = widget.bookname!;
      }
      if(widget.authorname!.isNotEmpty){
        addAuthorTextEditingController.text = widget.authorname!;
      }
      if(widget.description!.isNotEmpty){
        summaryTextEditingController.text = widget.description!;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: theme.colorScheme.primary,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                dark_blue,
                theme.colorScheme.primary
                //Color(0xFF2E3170)
              ],
              begin : Alignment.topCenter,
              end : Alignment(0,-0.8),
              // stops: [0,1]
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06) +
                  EdgeInsets.only(top: 30),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                          ),
                        ),
                        Expanded(child: Container()),
                        Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          width: 40,
                          height: 40,
                        )
                      ],
                    ),
                  ),
                  // TabBar(
                  //   controller: _tabController,
                  //   indicatorColor: Colors.transparent,
                  //   indicatorPadding: EdgeInsets.all(0),
                  //   tabs: [
                  //     //room
                  //     Container(
                  //       height: 45,
                  //       width: double.infinity,
                  //       margin: EdgeInsets.all(0),
                  //       padding: EdgeInsets.all(0),
                  //       child: ElevatedButton.icon(
                  //         onPressed: () => {
                  //           setState(() => {_tabController.animateTo(0)})
                  //         },
                  //         style: ButtonStyle(
                  //             shape: MaterialStateProperty.all<
                  //                 RoundedRectangleBorder>(RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(11.0),
                  //             )),
                  //             backgroundColor: _tabController.index == 0
                  //                 ? MaterialStateProperty.all(Colors.white)
                  //                 : MaterialStateProperty.all(Colors.grey),
                  //             foregroundColor: _tabController.index == 0
                  //                 ? MaterialStateProperty.all(Colors.black)
                  //                 : MaterialStateProperty.all(Colors.white)),
                  //         icon: Icon(Icons.mic),
                  //         label: Text(
                  //           "Room",
                  //           style: TextStyle(fontSize: 20),
                  //         ),
                  //       ),
                  //     ),
                  //
                  //     //theatre
                  //     Container(
                  //       height: 45,
                  //       width: double.infinity,
                  //       margin: EdgeInsets.all(0),
                  //       padding: EdgeInsets.all(0),
                  //       child: ElevatedButton.icon(
                  //         onPressed: () => {
                  //           setState(() => {_tabController.animateTo(1)})
                  //         },
                  //         style: ButtonStyle(
                  //             shape: MaterialStateProperty.all<
                  //                 RoundedRectangleBorder>(RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(11.0),
                  //             )),
                  //             backgroundColor: _tabController.index == 1
                  //                 ? MaterialStateProperty.all(Colors.white)
                  //                 : MaterialStateProperty.all(Colors.grey),
                  //             foregroundColor: _tabController.index == 1
                  //                 ? MaterialStateProperty.all(Colors.black)
                  //                 : MaterialStateProperty.all(Colors.white)),
                  //         icon: Icon(Icons.theaters),
                  //         label: Text(
                  //           "Theatre",
                  //           style: TextStyle(fontSize: 20),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  ///room theatre toggle
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Room",
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontFamily: "drawerhead"
                  //       ),
                  //     ),
                  //     Switch(
                  //       onChanged: (value) {
                  //         setState(() {
                  //           if(value){
                  //             _tabController.index = 1;
                  //           } else {
                  //             _tabController.index = 0;
                  //           }
                  //         });
                  //       },
                  //       value: _tabController.index == 1 ? true : false,
                  //       activeColor: theme.colorScheme.secondary,
                  //       activeTrackColor: Colors.grey,
                  //       inactiveThumbColor: theme.colorScheme.secondary,
                  //       inactiveTrackColor: Colors.grey,
                  //     ),
                  //     Text(
                  //       "Theatre",
                  //       style: TextStyle(
                  //           fontSize: 20,
                  //           fontFamily: "drawerhead"
                  //       ),
                  //     ),
                  //
                  //   ],
                  // ),

                  Container(
                    height: 50,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: theme.colorScheme.secondary,
                      labelStyle: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 16,
                          fontFamily: "drawerbody"),
                      tabs: [
                        Tab(
                          child: Text(
                            "Room",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: "drawerhead"
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Theatre",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: "drawerhead"
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      // physics: NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: <Widget>[

                        //room
                        SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                alignment: Alignment.topCenter,
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Schedule Later",
                                                    style: TextStyle(),
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                  Text(
                                                    "Invite Only",
                                                    style: TextStyle(
                                                        color: invite == 2
                                                            ? Colors.grey
                                                            : theme.colorScheme
                                                                .inversePrimary),
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                  Text(
                                                    "Followers Only",
                                                    style: TextStyle(
                                                        color: invite == 1
                                                            ? Colors.grey
                                                            : theme.colorScheme
                                                                .inversePrimary),
                                                  ),
                                                  _switchValueScheduleRoom
                                                      ? SizedBox(
                                                          height: 30,
                                                        )
                                                      : SizedBox.shrink(),
                                                  _switchValueScheduleRoom
                                                      ? Text(
                                                          "Add Event to Phone Calender",
                                                        )
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                              Spacer(),
                                              Column(
                                                children: [
                                                  Switch(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _switchValueScheduleRoom =
                                                            value;
                                                      });
                                                    },
                                                    value:
                                                        _switchValueScheduleRoom,
                                                    activeColor: theme
                                                        .colorScheme.secondary,
                                                    inactiveTrackColor:
                                                        Colors.grey,
                                                  ),

                                                  //invite only
                                                  Switch(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        isInviteOnly = value;
                                                        if (value) {
                                                          followersOnly = false;
                                                          invite = 1;
                                                        }
                                                      });
                                                    },
                                                    value: isInviteOnly,
                                                    activeColor: theme
                                                        .colorScheme.secondary,
                                                    inactiveTrackColor:
                                                        Colors.grey,
                                                  ),

                                                  //only followers
                                                  Switch(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        followersOnly = value;
                                                        if (value) {
                                                          invite = 2;
                                                          isInviteOnly = false;
                                                        }
                                                      });
                                                    },
                                                    value: followersOnly,
                                                    activeColor: theme
                                                        .colorScheme.secondary,
                                                    inactiveTrackColor:
                                                        Colors.grey,
                                                  ),

                                                  //add to calender
                                                  _switchValueScheduleRoom
                                                      ? Switch(
                                                          onChanged: (value) {
                                                            setState(() {
                                                              addEvent = value;
                                                              emailTextEditingController
                                                                  .text = "";
                                                            });
                                                          },
                                                          value: addEvent,
                                                          activeColor: theme
                                                              .colorScheme
                                                              .secondary,
                                                          inactiveTrackColor:
                                                              Colors.grey,
                                                        )
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                              Container(),
                                            ],
                                          ),

                                          // room title
                                          TextField(
                                            onChanged: (e) {
                                              setState(() {
                                                searchBookController.text = "";
                                              });
                                            },
                                            controller:
                                                eventNameTextEditingController,
                                            style: h2.copyWith(
                                                color: theme
                                                    .colorScheme.inversePrimary),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 1,
                                                      horizontal: 15),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(15.0),
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: theme
                                                  .inputDecorationTheme.fillColor,
                                              hintStyle: new TextStyle(
                                                  color: Colors.grey[600]),
                                              hintText: "Event Name/Book name",
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: theme
                                                        .colorScheme.secondary),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            textInputAction: TextInputAction.next,
                                            onEditingComplete: () =>
                                                FocusScope.of(context)
                                                    .nextFocus(),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                              child: Text(
                                            "OR",
                                          )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                showModalBottomSheet(
                                                    isScrollControlled: false,
                                                    elevation: 2,
                                                    context: context,
                                                    builder: (context) {
                                                      return SearchBookBits(
                                                        onBookSelect: (result) {
                                                          if (result != null) {
                                                            setState(() {
                                                              eventNameTextEditingController
                                                                  .text = "";
                                                              searchBookController
                                                                      .text =
                                                                  result[0];
                                                              summaryTextEditingController
                                                                      .text =
                                                                  result[1];
                                                              isUploaded = true;
                                                              imageUrl = result[2]
                                                                  .toString();
                                                              addAuthorTextEditingController
                                                                      .text =
                                                                  result[3];
                                                            });
                                                          }
                                                        },
                                                      );
                                                    });

                                                // final result =
                                                //     await Navigator.of(context)
                                                //         .push(
                                                //   CupertinoPageRoute(
                                                //     builder: (context) {
                                                //       return SearchBookBits(
                                                //           onBookSelect: (e) {});
                                                //     },
                                                //   ),
                                                // );

                                                // if (result != null) {
                                                //   setState(() {
                                                //     eventNameTextEditingController
                                                //         .text = "";
                                                //     searchBookController.text =
                                                //         result[0];
                                                //     summaryTextEditingController
                                                //         .text = result[1];
                                                //     isUploaded = true;
                                                //     imageUrl =
                                                //         result[2].toString();
                                                //     addAuthorTextEditingController
                                                //         .text = result[3];
                                                //   });
                                                // }
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 1,
                                                      horizontal: 15),
                                                  height: 50,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      1,
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .inputDecorationTheme
                                                        .fillColor,
                                                    border: Border.all(
                                                        color: Colors.black38),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(15)),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        (searchBookController
                                                                .text.isEmpty)
                                                            ? "Search for book"
                                                            : searchBookController
                                                                .text,
                                                        style: TextStyle(
                                                            color: (searchBookController
                                                                    .text.isEmpty)
                                                                ? Colors.grey[600]
                                                                : theme
                                                                    .colorScheme
                                                                    .inversePrimary,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ))),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          // TextField(
                                          //   controller: withTextEditingController,
                                          //   style: h2,
                                          //   decoration: InputDecoration(
                                          //     contentPadding: EdgeInsets.symmetric(
                                          //         vertical: 1, horizontal: 15),
                                          //     border: OutlineInputBorder(
                                          //       borderRadius: const BorderRadius.all(
                                          //         Radius.circular(15.0),
                                          //       ),
                                          //     ),
                                          //     filled: true,
                                          //     hintStyle:
                                          //         new TextStyle(color: Colors.grey[600]),
                                          //     hintText: "Book Name",
                                          //     fillColor: Colors.white,
                                          //     enabledBorder: OutlineInputBorder(
                                          //       borderRadius:
                                          //           BorderRadius.all(Radius.circular(15)),
                                          //       borderSide: BorderSide(
                                          //           width: 0.5, color: Colors.grey),
                                          //     ),
                                          //   ),
                                          //   textInputAction: TextInputAction.next,
                                          //   onEditingComplete: () =>
                                          //       FocusScope.of(context).nextFocus(),
                                          // ),
                                          // SizedBox(
                                          //   height: 20,
                                          // ),
                                          TextField(
                                            controller:
                                                addAuthorTextEditingController,
                                            style: h2.copyWith(
                                                color: theme
                                                    .colorScheme.inversePrimary),
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: theme
                                                        .colorScheme.secondary),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 1,
                                                      horizontal: 15),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(15.0),
                                                ),
                                              ),
                                              filled: true,
                                              hintStyle: new TextStyle(
                                                  color: Colors.grey[600]),
                                              hintText: "Author name",
                                              fillColor: Colors.white12,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            textInputAction: TextInputAction.next,
                                            onEditingComplete: () =>
                                                FocusScope.of(context)
                                                    .nextFocus(),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),

                                          //summary
                                          TextField(
                                            controller:
                                                summaryTextEditingController,
                                            style: h2.copyWith(
                                                color: theme
                                                    .colorScheme.inversePrimary),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 1,
                                                      horizontal: 15),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(15.0),
                                                ),
                                              ),
                                              filled: true,
                                              hintStyle: new TextStyle(
                                                  color: Colors.grey[600]),
                                              hintText: "Room summary",
                                              fillColor: Colors.white12,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            textInputAction: TextInputAction.next,
                                            onEditingComplete: () =>
                                                FocusScope.of(context)
                                                    .nextFocus(),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),

                                          //email
                                          // addEvent ? TextFormField(
                                          //   controller:
                                          //   emailTextEditingController,
                                          //   style: h2,
                                          //   validator: (value) {
                                          //     if (isError && error != "Wrong password") {
                                          //       isError = false;
                                          //       return error;
                                          //     }
                                          //     if (value!.isEmpty) {
                                          //       return "enter your email";
                                          //     }
                                          //     if (!Validator.isEmail(value)) {
                                          //       return "invalid email";
                                          //     }
                                          //     return null;
                                          //   },
                                          //   decoration: InputDecoration(
                                          //     contentPadding:
                                          //     EdgeInsets.symmetric(
                                          //         vertical: 1,
                                          //         horizontal: 15),
                                          //     border: OutlineInputBorder(
                                          //       borderRadius:
                                          //       const BorderRadius.all(
                                          //         Radius.circular(15.0),
                                          //       ),
                                          //     ),
                                          //     filled: true,
                                          //     hintStyle: new TextStyle(
                                          //         color: Colors.grey[600]),
                                          //     hintText: "Email for adding event",
                                          //     fillColor: Colors.white12,
                                          //     enabledBorder: OutlineInputBorder(
                                          //       borderRadius: BorderRadius.all(
                                          //           Radius.circular(15)),
                                          //       borderSide: BorderSide(
                                          //           width: 0.5,
                                          //           color: Colors.black),
                                          //     ),
                                          //   ),
                                          //   textInputAction: TextInputAction.next,
                                          //   onEditingComplete: () =>
                                          //       FocusScope.of(context)
                                          //           .nextFocus(),
                                          // ) : SizedBox.shrink(),
                                          // addEvent ? SizedBox(
                                          //   height: 20,
                                          // ) : SizedBox.shrink(),
                                          _switchValueScheduleRoom
                                              ? Theme(
                                                  data: ThemeData(
                                                      primarySwatch:
                                                          MaterialColor(
                                                              theme
                                                                  .colorScheme
                                                                  .secondary
                                                                  .value,
                                                              getSwatch(theme
                                                                  .colorScheme
                                                                  .secondary)),
                                                      brightness:
                                                          theme.brightness,
                                                      primaryColor: theme
                                                          .colorScheme.secondary),
                                                  child: DateTimePicker(
                                                    // controller:
                                                    //     dateTimeController,
                                                    type: DateTimePickerType
                                                        .dateTime,
                                                    dateMask: 'd MMM, yyyy HH:mm',
                                                    initialValue: DateTime.now()
                                                        .add(Duration(minutes: 90))
                                                        .toString(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.now()
                                                        .add(Duration(days: 6)),
                                                    icon: Icon(
                                                      Icons.event,
                                                    ),
                                                    dateLabelText:
                                                        'Date and time',
                                                    timeLabelText: "Hour",
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _dateTime =
                                                            DateTime.parse(val);
                                                      });
                                                    },
                                                    validator: (val) {
                                                      final DateTime dateTime =
                                                          DateTime.parse(val!);
                                                      if (dateTime.compareTo(
                                                              DateTime.now()) <
                                                          0) {
                                                        return "Date and time must be in the future";
                                                      }
                                                      return null;
                                                    },
                                                    onSaved: (val) {
                                                      setState(() {
                                                        _dateTime =
                                                            DateTime.parse(val!);
                                                      });
                                                    },
                                                  ),
                                                )
                                              : SizedBox.shrink(),

                                          SizedBox(
                                            height: 20,
                                          ),

                                          //image
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              isLoading
                                                  ? AppLoading(
                                                      height: 70,
                                                      width: 70,
                                                    )
                                                  : Expanded(
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          if (eventNameTextEditingController
                                                                  .text
                                                                  .isNotEmpty ||
                                                              searchBookController
                                                                  .text
                                                                  .isNotEmpty) {
                                                            setState(() {
                                                              isLoading = true;
                                                              isUploaded = false;
                                                            });
                                                            try {
                                                              final file =
                                                                  await Files
                                                                      .getFile();

                                                              if (file['file'] !=
                                                                  null) {
                                                                try {
                                                                  final croppedFile =
                                                                      await ImageCropper()
                                                                          .cropImage(
                                                                    sourcePath:
                                                                        file['file']
                                                                            .path,
                                                                    maxHeight:
                                                                        150,
                                                                    maxWidth: 150,
                                                                    aspectRatio:
                                                                        CropAspectRatio(
                                                                            ratioX:
                                                                                1,
                                                                            ratioY:
                                                                                1),
                                                                  );

                                                                  if (croppedFile !=
                                                                      null) {
                                                                    imageUrl =
                                                                        await Storage
                                                                            .saveRoomImage({
                                                                      "file":
                                                                          croppedFile,
                                                                      "ext": file[
                                                                          "ext"]
                                                                    }, basename(croppedFile.path).substring(14));

                                                                    setState(() {
                                                                      isLoading =
                                                                          false;
                                                                      isUploaded =
                                                                          true;
                                                                      image = file[
                                                                              'file']
                                                                          .toString()
                                                                          .substring(
                                                                              file['file'].toString().lastIndexOf('/') +
                                                                                  1,
                                                                              file['file'].toString().length -
                                                                                  1);
                                                                    });
                                                                  } else {
                                                                    setState(() {
                                                                      isLoading =
                                                                          false;
                                                                      isUploaded =
                                                                          false;
                                                                    });
                                                                  }
                                                                } catch (e) {
                                                                  setState(() {
                                                                    isLoading =
                                                                        false;
                                                                    isUploaded =
                                                                        false;
                                                                  });
                                                                }
                                                              } else {
                                                                setState(() {
                                                                  isLoading =
                                                                      false;
                                                                  isUploaded =
                                                                      false;
                                                                });
                                                                ToastMessege(
                                                                    "Image must be less than 700KB",
                                                                    context:
                                                                        context);
                                                                // Fluttertoast.showToast(
                                                                //     msg:
                                                                //         "Image must be less than 700KB",
                                                                //     toastLength: Toast
                                                                //         .LENGTH_SHORT,
                                                                //     gravity:
                                                                //         ToastGravity
                                                                //             .BOTTOM,
                                                                //     timeInSecForIosWeb:
                                                                //         1,
                                                                //     backgroundColor:
                                                                //         gradientBottom,
                                                                //     textColor:
                                                                //         Colors
                                                                //             .white,
                                                                //     fontSize:
                                                                //         16.0);
                                                              }
                                                            } catch (e) {
                                                              print(e);
                                                              setState(() {
                                                                isLoading = false;
                                                                isUploaded =
                                                                    false;
                                                              });
                                                            }
                                                          } else {
                                                            ToastMessege(
                                                                "Event Name is required!",
                                                                context: context);
                                                            // Fluttertoast.showToast(
                                                            //     msg:
                                                            //         "Event Name is required!",
                                                            //     toastLength: Toast
                                                            //         .LENGTH_SHORT,
                                                            //     gravity:
                                                            //         ToastGravity
                                                            //             .BOTTOM,
                                                            //     timeInSecForIosWeb:
                                                            //         1,
                                                            //     backgroundColor:
                                                            //         gradientBottom,
                                                            //     textColor:
                                                            //         Colors.white,
                                                            //     fontSize: 16.0);
                                                          }
                                                        },
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.18,
                                                          child: isUploaded ==
                                                                  false
                                                              ? Center(
                                                                  child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .image_outlined,
                                                                      size: 83,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    Text(
                                                                      "add an image (378x224)",
                                                                    ),
                                                                  ],
                                                                ))
                                                              : Center(
                                                                  child: Image
                                                                      .network(
                                                                          imageUrl),
                                                                ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white12,
                                                            borderRadius:
                                                                BorderRadius.all(
                                                              Radius.circular(10),
                                                            ),
                                                            border: Border.all(
                                                                color:
                                                                    Colors.black,
                                                                width: 0.5),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),

                                          //genre
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Icon(
                                                Icons.theater_comedy,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Genre",
                                                ),
                                              ),
                                              DropdownButton<String>(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                dropdownColor:
                                                    theme.colorScheme.primary,
                                                value: value1,
                                                items: genres.map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: TextStyle(
                                                          color: theme.colorScheme
                                                              .inversePrimary),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (val) {
                                                  setState(() {
                                                    value1 = val!;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height *
                                          0.008,
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height *
                                          0.03,
                                    ),
                                    scheduling
                                        ? AppLoading(
                                            height: 70,
                                            width: 70,
                                          )
                                        // CircularProgressIndicator(
                                        //    color: GlobalColors.signUpSignInButton,
                                        // )
                                        :
                                        // _dateTime.isAfter(DateTime.now().add(
                                        //             Duration(minutes: 90))) &&
                                        _switchValueScheduleRoom
                                            ? //any event scheduled after 1 day will be updated into upcoming events
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                    child: Text(
                                                      'Schedule',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    onPressed: () async {
                                                      if (eventNameTextEditingController
                                                              .text.isEmpty &&
                                                          searchBookController
                                                              .text.isEmpty) {
                                                        ToastMessege(
                                                            "Event Name is required!",
                                                            context: context);
                                                        // Fluttertoast.showToast(
                                                        //     msg:
                                                        //         "Event Name is required!",
                                                        //     toastLength: Toast
                                                        //         .LENGTH_SHORT,
                                                        //     gravity: ToastGravity
                                                        //         .BOTTOM,
                                                        //     timeInSecForIosWeb: 1,
                                                        //     backgroundColor:
                                                        //         gradientBottom,
                                                        //     textColor:
                                                        //         Colors.white,
                                                        //     fontSize: 16.0);
                                                      } else {
                                                        if (DateTime.now().day < _dateTime.day &&
                                                            DateTime.now().month == _dateTime.month &&
                                                            DateTime.now().year == _dateTime.year)
                                                        // DateTime.now()
                                                        //         .compareTo(
                                                        //             _dateTime) >
                                                        //     0)
                                                        {
                                                          ToastMessege(
                                                              "Date and Time must be greater than current date!",
                                                              context: context);
                                                          return;
                                                        }
                                                        setState(() {
                                                          scheduling = true;
                                                        });
                                                        if (DateTime.now()
                                                                    .toUtc()
                                                                    .add(Duration(
                                                                        minutes:
                                                                            25))
                                                                    .minute >
                                                                _dateTime
                                                                    .toUtc()
                                                                    .minute &&
                                                            DateTime.now()
                                                                    .toUtc()
                                                                    .add(Duration(
                                                                        minutes:
                                                                            25))
                                                                    .day >
                                                                _dateTime
                                                                    .toUtc()
                                                                    .day) {
                                                          setState(() {
                                                            scheduling = false;
                                                          });
                                                          ToastMessege(
                                                              "Scheduling time must be 30 minutes ahead",
                                                              context: context);
                                                          // Fluttertoast.showToast(
                                                          //     msg:
                                                          //         "Scheduling time must be 30 minutes ahead",
                                                          //     toastLength: Toast
                                                          //         .LENGTH_SHORT,
                                                          //     gravity:
                                                          //         ToastGravity
                                                          //             .BOTTOM,
                                                          //     timeInSecForIosWeb:
                                                          //         1,
                                                          //     backgroundColor:
                                                          //         gradientBottom,
                                                          //     textColor:
                                                          //         Colors.white,
                                                          //     fontSize: 16.0);
                                                        } else {
                                                          final newUser =
                                                              await GetIt.I<
                                                                      RoomService>()
                                                                  .createRoom(
                                                            user,
                                                            (eventNameTextEditingController
                                                                    .text.isEmpty)
                                                                ? searchBookController
                                                                    .text
                                                                : eventNameTextEditingController
                                                                    .text,
                                                            agendaTextEditingController
                                                                .text,
                                                            _dateTime.toUtc(),
                                                            _switchValueScheduleRoom,
                                                            value1,
                                                            imageUrl,
                                                            passController.text,
                                                            now,
                                                            adTitle.text,
                                                            adDescription.text,
                                                            redirectLink.text,
                                                            imageUrl2,
                                                            addAuthorTextEditingController
                                                                .text,
                                                            summaryTextEditingController
                                                                .text,
                                                            isInviteOnly,
                                                            followersOnly,
                                                          );
                                                          Add2Calendar
                                                              .addEvent2Cal(
                                                            Event(
                                                              title: (eventNameTextEditingController
                                                                      .text
                                                                      .isEmpty)
                                                                  ? searchBookController
                                                                      .text
                                                                  : eventNameTextEditingController
                                                                      .text,
                                                              description: value1,
                                                              location:
                                                                  'Foster Reads',
                                                              startDate: _dateTime,
                                                              endDate: _dateTime
                                                                  .add(Duration(
                                                                      minutes:
                                                                          45)),
                                                              allDay: false,
                                                              iosParams: IOSParams(
                                                                  // reminder: Duration(minutes: 40),
                                                                  ),
                                                              androidParams:
                                                                  AndroidParams(
                                                                      // emailInvites: [""],
                                                                      ),
                                                            ),
                                                          );
                                                          auth.refreshUser(
                                                              newUser);

                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CalendarPage(
                                                                            chip: 0,
                                                                            selectDay: _dateTime,
                                                                          )
                                                                          // UserDashboard(
                                                                          //   tab:
                                                                          //       "rooms",
                                                                          //   refresh:
                                                                          //       true,
                                                                          //   home:
                                                                          //       1,
                                                                          //   selectDay:
                                                                          //       _dateTime,
                                                                          // )
                                                              ));
                                                        }
                                                      }
                                                    },
                                                    style: ButtonStyle(
                                                      padding: MaterialStateProperty
                                                          .all<EdgeInsets>(
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          30,
                                                                      vertical:
                                                                          15)),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(theme
                                                                  .colorScheme
                                                                  .secondary),
                                                      shape: MaterialStateProperty
                                                          .all<OutlinedBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : ElevatedButton(
                                                onPressed: () async {
                                                  if (eventNameTextEditingController
                                                          .text.isEmpty &&
                                                      searchBookController
                                                          .text.isEmpty) {
                                                    ToastMessege(
                                                        "Event Name is required!",
                                                        context: context);
                                                    // Fluttertoast.showToast(
                                                    //     msg:
                                                    //         "Event Name is required!",
                                                    //     toastLength:
                                                    //         Toast.LENGTH_SHORT,
                                                    //     gravity:
                                                    //         ToastGravity.BOTTOM,
                                                    //     timeInSecForIosWeb: 1,
                                                    //     backgroundColor:
                                                    //         gradientBottom,
                                                    //     textColor: Colors.white,
                                                    //     fontSize: 16.0);
                                                  } else {
                                                    setState(() {
                                                      scheduling = true;
                                                    });
                                                    // if (DateTime.now()
                                                    //             .toUtc()
                                                    //             .minute -
                                                    //         5 >
                                                    //     _dateTime
                                                    //         .toUtc()
                                                    //         .minute) {
                                                    //   setState(() {
                                                    //     scheduling = false;
                                                    //   });
                                                    //   Fluttertoast.showToast(
                                                    //       msg:
                                                    //           "invalid scheduling time",
                                                    //       toastLength:
                                                    //           Toast.LENGTH_SHORT,
                                                    //       gravity:
                                                    //           ToastGravity.BOTTOM,
                                                    //       timeInSecForIosWeb: 1,
                                                    //       backgroundColor:
                                                    //           gradientBottom,
                                                    //       textColor: Colors.white,
                                                    //       fontSize: 16.0);
                                                    // } else {
                                                    final newUser = await GetIt.I<
                                                            RoomService>()
                                                        .createRoomNow(
                                                      user,
                                                      (eventNameTextEditingController
                                                              .text.isEmpty)
                                                          ? searchBookController
                                                              .text
                                                          : eventNameTextEditingController
                                                              .text,
                                                      _switchValueScheduleRoom,
                                                      agendaTextEditingController
                                                          .text,
                                                      value1,
                                                      imageUrl,
                                                      passController.text,
                                                      DateTime.now().toUtc(),
                                                      // now,
                                                      addAuthorTextEditingController
                                                          .text,
                                                      summaryTextEditingController
                                                          .text,
                                                      adTitle.text,
                                                      adDescription.text,
                                                      redirectLink.text,
                                                      imageUrl2,
                                                      isInviteOnly,
                                                      followersOnly,
                                                    );
                                                    auth.refreshUser(newUser);
                                                    final feedsProvider =
                                                        Provider.of<FeedProvider>(
                                                            context,
                                                            listen: false);
                                                    feedsProvider
                                                        .refreshFeed(true);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                UserDashboard(
                                                                    tab: "rooms",
                                                                    refresh: true,
                                                                    currentindex: 3,
                                                                    selectDay:
                                                                        DateTime
                                                                            .now())));
                                                    // }
                                                  }
                                                },
                                                child: const Text(
                                                  "Start Now",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ButtonStyle(
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsets>(
                                                          EdgeInsets.symmetric(
                                                              horizontal: 30,
                                                              vertical: 15)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          theme.colorScheme
                                                              .secondary),
                                                  shape: MaterialStateProperty
                                                      .all<OutlinedBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                    SizedBox(
                                      height: 300,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        //theatre
                        EnterTheatreDetails(
                          bookname: widget.bookname,
                          authorname: widget.authorname,
                          description: widget.description,
                          image: widget.image,
                        )
                      ],
                    ),
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

InputDecoration inputDecoration() {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 15),
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(15.0),
      ),
    ),
    filled: true,
    hintStyle: new TextStyle(color: Colors.grey[600]),
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(width: 0.5, color: Colors.grey),
    ),
  );
}
