import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/TopReads.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/models/UserModel/UserProfile.dart';
import 'package:fostr/pages/bookClub/dashboard.dart';
import 'package:fostr/pages/user/SearchBook.dart';
import 'package:fostr/pages/user/SelectProfileGenre.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/screen/Eula.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/services/StorageService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:username_gen/username_gen.dart';

class AddDetails extends StatefulWidget {
  const AddDetails({Key? key}) : super(key: key);

  @override
  _AddDetailsState createState() => _AddDetailsState();
}

class _AddDetailsState extends State<AddDetails> with FostrTheme {
  final UserService _userService = GetIt.I<UserService>();

  final nameForm = GlobalKey<FormState>();
  final passwordForm = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController(text: "");
  final double profileHeight = 144;
  bool isExists = false;

  UserService userServices = GetIt.I<UserService>();

  void updateProfile(Map<String, dynamic> data) async {
    await userServices.updateUserField(data);
  }

  User user = User.fromJson({
    "toLowerUserName": "",
    "name": "",
    "userName": "",
    "id": "",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
    // "bookClubName": ""
  });

  List topReads = [];

  var name = UsernameGen().generate();
  var username = UsernameGen().generate();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userType == UserType.CLUBOWNER) {
        nameController.value = TextEditingValue(text: name);
            // TextEditingValue(text: auth.user?.bookClubName ?? "");
      } else {
        nameController.value = TextEditingValue(text: name);
            // TextEditingValue(text: auth.user?.name ?? "");
      }
      usernameController.value =TextEditingValue(text: username);
          // TextEditingValue(text: auth.user?.userName ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.user != null) {
      user = auth.user!;
    }
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: theme.colorScheme.primary,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: nameForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                              )),
                          IconButton(
                            onPressed: () async {
                              await checkUsername();
                              if (nameForm.currentState!.validate()) {
                                var user = auth.user!;
                                var newUser;
                                var userJson = user.toJson();
                                if (user.createdOn == user.lastLogin) {
                                  userJson["toLowerUserName"] =
                                      usernameController.text
                                          .toLowerCase()
                                          .trim();
                                  userJson["userName"] =
                                      usernameController.text.trim();
                                  userJson["userProfile"] =
                                      user.userProfile?.toJson();
                                  newUser = User.fromJson(userJson);
                                } else {
                                  newUser = user;
                                  log("hello");
                                }
                                if (auth.userType == UserType.CLUBOWNER) {
                                  newUser.bookClubName =
                                      nameController.text.trim();
                                  newUser.toLowerBookClubName =
                                      nameController.text.trim().toLowerCase();
                                } else {
                                  newUser.name = nameController.text.trim();
                                  newUser.toLowerName =
                                      nameController.text.trim().toLowerCase();
                                }
                                newUser.userProfile =
                                    auth.addUserDetails(newUser).then((value) {
                                  if (auth.userType == UserType.USER) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)
                                     =>EULA(userid: auth.user!.id,isOnboarding: true,)
                                    ));
                                    // FostrRouter.removeUntillAndGoto(context,
                                    //     Routes.userDashboard, (route) => false);
                                  } else if (auth.userType ==
                                      UserType.CLUBOWNER) {
                                    FostrRouter.goto(
                                      context,
                                      Routes.allBookClubs,
                                    );
                                  }
                                  updateProfile({
                                    // "userProfile": user.userProfile?.toJson(),
                                    "userProfile.bio": bioController.text,
                                    "userName": usernameController.text,
                                    "toLowerUserName":
                                        usernameController.text.toLowerCase(),
                                    "name": nameController.text,
                                    "id": user.id,
                                    "userProfile.topRead": topReads,
                                    "points": 20,
                                    "rewardcountforbookclub": 1,
                                    "rewardcountfordailycheckin": 100,
                                    "rewardcountforpost": 5,
                                    "rewardcountforreferral": 5,
                                    "rewardcountforreview": 5,
                                    "rewardcountforroom": 5,
                                    "rewardcountfortheatre": 5,
                                  });
                                }).catchError((e) {
                                  print(e);
                                });
                              }
                            },
                            icon: Icon(
                              Icons.check,
                            ),
                          )
                        ],
                      ),
                    ),

                    //image
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Set up your profile",
                              style: TextStyle(
                                fontSize: 20,
                              )),
                        ],
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          width: 100,
                          height: 100,
                          child: InkWell(
                            onTap: () async {
                              final file = await Files.getFile();

                              final url = await Storage.saveFile(file, user.id);
                              setState(() {
                                if (user.userProfile == null) {
                                  var userProfile = UserProfile();
                                  userProfile.profileImage = url;
                                  user.userProfile = userProfile;
                                } else {
                                  user.userProfile!.profileImage = url;
                                }
                                updateProfile({
                                  "userProfile.profileImage": url,
                                  "id": user.id
                                });
                              });
                            },
                            child: Stack(
                              children: [
                                RoundedImage(
                                  width: 100,
                                  height: 100,
                                  borderRadius: 35,
                                  url: user.userProfile?.profileImage,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 20,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    //username
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Row(
                        children: [
                          Text(
                            "Username",
                          ),
                          Text(
                            "(Please edit your username)",
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Container(
                        child: TextFormField(
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                          style: h2.copyWith(
                            color: theme.colorScheme.inversePrimary,
                          ),
                          onChanged: (value) => checkUsername(),
                          controller: usernameController,
                          validator: (value) {
                            if (value!.isNotEmpty) {
                              if (!Validator.isUsername(value)) {
                                return "Username is not valid";
                              }
                              if (isExists) {
                                return "Username already exists";
                              }
                            } else {
                              return "Enter a user name";
                            }
                          },
                          decoration: registerInputDecoration.copyWith(
                              hintText: 'Enter Username',
                              fillColor: theme.inputDecorationTheme.fillColor),
                        ),
                      ),
                    ),

                    //name
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Text(
                        "Name",
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 15),
                      child: Container(
                        child: TextFormField(
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                          style: h2.copyWith(
                            color: theme.colorScheme.inversePrimary,
                          ),
                          controller: nameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              if (auth.userType == UserType.CLUBOWNER) {
                                return "Enter a Book Club name";
                              } else {
                                return "Enter a name";
                              }
                            }
                          },
                          decoration: registerInputDecoration.copyWith(
                              hintText: 'Enter Full name',
                              fillColor: theme.inputDecorationTheme.fillColor),
                        ),
                      ),
                    ),

                    //bio
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Text(
                        "Bio",
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 15),
                      child: Container(
                        child: TextFormField(
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                          style: h2.copyWith(
                            color: theme.colorScheme.inversePrimary,
                          ),
                          controller: bioController,
                          decoration: registerInputDecoration.copyWith(
                              hintText: 'Enter bio',
                              fillColor: theme.inputDecorationTheme.fillColor),
                        ),
                      ),
                    ),

                    //top 5 reads
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20),
                      child: Row(
                        children: [
                          Text("Favourite Reads",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat')),
                          IconButton(
                            icon: Icon(Icons.search),
                            iconSize: 14,
                            onPressed: () {
                              var doc = FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user.id)
                                  .get();
                              List list = [];
                              doc.then((value) {
                                if (value.data()?['userProfile']?["topRead"] !=
                                    null)
                                  list =
                                      value.data()?['userProfile']?["topRead"];
                                print(list.length);
                                if (list.length == 5) {
                                  ToastMessege("Can add only 5 books",
                                      context: context);
                                  // Fluttertoast.showToast(
                                  //     msg: "Can add only 5 books",
                                  //     toastLength: Toast.LENGTH_SHORT,
                                  //     gravity: ToastGravity.BOTTOM,
                                  //     timeInSecForIosWeb: 1,
                                  //     backgroundColor: gradientBottom,
                                  //     textColor: Colors.white,
                                  //     fontSize: 16.0);
                                } else {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => SearchBook(),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10.0, left: 15, right: 15),
                      child: buildGenreTab(),
                    ),

                    //genres
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 20),
                      child: Row(
                        children: [
                          Text("Favourite Genres",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat')),
                          IconButton(
                            icon: Icon(Icons.search),
                            // FaIcon(FontAwesomeIcons.edit),

                            iconSize: 14,
                            onPressed: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => SelectProfileGenre(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user.id)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError)
                                  return new Text('Error: ${snapshot.error}');
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return new Text('Loading...');
                                  default:
                                    var topReadList = snapshot
                                        .data?['userProfile']?['genres'];
                                    // print(topReadList.isEmpty);
                                    return topReadList != null
                                        ? new ListView(
                                            //shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            children: List.generate(
                                                snapshot
                                                    .data!['userProfile']
                                                        ['genres']
                                                    .length, (index) {
                                              return Container(
                                                child: Column(children: [
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10, left: 10),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      decoration: BoxDecoration(
                                                          // color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: FittedBox(
                                                        fit: BoxFit.fill,
                                                        child: (snapshot.data!['userProfile']
                                                                        ['genres']
                                                                    [index] ==
                                                                "Action and Adventure")
                                                            ? Image.asset(
                                                                "assets/images/Genre_A&A.png")
                                                            : (snapshot.data!['userProfile']
                                                                            ['genres']
                                                                        [
                                                                        index] ==
                                                                    "Biographies and Autobiographies")
                                                                ? Image.asset(
                                                                    "assets/images/Genre_B&A.png")
                                                                : (snapshot.data!['userProfile']['genres'][index] ==
                                                                        "Classics")
                                                                    ? Image.asset(
                                                                        "assets/images/Genre_Classics.png")
                                                                    : (snapshot.data!['userProfile']['genres'][index] ==
                                                                            "Comic Book")
                                                                        ? Image.asset("assets/images/Genre_Comic.png")
                                                                        : (snapshot.data!['userProfile']['genres'][index] == "Cookbooks")
                                                                            ? Image.asset("assets/images/Genre_Cooking.png")
                                                                            : (snapshot.data!['userProfile']['genres'][index] == "Detective and Mystery")
                                                                                ? Image.asset("assets/images/Genre_D&M.png")
                                                                                : (snapshot.data!['userProfile']['genres'][index] == "Essays")
                                                                                    ? Image.asset("assets/images/Genre_Essay.png")
                                                                                    : (snapshot.data!['userProfile']['genres'][index] == "Fantasy")
                                                                                        ? Image.asset("assets/images/Genre_Fantasy.png")
                                                                                        : (snapshot.data!['userProfile']['genres'][index] == "Historical Fiction")
                                                                                            ? Image.asset("assets/images/Genre_HF.png")
                                                                                            : (snapshot.data!['userProfile']['genres'][index] == "Horror")
                                                                                                ? Image.asset("assets/images/Genre_Horror.png")
                                                                                                : (snapshot.data!['userProfile']['genres'][index] == "Literary Fiction")
                                                                                                    ? Image.asset("assets/images/Genre_LF.png")
                                                                                                    : (snapshot.data!['userProfile']['genres'][index] == "Memoir")
                                                                                                        ? Image.asset("assets/images/Genre_Memoir.png")
                                                                                                        : (snapshot.data!['userProfile']['genres'][index] == "Poetry")
                                                                                                            ? Image.asset("assets/images/Genre_Poetry.png")
                                                                                                            : (snapshot.data!['userProfile']['genres'][index] == "Romance")
                                                                                                                ? Image.asset("assets/images/Genre_Romance.png")
                                                                                                                : (snapshot.data!['userProfile']['genres'][index] == "Science Fiction (Sci-Fi)")
                                                                                                                    ? Image.asset("assets/images/Genre_SciFi.png")
                                                                                                                    : (snapshot.data!['userProfile']['genres'][index] == "Short Stories")
                                                                                                                        ? Image.asset("assets/images/Genre_SS.png")
                                                                                                                        : (snapshot.data!['userProfile']['genres'][index] == "Suspense and Thrillers")
                                                                                                                            ? Image.asset("assets/images/Genre_S&T.png")
                                                                                                                            : (snapshot.data!['userProfile']['genres'][index] == "Self-Help")
                                                                                                                                ? Image.asset("assets/images/Genre_Self.png")
                                                                                                                                : (snapshot.data!['userProfile']['genres'][index] == "True Crime")
                                                                                                                                    ? Image.asset("assets/images/Genre_TC.png")
                                                                                                                                    : (snapshot.data!['userProfile']['genres'][index] == "Women's Fiction")
                                                                                                                                        ? Image.asset("assets/images/Genre_WF.png")
                                                                                                                                        : Image.asset("assets/images/quiz.png"),
                                                      )),
                                                  // SizedBox(height: 5.0),
                                                  // Text(
                                                  //     snapshot.data!['userProfile']['genres'][index],
                                                  //   style: TextStyle(
                                                  //       color:Colors.white,
                                                  //     fontWeight: FontWeight.bold
                                                  //   ),
                                                  // ),
                                                ]),
                                              );
                                            }),
                                          )
                                        : Center(
                                            child: Text(
                                            'No genres added',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'acumin-pro',
                                              fontSize: 15,
                                            ),
                                          ));
                                }
                              }),
                        ),
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
    if (usernameController.text.isNotEmpty) {
      var isExists = await _userService
          .checkUserName(usernameController.text.trim().toLowerCase());
      setState(() {
        this.isExists = isExists;
      });
    }
    if (nameForm.currentState!.validate()) {
      setState(() {
        isExists = false;
      });
    }
  }

  ButtonStyle buildButtonStyle(Color color) {
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0),
        )));
  }

  StreamBuilder<DocumentSnapshot<Object?>> buildGenreTab() {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              var topReadList = snapshot.data?['userProfile']?['topRead'];
              if (topReadList != null &&
                  snapshot.data?['userProfile']?['topRead'].length > 0) {
                topReads = snapshot.data?['userProfile']?['topRead'];
                return Container(
                  height: 170,
                  // height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width,
                  child: new ListView(
                    scrollDirection: Axis.horizontal,
                    // shrinkWrap: true,
                    // controller: new ScrollController(keepScrollOffset: false),
                    //scrollDirection: Axis.horizontal,
                    // crossAxisCount: 2,
                    // childAspectRatio: (MediaQuery.of(context).size.width) /
                    //     (MediaQuery.of(context).size.height/1),

                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 2,
                    //     childAspectRatio: (MediaQuery.of(context).size.width) /
                    //              (MediaQuery.of(context).size.height/1.3),
                    //     crossAxisSpacing:15,
                    //   mainAxisSpacing: 10
                    // ),
                    children: List.generate(
                        snapshot.data!['userProfile']['topRead'].length,
                        (index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: 160,
                              // height: MediaQuery.of(context).size.height * 0.28,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.black,
                              ),
                              child: Card(
                                  semanticContainer: true,
                                  margin: EdgeInsets.all(20),
                                  child: ClipRRect(
                                    clipBehavior: Clip.antiAlias,
                                    child: FosterImage(
                                      imageUrl: snapshot.data!['userProfile']
                                          ['topRead'][index]['image_link'],
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                    ),
                                  )),
                            ),
                            // Positioned(
                            //   top:0.0,
                            //   right: 0.0,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: new IconButton(
                            //       onPressed: (){},
                            //       icon: Icon(Icons.close,color: Colors.red,),
                            //     )
                            //   ),
                            // )
                            Positioned(
                              top: -12,
                              right: -12,
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: () {
                                      final _userCollection = FirebaseFirestore
                                          .instance
                                          .collection("users");
                                      TopReads tr = TopReads(
                                          snapshot.data!['userProfile']
                                              ['topRead'][index]['book_name'],
                                          snapshot.data!['userProfile']
                                              ['topRead'][index]['image_link']);

                                      _userCollection.doc(user.id).set({
                                        "userProfile": {
                                          "topRead": FieldValue.arrayRemove(
                                              [tr.toMap()])
                                        }
                                      }, SetOptions(merge: true));
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                );
              } else {
                return Center(
                    child: Text(
                  'Search for books to add',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'acumin-pro',
                    fontSize: 15,
                  ),
                ));
              }
          }
        });
  }
}
