import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/core/functions.dart';
import 'package:fostr/pages/user/SearchBookBits.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/BookClubServices.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/services/StorageService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../widgets/AppLoading.dart';

class EnterBookClubRoomDetails extends StatefulWidget {
  final String clubID;
  const EnterBookClubRoomDetails({Key? key, required this.clubID})
      : super(key: key);

  @override
  _EnterBookClubRoomDetailsState createState() =>
      _EnterBookClubRoomDetailsState();
}

class _EnterBookClubRoomDetailsState extends State<EnterBookClubRoomDetails>
    with FostrTheme, TickerProviderStateMixin {
  DateTime now = DateTime.now().toUtc();
  final TextEditingController dateTimeController = TextEditingController(
      text: DateTime.now().add(Duration(minutes: 90)).toString());

  DateTime _dateTime = DateTime.now();
  Timestamp time = Timestamp.now();
  bool _switchValueHumanLibrary = false;
  bool _switchValueScheduleRoom = false;
  bool _switchValueMembersRoom = false;
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
      TextEditingController();
  TextEditingController withTextEditingController = TextEditingController();
  TextEditingController addAuthorTextEditingController =
      TextEditingController();
  TextEditingController summaryTextEditingController = TextEditingController();
  TextEditingController searchBookController = TextEditingController();
  // TextEditingController dateTextEditingController = new TextEditingController();
  // TextEditingController timeTextEditingController = new TextEditingController();
  TextEditingController agendaTextEditingController =
      new TextEditingController();
  TextEditingController passController = TextEditingController();
  String image = "Add a Image (378x 224)", imageUrl = "";
  bool isLoading = false,
      scheduling = false,
      isUploaded = false,
      isUploadedAd = false;

  late TabController _tabController =
      TabController(vsync: this, length: 1, initialIndex: 0);

  List<bool> isOpen = [false];

  String imageUrl2 = "";

  TextEditingController adTitle = TextEditingController();
  TextEditingController adDescription = TextEditingController();
  TextEditingController redirectLink = TextEditingController();

  final BookClubServices bookClubServices = GetIt.I<BookClubServices>();

  var roomToken;
  var bearerToken;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final user = auth.user!;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: theme.colorScheme.primary,
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
                        )),
                    Expanded(child: Container()),
                    Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    )
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                indicatorPadding: EdgeInsets.all(0),
                tabs: [
                  //room
                  Container(
                    height: 45,
                    width: double.infinity,
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(0),
                    child: ElevatedButton.icon(
                      onPressed: () => {
                        setState(() => {_tabController.animateTo(0)})
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.0),
                          )),
                          backgroundColor: _tabController.index == 0
                              ? MaterialStateProperty.all(Colors.white)
                              : MaterialStateProperty.all(Colors.black),
                          foregroundColor: _tabController.index == 0
                              ? MaterialStateProperty.all(Colors.black)
                              : MaterialStateProperty.all(Colors.white)),
                      icon: Icon(Icons.mic),
                      label: Text("Book Club Room"),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    //room
                    SingleChildScrollView(
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
                                          Text(
                                            "Human library",
                                          ),
                                          SizedBox(width: 10),
                                          Switch(
                                            onChanged: (value) {
                                              setState(() {
                                                _switchValueHumanLibrary =
                                                    value;
                                              });
                                            },
                                            value: _switchValueHumanLibrary,
                                            activeColor:
                                                theme.colorScheme.secondary,
                                            inactiveTrackColor:
                                                Colors.grey[300],
                                          ),
                                        ],
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Schedule Later",
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Switch(
                                            onChanged: (value) {
                                              setState(() {
                                                _switchValueScheduleRoom =
                                                    value;
                                              });
                                            },
                                            value: _switchValueScheduleRoom,
                                            activeColor:
                                                theme.colorScheme.secondary,
                                            inactiveTrackColor:
                                                Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Members only",
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Switch(
                                            onChanged: (value) {
                                              setState(() {
                                                _switchValueMembersRoom = value;
                                              });
                                            },
                                            value: _switchValueMembersRoom,
                                            activeColor:
                                                theme.colorScheme.secondary,
                                            inactiveTrackColor:
                                                Colors.grey[300],
                                          ),
                                        ],
                                      ),

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
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 1, horizontal: 15),
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
                                            FocusScope.of(context).nextFocus(),
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
                                                              .text = result[0];
                                                          summaryTextEditingController
                                                              .text = result[1];
                                                          isUploaded = true;
                                                          imageUrl = result[2]
                                                              .toString();
                                                          addAuthorTextEditingController
                                                              .text = result[3];
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
                                                  vertical: 1, horizontal: 15),
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
                                                borderRadius: BorderRadius.all(
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
                                                            : theme.colorScheme
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
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 1, horizontal: 15),
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
                                          hintText: "Author name",
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
                                            FocusScope.of(context).nextFocus(),
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
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 1, horizontal: 15),
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
                                          hintText: "Room description",
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
                                            FocusScope.of(context).nextFocus(),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),

                                      _switchValueScheduleRoom
                                          ? Theme(
                                              data: ThemeData(
                                                  primarySwatch: MaterialColor(
                                                      theme.colorScheme
                                                          .secondary.value,
                                                      getSwatch(theme
                                                          .colorScheme
                                                          .secondary)),
                                                  brightness: theme.brightness,
                                                  primaryColor: theme
                                                      .colorScheme.secondary),
                                              child: DateTimePicker(
                                                controller: dateTimeController,
                                                type:
                                                    DateTimePickerType.dateTime,
                                                dateMask: 'd MMM, yyyy HH:mm',
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now()
                                                    .add(Duration(days: 6)),
                                                icon: Icon(
                                                  Icons.event,
                                                ),
                                                dateLabelText: 'Date and time',
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
                                      // SizedBox(
                                      //   height: 20,
                                      // ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          isLoading
                                              ? AppLoading(
                                                  height: 70,
                                                  width: 70,
                                                )
                                              // CircularProgressIndicator(
                                              //   color: GlobalColors.signUpSignInButton,
                                              // )
                                              : Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (eventNameTextEditingController
                                                          .text.isNotEmpty) {
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
                                                                maxHeight: 150,
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
                                                                imageUrl = await Storage.saveRoomImage(
                                                                    {
                                                                      "file":
                                                                          croppedFile,
                                                                      "ext": file[
                                                                          "ext"]
                                                                    },
                                                                    basename(croppedFile
                                                                            .path)
                                                                        .substring(
                                                                            14));
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
                                                              isLoading = false;
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
                                                            //     fontSize: 16.0);
                                                          }
                                                        } catch (e) {
                                                          print(e);
                                                          setState(() {
                                                            isLoading = false;
                                                            isUploaded = false;
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
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.18,
                                                      child: isUploaded == false
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
                                                              child: FosterImage(
                                                                  imageUrl:
                                                                      imageUrl),
                                                            ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white12,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                        border: Border.all(
                                                            color: Colors.black,
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.theater_comedy,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Genre",
                                            ),
                                          ),
                                          DropdownButton<String>(
                                            style: TextStyle(fontSize: 13),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                            value: value1,
                                            dropdownColor:
                                                theme.colorScheme.primary,
                                            items: genres.map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: theme.colorScheme
                                                        .inversePrimary,
                                                  ),
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                scheduling
                                    ? AppLoading(
                                        height: 70,
                                        width: 70,
                                      )
                                    // CircularProgressIndicator(color:GlobalColors.signUpSignInButton)
                                    : _switchValueScheduleRoom
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

                                                    final cUser = FirebaseAuth
                                                        .instance.currentUser;
                                                    if (cUser!.uid.isNotEmpty) {
                                                      final token = await cUser
                                                          .getIdToken();

                                                      String eventName =
                                                          eventNameTextEditingController
                                                              .text;
                                                      if (eventNameTextEditingController
                                                          .text.isEmpty) {
                                                        eventName =
                                                            searchBookController
                                                                .text;
                                                      }

                                                      await bookClubServices
                                                          .createBookCLubRoomLater(
                                                        widget.clubID,
                                                        user.id,
                                                        value1,
                                                        _switchValueHumanLibrary,
                                                        eventName,
                                                        imageUrl,
                                                        addAuthorTextEditingController
                                                                .text.isEmpty
                                                            ? user.name
                                                            : addAuthorTextEditingController
                                                                .text,
                                                        token,
                                                        summaryTextEditingController
                                                            .text,
                                                        _switchValueMembersRoom,
                                                      );
                                                      Navigator.pop(context);
                                                    }
                                                  }
                                                },
                                                style: ButtonStyle(
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsets>(
                                                          EdgeInsets.symmetric(
                                                              horizontal: 30,
                                                              vertical: 15)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Color(0xff2A9D8F)),
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
                                                print("inside button");
                                                setState(() {
                                                  scheduling = true;
                                                });
                                                final cUser = FirebaseAuth
                                                    .instance.currentUser;

                                                final token =
                                                    await cUser!.getIdToken();
                                                String eventName =
                                                    eventNameTextEditingController
                                                        .text;
                                                if (eventNameTextEditingController
                                                    .text.isEmpty) {
                                                  eventName =
                                                      searchBookController.text;
                                                }
                                                await bookClubServices
                                                    .createBookCLubRoomNow(
                                                  summaryTextEditingController
                                                      .text,
                                                  widget.clubID,
                                                  user.id,
                                                  value1,
                                                  _switchValueHumanLibrary,
                                                  eventName,
                                                  imageUrl,
                                                  addAuthorTextEditingController
                                                          .text.isEmpty
                                                      ? user.name
                                                      : addAuthorTextEditingController
                                                          .text,
                                                  token,
                                                  _switchValueMembersRoom,
                                                );
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text("Create",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )),
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
                                              shape: MaterialStateProperty.all<
                                                  OutlinedBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                              ),
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
