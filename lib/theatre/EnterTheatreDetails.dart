import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/pages/user/CalendarPage.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/services/StorageService.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fostr/pages/user/SearchBookBits.dart';

import '../widgets/AppLoading.dart';

class EnterTheatreDetails extends StatefulWidget {
  final String? bookname;
  final String? authorname;
  final String? description;
  final String? image;
  const EnterTheatreDetails({
    Key? key,
    this.bookname = "",
    this.authorname = "",
    this.description = "",
    this.image = "",
  }) : super(key: key);

  @override
  _EnterTheatreDetailsState createState() => _EnterTheatreDetailsState();
}

class _EnterTheatreDetailsState extends State<EnterTheatreDetails>
    with FostrTheme, TickerProviderStateMixin {
  DateTime now = DateTime.now().toUtc();

  TextEditingController addAuthorTextEditingController =
      TextEditingController();

  DateTime _dateTime = DateTime.now().add(Duration(minutes: 90));
  Timestamp time = Timestamp.now();
  bool _switchValueHumanLibrary = false;
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
  bool _switchValueScheduleRoom = false;
  bool isInviteOnly = false;
  int invite = 0;

  TextEditingController eventNameTextEditingController =
      TextEditingController();
  TextEditingController withTextEditingController = TextEditingController();
  TextEditingController addSummaryTextEditingController =
      TextEditingController();
  TextEditingController adLinkTextController = TextEditingController();

  // TextEditingController dateTextEditingController =   TextEditingController();
  // TextEditingController timeTextEditingController =   TextEditingController();
  TextEditingController agendaTextEditingController = TextEditingController();
  TextEditingController passController = TextEditingController();
  String image = "Add a Image (378x 224)", imageUrl = "";
  String adImage = "advertisment image", adUrl = "";
  bool isLoading = false,
      scheduling = false,
      isUploaded = false,
      isAdLoading = false,
      isUploadedAd = false;

  late TabController _tabController =
      TabController(vsync: this, length: 1, initialIndex: 0);

  List<bool> isOpen = [false];

  String imageUrl2 = "";

  TextEditingController adTitle = TextEditingController();
  TextEditingController adDescription = TextEditingController();
  TextEditingController redirectLink = TextEditingController();
  TextEditingController searchBookController = TextEditingController();

  var roomToken;
  var bearerToken;

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
        addSummaryTextEditingController.text = widget.description!;
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
    final theme = Theme.of(context);
    final user = auth.user!;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: theme.colorScheme.primary,
        child: SafeArea(
          child: Container(
            // padding: EdgeInsets.symmetric(
            //         horizontal: MediaQuery.of(context).size.width * 0.06) +
            //     EdgeInsets.only(top: 30),
            child: Column(
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 10),
                //   child: Row(
                //     children: [
                //       GestureDetector(
                //           onTap: () {
                //             Navigator.push(
                //                 context,
                //                 MaterialPageRoute(
                //                     builder: (context) => UserDashboard(
                //                         tab: "all",
                //                         selectDay: DateTime.now())));
                //           },
                //           child: Icon(
                //             Icons.arrow_back_ios,
                //           )),
                //       Expanded(child: Container()),
                //       Image.asset(
                //         'assets/images/logo.png',
                //         fit: BoxFit.cover,
                //         width: 50,
                //         height: 50,
                //       )
                //     ],
                //   ),
                // ),
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
                //                 : MaterialStateProperty.all(Colors.black),
                //             foregroundColor: _tabController.index == 0
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
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      //room
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
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
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Switch(
                                          onChanged: (value) {
                                            setState(() {
                                              _switchValueScheduleRoom = value;
                                            });
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          value: _switchValueScheduleRoom,
                                          activeColor:
                                              theme.colorScheme.secondary,
                                          inactiveTrackColor: Colors.grey,
                                        ),

                                        //invite only
                                        Switch(
                                          onChanged: (value) {
                                            setState(() {
                                              isInviteOnly = value;
                                              // if (value) {
                                              //   followersOnly = false;
                                              //   invite = 1;
                                              // }
                                            });
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          value: isInviteOnly,
                                          activeColor:
                                              theme.colorScheme.secondary,
                                          inactiveTrackColor: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    TextField(
                                      onChanged: (e) {
                                        setState(() {
                                          searchBookController.text = "";
                                        });
                                      },
                                      controller:
                                          eventNameTextEditingController,
                                      style: h2.copyWith(
                                          color:
                                              theme.colorScheme.inversePrimary),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color:
                                                  theme.colorScheme.secondary),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 15),
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(15.0),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle:
                                            TextStyle(color: Colors.grey[600]),
                                        hintText: "Event Name/Book name",
                                        fillColor: Colors.white12,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          borderSide: BorderSide(
                                              width: 0.5, color: Colors.black),
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
                                      height: 20,
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
                                              addSummaryTextEditingController
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
                                          //     await Navigator.of(context).push(
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
                                          //     addSummaryTextEditingController
                                          //         .text = result[1];
                                          //     isUploaded = true;
                                          //     imageUrl = result[2].toString();
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
                                              color: theme.inputDecorationTheme
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

                                    //author
                                    TextField(
                                      controller:
                                      addAuthorTextEditingController,
                                      style: h2.copyWith(
                                          color:
                                          theme.colorScheme.inversePrimary),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color:
                                              theme.colorScheme.secondary),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 15),
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
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
                                              width: 0.5, color: Colors.black),
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
                                          addSummaryTextEditingController,
                                      style: h2.copyWith(
                                          color:
                                              theme.colorScheme.inversePrimary),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color:
                                                  theme.colorScheme.secondary),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 15),
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(15.0),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle:
                                            TextStyle(color: Colors.grey[600]),
                                        hintText: "Summary",
                                        fillColor: Colors.white12,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          borderSide: BorderSide(
                                              width: 0.5, color: Colors.black),
                                        ),
                                      ),
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () =>
                                          FocusScope.of(context).nextFocus(),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        isLoading
                                            ? Center(
                                                child: AppLoading(
                                                height: 70,
                                                width: 70,
                                              )
                                                //       CircularProgressIndicator(
                                                //   color: GlobalColors.signUpSignInButton,
                                                // ),
                                                )
                                            : Expanded(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    if (eventNameTextEditingController
                                                            .text.isNotEmpty ||
                                                        searchBookController
                                                            .text.isNotEmpty) {
                                                      setState(() {
                                                        isLoading = true;
                                                        isUploaded = false;
                                                      });
                                                      try {
                                                        final file = await Files
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
                                                                      ratioX: 1,
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
                                                              isLoading = false;
                                                              isUploaded =
                                                                  false;
                                                            });
                                                          }
                                                        } else {
                                                          setState(() {
                                                            isLoading = false;
                                                            isUploaded = false;
                                                          });
                                                          ToastMessege(
                                                              "Image must be less than 700KB",
                                                              context: context);
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
                                                                color:
                                                                    Colors.grey,
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
                                    _switchValueScheduleRoom
                                        ? Theme(
                                            data: ThemeData(
                                                primarySwatch: MaterialColor(
                                                    theme.colorScheme.secondary
                                                        .value,
                                                    getSwatch(theme.colorScheme
                                                        .secondary)),
                                                brightness: theme.brightness,
                                                primaryColor: theme
                                                    .colorScheme.secondary),
                                            child: DateTimePicker(
                                              type: DateTimePickerType.dateTime,
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
                                              dateLabelText: 'Date and time',
                                              timeLabelText: "Hour",
                                              onChanged: (val) {
                                                print(val);
                                                setState(() {
                                                  _dateTime =
                                                      DateTime.parse(val);
                                                });
                                              },
                                              validator: (val) {
                                                print(val);
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

                                    //genre
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
                                          style: TextStyle(
                                            fontSize: 13,
                                          ),
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
                                    SizedBox(
                                      height: 20,
                                    ),

                                    ///ad image
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.center,
                                    //   children: [
                                    //     isAdLoading
                                    //         ? Center(
                                    //             child: AppLoading(
                                    //             height: 70,
                                    //             width: 70,
                                    //           )
                                    //             //       CircularProgressIndicator(
                                    //             //   color: GlobalColors.signUpSignInButton,
                                    //             // ),
                                    //             )
                                    //         : Expanded(
                                    //             child: GestureDetector(
                                    //               onTap: () async {
                                    //                 print(
                                    //                     eventNameTextEditingController
                                    //                         .text.isEmpty);
                                    //                 print(searchBookController
                                    //                     .text.isEmpty);
                                    //                 if (eventNameTextEditingController
                                    //                         .text.isNotEmpty ||
                                    //                     searchBookController
                                    //                         .text.isNotEmpty) {
                                    //                   setState(() {
                                    //                     isAdLoading = true;
                                    //                     isUploadedAd = false;
                                    //                   });
                                    //                   try {
                                    //                     final file = await Files
                                    //                         .getFile();
                                    //
                                    //                     if (file['file'] !=
                                    //                         null) {
                                    //                       try {
                                    //                         final croppedFile =
                                    //                             await ImageCropper()
                                    //                                 .cropImage(
                                    //                           sourcePath:
                                    //                               file['file']
                                    //                                   .path,
                                    //                           maxHeight: 224,
                                    //                           maxWidth: 378,
                                    //                           aspectRatioPresets: [
                                    //                             CropAspectRatioPreset
                                    //                                 .square,
                                    //                             CropAspectRatioPreset
                                    //                                 .ratio3x2,
                                    //                             CropAspectRatioPreset
                                    //                                 .original,
                                    //                             CropAspectRatioPreset
                                    //                                 .ratio4x3,
                                    //                             CropAspectRatioPreset
                                    //                                 .ratio16x9
                                    //                           ],
                                    //                         );
                                    //
                                    //                         if (croppedFile !=
                                    //                             null) {
                                    //                           adUrl = await Storage.saveRoomAdImage(
                                    //                               {
                                    //                                 "file":
                                    //                                     croppedFile,
                                    //                                 "ext": file[
                                    //                                     "ext"]
                                    //                               },
                                    //                               basename(croppedFile
                                    //                                       .path)
                                    //                                   .substring(
                                    //                                       14));
                                    //                           setState(() {
                                    //                             isAdLoading =
                                    //                                 false;
                                    //                             isUploadedAd =
                                    //                                 true;
                                    //                             adImage = file[
                                    //                                     'file']
                                    //                                 .toString()
                                    //                                 .substring(
                                    //                                     file['file'].toString().lastIndexOf('/') +
                                    //                                         1,
                                    //                                     file['file'].toString().length -
                                    //                                         1);
                                    //                           });
                                    //                         } else {
                                    //                           setState(() {
                                    //                             isAdLoading =
                                    //                                 false;
                                    //                             isUploadedAd =
                                    //                                 false;
                                    //                           });
                                    //                         }
                                    //                       } catch (e) {
                                    //                         setState(() {
                                    //                           isAdLoading =
                                    //                               false;
                                    //                           isUploadedAd =
                                    //                               false;
                                    //                         });
                                    //                       }
                                    //                     } else {
                                    //                       setState(() {
                                    //                         isAdLoading = false;
                                    //                         isUploadedAd =
                                    //                             false;
                                    //                       });
                                    //                       ToastMessege(
                                    //                           "Ad Image must be less than 700KB",
                                    //                           context: context);
                                    //                       // Fluttertoast.showToast(
                                    //                       //     msg:
                                    //                       //         "Image must be less than 700KB",
                                    //                       //     toastLength: Toast
                                    //                       //         .LENGTH_SHORT,
                                    //                       //     gravity:
                                    //                       //         ToastGravity
                                    //                       //             .BOTTOM,
                                    //                       //     timeInSecForIosWeb:
                                    //                       //         1,
                                    //                       //     backgroundColor:
                                    //                       //         gradientBottom,
                                    //                       //     textColor:
                                    //                       //         Colors
                                    //                       //             .white,
                                    //                       //     fontSize:
                                    //                       //         16.0);
                                    //                     }
                                    //                   } catch (e) {
                                    //                     print(e);
                                    //                     setState(() {
                                    //                       isAdLoading = false;
                                    //                       isUploadedAd = false;
                                    //                     });
                                    //                   }
                                    //                 } else {
                                    //                   ToastMessege(
                                    //                       "Event Name is required!",
                                    //                       context: context);
                                    //                   // Fluttertoast.showToast(
                                    //                   //     msg:
                                    //                   //         "Event Name is required!",
                                    //                   //     toastLength: Toast
                                    //                   //         .LENGTH_SHORT,
                                    //                   //     gravity:
                                    //                   //         ToastGravity
                                    //                   //             .BOTTOM,
                                    //                   //     timeInSecForIosWeb:
                                    //                   //         1,
                                    //                   //     backgroundColor:
                                    //                   //         gradientBottom,
                                    //                   //     textColor:
                                    //                   //         Colors.white,
                                    //                   //     fontSize: 16.0);
                                    //                 }
                                    //               },
                                    //               child: Container(
                                    //                 height:
                                    //                     MediaQuery.of(context)
                                    //                             .size
                                    //                             .height *
                                    //                         0.18,
                                    //                 child: isUploadedAd == false
                                    //                     ? Center(
                                    //                         child: Column(
                                    //                         mainAxisAlignment:
                                    //                             MainAxisAlignment
                                    //                                 .spaceEvenly,
                                    //                         children: [
                                    //                           Icon(
                                    //                             Icons
                                    //                                 .image_outlined,
                                    //                             size: 83,
                                    //                             color:
                                    //                                 Colors.grey,
                                    //                           ),
                                    //                           Text(
                                    //                             "advertisement image (378x224)",
                                    //                           ),
                                    //                         ],
                                    //                       ))
                                    //                     : Center(
                                    //                         child: FosterImage(
                                    //                             imageUrl:
                                    //                                 adUrl),
                                    //                       ),
                                    //                 decoration: BoxDecoration(
                                    //                   color: Colors.white12,
                                    //                   borderRadius:
                                    //                       BorderRadius.all(
                                    //                     Radius.circular(10),
                                    //                   ),
                                    //                   border: Border.all(
                                    //                       color: Colors.black,
                                    //                       width: 0.5),
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //   ],
                                    // ),
                                    // SizedBox(
                                    //   height: 20,
                                    // ),

                                    ///ad link
                                    // TextField(
                                    //   scrollPadding: EdgeInsets.only(
                                    //       bottom: MediaQuery.of(context)
                                    //               .viewInsets
                                    //               .bottom +
                                    //           20 * 4),
                                    //   controller: adLinkTextController,
                                    //   style: h2.copyWith(
                                    //       color:
                                    //           theme.colorScheme.inversePrimary),
                                    //   decoration: InputDecoration(
                                    //     focusedBorder: OutlineInputBorder(
                                    //       borderRadius: BorderRadius.all(
                                    //           Radius.circular(15)),
                                    //       borderSide: BorderSide(
                                    //           width: 1,
                                    //           color:
                                    //               theme.colorScheme.secondary),
                                    //     ),
                                    //     contentPadding: EdgeInsets.symmetric(
                                    //         vertical: 1, horizontal: 15),
                                    //     border: OutlineInputBorder(
                                    //       borderRadius: const BorderRadius.all(
                                    //         Radius.circular(15.0),
                                    //       ),
                                    //     ),
                                    //     filled: true,
                                    //     hintStyle:
                                    //         TextStyle(color: Colors.grey[600]),
                                    //     hintText:
                                    //         "Redirect Link for advertisement",
                                    //     fillColor: Colors.white12,
                                    //     enabledBorder: OutlineInputBorder(
                                    //       borderRadius: BorderRadius.all(
                                    //           Radius.circular(15)),
                                    //       borderSide: BorderSide(
                                    //           width: 0.5, color: Colors.black),
                                    //     ),
                                    //   ),
                                    //   textInputAction: TextInputAction.next,
                                    //   onEditingComplete: () =>
                                    //       FocusScope.of(context).nextFocus(),
                                    // ),
                                  ],
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
                                    ? Center(
                                        child: AppLoading(
                                        height: 70,
                                        width: 70,
                                      )
                                        // CircularProgressIndicator(color: GlobalColors.signUpSignInButton)
                                        )
                                    : _switchValueScheduleRoom
                                        ? Row(
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
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
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
                                                    setState(() {
                                                      scheduling = true;
                                                    });
                                                    if (DateTime.now()
                                                            .toUtc()
                                                            .millisecondsSinceEpoch >
                                                        _dateTime
                                                            .toUtc()
                                                            .millisecondsSinceEpoch) {
                                                      setState(() {
                                                        scheduling = false;
                                                      });
                                                      ToastMessege(
                                                          "invalid scheduling time",
                                                          context: context);
                                                      // Fluttertoast.showToast(
                                                      //     msg:
                                                      //         "invalid scheduling time",
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
                                                      final newUser = await TheatreService().createTheatreLater(
                                                          user,
                                                          (eventNameTextEditingController
                                                                  .text.isEmpty)
                                                              ? searchBookController
                                                                  .text
                                                              : eventNameTextEditingController
                                                                  .text,
                                                          _dateTime.toUtc(),
                                                          value1,
                                                          imageUrl,
                                                          addSummaryTextEditingController
                                                              .text,
                                                          adUrl,
                                                          adLinkTextController
                                                              .text,
                                                          isInviteOnly,
                                                          addAuthorTextEditingController
                                                              .text
                                                              .trim());
                                                      auth.refreshUser(newUser);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CalendarPage(
                                                                    chip: 0,
                                                                    selectDay: _dateTime,
                                                                  )
                                                                  // UserDashboard(
                                                                  //   tab:
                                                                  //       "theatres",
                                                                  //   refresh:
                                                                  //       true,
                                                                  //   home: 1,
                                                                  //   chip: 1,
                                                                  //   selectDay:
                                                                  //       _dateTime,
                                                                  // )
                                                          ));
                                                    }
                                                    print(value1);
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
                                            ],
                                          )
                                        : ElevatedButton(
                                            child: Text(
                                              'Start Now',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
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
                                                //         .toUtc()
                                                //         .millisecondsSinceEpoch >
                                                //     _dateTime
                                                //         .toUtc()
                                                //         .millisecondsSinceEpoch) {
                                                //   setState(() {
                                                //     scheduling = false;
                                                //   });
                                                //   ToastMessege(
                                                //       "invalid scheduling time");
                                                // Fluttertoast.showToast(
                                                //     msg:
                                                //         "invalid scheduling time",
                                                //     toastLength:
                                                //         Toast.LENGTH_SHORT,
                                                //     gravity:
                                                //         ToastGravity.BOTTOM,
                                                //     timeInSecForIosWeb: 1,
                                                //     backgroundColor:
                                                //         gradientBottom,
                                                //     textColor: Colors.white,
                                                //     fontSize: 16.0);
                                                // } else {
                                                final UserService _userService =
                                                    GetIt.I<UserService>();
                                                final newUser = await TheatreService().createTheatreNow(
                                                    user,
                                                    (eventNameTextEditingController
                                                            .text.isEmpty)
                                                        ? searchBookController
                                                            .text
                                                        : eventNameTextEditingController
                                                            .text,
                                                    DateTime.now().toUtc(),
                                                    value1,
                                                    imageUrl,
                                                    addSummaryTextEditingController
                                                        .text,
                                                    adUrl,
                                                    adLinkTextController.text,
                                                    isInviteOnly,
                                                    addAuthorTextEditingController
                                                        .text
                                                        .trim());
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            UserDashboard(
                                                              tab: "theatres",
                                                              currentindex: 3,
                                                              selectDay:
                                                                  DateTime
                                                                      .now(),
                                                              refresh: true,
                                                            )));
                                                auth.refreshUser(newUser);
                                                user.points = user.points + 25;
                                                // _userService.updateUserField({"id": user.id, "points": user.points});
                                                if (user.rewardcountfortheatre >
                                                    -5) {
                                                  final response = await http
                                                      .post(
                                                          Uri.parse(
                                                              "https://us-central1-fostr2021.cloudfunctions.net/rewards/v1/rewardsupdate"),
                                                          headers: {
                                                            'Authorization':
                                                                'Bearer $bearerToken',
                                                            'Content-Type':
                                                                'application/json'
                                                          },
                                                          body: jsonEncode({
                                                            "activity_name":
                                                                "create_theatre",
                                                            "dateTime": DateTime
                                                                    .now()
                                                                .toIso8601String(),
                                                            "points": 25,
                                                            "type": "credit",
                                                            "userId": user.id,
                                                          }))
                                                      .then((http.Response
                                                          response) {
                                                    print(
                                                        "Response status: ${response.statusCode}");
                                                    print(
                                                        "Response body: ${response.contentLength}");
                                                    print(response.headers);
                                                    print(response.request);
                                                  });

                                                  // user.rewardcountfortheatre = user.rewardcountfortheatre - 1;
                                                  // _userService.updateUserField({"id": user.id, "rewardcountfortheatre": user.rewardcountfortheatre});
                                                } else {
                                                  ToastMessege(
                                                      'You have availed the maximum number of rewards for creating theatres',
                                                      context: context);
                                                  // Fluttertoast.showToast(
                                                  //     msg:
                                                  //         'You have availed the maximum number of rewards for creating theatres');
                                                }
                                                // }
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
                                SizedBox(
                                  height: 300,
                                )
                              ],
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
      ),
    );
  }
}
