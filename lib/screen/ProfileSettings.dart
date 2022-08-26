import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/models/UserModel/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/services/StorageService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final settingForm = GlobalKey<FormState>();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _aboutController = new TextEditingController();
  TextEditingController _linkController = new TextEditingController();
  TextEditingController _tellMoreController = new TextEditingController();

  bool isExists = false;

  List<dynamic> addGenres = [];
  List<dynamic> fetchGenres = [];

  var user;
  int len = 1;

  UserService userServices = GetIt.I<UserService>();

  Future<void> showPopUp(String field, String uid, Function cb,
      {String? value, int? maxLine}) {
    return displayTextInputDialog(context, field,
            maxLine: maxLine, value: value)
        .then((shouldUpdate) {
      if (shouldUpdate[0]) {
        cb(shouldUpdate);
      }
    });
  }

  void updateProfile(Map<String, dynamic> data) async {
    await userServices.updateUserField(data);
  }

  Future<List<dynamic>> fetchFields(User? user) async {
    var doc =
        FirebaseFirestore.instance.collection("users").doc(user!.id).get();
    List<dynamic> list;
    return doc.then((value) {
      list = value.data()?['userProfile']?["genres"];
      print(list);

      addGenres = list;

      return list;
    });
  }

  void getProfile(User user) async {
    user = (await userServices.getUserById(user.id))!;
  }

  void addFieldInProfile(String fieldName, String fielValue, User user) {
    final _userCollection = FirebaseFirestore.instance.collection("users");
    _userCollection.doc(user.id).set({
      "userProfile": {fieldName: fielValue}
    }, SetOptions(merge: true));
  }

  void addGenresToDB(String fieldName, List<dynamic> list, User user) {
    final _userCollection = FirebaseFirestore.instance.collection("users");
    _userCollection.doc(user.id).set({
      "userProfile": {fieldName: list}
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      var doc = FirebaseFirestore.instance
          .collection("users")
          .doc(auth.user?.id)
          .get();
      doc.then((value) => {
            auth.user?.name = value.data()?['name'],
            auth.user?.userProfile?.bio = value.data()?['userProfile']['bio'],
            auth.user?.userProfile?.description =
                value.data()?['userProfile']['description'],
            auth.user?.userName = value.data()?['userName']
          });
      if (auth.userType == UserType.CLUBOWNER) {
        _nameController.value =
            TextEditingValue(text: auth.user?.bookClubName ?? "");
      } else {
        _nameController.value = TextEditingValue(text: auth.user?.name ?? "");
      }

      _usernameController.value =
          TextEditingValue(text: auth.user?.userName ?? "");
      _aboutController.value =
          TextEditingValue(text: auth.user?.userProfile?.bio ?? "");
      _tellMoreController.value =
          TextEditingValue(text: auth.user?.userProfile?.description ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: theme.colorScheme.primary,
          resizeToAvoidBottomInset: true,
          body: Form(
            key: settingForm,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                              )),
                          Text(
                            "Profile Settings",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: theme.colorScheme.inversePrimary
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                if (settingForm.currentState!.validate()) {
                                  settingForm.currentState!.save();
                                  user.userName = _usernameController.text;
                                  user.name = _nameController.text;
                                  if (user.userProfile == null) {
                                    var userProfile = UserProfile();
                                    userProfile.bio = _aboutController.text;
                                    userProfile.description =
                                        _tellMoreController.text;
                                    user.userProfile = userProfile;
                                  } else {
                                    user.userProfile?.bio =
                                        _aboutController.text;
                                    user.userProfile?.description =
                                        _tellMoreController.text;
                                  }

                                  updateProfile({
                                    "userProfile.bio":
                                        _aboutController.text == ""
                                            ? null
                                            : _aboutController.text,
                                    "userProfile.description":
                                        _tellMoreController.text == ""
                                            ? null
                                            : _tellMoreController.text,
                                    "userName": _usernameController.text,
                                    "toLowerUserName":
                                        _usernameController.text.toLowerCase(),
                                    "name": _nameController.text,
                                    "id": user.id,
                                  });
                                  auth.refreshUser(user);
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: Icon(
                                Icons.check,
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          try {
                            final file = await Files.getFile();
                            final url = await Storage.saveFile(file, user.id);
                            setState(() {
                              if (user.userProfile == null) {
                                var userProfile = UserProfile();
                                userProfile.profileImage = url;
                                user.userProfile = userProfile;
                              } else {
                                user.userProfile?.profileImage = url;
                              }
                              // addFieldInProfile("profileImage", url,user);
                              updateProfile({
                                "userProfile.profileImage": url,
                                "id": user.id
                              });
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: RoundedImage(
                          width: 80,
                          height: 80,
                          borderRadius: 35,
                          url: user.userProfile?.profileImage,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Text(
                        "Name",
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: theme.colorScheme.inversePrimary),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 6, bottom: 9, left: 20, right: 20),
                      child: TextFormField(
                        controller: _nameController,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'drawerbody',
                            color: theme.colorScheme.inversePrimary
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter full name' : null,
                        decoration: registerInputDecoration.copyWith(
                            hintText: "Enter name",
                            hintStyle: TextStyle(
                              fontFamily: 'drawerbody',
                                color: theme.colorScheme.inversePrimary
                            ),
                            fillColor: theme.inputDecorationTheme.fillColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Text(
                        "Username",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 6, bottom: 9, left: 20, right: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Username";
                          }
                          if (value.isNotEmpty) {
                            if (!Validator.isUsername(value)) {
                              return "Username is not valid";
                            }
                            if (isExists) {
                              return "Username already exists";
                            }
                          }
                          return null;
                        },
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: theme.colorScheme.inversePrimary),
                        onChanged: (value) {
                          checkUsername();
                        },
                        controller: _usernameController,
                        maxLines: 1,
                        decoration: registerInputDecoration.copyWith(
                            hintText: "Enter Username",
                            hintStyle: TextStyle(fontFamily: 'drawerbody',
                                color: theme.colorScheme.inversePrimary),
                            fillColor: theme.inputDecorationTheme.fillColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Text(
                        "About",
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: theme.colorScheme.inversePrimary),
                      ),
                    ),
                    buildField(
                      "Bio",
                      _aboutController,
                      theme,
                      isAbout: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Text(
                        "Tell more about yourself",
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: theme.colorScheme.inversePrimary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 20),
                      child: Container(
                        child: TextFormField(
                          controller: _tellMoreController,
                          maxLines: null,
                          style: TextStyle(fontFamily: "drawerbody"),
                          decoration: registerInputDecoration.copyWith(
                              hintText: "Tell more about yourself",
                              hintStyle: TextStyle(fontFamily: "drawerbody",
                                  color: theme.colorScheme.inversePrimary),
                              fillColor: theme.inputDecorationTheme.fillColor),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 28.0, top: 14.0, right: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  _linkController.text =
                                      "@${user.userProfile?.instagram ?? ""}";
                                  await showPopUp(
                                    "Instagram",
                                    user.id,
                                    (e) {
                                      setState(() {
                                        String? link = e[1] as String;
                                        // if (link[0] == '@') {
                                        //   link = link.substring(1);
                                        // }

                                        if (_linkController.text.isNotEmpty &&
                                            _linkController.text[0] == '@' &&
                                            _linkController.text.length > 1) {
                                          link =
                                              _linkController.text.substring(1);
                                        } else {
                                          link = null;
                                        }

                                        if (user.userProfile == null) {
                                          var userProfile = UserProfile();
                                          userProfile.instagram = link;
                                          user.userProfile = userProfile;
                                        } else {
                                          user.userProfile?.instagram = link;
                                        }
                                        updateProfile({
                                          "userProfile.instagram": link,
                                          "id": user.id
                                        });
                                      });
                                    },
                                    value:
                                        "@${user.userProfile?.instagram ?? ""}",
                                  );
                                },
                                child: SvgPicture.asset(
                                  "assets/icons/instagram.svg",
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                ),
                              ),
                              Text(
                                user.userProfile?.instagram == null
                                    ? "Not Connected"
                                    : "Connected",
                                style: TextStyle(
                                    color: GlobalColors.highlightedText),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  _linkController.text =
                                      "@${user.userProfile?.twitter ?? ""}";
                                  await showPopUp(
                                    "Twitter",
                                    user.id,
                                    (e) {
                                      setState(() {
                                        String? link = e[1] as String;
                                        // if (link[0] == '@') {
                                        //   link = link.substring(1);
                                        // }

                                        if (_linkController.text.isNotEmpty &&
                                            _linkController.text[0] == '@' &&
                                            _linkController.text.length > 1) {
                                          link =
                                              _linkController.text.substring(1);
                                        } else {
                                          link = null;
                                        }
                                        if (user.userProfile == null) {
                                          var userProfile = UserProfile();
                                          userProfile.twitter = link;
                                          user.userProfile = userProfile;
                                        } else {
                                          user.userProfile?.twitter = link;
                                        }
                                        updateProfile({
                                          "userProfile.twitter": link,
                                          "id": user.id
                                        });
                                      });
                                    },
                                    value:
                                        "@${user.userProfile?.twitter ?? ""}",
                                  );
                                },
                                child: SvgPicture.asset(
                                  "assets/icons/twitter.svg",
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                ),
                              ),
                              Text(
                                user.userProfile?.twitter == null
                                    ? "Not Connected"
                                    : "Connected",
                                style: TextStyle(
                                    color: GlobalColors.highlightedText),
                              )
                            ],
                          ),
                          // ),Column(
                          //   children: <Widget>[
                          //     InkWell(
                          //       onTap:() async {
                          //         _linkController.text = "@${user.userProfile?.facebook ?? ""}";
                          //         await showPopUp(
                          //           "Instagram",
                          //           user.id,
                          //               (e) {
                          //             setState(() {
                          //               var link = e[1] as String;
                          //               if (link[0] == '@') {
                          //                 link = link.substring(1);
                          //               }
                          //               if (user.userProfile == null) {
                          //                 var userProfile = UserProfile();
                          //                 userProfile.facebook = link;
                          //                 user.userProfile = userProfile;
                          //               } else {
                          //                 user.userProfile?.facebook = link;
                          //               }
                          //               updateProfile({
                          //                 "userProfile":
                          //                 user.userProfile?.toJson(),
                          //                 "id": user.id
                          //               });
                          //             });
                          //           },
                          //           value:
                          //           "@${user.userProfile?.facebook ?? ""}",
                          //         );
                          //       },
                          //       child: SvgPicture.asset(
                          //         "assets/icons/facebook.svg",
                          //         height: MediaQuery.of(context).size.height*0.1,
                          //       )
                          //     ),
                          //     Text(
                          //       user.userProfile?.facebook == null ? " ":"Connected",
                          //       style: TextStyle(
                          //           color: GlobalColors.highlightedText
                          //       ),
                          //     )
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkUsername({String? value}) async {
    setState(() {
      isExists = false;
    });
    if (_usernameController.text.isNotEmpty) {
      var isExists = await userServices
          .checkUserName(_usernameController.text.trim().toLowerCase());
      setState(() {
        this.isExists = isExists;
      });
    }
    if (settingForm.currentState!.validate()) {
      setState(() {
        isExists = false;
      });
    }
  }

  Future displayTextInputDialog(BuildContext context, String field,
      {String? value, int? maxLine}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        final size = MediaQuery.of(context).size;
        return Container(
          height: size.height,
          width: size.width,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Align(
              alignment: Alignment(0, -0.5),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: size.width * 0.9,
                  constraints: BoxConstraints(
                    maxHeight: (maxLine != null && maxLine > 4) ? 380 : 240,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter your $field',
                        style: TextStyle(
                        color: Colors.white),
                      ),
                      SizedBox(
                          height: (maxLine != null && maxLine > 4) ? 180 : 60,
                          child:
                              buildField("Enter link", _linkController, theme)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop([false]);
                            },
                            child: Text(
                              "CANCEL",
                              style: TextStyle(
                                  color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop([true, value]);
                            },
                            child: Text(
                              "UPDATE",
                              style: TextStyle(
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle buildButtonStyle(Color color) {
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0),
        )));
  }

  Widget buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: GlobalColors.profilePageHeading),
      ),
    );
  }

  Widget buildField(
      String text, TextEditingController controller, ThemeData theme,
      {bool isAbout = false}) {
    return Container(
      margin: EdgeInsets.only(top: 6, bottom: 9, left: 20, right: 20),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontFamily: "drawerbody"),
        maxLines: isAbout ? 5 : 1,
        decoration: registerInputDecoration.copyWith(
            hintText: text,
            hintStyle: TextStyle(fontFamily: "drawerbody", fontSize: 16),
            fillColor: theme.inputDecorationTheme.fillColor),
      ),
    );
  }
}
