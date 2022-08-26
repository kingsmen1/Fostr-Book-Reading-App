import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/BookClub.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class BookClubSearchPage extends StatefulWidget {
  const BookClubSearchPage({Key? key}) : super(key: key);

  @override
  State<BookClubSearchPage> createState() => _BookClubSearchPageState();
}

class _BookClubSearchPageState extends State<BookClubSearchPage>
    with FostrTheme {
  String query = "";
  bool searched = false;

  List<Map<String, dynamic>> users = [];
  List<String> containedUsers = [];

  final UserService userService = GetIt.I<UserService>();
  final searchForm = GlobalKey<FormState>();

  List<BookClubModel> bookClubs = [];

  final List options = [
    {"text": 'All', 'selected': true},
    {"text": 'People', 'selected': false},
    {"text": 'Clubs', 'selected': false},
    {'text': "Events", 'selected': false}
  ];

  @override
  void initState() {
    super.initState();
    //bookCLubsAvailable();
  }

  // void bookCLubsAvailable() async {
  //   await FirebaseFirestore.instance
  //       .collection("bookclubs")
  //       .get()
  //       .then((value){
  //         for(int i = 0 ; i < value.docs.length ; i++){
  //           bookClubs.add(value.docs[i].id);
  //         }
  //   });
  //   print("BookCLubs = $bookClubs");
  // }

  void searchUsers(String id) async {
    // var res = await userService.searchUser(query.toLowerCase());
    // setState(() {
    //   searched = true;
    //   users = res.where((element) => element['id'] != id).toList();
    // });
  }

  void searchBookClubs() async {
    await FirebaseFirestore.instance
        .collection("bookclubs")
        .where("bookclubLowerName",
            isGreaterThanOrEqualTo: query.toLowerCase().trimLeft())
        .where("bookclubLowerName",
            isLessThan: query.toLowerCase().trimLeft() + 'z')
        .get()
        .then((value) {
      bookClubs.clear();
      for (int i = 0; i < value.docs.length; i++) {
        bool active = value.docs[i].get("isActive");
        if (active) {
          setState(() {
            bookClubs.add(BookClubModel.fromJson(
                {...value.docs[i].data(), "id": value.docs[i].id}));
          });
        }
      }
    });
    // print(bookClubs);
  }

  @override
  Widget build(BuildContext buildContext) {
    final auth = Provider.of<AuthProvider>(buildContext);
    final theme = Theme.of(buildContext);
    return Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 50, left: 10, right: 10, bottom: 10),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                      )),
                  // Expanded(child:Container()),

                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 0,
                      ),
                      // width:MediaQuery.of(buildContext).size.width*0.9,
                      height: 50,
                      child: Form(
                        key: searchForm,
                        child: TextFormField(
                          validator: (va) {
                            if (va!.isEmpty) {
                              return "Search can't be empty";
                            }
                          },
                          style: h2.copyWith(
                              fontSize: 14.sp,
                              color: theme.colorScheme.onPrimary),
                          onEditingComplete: () {
                            searchUsers(auth.user!.id);
                            bookClubs = [];
                            searchBookClubs();
                            FocusScope.of(buildContext).unfocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              query = value;
                              if (value.isEmpty) {
                                bookClubs = [];
                              }
                            });
                            if (value.isNotEmpty && value.length >= 1) {
                              searchUsers(auth.user!.id);
                              bookClubs = [];
                              searchBookClubs();
                            }
                            // if (value.isNotEmpty) {
                            //   bookClubs = [];
                            //   searchBookClubs();
                            // }
                          },
                          decoration: registerInputDecoration.copyWith(
                              hintText: 'Search for bookclubs',
                              fillColor: theme.inputDecorationTheme.fillColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),

                  // Text("Search"),
                  //
                  // Expanded(child:Container()),
                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.only(
            //     top: 0,
            //   ),
            //   width:MediaQuery.of(buildContext).size.width*0.9,
            //   child: Form(
            //     key: searchForm,
            //     child: TextFormField(
            //       validator: (va) {
            //         if (va!.isEmpty) {
            //           return "Search can't be empty";
            //         }
            //       },
            //       style: h2.copyWith(fontSize: 14.sp),
            //       onEditingComplete: () {
            //         searchUsers(auth.user!.id);
            //         bookClubs = [];
            //         searchBookClubs();
            //         FocusScope.of(buildContext).unfocus();
            //       },
            //       onChanged: (value) {
            //         setState(() {
            //           query = value;
            //           if(value.isEmpty){
            //             bookClubs = [];
            //           }
            //         });
            //         if (value.isNotEmpty && value.length >= 1) {
            //           searchUsers(auth.user!.id);
            //           bookClubs = [];
            //           searchBookClubs();
            //         }
            //         // if (value.isNotEmpty) {
            //         //   bookClubs = [];
            //         //   searchBookClubs();
            //         // }
            //       },
            //       decoration: registerInputDecoration.copyWith(
            //         hintText: 'Search for clubs, people, events',
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(buildContext).size.width * 0.05),
                child: Column(
                  children: [
                    // Wrap(
                    //   alignment: WrapAlignment.start,
                    //   children:options.map(
                    //           (e) => InkResponse(
                    //             highlightShape:BoxShape.rectangle,
                    //             onTap: ()=>{
                    //               setState((){
                    //                 for(int i=0;i<options.length;i++){
                    //                   if(options[i]["text"]==e["text"]){
                    //                     options[i]['selected']=!options[i]['selected'];
                    //                   }
                    //                 }
                    //               })
                    //             },
                    //             child: Padding(
                    //               padding: const EdgeInsets.all(4.0),
                    //               child: Chip(
                    //                 padding: EdgeInsets.symmetric(vertical: 4,horizontal: 10),
                    //                   backgroundColor: e['selected']?Colors.black:Colors.white,
                    //                   label: Text(e["text"],
                    //                     style: TextStyle(
                    //                       color: e['selected']?Colors.white:Colors.black,
                    //                     ),
                    //                   )
                    //               ),
                    //             ),
                    //           )
                    //   ).toList(),
                    // ),
                    // SizedBox(height: 10,),

                    //searching profiles

                    users.length > 0
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10, top: 10),
                            child: Row(
                              children: [
                                Text(
                                  users.length > 0 ? "Users" : "",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    users.length > 0
                        ? Expanded(
                            child: (users.length > 0)
                                ? ListView.builder(
                                    itemCount: users.length,
                                    itemBuilder: (context, idx) {
                                      var user = User.fromJson(users[idx]);
                                      containedUsers.add(user.id);
                                      return UserCard(
                                        user: user,
                                      );
                                    },
                                  )
                                : (searched)
                                    ? SizedBox.shrink()
                                    : Center(
                                        child: Text(
                                          "You can follow some readers here",
                                        ),
                                      ),
                          )
                        : SizedBox.shrink(),

                    //searching book clubs
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Row(
                        children: [
                          Text(
                            bookClubs.length > 0 ? "Book Clubs" : "",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    bookClubs.length > 0
                        ? Expanded(
                            child: ListView.builder(
                                itemCount: bookClubs.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      naviagteToBookClub(
                                          bookClubs[index], buildContext);
                                    },
                                    child: BookClubCard(
                                        bookClubModel: bookClubs[index]),
                                  );
                                }))
                        : SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class UserCard extends StatefulWidget {
  final User user;
  const UserCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> with FostrTheme {
  bool followed = false;
  final UserService userService = GetIt.I<UserService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user!.followings!.contains(widget.user.id)) {
        setState(() {
          followed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthProvider>(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) {
              return ExternalProfilePage(
                user: widget.user,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 60.w,
        constraints: BoxConstraints(minHeight: 70),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xffffffff),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (widget.user.name.isNotEmpty)
                    ? SizedBox(
                        width: 200,
                        child: Text(
                          widget.user.name,
                          style: h1.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 3,
                ),
                (widget.user.bookClubName != null &&
                        widget.user.bookClubName!.isNotEmpty)
                    ? SizedBox(
                        width: 200,
                        child: Text(
                          widget.user.bookClubName!,
                          overflow: TextOverflow.ellipsis,
                          style: h1.copyWith(fontSize: 13.sp),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "@" + widget.user.userName,
                  style: h1.copyWith(fontSize: 10.sp),
                )
              ],
            ),
            Container(
              height: 15.w,
              width: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: (widget.user.userProfile != null)
                        ? (widget.user.userProfile?.profileImage != null)
                            ? FosterImageProvider(
                                imageUrl:
                                    widget.user.userProfile!.profileImage!,
                              )
                            : Image.asset(IMAGES + "profile.png").image
                        : Image.asset(IMAGES + "profile.png").image),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void naviagteToBookClub(
    BookClubModel bookClubModel, BuildContext context) async {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BookClub(
                bookClub: bookClubModel,
              )));
}

class BookClubCard extends StatefulWidget {
  final BookClubModel bookClubModel;
  const BookClubCard({Key? key, required this.bookClubModel}) : super(key: key);

  @override
  _BookClubCardState createState() => _BookClubCardState();
}

class _BookClubCardState extends State<BookClubCard> with FostrTheme {
  String userName = "";

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.bookClubModel.createdBy)
        .get()
        .then((value) => {
              if (mounted)
                {
                  setState(() {
                    userName = value.data()?["userName"];
                  })
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 60.w,
      constraints: BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 1,
            color: Colors.black.withOpacity(0.1),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: Text(
                  widget.bookClubModel.bookClubName,
                  style: h1.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.inversePrimary),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [Text("@" + userName)],
              )
            ],
          ),
          Container(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: widget.bookClubModel.bookClubProfile != null &&
                      widget.bookClubModel.bookClubProfile!.isNotEmpty
                  ? FosterImage(
                      imageUrl: widget.bookClubModel.bookClubProfile!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
