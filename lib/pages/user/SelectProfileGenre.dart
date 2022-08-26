import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:provider/provider.dart';

class SelectProfileGenre extends StatefulWidget {
  const SelectProfileGenre({Key? key}) : super(key: key);

  @override
  _SelectProfileGenreState createState() => _SelectProfileGenreState();
}

class _SelectProfileGenreState extends State<SelectProfileGenre> {
  static List<Genres> genres = [
    Genres(
        name: "Action and Adventure",
        selected: false,
        imagePath: 'assets/images/Genre_A&A.png'),
    Genres(
        name: "Biographies and Autobiographies",
        selected: false,
        imagePath: 'assets/images/Genre_B&A.png'),
    Genres(
        name: "Classics",
        selected: false,
        imagePath: 'assets/images/Genre_Classics.png'),
    Genres(
        name: "Comic Book",
        selected: false,
        imagePath: 'assets/images/Genre_Comic.png'),
    Genres(
        name: "Cookbooks",
        selected: false,
        imagePath: 'assets/images/Genre_Cooking.png'),
    Genres(
        name: "Detective and Mystery",
        selected: false,
        imagePath: 'assets/images/Genre_D&M.png'),
    Genres(
        name: "Essays",
        selected: false,
        imagePath: 'assets/images/Genre_Essay.png'),
    Genres(
        name: "Fantasy",
        selected: false,
        imagePath: 'assets/images/Genre_Fantasy.png'),
    Genres(
        name: "Historical Fiction",
        selected: false,
        imagePath: 'assets/images/Genre_HF.png'),
    Genres(
        name: "Horror",
        selected: false,
        imagePath: 'assets/images/Genre_Horror.png'),
    Genres(
        name: "Literary Fiction",
        selected: false,
        imagePath: 'assets/images/Genre_LF.png'),
    Genres(
        name: "Memoir",
        selected: false,
        imagePath: 'assets/images/Genre_Memoir.png'),
    Genres(
        name: "Poetry",
        selected: false,
        imagePath: 'assets/images/Genre_Poetry.png'),
    Genres(
        name: "Romance",
        selected: false,
        imagePath: 'assets/images/Genre_Romance.png'),
    Genres(
        name: "Science Fiction (Sci-Fi)",
        selected: false,
        imagePath: 'assets/images/Genre_SciFi.png'),
    Genres(
        name: "Short Stories",
        selected: false,
        imagePath: 'assets/images/Genre_SS.png'),
    Genres(
        name: "Suspense and Thrillers",
        selected: false,
        imagePath: 'assets/images/Genre_S&T.png'),
    Genres(
        name: "Self-Help",
        selected: false,
        imagePath: 'assets/images/Genre_Self.png'),
    Genres(
        name: "True Crime",
        selected: false,
        imagePath: 'assets/images/Genre_TC.png'),
    Genres(
        name: "Women's Fiction",
        selected: false,
        imagePath: 'assets/images/Genre_WF.png'),
  ];

  List<dynamic> list = [];
  List<int> selectedIndex = [];
  bool enabled = false;
  int count = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      var doc = FirebaseFirestore.instance
          .collection("users")
          .doc(auth.user!.id)
          .get();
      doc.then((value) {
        if (value.data()?['userProfile']?["genres"] != null) {
          setState(() {
            list = value.data()?['userProfile']?["genres"];
          });
        }
        for (int i = 0; i < genres.length; i++) {
          var currentGenre = genres[i].name;
          list.forEach((element) {
            if (currentGenre == element) {
              setState(() {
                genres[i].selected = true;
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
      backgroundColor: theme.colorScheme.primary,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.primary,
            automaticallyImplyLeading: false,
            title: Text("Select Genre",
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'drawerhead'
              ),),
            leading: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios,)
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    // if(selectedIndex.length >= 1 && selectedIndex.length < 3){
                    //   Fluttertoast.showToast(
                    //       msg: "Please select at least 3 genres ",
                    //       toastLength: Toast.LENGTH_SHORT,
                    //       gravity: ToastGravity.BOTTOM,
                    //       timeInSecForIosWeb: 1,
                    //       backgroundColor: gradientBottom,
                    //       textColor: Colors.white,
                    //       fontSize: 16.0);
                    // }else{
                    var list = [];
                    for (int i = 0; i < genres.length; i++) {
                      if (genres[i].selected == true) {
                        list.add(genres[i].name);
                      }
                    }

                    // list.add(genres[selectedIndex[0]].name);
                    // list.add(genres[selectedIndex[1]].name);
                    // list.add(genres[selectedIndex[2]].name);
                    final _userCollection =
                    FirebaseFirestore.instance.collection("users");
                    await _userCollection.doc(user.id).set({
                      "userProfile": {
                        "genres": list.isEmpty ? null : list
                      }
                    }, SetOptions(merge: true));
                    var userJson = user.toJson();
                    if (userJson['userProfile'] != null) {
                      userJson['userProfile']['genres'] =
                      list.isEmpty ? null : list;
                    } else {
                      userJson['userProfile'] = {
                        "genres": list.isEmpty ? null : list
                      };
                    }
                    auth.refreshUser(User.fromJson(userJson));
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.black,
                  ))
            ],
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     IconButton(
              //         onPressed: () {
              //           Navigator.of(context).pop();
              //         },
              //         icon: Icon(
              //           Icons.arrow_back_ios,
              //           color: Colors.black,
              //         )),
              //     Padding(
              //         padding: const EdgeInsets.only(left: 0, top: 0),
              //         child: buildHeading("Select genres")),
              //     IconButton(
              //         onPressed: () async {
              //           // if(selectedIndex.length >= 1 && selectedIndex.length < 3){
              //           //   Fluttertoast.showToast(
              //           //       msg: "Please select at least 3 genres ",
              //           //       toastLength: Toast.LENGTH_SHORT,
              //           //       gravity: ToastGravity.BOTTOM,
              //           //       timeInSecForIosWeb: 1,
              //           //       backgroundColor: gradientBottom,
              //           //       textColor: Colors.white,
              //           //       fontSize: 16.0);
              //           // }else{
              //           var list = [];
              //           for (int i = 0; i < genres.length; i++) {
              //             if (genres[i].selected == true) {
              //               list.add(genres[i].name);
              //             }
              //           }
              //
              //           // list.add(genres[selectedIndex[0]].name);
              //           // list.add(genres[selectedIndex[1]].name);
              //           // list.add(genres[selectedIndex[2]].name);
              //           final _userCollection =
              //               FirebaseFirestore.instance.collection("users");
              //           await _userCollection.doc(user.id).set({
              //             "userProfile": {
              //               "genres": list.isEmpty ? null : list
              //             }
              //           }, SetOptions(merge: true));
              //           var userJson = user.toJson();
              //           if (userJson['userProfile'] != null) {
              //             userJson['userProfile']['genres'] =
              //                 list.isEmpty ? null : list;
              //           } else {
              //             userJson['userProfile'] = {
              //               "genres": list.isEmpty ? null : list
              //             };
              //           }
              //           auth.refreshUser(User.fromJson(userJson));
              //           Navigator.of(context).pop();
              //         },
              //         icon: Icon(
              //           Icons.check,
              //           color: Colors.black,
              //         )),
              //   ],
              // ),
              SizedBox(height: 10.0),
              Wrap(
                children: [
                  ...List.generate(
                    genres.length,
                    (index) => Container(
                      padding: const EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.width * 0.43,
                      width: MediaQuery.of(context).size.width * 0.43,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            enabled = !enabled;
                            genres[index].selected =
                                !genres[index].selected;
                          });
                          // if(selectedIndex.length < 3){
                          //   setState(() {
                          //     selectedIndex.add(index);
                          //   });
                          // }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: genres[index].selected == true
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(3),
                          // child: Text(
                          //     genres[index].name,
                          //   style: TextStyle(
                          //     color: genres[index].selected == true? Colors.white:Colors.black,
                          //   ),
                          // ),
                          child: Container(
                            height:
                                MediaQuery.of(context).size.width * 0.29,
                            width: MediaQuery.of(context).size.width * 0.29,
                            color: Colors.transparent,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: ShowGenre(genres[index].name,
                                  genres[index].imagePath),
                              // child: (genres[index].name ==
                              //         "Action and Adventure")
                              //     ? Image.asset(genres[index].imagePath)
                              //     : (genres[index].name ==
                              //             "Biographies and Autobiographies")
                              //         ? Image.asset(
                              //             genres[index].imagePath)
                              //         : (genres[index].name == "Classics")
                              //             ? Image.asset(
                              //                 genres[index].imagePath)
                              //             : (genres[index].name ==
                              //                     "Comic Book")
                              //                 ? Image.asset(
                              //                     genres[index].imagePath)
                              //                 : (genres[index].name ==
                              //                         "Cookbooks")
                              //                     ? Image.asset(genres[index]
                              //                         .imagePath)
                              //                     : (genres[index].name ==
                              //                             "Detective and Mystery")
                              //                         ? Image.asset(
                              //                             genres[index]
                              //                                 .imagePath)
                              //                         : (genres[index]
                              //                                     .name ==
                              //                                 "Essays")
                              //                             ? Image.asset(
                              //                                 genres[index]
                              //                                     .imagePath)
                              //                             : (genres[index]
                              //                                         .name ==
                              //                                     "Fantasy")
                              //                                 ? Image.asset(
                              //                                     genres[index]
                              //                                         .imagePath)
                              //                                 : (genres[index].name ==
                              //                                         "Historical Fiction")
                              //                                     ? Image.asset(genres[index].imagePath)
                              //                                     : (genres[index].name == "Horror")
                              //                                         ? Image.asset(genres[index].imagePath)
                              //                                         : (genres[index].name == "Literary Fiction")
                              //                                             ? Image.asset(genres[index].imagePath)
                              //                                             : (genres[index].name == "Memoir")
                              //                                                 ? Image.asset(genres[index].imagePath)
                              //                                                 : (genres[index].name == "Poetry")
                              //                                                     ? Image.asset(genres[index].imagePath)
                              //                                                     : (genres[index].name == "Romance")
                              //                                                         ? Image.asset(genres[index].imagePath)
                              //                                                         : (genres[index].name == "Science Fiction (Sci-Fi)")
                              //                                                             ? Image.asset(genres[index].imagePath)
                              //                                                             : (genres[index].name == "Short Stories")
                              //                                                                 ? Image.asset(genres[index].imagePath)
                              //                                                                 : (genres[index].name == "Suspense and Thrillers")
                              //                                                                     ? Image.asset(genres[index].imagePath)
                              //                                                                     : (genres[index].name == "Self-Help")
                              //                                                                         ? Image.asset(genres[index].imagePath)
                              //                                                                         : (genres[index].name == "True Crime")
                              //                                                                             ? Image.asset(genres[index].imagePath)
                              //                                                                             : (genres[index].name == "Women's Fiction")
                              //                                                                                 ? Image.asset(genres[index].imagePath)
                              //                                                                                 : Image.asset("assets/images/quiz.png")
                            ),
                          ),
                          // child: Column(
                          //   children: [

                          //     SizedBox(
                          //       height: 5.0,
                          //     ),
                          //     Text(
                          //       genres[index].name,
                          //       style: TextStyle(
                          //           color: genres[index].selected == true
                          //               ? Colors.white
                          //               : Colors.black,
                          //           fontSize: MediaQuery.of(context).size.height*0.02,
                          //           fontWeight: FontWeight.bold),
                          //     ),
                          //   ],
                          // ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}

Widget buildHeading(String text) {
  return Text(
    text,
    style: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black,
      fontFamily: 'drawerhead',),
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

class Genres {
  final String name;
  bool selected = false;
  final String imagePath;
  Genres({required this.name, required this.selected, required this.imagePath});
}

Widget ShowGenre(String name, String imagePath) {
  // to show all available genres
  switch (name) {
    case "Action and Adventure":
      return Image.asset(imagePath);
      break;
    case "Biographies and Autobiographies":
      return Image.asset(imagePath);
      break;
    case "Classics":
      return Image.asset(imagePath);
      break;
    case "Comic Book":
      return Image.asset(imagePath);
      break;
    case "Cookbooks":
      return Image.asset(imagePath);
      break;
    case "Detective and Mystery":
      return Image.asset(imagePath);
      break;
    case "Essays":
      return Image.asset(imagePath);
      break;
    case "Fantasy":
      return Image.asset(imagePath);
      break;
    case "Historical Fiction":
      return Image.asset(imagePath);
      break;
    case "Horror":
      return Image.asset(imagePath);
      break;
    case "Literary Fiction":
      return Image.asset(imagePath);
      break;
    case "Memoir":
      return Image.asset(imagePath);
      break;
    case "Poetry":
      return Image.asset(imagePath);
      break;
    case "Romance":
      return Image.asset(imagePath);
      break;
    case "Science Fiction (Sci-Fi)":
      return Image.asset(imagePath);
      break;
    case "Short Stories":
      return Image.asset(imagePath);
      break;
    case "Suspense and Thrillers":
      return Image.asset(imagePath);
      break;
    case "Self-Help":
      return Image.asset(imagePath);
      break;
    case "True Crime":
      return Image.asset(imagePath);
      break;
    case "Women's Fiction":
      return Image.asset(imagePath);
      break;
    default:
      return Image.asset("assets/images/quiz.png");
  }
}
