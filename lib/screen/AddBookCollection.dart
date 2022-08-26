import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddBookCollection extends StatefulWidget {
  final String title;
  const AddBookCollection({
    Key? key,
    required this.title
  }) : super(key: key);

  @override
  State<AddBookCollection> createState() => _AddBookCollectionState();
}

class _AddBookCollectionState extends State<AddBookCollection> with FostrTheme{

  bool isLoading = false;
  bool isUploaded = false;
  bool posting = false;
  String image = "Add a Image (378x 375)", imageUrl = "";
  var file;
  var croppedfile;
  File pickedImage = File("/file.jpg");

  TextEditingController bookNameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController authorController = new TextEditingController();
  TextEditingController linkController = new TextEditingController();

  Dialog dialog = Dialog();
  bool isNetworkImageAvailable = false;
  String netImage = "";

  void uploadData(String authId) async {
    String ref = "${bookNameController.text}_${DateTime.now().millisecondsSinceEpoch}";

    //storing image in storage
    await FirebaseStorage.instance
        .ref("books/$ref")
        .putFile(pickedImage)
    .then((p0) async {
      await FirebaseStorage.instance
          .ref("books/$ref")
          .getDownloadURL()
          .then((value) async {
        await FirebaseFirestore.instance
            .collection("booksearch")
            .doc(bookNameController.text.toLowerCase().trim())
            .set({
          "book_title" : bookNameController.text.toLowerCase().trim(),
          "author" : [authorController.text],
          "description" : descriptionController.text,
          "dateTime" : DateTime.now(),
          "url" : linkController.text,
          "image" : value,
          "addedBy" : authId
        },SetOptions(merge: true)).then((value){
          setState(() {
             isLoading = false;
             isUploaded = false;
             posting = false;
          });
          pickedImage.delete();
          Navigator.pop(context);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
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
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Text("Add Book",
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'drawerbody'
          ),),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios,)
        ),
        actions: [
          Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.contain,
            width: 40,
            height: 40,
          )
        ],
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(20),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [

              //pick image
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  isLoading
                      ?

                  //progress indicator
                  Container(
                    height:
                    MediaQuery.of(context)
                        .size
                        .width -
                        60,
                    width:
                    MediaQuery.of(context)
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
                        context: context,
                        builder: (context) {
                          return dialog;
                        },
                      );
                    },
                    child: Container(
                      height: MediaQuery.of(
                          context)
                          .size
                          .width -
                          52,
                      width: MediaQuery.of(
                          context)
                          .size
                          .width -
                          52,
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
                                size: 83,
                                color: Colors.grey,
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
                height: 15,
              ),

              //book name
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
                  hintText: "Book name/title",
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
                height: 15,
              ),

              //book author
              TextField(
                controller:
                authorController,
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
                height: 15,
              ),

              //book link
              TextField(
                controller:
                linkController,
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
                  hintText: "Book link",
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
                height: 15,
              ),

              //Add book description
              TextField(
                controller: descriptionController,
                style: h2.copyWith(
                  color:
                  theme.colorScheme.inversePrimary,
                ),
                maxLines: 4,
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
                  hintText: "Add book description",
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

              //post button
              posting
                  ? AppLoading(
                height: 70,
                width: 70,
              )
                  : ElevatedButton(
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
                      if(authorController.text.isEmpty){
                        ToastMessege("Please enter author name.", context: context);
                      } else {
                        if(descriptionController.text.isEmpty){
                          ToastMessege("Please enter a description.", context: context);
                        } else {
                          setState(() {
                            posting = true;
                          });
                          uploadData(auth.user!.id);
                        }
                      }
                    }
                  }
                },
                child: Text(
                  "  Add Book  ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty
                      .all<EdgeInsets>(
                      EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10)),
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
      ),

    );
  }
}
