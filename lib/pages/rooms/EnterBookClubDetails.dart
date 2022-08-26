import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as us;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/pages/user/AllBookClubs.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/BookClubServices.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/services/StorageService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../widgets/AppLoading.dart';

class EnterBookClubDetails extends StatefulWidget {
  const EnterBookClubDetails({Key? key}) : super(key: key);

  @override
  _EnterBookClubDetailsState createState() => _EnterBookClubDetailsState();
}

class _EnterBookClubDetailsState extends State<EnterBookClubDetails>
    with FostrTheme, TickerProviderStateMixin {
  Timestamp time = Timestamp.now();
  String image = "Add a Image (378x 224)", imageUrl = "";
  bool isLoading = false,
      scheduling = false,
      isUploaded = false,
      isUploadedAd = false;

  final BookClubServices _bookClubServices = GetIt.I.get<BookClubServices>();

  late TabController _tabController =
      new TabController(vsync: this, length: 1, initialIndex: 0);
  TextEditingController bookClubNameTextEditingController =
      new TextEditingController();
  TextEditingController bookClubBioTextEditingController =
      new TextEditingController();
  bool created = false;
  bool navigateToAllBookCLubs = false;
  List bnames = [];

  void bookClubNames(String username) async {
    await FirebaseFirestore.instance
        .collection("bookclubs")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (username == element.get('createdBy') && element.get('isActive')) {
          bnames.add(element.get('bookclubName'));
          print(bnames);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    bnames.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    bookClubNames(user.userName);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: theme.colorScheme.primary,
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
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                        ),
                      ),
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
                    //bookClub
                    Container(
                      height: 45,
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(0),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => {
                          setState(() => {_tabController.animateTo(1)})
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11.0),
                            )),
                            backgroundColor: _tabController.index == 0
                                ? MaterialStateProperty.all(Colors.white)
                                : MaterialStateProperty.all(Colors.black),
                            foregroundColor: _tabController.index == 0
                                ? MaterialStateProperty.all(Colors.black)
                                : MaterialStateProperty.all(Colors.white)),
                        icon: Icon(
                          Icons.menu_book_rounded,
                          color: Colors.black,
                        ),
                        label: Text(
                          "Book Club",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      //bookclub
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
                                        //bookclub name
                                        TextField(
                                          controller:
                                              bookClubNameTextEditingController,
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
                                            fillColor: theme
                                                .inputDecorationTheme.fillColor,
                                            hintStyle: new TextStyle(
                                                color: Colors.grey[600]),
                                            hintText: "Book Club Name",
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
                                                  color: theme.colorScheme
                                                      .inversePrimary),
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

                                        //book club bio
                                        TextField(
                                          controller:
                                              bookClubBioTextEditingController,
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
                                            fillColor: theme
                                                .inputDecorationTheme.fillColor,
                                            hintStyle: new TextStyle(
                                                color: Colors.grey[600]),
                                            hintText: "Book Club Bio",
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
                                                  color: theme.colorScheme
                                                      .inversePrimary),
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

                                        //book club profile image
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
                                                        if (bookClubNameTextEditingController
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
                                                                          .saveBookClubImage({
                                                                    "file":
                                                                        croppedFile,
                                                                    "ext": file[
                                                                        "ext"]
                                                                  }, basename(bookClubNameTextEditingController.text));
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
                                                              //     fontSize: 16.0);
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
                                                              "Book Club Name is required!",
                                                              context: context);
                                                          // Fluttertoast.showToast(
                                                          //     msg:
                                                          //         "Book Club Name is required!",
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
                                                                child: FosterImage(
                                                                    imageUrl:
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

                                  //create button
                                  scheduling
                                      ? AppLoading(
                                          height: 70,
                                          width: 70,
                                        )
                                      :
                                      // CircularProgressIndicator(color: GlobalColors.signUpSignInButton,) :
                                      ElevatedButton(
                                          onPressed: () async {
                                            if (bookClubNameTextEditingController
                                                .text.isEmpty) {
                                              ToastMessege(
                                                  "Book Club name is required!",
                                                  context: context);
                                            } else {
                                              setState(() {
                                                scheduling = true;
                                              });

                                              if (auth.firebaseUser != null) {
                                                final token = await auth
                                                    .firebaseUser!
                                                    .getIdToken();

                                                //create bookclub function
                                                BookClubModel bookClub =
                                                    BookClubModel(
                                                  followers: [],
                                                  followings: [],
                                                  members: [],
                                                  pendingMembers: [],
                                                  adminAccounts: 1,
                                                  adminUsers: [auth.user!.id],
                                                  bookClubName:
                                                      bookClubNameTextEditingController
                                                          .text,
                                                  createdBy: auth.user!.id,
                                                  createdOn: DateTime.now(),
                                                  genres: [],
                                                  id: "",
                                                  isActive: true,
                                                  isInviteOnly: false,
                                                  membersCount: 0,
                                                  roomsCount: 0,
                                                  adminProfile: auth
                                                      .user
                                                      ?.userProfile
                                                      ?.profileImage,
                                                  bookClubBio:
                                                      bookClubBioTextEditingController
                                                          .text,
                                                  bookClubProfile: imageUrl,
                                                );

                                                await _bookClubServices
                                                    .createBookClub(
                                                        bookClub, token);
                                                Navigator.of(context).pop();
                                              } else {
                                                ToastMessege(
                                                    "Please login to create a book club",
                                                    context: context);
                                              }
                                              //break;
                                            }
                                            //}
                                            setState(() {
                                              scheduling = false;
                                            });
                                          },
                                          child: Text(
                                            "Create Now",
                                            style:
                                                TextStyle(color: Colors.white),
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
      ),
    );
  }
}
