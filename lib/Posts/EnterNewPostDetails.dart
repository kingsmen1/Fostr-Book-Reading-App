import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as us;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/providers/PostProvider.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:fostr/pages/user/Book.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/services/PostService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';

import '../providers/FeedProvider.dart';
import '../widgets/AppLoading.dart';

class EnterNewPostDetails extends StatefulWidget {
  final UserModel.User user;
  final String? bookname;
  final String? authorname;
  final String? description;
  final String? image;
  const EnterNewPostDetails({Key? key, required this.user,
    this.bookname = "",
    this.authorname = "",
    this.description = "",
    this.image = "",}) : super(key: key);

  @override
  _EnterNewPostDetailsState createState() => _EnterNewPostDetailsState();
}

class _EnterNewPostDetailsState extends State<EnterNewPostDetails>
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
  TextEditingController bookNameController = new TextEditingController();
  TextEditingController captionController = new TextEditingController();
  List<VolumeInfo> _items = [];
  List<ImageLinks> _imageItems = [];

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
        bookNameController.text = widget.bookname!;
      }
      if(widget.description!.isNotEmpty){
        captionController.text = widget.description!;
      }
    });
  }

  void _addBook(dynamic book) {
    setState(() {
      _items.add(
        VolumeInfo(
            book['publisher'],
            book['title'],
            book['publisher'],
            ImageLinks(book['image']),
            book['isbn13'],
            book['synopsys'],
            book['date_published'],
            book['authors'][0]),
      );
    });
  }

  void uploadPost(BuildContext context) async {
    String ref =
        "${widget.user.id}_${DateTime.now().toUtc().millisecondsSinceEpoch}";

    if(isNetworkImageAvailable){
      await FirebaseAuth.instance.currentUser!
          .getIdToken()
          .then((token) async {
        await PostService()
            .createPost(
            token,
            ref,
            bookNameController.text,
            widget.image!,
            captionController.text,
            widget.user.id,
            widget.user.userName,
            widget.user.userProfile!.profileImage ?? "")
            .then((value) async {
          if (value) {
            final postsProvider =
            Provider.of<PostsProvider>(context, listen: false);
            final feedsProvider =
            Provider.of<FeedProvider>(context, listen: false);
            feedsProvider.refreshFeed(true);
            await postsProvider.refreshPosts(true);
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserDashboard(
                          tab: "all",
                          refresh: true,
                          selectDay: DateTime.now()
                      )));
              posting = false;
              netImage = "";
              isNetworkImageAvailable = false;
              file.clear();
              croppedfile.delete();
              pickedImage.delete();
            });
            ToastMessege("Reading posted", context: context);
          } else {
            print("post failed");
          }
        });
      });
    } else {
      //storing image in storage
      await FirebaseStorage.instance
          .ref("posts/${widget.user.id}/$ref")
          .putFile(pickedImage)
          .then((p0) async {
        //getting image url
        await FirebaseStorage.instance
            .ref("posts/${widget.user.id}/$ref")
            .getDownloadURL()
            .then((value) async {
          //storing data in firestore

          await FirebaseAuth.instance.currentUser!
              .getIdToken()
              .then((token) async {
            await PostService()
                .createPost(
                token,
                ref,
                bookNameController.text,
                value,
                captionController.text,
                widget.user.id,
                widget.user.userName,
                widget.user.userProfile!.profileImage ?? "")
                .then((value) async {
              if (value) {
                final postsProvider =
                Provider.of<PostsProvider>(context, listen: false);
                final feedsProvider =
                Provider.of<FeedProvider>(context, listen: false);
                feedsProvider.refreshFeed(true);
                await postsProvider.refreshPosts(true);
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserDashboard(
                              tab: "all",
                              refresh: true,
                              selectDay: DateTime.now()
                          )));
                  posting = false;
                  file.clear();
                  croppedfile.delete();
                  pickedImage.delete();
                });
                ToastMessege("Reading posted", context: context);
              } else {
                print("post failed");
              }
            });
          });

        });
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    pickedImage.delete();
    super.dispose();
  }

  Dialog dialog = Dialog();

  bool isNetworkImageAvailable = false;
  String netImage = "";

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

                          // setState(() {
                          //   isLoading = false;
                          //   isUploaded = true;
                          //   pickedImage = croppedfile;
                          //   print("------------------------------");
                          //   print("picked file : ${pickedImage.path}");
                          //   print("------------------------------");
                          //   // file.clear();
                          //   // croppedfile.delete();
                          // });
                        }
                      } else {
                        setState(() {
                          isLoading = false;
                          isUploaded = false;
                        });
                        ToastMessege("Image not uploaded", context: context);
                        // Fluttertoast.showToast(
                        //     msg: "Image not uploaded",
                        //     toastLength: Toast.LENGTH_SHORT,
                        //     gravity: ToastGravity.BOTTOM,
                        //     timeInSecForIosWeb: 1,
                        //     backgroundColor: gradientBottom,
                        //     textColor: Colors.white,
                        //     fontSize: 16.0);
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
                      child: Text("Post",
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
                  horizontal: MediaQuery.of(mainContext).size.width * 0.06),
              // + EdgeInsets.only(top: 50),
          child: Column(
            children: <Widget>[
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 10),
              //   child: Row(
              //     children: [
              //       GestureDetector(
              //         onTap: () {
              //
              //           Navigator.pop(context);
              //
              //           // Navigator.push(
              //           //     mainContext,
              //           //     MaterialPageRoute(
              //           //         builder: (context) => UserDashboard(
              //           //             tab: "all", selectDay: DateTime.now())
              //           //     ));
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
              //                 MaterialStateProperty.all<RoundedRectangleBorder>(
              //                     RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(11.0),
              //             )),
              //             backgroundColor: _tabController.index == 0
              //                 ? MaterialStateProperty.all(Colors.white)
              //                 : MaterialStateProperty.all(Colors.black),
              //             foregroundColor: _tabController.index == 0
              //                 ? MaterialStateProperty.all(Colors.black)
              //                 : MaterialStateProperty.all(Colors.white)),
              //         icon: Icon(Icons.add_photo_alternate_outlined),
              //         label: Text(
              //           "Reading",
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


                                      //pick image
                                      // Row(
                                      //   mainAxisAlignment:
                                      //   MainAxisAlignment.center,
                                      //   children: [
                                      //     isLoading
                                      //         ?
                                      //
                                      //     //progress indicator
                                      //     Container(
                                      //       height:
                                      //       MediaQuery.of(mainContext)
                                      //           .size
                                      //           .width -
                                      //           60,
                                      //       width:
                                      //       MediaQuery.of(mainContext)
                                      //           .size
                                      //           .width -
                                      //           60,
                                      //       decoration: BoxDecoration(
                                      //         color: theme
                                      //             .colorScheme.primary,
                                      //         borderRadius:
                                      //         BorderRadius.all(
                                      //           Radius.circular(10),
                                      //         ),
                                      //         border: Border.all(
                                      //             color: theme.colorScheme
                                      //                 .inversePrimary,
                                      //             width: 1),
                                      //       ),
                                      //       child: Center(
                                      //           child: AppLoading(
                                      //             height: 70,
                                      //             width: 70,
                                      //           )
                                      //         // CircularProgressIndicator(
                                      //         //   color: GlobalColors.signUpSignInButton,
                                      //         // ),
                                      //       ),
                                      //     )
                                      //         : GestureDetector(
                                      //       onTap: () async {
                                      //         showDialog(
                                      //           context: mainContext,
                                      //           builder: (context) {
                                      //             return dialog;
                                      //           },
                                      //         );
                                      //       },
                                      //       child: Container(
                                      //         height: 100,
                                      //         // MediaQuery.of(
                                      //         //     mainContext)
                                      //         //     .size
                                      //         //     .width -
                                      //         //     52,
                                      //         width: 100,
                                      //           // MediaQuery.of(
                                      //           //   mainContext)
                                      //           //   .size
                                      //           //   .width -
                                      //           //   52,
                                      //         child: isUploaded == false
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
                                      //                   color: theme
                                      //                       .colorScheme
                                      //                       .inversePrimary,
                                      //                 ),
                                      //                 // Text(image, style: TextStyle(color: Colors.white24),),
                                      //               ],
                                      //             ))
                                      //             : ClipRRect(
                                      //           borderRadius:
                                      //           BorderRadius
                                      //               .all(
                                      //             Radius.circular(
                                      //                 10),
                                      //           ),
                                      //           child:
                                      //           isNetworkImageAvailable ==
                                      //               false
                                      //               ? Image
                                      //               .file(
                                      //             pickedImage,
                                      //             fit: BoxFit
                                      //                 .cover,
                                      //           )
                                      //               : Image
                                      //               .network(
                                      //             netImage,
                                      //             fit: BoxFit
                                      //                 .cover,
                                      //           ),
                                      //         ),
                                      //         decoration: BoxDecoration(
                                      //           color: theme
                                      //               .colorScheme.primary,
                                      //           borderRadius:
                                      //           BorderRadius.all(
                                      //             Radius.circular(10),
                                      //           ),
                                      //           border: Border.all(
                                      //               color: theme
                                      //                   .colorScheme
                                      //                   .inversePrimary,
                                      //               width: 0.5),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // SizedBox(
                                      //   height: 15,
                                      // ),

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
                                        controller:
                                        bookNameController,
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
                                          hintText: "Book name/Title",
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

                                      //add a caption
                                      // TextField(
                                      //   controller: captionController,
                                      //   style: h2.copyWith(
                                      //     color:
                                      //         theme.colorScheme.inversePrimary,
                                      //   ),
                                      //   maxLines: 3,
                                      //   decoration: InputDecoration(
                                      //     contentPadding: EdgeInsets.symmetric(
                                      //         vertical: 10, horizontal: 15),
                                      //     border: OutlineInputBorder(
                                      //       borderRadius:
                                      //           const BorderRadius.all(
                                      //         Radius.circular(15.0),
                                      //       ),
                                      //     ),
                                      //     filled: true,
                                      //     hintStyle: new TextStyle(
                                      //         color: Colors.grey[600]),
                                      //     hintText: "add a caption",
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
                                                      height: 70,
                                                      width: 70,
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
                                                  //   mainContext)
                                                  //   .size
                                                  //   .width -
                                                  //   52,
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
                                                controller: captionController,
                                                style: h2.copyWith(
                                                  color:
                                                  theme.colorScheme.inversePrimary,
                                                ),
                                                maxLines: 4,
                                                decoration: InputDecoration(
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
                                                  hintText: "add a caption",
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

                                      //post button
                                      SizedBox(
                                        height: 15,
                                      ),
                                      posting
                                          ? AppLoading(
                                              height: 70,
                                              width: 70,
                                            )
                                          :
                                          // CircularProgressIndicator(color: GlobalColors.signUpSignInButton) :
                                          ElevatedButton(
                                              onPressed: () async {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                if (!pickedImage.existsSync() && !isNetworkImageAvailable) {
                                                  ToastMessege(
                                                      "Image is required!",
                                                      context: context);
                                                } else {
                                                  if(bookNameController.text.isEmpty){
                                                    ToastMessege("Please enter a title.", context: context);
                                                  } else {
                                                    setState(() {
                                                      posting = true;
                                                    });
                                                    uploadPost(context);
                                                    user.points = user.points + 5;
                                                    final cUser = us.FirebaseAuth
                                                        .instance.currentUser;
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
                                                            "create_post",
                                                            "dateTime": DateTime
                                                                .now()
                                                                .toUtc()
                                                                .toIso8601String(),
                                                            "points": 1,
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
                                                      if (response.statusCode ==
                                                          200) {
                                                        final postsProvider =
                                                        Provider.of<
                                                            PostsProvider>(
                                                            context,
                                                            listen: false);

                                                        await postsProvider
                                                            .refreshPosts(true);
                                                      } else {
                                                        print('API Failed');
                                                      }
                                                      // user.rewardcountforreview = user.rewardcountforreview - 1;
                                                      // _userService.updateUserField({"id": user.id, "rewardcountforreview": user.rewardcountforreview});
                                                    }
                                                    else {
                                                      ToastMessege('You have availed the maximum rewards for posts', context: context);
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
