import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:fostr/models/UserModel/User.dart' as us;
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EnterAlbumDetails extends StatefulWidget {
  final String? bookname;
  final String? authorname;
  final String? description;
  final String? image;
  const EnterAlbumDetails({
    Key? key,
    this.bookname = "",
    this.authorname = "",
    this.description = "",
    this.image = "",
  }) : super(key: key);

  @override
  State<EnterAlbumDetails> createState() => _EnterAlbumDetailsState();
}

class _EnterAlbumDetailsState extends State<EnterAlbumDetails>
    with FostrTheme, TickerProviderStateMixin {
  late TabController _tabController =
  new TabController(vsync: this, length: 1, initialIndex: 0);
  bool isLoading = false;
  bool isUploaded = false;
  bool posting = false;
  String image = "Add a Image (378x 375)", imageUrl = "";
  var file;
  var croppedfile;
  File pickedImage = File("/file.jpg");
  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  Dialog dialog = Dialog();
  bool isNetworkImageAvailable = false;
  String netImage = "";
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

  @override
  void initState() {
    super.initState();

    setState(() {
      if(widget.image!.isNotEmpty){
        isNetworkImageAvailable = true;
        netImage = widget.image!;
        isLoading = false;
        isUploaded = true;
      }
      if(widget.bookname!.isNotEmpty){
        titleController.text = widget.bookname!;
      }
      if(widget.description!.isNotEmpty){
        descriptionController.text = widget.description!;
      }
    });
  }

  void createAlbum(BuildContext context, us.User user) async {
    String ref = "${titleController.text.trim()}_${user.id}_${DateTime.now().toUtc().millisecondsSinceEpoch}";

    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    String albumId = String.fromCharCodes(Iterable.generate(
        20, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    if(isNetworkImageAvailable){
      await FirebaseFirestore.instance
          .collection("albums")
          .doc(albumId)
          .set({
        "episodes" : 0,
        "authorId" : user.id,
        "authorName" : user.name,
        "authorUserName" : user.userName,
        "authorProfile" : user.userProfile!.profileImage,
        "id" : albumId,
        "title" : titleController.text,
        "titleLowerCase" : titleController.text.toLowerCase().trim(),
        "description" : descriptionController.text,
        "genre" : selectedGenre,
        "image" : widget.image!,
        "playCount" : 0,
        "bookmarkCount" : 0,
        "isActive" : true,
        "dateTime" : DateTime.now().toUtc(),
      },SetOptions(merge: true)).then((value){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboard(
                currentindex: 2,
                tab: "bits", refresh: true, selectDay: DateTime.now()),
          ),
        );
        ToastMessege("Podcast created", context: context);

        ///search feed
        Future.delayed(Duration(seconds: 2)).then((value) async {

          String book_name = titleController.text.toLowerCase().trim();

          await FirebaseFirestore.instance
              .collection("booksearch")
              .doc(book_name)
              .set({
            "book_title" : book_name
          },SetOptions(merge: true)).then((value) async {
            await FirebaseFirestore.instance
                .collection("booksearch")
                .doc(book_name)
                .collection("activities")
                .doc(albumId)
                .set({
              "activityid" : albumId,
              "activitytype" : SearchType.album.name,
              "creatorid" : user.id
            },SetOptions(merge: true));
          });
        });

      });
    } else {
      //storing image in storage
      await FirebaseStorage.instance
          .ref("albums/${user.id}/$ref")
          .putFile(pickedImage)
          .then((p0) async {
        //getting image url
        await FirebaseStorage.instance
            .ref("albums/${user.id}/$ref")
            .getDownloadURL()
            .then((value) async {
          //storing data in firestore

          await FirebaseFirestore.instance
              .collection("albums")
              .doc(albumId)
              .set({
            "episodes" : 0,
            "authorId" : user.id,
            "authorName" : user.name,
            "authorUserName" : user.userName,
            "authorProfile" : user.userProfile!.profileImage,
            "id" : albumId,
            "title" : titleController.text,
            "titleLowerCase" : titleController.text.toLowerCase().trim(),
            "description" : descriptionController.text,
            "genre" : selectedGenre,
            "image" : value,
            "playCount" : 0,
            "bookmarkCount" : 0,
            "isActive" : true,
            "dateTime" : DateTime.now().toUtc(),
          },SetOptions(merge: true)).then((value){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDashboard(
                    currentindex: 2,
                    tab: "bits", refresh: true, selectDay: DateTime.now()),
              ),
            );

            ToastMessege("Podcast created", context: context);

            ///search feed
            Future.delayed(Duration(seconds: 2)).then((value) async {

              String book_name = titleController.text.toLowerCase().trim();

              await FirebaseFirestore.instance
                  .collection("booksearch")
                  .doc(book_name)
                  .set({
                "book_title" : book_name
              },SetOptions(merge: true)).then((value) async {
                await FirebaseFirestore.instance
                    .collection("booksearch")
                    .doc(book_name)
                    .collection("activities")
                    .doc(albumId)
                    .set({
                  "activityid" : albumId,
                  "activitytype" : SearchType.album.name,
                  "creatorid" : user.id
                },SetOptions(merge: true));
              });
            });

          });
        });
      });
    }

  }

  @override
  Widget build(BuildContext mainContext) {
    final theme = Theme.of(mainContext);
    final auth = Provider.of<AuthProvider>(mainContext);
    final user = auth.user!;
    dialog = Dialog(
      backgroundColor: theme.colorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: 100,
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.colorScheme.secondary, width: 0.5)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //camera
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                    isUploaded = false;
                  });

                  try {
                    var clickedfile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    //   .catchError((e){
                    // FirebaseFirestore.instance.collection("errorLogs").add({
                    //   "error": e,
                    //   "time": DateTime.now(),
                    //   "type":"readings"
                    //   });
                    // });

                    File image = File(clickedfile!.path);

                    if (image.path.split(".").last == "jpeg" ||
                        image.path.split(".").last == "jpg") {
                      if (image != null) {
                        croppedfile = await ImageCropper().cropImage(
                            sourcePath: image.path,
                            aspectRatioPresets: [
                              CropAspectRatioPreset.square,
                              CropAspectRatioPreset.ratio3x2,
                              CropAspectRatioPreset.original,
                              CropAspectRatioPreset.ratio4x3,
                              CropAspectRatioPreset.ratio16x9
                            ],
                            androidUiSettings: AndroidUiSettings(
                                toolbarTitle: 'Image Cropper',
                                toolbarColor: theme.colorScheme.secondary,
                                toolbarWidgetColor: theme.colorScheme.primary,
                                initAspectRatio: CropAspectRatioPreset.original,
                                lockAspectRatio: false),
                            iosUiSettings: IOSUiSettings(
                              minimumAspectRatio: 1.0,
                            ));
                        if (croppedfile != null) {
                          await FlutterImageCompress.compressAndGetFile(
                            croppedfile.path,
                            image.path,
                            quality: 50, // the lesser the poorer the
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                isLoading = false;
                                isUploaded = true;
                                pickedImage = value;
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              });
                            }
                          });

                        }
                      } else {
                        setState(() {
                          isLoading = false;
                          isUploaded = false;
                        });
                        ToastMessege("Image not uploaded", context: context);
                      }
                    } else {
                      setState(() {
                        isLoading = false;
                        isUploaded = false;
                      });
                      ToastMessege("Only .jpeg/.jpg formats allowed",
                          context: context);
                      // Fluttertoast.showToast(
                      //     msg: "Only .jpeg/.jpg formats allowed",
                      //     toastLength: Toast.LENGTH_SHORT,
                      //     gravity: ToastGravity.BOTTOM,
                      //     timeInSecForIosWeb: 1,
                      //     backgroundColor: gradientBottom,
                      //     textColor: Colors.white,
                      //     fontSize: 16.0);
                    }
                  } catch (e) {
                    print(e);
                    setState(() {
                      isLoading = false;
                      isUploaded = false;
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: theme.colorScheme.secondary,
                      size: 40,
                    ),
                    // SizedBox(width: 25,),
                    // Text("Open Camera",
                    //   style: TextStyle(
                    //       color: Colors.white,
                    //       fontFamily: "drawerbody",
                    //       fontStyle: FontStyle.italic
                    //   ),)
                  ],
                ),
              ),

              Container(
                height: 80,
                width: 0.5,
                color: theme.colorScheme.secondary,
              ),

              //gallery
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                    isUploaded = false;
                  });

                  try {
                    file = await Files.getFile().catchError((e) {
                      FirebaseFirestore.instance.collection("errorLogs").add({
                        "error": e,
                        "time": DateTime.now(),
                        "type": "readings"
                      });
                    });

                    if (file['file'].path.split(".").last == "jpeg" ||
                        file['file'].path.split(".").last == "jpg") {
                      if (file['file'] != null) {
                        print("------------------------------");
                        print(file['file'].path);
                        print("------------------------------");
                        croppedfile = await ImageCropper().cropImage(
                            sourcePath: file['file'].path,
                            aspectRatioPresets: [
                              CropAspectRatioPreset.square,
                              CropAspectRatioPreset.ratio3x2,
                              CropAspectRatioPreset.original,
                              CropAspectRatioPreset.ratio4x3,
                              CropAspectRatioPreset.ratio16x9
                            ],
                            androidUiSettings: AndroidUiSettings(
                                toolbarTitle: 'Image Cropper',
                                toolbarColor: theme.colorScheme.secondary,
                                toolbarWidgetColor: theme.colorScheme.primary,
                                initAspectRatio: CropAspectRatioPreset.original,
                                lockAspectRatio: false),
                            iosUiSettings: IOSUiSettings(
                              minimumAspectRatio: 1.0,
                            ));
                        if (croppedfile != null) {
                          await FlutterImageCompress.compressAndGetFile(
                            croppedfile.path,
                            file['file'].path,
                            quality: 50,
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                isLoading = false;
                                isUploaded = true;
                                pickedImage = value;
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              });
                            }
                          });
                        }
                      } else {
                        setState(() {
                          isLoading = false;
                          isUploaded = false;
                        });
                        ToastMessege("Image not uploaded", context: context);
                      }
                    } else {
                      setState(() {
                        isLoading = false;
                        isUploaded = false;
                      });
                      ToastMessege("Only .jpeg/.jpg formats allowed",
                          context: context);
                    }
                  } catch (e) {
                    print(e);
                    setState(() {
                      isLoading = false;
                      isUploaded = false;
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apps_rounded,
                      color: theme.colorScheme.secondary,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                      child: Text("Podcast",
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
              horizontal: MediaQuery.of(mainContext).size.width * 0.06) ,
              // + EdgeInsets.only(top: 50),
          child: Column(
            children: <Widget>[

              //app bar
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 10),
              //   child: Row(
              //     children: [
              //       GestureDetector(
              //         onTap: () {
              //           Navigator.pop(context);
              //         },
              //         child: Icon(
              //           Icons.arrow_back_ios,
              //         ),
              //       ),
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
              //             shape:
              //             MaterialStateProperty.all<RoundedRectangleBorder>(
              //                 RoundedRectangleBorder(
              //                   borderRadius: BorderRadius.circular(11.0),
              //                 )),
              //             backgroundColor: _tabController.index == 0
              //                 ? MaterialStateProperty.all(Colors.white)
              //                 : MaterialStateProperty.all(Colors.black),
              //             foregroundColor: _tabController.index == 0
              //                 ? MaterialStateProperty.all(Colors.black)
              //                 : MaterialStateProperty.all(Colors.white)),
              //         icon: Icon(Icons.add_photo_alternate_outlined),
              //         label: Text(
              //           "Album",
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

                                      // add a title
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
                                        controller: titleController,
                                        style: h2.copyWith(
                                          color:
                                          theme.colorScheme.inversePrimary,
                                        ),
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(15.0),
                                            ),
                                          ),
                                          filled: true,
                                          hintStyle: new TextStyle(
                                              color: Colors.grey[600]),
                                          hintText: "add a title",
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
                                            FocusScope.of(mainContext)
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
                                              isLoading
                                                  ?

                                              //progress indicator
                                              Container(
                                                height:
                                                MediaQuery.of(mainContext)
                                                    .size
                                                    .width -
                                                    60,
                                                width:
                                                MediaQuery.of(mainContext)
                                                    .size
                                                    .width -
                                                    60,
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme.primary,
                                                  borderRadius:
                                                  BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                  border: Border.all(
                                                      color: theme.colorScheme
                                                          .inversePrimary,
                                                      width: 1),
                                                ),
                                                child: Center(
                                                    child: AppLoading(
                                                      height: 30,
                                                      width: 30,
                                                    )
                                                  // CircularProgressIndicator(
                                                  //   color: GlobalColors.signUpSignInButton,
                                                  // ),
                                                ),
                                              )
                                                  : GestureDetector(
                                                onTap: () async {
                                                  showDialog(
                                                    context: mainContext,
                                                    builder: (context) {
                                                      return dialog;
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: 100,
                                                  // MediaQuery.of(
                                                  //     mainContext)
                                                  //     .size
                                                  //     .width -
                                                  //     52,
                                                  width: 100,
                                                  // MediaQuery.of(
                                                  //     mainContext)
                                                  //     .size
                                                  //     .width -
                                                  //     52,
                                                  child: isUploaded == false
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
                                                            color: theme
                                                                .colorScheme
                                                                .inversePrimary,
                                                          ),
                                                          // Text(image, style: TextStyle(color: Colors.white24),),
                                                        ],
                                                      ))
                                                      : ClipRRect(
                                                    borderRadius:
                                                    BorderRadius
                                                        .all(
                                                      Radius.circular(
                                                          10),
                                                    ),
                                                    child:
                                                    isNetworkImageAvailable ==
                                                        false
                                                        ? Image
                                                        .file(
                                                      pickedImage,
                                                      fit: BoxFit
                                                          .cover,
                                                    )
                                                        : Image
                                                        .network(
                                                      netImage,
                                                      fit: BoxFit
                                                          .cover,
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    borderRadius:
                                                    BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                    border: Border.all(
                                                        color: theme
                                                            .colorScheme
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
                                                maxLength: 250,
                                                style: h2.copyWith(
                                                  color:
                                                  theme.colorScheme.inversePrimary,
                                                ),
                                                maxLines: 4,
                                                decoration: InputDecoration(
                                                  counterText: "",
                                                  contentPadding: EdgeInsets.symmetric(
                                                      vertical: 12, horizontal: 15),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    const BorderRadius.all(
                                                      Radius.circular(15.0),
                                                    ),
                                                  ),
                                                  filled: true,
                                                  hintStyle: new TextStyle(
                                                      color: Colors.grey[600]),
                                                  hintText: "add a description",
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
                                                    FocusScope.of(mainContext)
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

                                      // add a description
                                      // TextField(
                                      //   controller: descriptionController,
                                      //   maxLength: 250,
                                      //   style: h2.copyWith(
                                      //     color:
                                      //     theme.colorScheme.inversePrimary,
                                      //   ),
                                      //   maxLines: 3,
                                      //   decoration: InputDecoration(
                                      //     contentPadding: EdgeInsets.symmetric(
                                      //         vertical: 10, horizontal: 15),
                                      //     border: OutlineInputBorder(
                                      //       borderRadius:
                                      //       const BorderRadius.all(
                                      //         Radius.circular(15.0),
                                      //       ),
                                      //     ),
                                      //     filled: true,
                                      //     hintStyle: new TextStyle(
                                      //         color: Colors.grey[600]),
                                      //     hintText: "add a description",
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
                                      //       FocusScope.of(mainContext)
                                      //           .nextFocus(),
                                      // ),
                                      // SizedBox(
                                      //   height: 15,
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
                                              vertical: 5,
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
                                      SizedBox(
                                        height: 30,
                                      ),


                                      //create button
                                      posting
                                          ? AppLoading(
                                        height: 70,
                                        width: 70,
                                      )
                                          :
                                      ElevatedButton(
                                        onPressed: () async {
                                          FocusManager
                                              .instance.primaryFocus
                                              ?.unfocus();
                                          if (!pickedImage.existsSync()) {
                                            ToastMessege("Image is required!", context: context);

                                          } else {
                                            if (titleController.text.isEmpty){
                                              ToastMessege("Title is required!", context: context);

                                            } else {
                                              if (descriptionController.text.isEmpty){
                                                ToastMessege("Description is required!", context: context);

                                              } else {
                                                setState(() {
                                                  posting = true;
                                                });
                                                createAlbum(context, auth.user!);
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
