import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/ImagePickerDialouge.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as PATH;
import 'package:audioplayers/audioplayers.dart' as AudioPlayers;
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';

class EnterEpisodeDetails extends StatefulWidget {
  final String albumId;
  final String albumImage;
  final String authorId;
  const EnterEpisodeDetails({
    Key? key,
    required this.albumId,
    required this.albumImage,
    required this.authorId
  }) : super(key: key);

  @override
  State<EnterEpisodeDetails> createState() => _EnterEpisodeDetailsState();
}

class _EnterEpisodeDetailsState extends State<EnterEpisodeDetails>
    with FostrTheme, TickerProviderStateMixin {

  late TabController _tabController =
  new TabController(vsync: this, length: 1, initialIndex: 0);

  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  File? image;

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

  @override
  void initState() {

    showPlayer = false;
    audioData.fileReceived = false;
    audioData.filePath = "";
    audioData.myFile = File("");
    audioData.recorded = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    audioData.myFile.delete();
  }

  final validExtensions = ["mp3", "m4a", "mpeg", "wav", "aac"];

  void uploadToStorage(BuildContext context) async {
    User user = FirebaseAuth.instance.currentUser!;
    String datetime = DateTime.now().millisecondsSinceEpoch.toString();
    storedFileName = "albums/${widget.albumId}/episodes/${titleController.text}_${user.uid}_$datetime";
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String episodeId = String.fromCharCodes(Iterable.generate(
        20, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    if (audioData.ext == "m4a") {
      audioData.ext = "mpeg";
    }

    final SettableMetadata settableMetadata = SettableMetadata(
      contentType: (Platform.isIOS) ? "audio/${audioData.ext}" : "video/mp4",
    );

    await FirebaseStorage.instance.ref(storedFileName).putFile(audioData.myFile, settableMetadata);
    String episodeUrl = await FirebaseStorage.instance.ref(storedFileName).getDownloadURL();

    image != null ?
    await FirebaseStorage.instance.ref(storedFileName + "_image").putFile(image!) : null;

    String imageUrl = image != null ?
    await FirebaseStorage.instance.ref(storedFileName + "_image").getDownloadURL() :
        widget.albumImage;

    await FirebaseFirestore.instance
    .collection("albums")
    .doc(widget.albumId)
    .collection("episodes")
    .doc(episodeId)
    .set({
      "albumId" : widget.albumId,
      "authorId" : widget.authorId,
      "id" : episodeId,
      "image" : imageUrl,
      "audio" : episodeUrl,
      "dateTime" : DateTime.now(),
      "isActive" : true,
      "title" : titleController.text,
      "description" : descriptionController.text,
      "bookmarkCount" : 0,
    },SetOptions(merge: true)).then((value) async {
      await FirebaseFirestore.instance
          .collection("albums")
          .doc(widget.albumId)
      .update({
        "episodes" : FieldValue.increment(1)
      }).then((value){
        setState(() {
          audioData.myFile = File("");
          audioData.filePath = "";
        });
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
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
                        child: Text("Episode",
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
                horizontal: MediaQuery.of(context).size.width * 0.06),
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

                //episode tab
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
                //         onPressed: () {},
                //         style: ButtonStyle(
                //             shape: MaterialStateProperty.all<
                //                 RoundedRectangleBorder>(RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(11.0),
                //             )),
                //             backgroundColor: MaterialStateProperty.all(Colors.white),
                //             foregroundColor: MaterialStateProperty.all(Colors.black)),
                //         icon: Icon(Icons.audiotrack),
                //         label: Text(
                //           "Episode",
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

                                        //image
                                        // Row(
                                        //   mainAxisAlignment:
                                        //   MainAxisAlignment.center,
                                        //   children: [
                                        //     //progress indicator
                                        //     GestureDetector(
                                        //       onTap: () async {
                                        //         imagePickerDialoge(context,
                                        //             onImageSelected: (file) {
                                        //               setState(() {
                                        //                 image = file;
                                        //               });
                                        //             });
                                        //       },
                                        //       child: Container(
                                        //         height: 100,
                                        //         // MediaQuery.of(context)
                                        //         //     .size
                                        //         //     .width -
                                        //         //     52,
                                        //         width: 100,
                                        //         // MediaQuery.of(context)
                                        //         //     .size
                                        //         //     .width -
                                        //         //     52,
                                        //         child: (image == null)
                                        //             ? Center(
                                        //             child: Column(
                                        //               mainAxisAlignment:
                                        //               MainAxisAlignment
                                        //                   .spaceEvenly,
                                        //               children: [
                                        //                 Icon(
                                        //                   Icons
                                        //                       .add_photo_alternate_outlined,
                                        //                   size: 30,
                                        //                 ),
                                        //                 // Text(
                                        //                 //   "Select an Image",
                                        //                 // ),
                                        //               ],
                                        //             ))
                                        //             : ClipRRect(
                                        //             borderRadius:
                                        //             BorderRadius.all(
                                        //               Radius.circular(10),
                                        //             ),
                                        //             child:Image.file(
                                        //               image!,
                                        //               fit: BoxFit
                                        //                   .cover,
                                        //             )),
                                        //         decoration: BoxDecoration(
                                        //           color:
                                        //           theme.colorScheme.primary,
                                        //           borderRadius:
                                        //           BorderRadius.all(
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

                                        //episode title
                                        Row(
                                          children: [
                                            Text("Title",
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
                                          titleController,
                                          maxLength: 250,
                                          style: h2.copyWith(
                                              color: theme
                                                  .colorScheme.inversePrimary),
                                          decoration: InputDecoration(
                                            counterText: "",
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
                                            hintText: "Title",
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
                                                    child: (image == null)
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
                                                        child:Image.file(
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
                                                  controller: descriptionController,
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
                                                    hintText: "Write a description here",
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
                                        //   controller: descriptionController,
                                        //   style: h2.copyWith(
                                        //       color: theme
                                        //           .colorScheme.inversePrimary),
                                        //   maxLength: 500,
                                        //   maxLines: 5,
                                        //   decoration: InputDecoration(
                                        //     contentPadding:
                                        //     EdgeInsets.symmetric(
                                        //         vertical: 10,
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
                                        //     hintText: "Write a description here",
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
                                        //   height: 10,
                                        // ),
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

                                  //upload from device and record episode
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
                                      //record episode
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
                                      : ElevatedButton(
                                    onPressed: () async {
                                      if (image == null) {

                                        // ToastMessege(
                                        //     "Please select an image",
                                        //     context: context);
                                        // return;
                                      }
                                      if (titleController
                                          .text.isEmpty ) {
                                        ToastMessege(
                                            "Episode title is required!",
                                            context: context);
                                      } else {
                                        if (audioData.myFile ==
                                            File("") ||
                                            audioData.myFile == null) {
                                          ToastMessege(
                                              "File not uploaded",
                                              context: context);
                                        } else {
                                          if (audioData.fileReceived) {
                                            setState(() {
                                              recorded = true;
                                            });
                                            uploadToStorage(context);
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
                                            "Post  ",
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
                                    height: 100,
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
      audioData.recorded ? "Record again" : "Record episode",
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
          msg: "recorded episode time is 2 minutes",
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
