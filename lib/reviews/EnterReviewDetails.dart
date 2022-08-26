import 'dart:async';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:convert';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as us;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/pages/user/SearchBookBits.dart';
import 'package:fostr/pages/user/SearchBookRoom.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/ImagePickerDialouge.dart';
import 'package:fostr/services/ReviewService.dart';
import 'package:audioplayers/audioplayers.dart' as AudioPlayers;
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as PATH;

import '../providers/BitsProvider.dart';
import '../providers/FeedProvider.dart';
import '../widgets/AppLoading.dart';

class EnterReviewDetails extends StatefulWidget {
  final String? bookname;
  final String? authorname;
  final String? description;
  final String? image;
  const EnterReviewDetails({
    Key? key,
    this.bookname = "",
    this.authorname = "",
    this.description = "",
    this.image = "",
  }) : super(key: key);

  @override
  _EnterReviewDetailsState createState() => _EnterReviewDetailsState();
}

class _EnterReviewDetailsState extends State<EnterReviewDetails>
    with FostrTheme, TickerProviderStateMixin {
  late TabController _tabController =
      new TabController(vsync: this, length: 1, initialIndex: 0);
  TextEditingController bookNameTextEditingController =
      new TextEditingController();
  TextEditingController authorNameTextEditingController =
      new TextEditingController();
  TextEditingController searchBookController = new TextEditingController();
  TextEditingController noteTextEditingController = new TextEditingController();

  bool recorded = false;
  bool recordNow = false;
  String filename = "";
  String fileext = "";
  int filesize = 0;
  String filepath = "";
  String fileUrl = "";
  String storedFileName = "";
  Uint8List? filebytes;

  final audioRecorder = Record();
  Duration duration = Duration.zero;
  DateTime? recordingStartTime;

  Uint8List? file;

  bool showPlayer = false;
  AudioSource? audioSource;

  final List<String> genres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Historical',
    'Historical Fiction',
    'Horror',
    'Magical Realism',
    'Mystery',
    'Paranoid',
    'Philosophical',
    'Political',
    'Romance',
    'Saga',
    'Satire',
    'Self-Help',
    'Sci-Fi',
    'Speculative',
    'Thriller',
    'Urban',
    'Western',
    'Other'
  ];

  String selectedGenre = 'Action';
  String? imageLink;
  File? image;

  @override
  void initState() {
    showPlayer = false;
    audioData.fileReceived = false;
    audioData.filePath = "";
    audioData.myFile = File("");
    // print("file--------------${audioData.myFile}");
    audioData.recorded = false;
    super.initState();

    setState(() {
      if(widget.image!.isNotEmpty){
        imageLink = widget.image!;
      }
      if(widget.bookname!.isNotEmpty){
        searchBookController.text = widget.bookname!;
      }
      if(widget.authorname!.isNotEmpty){
        authorNameTextEditingController.text = widget.authorname!;
      }
      if(widget.description!.isNotEmpty){
        noteTextEditingController.text = widget.description!;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioData.myFile.delete();
  }

  final validExtensions = ["mp3", "m4a", "mpeg", "wav", "aac"];

  void uploadToStorage(BuildContext context, {bool withLink = false}) async {
    User user = us.FirebaseAuth.instance.currentUser!;
    String datetime = DateTime.now().millisecondsSinceEpoch.toString();
    storedFileName =
        "reviews/${bookNameTextEditingController.text}_${user.uid}_$datetime";

    if (audioData.ext == "m4a") {
      audioData.ext = "mpeg";
    }

    final SettableMetadata settableMetadata = SettableMetadata(
      contentType: (Platform.isIOS) ? "audio/${audioData.ext}" : "video/mp4",
    );

    await FirebaseStorage.instance
        .ref(storedFileName)
        .putFile(audioData.myFile, settableMetadata);
    String url =
        await FirebaseStorage.instance.ref(storedFileName).getDownloadURL();

    String imageUrl = imageLink ?? "";
    if (!withLink) {
      await FirebaseStorage.instance
          .ref(storedFileName + "_image")
          .putFile(image!);
      imageUrl = await FirebaseStorage.instance
          .ref(storedFileName + "_image")
          .getDownloadURL();
    }

    String bookName = "";

    if (bookNameTextEditingController.text.isNotEmpty) {
      bookName = bookNameTextEditingController.text;
    } else {
      bookName = searchBookController.text;
    }

    user.getIdToken().then((token) async {
      ReviewService()
          .createReview(
        token,
        "${user.uid}_${DateTime.now().toUtc().millisecondsSinceEpoch.toString()}",
        bookName,
        authorNameTextEditingController.text,
        noteTextEditingController.text,
        user.uid,
        url,
        selectedGenre,
        imageUrl,
      )
          .then((value) async {
        print("value $value");
        if (value) {
          print("success");
          audioData.myFile = File("");
          audioData.filePath = "";
          final bitsProvider =
              Provider.of<BitsProvider>(context, listen: false);
          final feedsProvider =
              Provider.of<FeedProvider>(context, listen: false);
          feedsProvider.refreshFeed(true);
          await bitsProvider.refreshFeed(true);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDashboard(
                currentindex: 1,
                  tab: "bits", refresh: true, selectDay: DateTime.now()),
            ),
          );
        } else {
          print("not uploaded");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          backgroundColor: theme.colorScheme.background,
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
                    alignment: Alignment(0,0.5),
                    child: Container(
                      width: 100,
                      height: 50,
                      child: Center(
                        child: Text("Review",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: "drawerhead"
                          ),
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
          body: Padding(
            padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.06) ,
                // + EdgeInsets.only(top: 50),
            child: Column(
              children: <Widget>[
                //top bar
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 10),
                //   child: Row(
                //     children: [
                //       GestureDetector(
                //           onTap: () {
                //             Navigator.pop(context);
                //           },
                //           child: Icon(
                //             Icons.arrow_back_ios,
                //           )),
                //       Expanded(child: Container()),
                //       Image.asset(
                //         'assets/images/logo.png',
                //         fit: BoxFit.contain,
                //         width: 40,
                //         height: 40,
                //       )
                //     ],
                //   ),
                // ),

                //bookreview tab
                // TabBar(
                //   controller: _tabController,
                //   indicatorColor: Colors.transparent,
                //   indicatorPadding: EdgeInsets.all(0),
                //   tabs: [
                //     Container(
                //       height: 45,
                //       // margin: EdgeInsets.all(0),
                //       // padding: EdgeInsets.all(0),
                //       width: double.infinity,
                //       child: ElevatedButton.icon(
                //         onPressed: () => {
                //           setState(() => {_tabController.animateTo(1)})
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
                //         icon:
                //             // Image.asset(
                //             //   "assets/icons/bitsicon.jpeg",
                //             //   width: 35,
                //             //   height: 35,
                //             // ),
                //             Icon(Icons.audiotrack),
                //         label: Text(
                //           "Foster Review",
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
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Center(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  //enter details
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [

                                        //book name
                                        Row(
                                          children: [
                                            Text("Book name",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: "drawerhead"
                                              ),),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextField(
                                          onChanged: (e) {
                                            setState(() {
                                              searchBookController.text = "";
                                            });
                                          },
                                          controller:
                                              bookNameTextEditingController,
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
                                            hintText: "Book name",
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
                                            style: TextStyle(),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        //isbn search
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
                                                  bookNameTextEditingController
                                                      .text = "";
                                                  searchBookController
                                                          .text =
                                                      result[0];
                                                  imageLink =
                                                      result[2]
                                                          .toString();
                                                  authorNameTextEditingController
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
                                              //     bookNameTextEditingController
                                              //         .text = "";
                                              //     searchBookController.text =
                                              //         result[0];
                                              //     imageLink =
                                              //         result[2].toString();
                                              //     authorNameTextEditingController
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
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15)),
                                                  color: Colors.white12,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      (searchBookController
                                                              .text.isNotEmpty)
                                                          ? searchBookController
                                                              .text
                                                          : "Search For Book",
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
                                          height: 30,
                                        ),


                                        //author name
                                        Row(
                                          children: [
                                            Text("Author name",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: "drawerhead"
                                              ),),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextField(
                                          controller:
                                              authorNameTextEditingController,
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
                                            hintText: "Author name",
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
                                          height: 30,
                                        ),

                                        //pick image
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 115,
                                              child: Text("Image",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontFamily: "drawerhead"
                                                ),),
                                            ),
                                            Text("Description",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: "drawerhead"
                                              ),),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [

                                            //image
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    imagePickerDialoge(context,
                                                        onImageSelected: (file) {
                                                          setState(() {
                                                            image = file;
                                                            imageLink = null;
                                                          });
                                                        });
                                                  },
                                                  child: Container(
                                                    height: 100,
                                                    // MediaQuery.of(context)
                                                    //     .size
                                                    //     .width -
                                                    //     52,
                                                    width: 100,
                                                    // MediaQuery.of(context)
                                                    //     .size
                                                    //     .width -
                                                    //     52,
                                                    child: (image == null &&
                                                        imageLink == null)
                                                        ? Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .add_photo_alternate_outlined,
                                                              size: 30,
                                                            ),
                                                            // Text(
                                                            //   "Select an Image",
                                                            // ),
                                                          ],
                                                        ))
                                                        : ClipRRect(
                                                        borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                        child:
                                                        (imageLink != null)
                                                            ? Image.network(
                                                            imageLink!,
                                                            fit: BoxFit
                                                                .cover)
                                                            : Image.file(
                                                          image!,
                                                          fit: BoxFit
                                                              .cover,
                                                        )),
                                                    decoration: BoxDecoration(
                                                      color:
                                                      theme.colorScheme.primary,
                                                      borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                      border: Border.all(
                                                          color: theme.colorScheme
                                                              .inversePrimary,
                                                          width: 0.5),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),

                                            //descrpition
                                            Expanded(
                                              child: Container(
                                                child: TextField(
                                                  controller: noteTextEditingController,
                                                  style: h2.copyWith(
                                                      color: theme
                                                          .colorScheme.inversePrimary),
                                                  maxLength: 500,
                                                  maxLines: 4,
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 12,
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
                                                    hintText: "Write a note here",
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
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),

                                        //note
                                        // TextField(
                                        //   controller: noteTextEditingController,
                                        //   style: h2.copyWith(
                                        //       color: theme
                                        //           .colorScheme.inversePrimary),
                                        //   maxLength: 500,
                                        //   maxLines: 5,
                                        //   decoration: InputDecoration(
                                        //     contentPadding:
                                        //         EdgeInsets.symmetric(
                                        //             vertical: 10,
                                        //             horizontal: 15),
                                        //     border: OutlineInputBorder(
                                        //       borderRadius:
                                        //           const BorderRadius.all(
                                        //         Radius.circular(15.0),
                                        //       ),
                                        //     ),
                                        //     filled: true,
                                        //     hintStyle: new TextStyle(
                                        //         color: Colors.grey[600]),
                                        //     hintText: "Write a note here",
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
                                        // ),
                                        // SizedBox(
                                        //   height: 20,
                                        // ),


                                        //image
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.center,
                                        //   children: [
                                        //     //progress indicator
                                        //     GestureDetector(
                                        //       onTap: () async {
                                        //         imagePickerDialoge(context,
                                        //             onImageSelected: (file) {
                                        //           setState(() {
                                        //             image = file;
                                        //             imageLink = null;
                                        //           });
                                        //         });
                                        //       },
                                        //       child: Container(
                                        //         height: MediaQuery.of(context)
                                        //                 .size
                                        //                 .width -
                                        //             52,
                                        //         width: MediaQuery.of(context)
                                        //                 .size
                                        //                 .width -
                                        //             52,
                                        //         child: (image == null &&
                                        //                 imageLink == null)
                                        //             ? Center(
                                        //                 child: Column(
                                        //                 mainAxisAlignment:
                                        //                     MainAxisAlignment
                                        //                         .spaceEvenly,
                                        //                 children: [
                                        //                   Icon(
                                        //                     Icons
                                        //                         .add_photo_alternate_outlined,
                                        //                     size: 83,
                                        //                   ),
                                        //                   Text(
                                        //                     "Select an Image",
                                        //                   ),
                                        //                 ],
                                        //               ))
                                        //             : ClipRRect(
                                        //                 borderRadius:
                                        //                     BorderRadius.all(
                                        //                   Radius.circular(10),
                                        //                 ),
                                        //                 child:
                                        //                     (imageLink != null)
                                        //                         ? Image.network(
                                        //                             imageLink!,
                                        //                             fit: BoxFit
                                        //                                 .cover)
                                        //                         : Image.file(
                                        //                             image!,
                                        //                             fit: BoxFit
                                        //                                 .cover,
                                        //                           )),
                                        //         decoration: BoxDecoration(
                                        //           color:
                                        //               theme.colorScheme.primary,
                                        //           borderRadius:
                                        //               BorderRadius.all(
                                        //             Radius.circular(10),
                                        //           ),
                                        //           border: Border.all(
                                        //               color: theme.colorScheme
                                        //                   .inversePrimary,
                                        //               width: 0.5),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        // SizedBox(
                                        //   height: 20,
                                        // ),


                                        //genre
                                        Row(
                                          children: [
                                            Text("Genre",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: "drawerhead"
                                              ),),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),

                                        //genre
                                        DropdownSearch<String>(
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select a genre';
                                            }
                                            return null;
                                          },
                                          searchFieldProps: TextFieldProps(
                                              decoration: InputDecoration(
                                            hintText: "Select a genre",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(15.0),
                                              ),
                                            ),
                                          )),
                                          popupBackgroundColor:
                                              theme.colorScheme.primary,
                                          popupShape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          popupItemBuilder:
                                              (context, item, isFound) {
                                            return Container(
                                              child: ListTile(
                                                title: Text(
                                                  item,
                                                  style: TextStyle(
                                                    color: theme.colorScheme
                                                        .inversePrimary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              selectedGenre = value ?? "Action";
                                            });
                                          },
                                          showSearchBox: true,
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(15.0),
                                              ),
                                            ),
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                              borderSide: BorderSide(
                                                  width: 0.5,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          mode: Mode.DIALOG,
                                          items: genres,
                                          dropDownButton: Icon(
                                            FontAwesomeIcons.chevronDown,
                                            color: Colors.grey[600],
                                          ),
                                          dropdownBuilder:
                                              (context, selectedItem) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 15),
                                              child: Text(
                                                selectedItem ?? "",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            );
                                          },
                                          selectedItem: selectedGenre,
                                        ),
                                      ],
                                    ),
                                  ),

                                  //toggle button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(),
                                      Text(
                                        "Record",
                                        style: TextStyle(
                                            fontWeight: recordNow
                                                ? FontWeight.normal
                                                : FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Switch(
                                        onChanged: (value) {
                                          setState(() {
                                            recordNow = value;
                                            filename = "";
                                            audioData.filePath = "";
                                            audioData.recorded = false;
                                            audioData.fileReceived = false;
                                            audioData.myFile = File("");
                                          });
                                        },
                                        value: recordNow,
                                        activeColor:
                                            theme.colorScheme.secondary,
                                        inactiveTrackColor: theme
                                            .colorScheme.secondary
                                            .withOpacity(0.5),
                                        inactiveThumbColor:
                                            theme.colorScheme.secondary,
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Text(
                                        "Upload",
                                        style: TextStyle(
                                            fontWeight: recordNow
                                                ? FontWeight.bold
                                                : FontWeight.normal),
                                      ),
                                      Container(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),

                                  //upload from device and record review
                                  Container(
                                    height: 90,
                                    child: Center(
                                      child: recordNow
                                          ?
                                          //upload from device
                                          Column(
                                              children: [
                                                Expanded(child: Container()),
                                                GestureDetector(
                                                  //upload file from device
                                                  onTap: () async {
                                                    setState(() {
                                                      filename = "";
                                                      audioData.recorded =
                                                          false;
                                                      audioData.filePath = "";
                                                    });
                                                    FilePickerResult? result =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles(
                                                      allowMultiple: false,
                                                      type: (Platform.isIOS)
                                                          ? FileType.any
                                                          : FileType.audio,
                                                    )
                                                            .then(
                                                                (value) async {
                                                      if (value != null) {
                                                        if (!validExtensions
                                                            .contains(value
                                                                .files
                                                                .single
                                                                .extension)) {
                                                          ToastMessege(
                                                              "Please upload a valid file",
                                                              context: context);
                                                          return;
                                                        } else {
                                                          setState(() {
                                                            filepath = value
                                                                .files
                                                                .first
                                                                .path!;
                                                            fileext = value
                                                                .files
                                                                .first
                                                                .extension!;
                                                          });
                                                          AudioPlayer player =
                                                              AudioPlayer();
                                                          await player
                                                              .setFilePath(
                                                                  filepath);
                                                          var duration =
                                                              await player
                                                                  .duration;
                                                          if (duration!
                                                                  .inMinutes <
                                                              2) {
                                                            setState(() {
                                                              filename = value
                                                                  .files
                                                                  .first
                                                                  .name;
                                                              audioData
                                                                      .fileReceived =
                                                                  true;
                                                              audioData
                                                                      .filePath =
                                                                  filepath;
                                                              audioData.myFile =
                                                                  File(
                                                                      filepath);
                                                            });
                                                          } else {
                                                            ToastMessege(
                                                                "file duration must be less than 2 minutes",
                                                                context:
                                                                    context);
                                                          }
                                                        }
                                                      } else {
                                                        ToastMessege(
                                                            "file not received, try again",
                                                            context: context);
                                                      }
                                                    });
                                                  },

                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        border: Border.all(
                                                            color: theme
                                                                .colorScheme
                                                                .secondary,
                                                            width: 1)),
                                                    child:
                                                        audioData.fileReceived
                                                            ? Center(
                                                                child: filename
                                                                        .isNotEmpty
                                                                    ? Text(
                                                                        "$filename",
                                                                      )
                                                                    : Row(
                                                                        children: [
                                                                          Expanded(
                                                                              child: Container()),
                                                                          Icon(
                                                                            Icons.mic,
                                                                            color:
                                                                                theme.colorScheme.secondary,
                                                                          ),
                                                                          // SvgPicture
                                                                          //     .asset(
                                                                          //         "assets/icons/reviewMic.svg"),
                                                                          Text(
                                                                            "     Upload from device",
                                                                            style:
                                                                                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                          ),
                                                                          Expanded(
                                                                              child: Container()),
                                                                        ],
                                                                      ),
                                                              )
                                                            : Row(
                                                                children: [
                                                                  Expanded(
                                                                      child:
                                                                          Container()),
                                                                  Icon(
                                                                    Icons.mic,
                                                                    color: theme
                                                                        .colorScheme
                                                                        .secondary,
                                                                  ),
                                                                  // SvgPicture
                                                                  //     .asset(
                                                                  //         "assets/icons/reviewMic.svg"),
                                                                  Text(
                                                                    "     Upload from device",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Container()),
                                                                ],
                                                              ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  "file must be less than 2 minutes in duration with .mp3 extension",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                // Text("data")
                                              ],
                                            )
                                          :
                                          //record review
                                          Column(
                                              children: [
                                                Expanded(child: Container()),
                                                AudioRecorder(
                                                  onStart: () {
                                                    recordingStartTime =
                                                        DateTime.now();
                                                    setState(() {
                                                      audioData.filePath = "";
                                                    });
                                                  },
                                                  onStop: (path) {
                                                    setState(() {
                                                      duration = DateTime.now()
                                                          .difference(
                                                              recordingStartTime!);
                                                      audioSource =
                                                          AudioSource.uri(
                                                              Uri.parse(path));
                                                      showPlayer = true;
                                                    });
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  "recording must be less than 2 minutes.",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Expanded(child: Container()),
                                              ],
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),

                                  //audio preview
                                  audioData.filePath.isNotEmpty && !recordNow
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: RecordedAudioPreview(
                                            path: audioData.filePath,
                                            duration: duration,
                                          ),
                                        )
                                      : SizedBox.shrink(),

                                  //post button
                                  recorded
                                      ? AppLoading(
                                          height: 70,
                                          width: 70,
                                        )
                                      // CircularProgressIndicator(
                                      //   color: GlobalColors.signUpSignInButton,
                                      //       )
                                      : ElevatedButton(
                                          onPressed: () async {
                                            if (image == null &&
                                                imageLink == null) {
                                              ToastMessege(
                                                  "Please select an image",
                                                  context: context);
                                              return;
                                            }
                                            if (bookNameTextEditingController
                                                    .text.isEmpty &&
                                                searchBookController
                                                    .text.isEmpty) {
                                              ToastMessege(
                                                  "Book name is required!",
                                                  context: context);
                                            } else {
                                              if (imageLink != null) {
                                                setState(() {
                                                  recorded = true;
                                                });
                                                uploadToStorage(context,
                                                    withLink: true);
                                              } else if (audioData.myFile ==
                                                      File("") ||
                                                  audioData.myFile == null) {
                                                ToastMessege(
                                                    "File not uploaded",
                                                    context: context);
                                              } else {
                                                if (audioData.fileReceived) {
                                                  setState(() {
                                                    recorded = true;
                                                    // audioData.filePath = "";
                                                  });
                                                  uploadToStorage(context);
                                                  user.points = user.points + 5;
                                                  final cUser = await us
                                                      .FirebaseAuth
                                                      .instance
                                                      .currentUser;
                                                  final bearerToken =
                                                      await cUser?.getIdToken();
                                                  if (user.rewardcountforreview >
                                                      -10) {
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
                                                                  "create_review",
                                                              "dateTime": DateTime
                                                                      .now()
                                                                  .toIso8601String(),
                                                              "points": 5,
                                                              "type": "credit",
                                                              "userId": user.id,
                                                            }))
                                                        .then((http.Response
                                                            response) {});
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'You have availed the maximum rewards for book reviews');
                                                  }
                                                } else {
                                                  ToastMessege(
                                                      "file not received",
                                                      context: context);
                                                }
                                              }
                                            }
                                          },
                                          child: Container(
                                            width: 100,
                                            height: 20,
                                            child: Row(
                                              children: [
                                                Expanded(child: Container()),
                                                Text(
                                                  "Create  ",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                ),
                                                Expanded(child: Container()),
                                              ],
                                            ),
                                          ),
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                    EdgeInsets>(
                                                EdgeInsets.symmetric(
                                                    horizontal: 30,
                                                    vertical: 15)),
                                            backgroundColor:
                                                MaterialStateProperty.all(theme
                                                    .colorScheme.secondary),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;
  final void Function() onStart;

  const AudioRecorder({required this.onStop, required this.onStart});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();

  @override
  void initState() {
    _isRecording = false;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: <Widget>[
            Expanded(child: Container()),
            _buildRecordStopControl(theme),
            const SizedBox(width: 20),
            _buildText(theme),
            const SizedBox(width: 20),
            _buildPauseResumeControl(theme),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordStopControl(ThemeData theme) {
    late Icon icon;
    late Color color;

    if (_isRecording || _isPaused) {
      icon = Icon(Icons.stop, color: Colors.white);
      color = theme.colorScheme.secondary;
    } else {
      icon = Icon(Icons.mic, color: Colors.white);
      color = theme.colorScheme.secondary;
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 45, height: 45, child: icon),
          onTap: () {
            _isRecording ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl(ThemeData theme) {
    if (!_isRecording && !_isPaused) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (!_isPaused) {
      icon = Icon(Icons.pause, color: Colors.white);
      color = theme.colorScheme.secondary;
    } else {
      icon = Icon(Icons.play_arrow, color: Colors.white);
      color = theme.colorScheme.secondary;
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 45, height: 45, child: icon),
          onTap: () {
            _isPaused ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText(ThemeData theme) {
    if (_isRecording || _isPaused) {
      return _buildTimer();
    }

    return Text(
      audioData.recorded ? "Record again" : "Record review",
      style: TextStyle(
          color: audioData.recorded ? theme.colorScheme.secondary : null,
          fontWeight: audioData.recorded ? FontWeight.normal : FontWeight.bold),
    );
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    if (minutes == "02") {
      _stop();
      Fluttertoast.showToast(
          msg: "recorded review time is 2 minutes",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: gradientBottom,
          fontSize: 16.0);
    }

    return Text(
      '$minutes : $seconds',
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  Future<void> _start() async {
    widget.onStart();

    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          audioData.filePath = "";
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    String? path = "";
    if (Platform.isIOS) {
      path = (await _audioRecorder.stop())?.substring(8);
    } else {
      path = await _audioRecorder.stop();
    }
    assert(path != null);
    widget.onStop(path!);
    final ext = PATH.extension(path);
    setState(() {
      if (_isPaused) {
        _isPaused = false;
      }
      audioData.fileReceived = true;
      audioData.myFile = File(path!);
      audioData.filePath = path;
      _isRecording = false;
      audioData.recorded = true;
      audioData.ext = ext.substring(1);
    });
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}

class RecordedAudioPreview extends StatefulWidget {
  final String path;
  final Duration duration;
  const RecordedAudioPreview(
      {Key? key, required this.path, required this.duration})
      : super(key: key);

  @override
  _RecordedAudioPreviewState createState() => _RecordedAudioPreviewState();
}

class _RecordedAudioPreviewState extends State<RecordedAudioPreview> {
  var player;
  Duration duration = Duration.zero;
  bool isFinished = false;
  Duration? audioDuration;
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      setState(() {
        player = AudioPlayer();
      });
      player.positionStream.listen((event) async {
        if (audioDuration != null && event == audioDuration) {
          await player.stop();
          player.seek(Duration.zero);
          setState(() {
            isPlaying = false;
            isFinished = true;
          });
        }
      });
    } else if (Platform.isIOS) {
      setState(() {
        player = AudioPlayers.AudioPlayer();
      });
      player.onPlayerStateChanged.listen((event) {
        if (event == AudioPlayers.PlayerState.COMPLETED) {
          setState(() {
            isPlaying = false;
            isFinished = true;
          });
        }
      });
    }
    _init();
  }

  void _init() async {
    if (Platform.isAndroid) {
      try {
        await player.setFilePath(audioData.myFile.path).then((value) {
          setState(() {
            audioDuration = value;
          });
        });
      } catch (e) {}
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        //play button
        Platform.isIOS
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      if (player.state == AudioPlayers.PlayerState.PAUSED) {
                        await player.resume();
                        setState(() {
                          isPlaying = true;
                        });
                      } else if (player.state ==
                          AudioPlayers.PlayerState.PLAYING) {
                        await player.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      } else if (player.state !=
                          AudioPlayers.PlayerState.PLAYING) {
                        await player
                            .play(audioData.myFile.path, isLocal: true)
                            .then((value) {
                          player.getDuration().then((value) {
                            setState(() {
                              duration = Duration(milliseconds: value);
                            });
                          }).catchError((o) {
                            print(o);
                          });
                        });
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
                    child: (!isPlaying)
                        ? Icon(
                            Icons.play_arrow,
                            size: 20,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.pause,
                            size: 20,
                            color: Colors.white,
                          ),
                  ),
                ),
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (!isPlaying) {
                        setState(() {
                          isPlaying = true;
                        });
                        player.play();
                      } else {
                        setState(() {
                          isPlaying = false;
                        });
                        player.pause();
                      }
                    },
                    child: (!isPlaying)
                        ? Icon(
                            Icons.play_arrow,
                            size: 20,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.pause,
                            size: 20,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
        SizedBox(
          width: 30,
        ),

        //seek bar
        Platform.isIOS
            ? Expanded(
                child: Container(
                  height: 40,
                  width: 200,
                  child: Center(
                    child: StreamBuilder(
                        stream: player.onAudioPositionChanged,
                        builder: (context, AsyncSnapshot<Duration> snapshot) {
                          return ProgressBar(
                            progress: snapshot.data ?? Duration.zero,
                            total: duration,
                            onSeek: (duration) {
                              player.seek(duration);
                            },
                            barHeight: 5,
                            baseBarColor:
                                theme.colorScheme.secondary.withOpacity(0.5),
                            progressBarColor: theme.colorScheme.secondary,
                            bufferedBarColor:
                                theme.colorScheme.secondary.withOpacity(0.5),
                            thumbColor: Colors.grey.shade300,
                            barCapShape: BarCapShape.round,
                            thumbRadius: 10,
                            thumbCanPaintOutsideBar: false,
                            timeLabelLocation: TimeLabelLocation.below,
                            timeLabelType: TimeLabelType.totalTime,
                            timeLabelTextStyle: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.inversePrimary),
                            timeLabelPadding: 0,
                          );
                        }),
                  ),
                ),
              )
            : Expanded(
                child: Container(
                  height: 40,
                  width: 200,
                  child: Center(
                    child: StreamBuilder<DurationState>(
                        stream: Rx.combineLatest2<Duration, PlaybackEvent,
                                DurationState>(
                            player.positionStream,
                            player.playbackEventStream,
                            (position, playbackEvent) => DurationState(
                                  progress: position,
                                  buffered: playbackEvent.bufferedPosition,
                                  total: playbackEvent.duration,
                                )),
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final position =
                              durationState?.progress ?? Duration.zero;
                          final buffered =
                              durationState?.buffered ?? Duration.zero;
                          final total = durationState?.total ??
                              durationState?.buffered ??
                              widget.duration;
                          return ProgressBar(
                            progress: position,
                            buffered: buffered,
                            total: total,
                            onSeek: (duration) {
                              player.seek(duration);
                            },
                            barHeight: 5,
                            baseBarColor:
                                theme.colorScheme.secondary.withOpacity(0.5),
                            progressBarColor: theme.colorScheme.secondary,
                            bufferedBarColor:
                                theme.colorScheme.secondary.withOpacity(0.5),
                            thumbColor: Colors.grey.shade300,
                            barCapShape: BarCapShape.round,
                            thumbRadius: 10,
                            thumbCanPaintOutsideBar: false,
                            timeLabelLocation: TimeLabelLocation.below,
                            timeLabelType: TimeLabelType.totalTime,
                            timeLabelTextStyle: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.inversePrimary),
                            timeLabelPadding: 0,
                          );
                        }),
                  ),
                ),
              ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;
}

class audioData {
  static bool fileReceived = false;
  static String filePath = "";
  static File myFile = File("");
  static bool recorded = false;
  static String ext = "";
}
