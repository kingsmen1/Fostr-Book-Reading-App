import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/PageSinglePost.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/AllLandingPage.dart';
import 'package:fostr/pages/user/BookClub.dart';
import 'package:fostr/pages/user/SearchBookBits.dart';
import 'package:fostr/pages/user/SearchBookISBN.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/pages/user/userActivity/PanelRecordings.dart';
import 'package:fostr/pages/user/userActivity/RoomRecordings.dart';
import 'package:fostr/pages/user/userActivity/UserRecordings.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/goToReviews.dart';
import 'package:fostr/screen/CollectionPage.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/SearchServices.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with FostrTheme {
  String query = "";
  bool searched = false;

  List<Map<String, dynamic>> users = [];
  List<String> containedUsers = [];

  final UserService userService = GetIt.I<UserService>();
  final searchForm = GlobalKey<FormState>();

  List<BookClubModel> bookClubs = [];
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> recordings = [];
  List<Map<String, dynamic>> albums = [];


  // List<Map<String,List>> collection = [
  //   {
  //     "posts": [],
  //     "albums": [],
  //     "reviews": [],
  //     "recordings": [],
  //   }
  // ];

  List bnamelist = [];
  List list = [];
  List images = [];

  final List options = [
    {"text": 'All', 'selected': true},
    {"text": 'People', 'selected': false},
    {"text": 'Clubs', 'selected': false},
    {'text': "Events", 'selected': false}
  ];

  TextEditingController booknameController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getbnamelist();

    //bookCLubsAvailable();
  }

  void getbnamelist() async {
    await FirebaseFirestore.instance
        .collection("booksearch")
        .get()
        .then((value){
          value.docs.forEach((element) async {
            setState(() {
              bnamelist.add(element.id);
            });
          });
    });
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

  // void searchUsers(String id) async {
  //   // var res = await userService.searchUser(query.toLowerCase());
  //   // setState(() {
  //   //   searched = true;
  //   //   users = res.where((element) => element['id'] != id).toList();
  //   // });
  // }
  //
  // void searchBookClubs() async {
  //   // await FirebaseFirestore.instance
  //   //     .collection("bookclubs")
  //   //     .where("bookclubLowerName",
  //   //         isGreaterThanOrEqualTo: query.toLowerCase().trimLeft())
  //   //     .where("bookclubLowerName",
  //   //         isLessThan: query.toLowerCase().trimLeft() + 'z')
  //   //     .get()
  //   //     .then((value) {
  //   //   bookClubs.clear();
  //   //   for (int i = 0; i < value.docs.length; i++) {
  //   //     bool active = value.docs[i].get("isActive");
  //   //     if (active) {
  //   //       setState(() {
  //   //         bookClubs.add(BookClubModel.fromJson(
  //   //             {...value.docs[i].data(), "id": value.docs[i].id}));
  //   //       });
  //   //     }
  //   //   }
  //   // });
  //   // print(bookClubs);
  // }
  //
  // void searchPosts() async {
  //   await FirebaseFirestore.instance
  //       .collection("posts")
  //       .where("bookNameLowerCase",
  //       isGreaterThanOrEqualTo: query.toLowerCase().trimLeft())
  //       .where("bookNameLowerCase",
  //       isLessThan: query.toLowerCase().trimLeft() + 'z')
  //       .get()
  //       .then((value){
  //     posts.clear();
  //     value.docs.forEach((element) {
  //       if(element["isActive"]){
  //         posts.add(element.data());
  //       }
  //     });
  //   });
  // }
  //
  // void searchBits() async {
  //   // await FirebaseFirestore.instance
  //   //     .collection("reviews")
  //   //     .where("bookNameLowerCase",
  //   //         isGreaterThanOrEqualTo: query.toLowerCase().trimLeft())
  //   //     .where("bookNameLowerCase",
  //   //         isLessThan: query.toLowerCase().trimLeft() + 'z')
  //   //     .get()
  //   //     .then((value){
  //   //       bits.clear();
  //   //       value.docs.forEach((element) {
  //   //         if(element["isActive"]){
  //   //           bits.add(element.data());
  //   //         }
  //   //       });
  //   // });
  // }
  //
  // void getSearchFeed() async {
  //   // await FirebaseFirestore.instance
  //   //     .collection("book_search")
  //   //     .get()
  //   //     .then((value){
  //   //       value.docs.forEach((element) async {
  //   //
  //   //         await FirebaseFirestore.instance
  //   //             .collection("book_search")
  //   //             .doc(element.id)
  //   //             .ge
  //   //
  //   //       });
  //   // });
  // }

  void onTextChange(String text) async {
    print("entered $text");
    setState(() {
      reviews.clear();
      recordings.clear();
      albums.clear();
      posts.clear();
      // collection.clear();
      list.clear();
      // collection["posts"]!.clear();
      // collection["reviews"]!.clear();
      // collection["albums"]!.clear();
      // collection["recordings"]!.clear();
    });

          bnamelist.forEach((element) async {
            if(element.contains(text)){
              list.add(element);
              // await FirebaseFirestore.instance
              // .collection("")
              // SearchServices().getActivitesByBookName(element).then((data){
              //   setState(() {
              //     data["data"].forEach((element){
              //
              //       if(element["activitytype"] == SearchType.review.name){
              //         collection[collection]["reviews"]!.add(element["activityid"]);
              //         // reviews.add({
              //         //   "id" : element["activityid"],
              //         //   "uid" : element["creatorid"]
              //         // });
              //       } else if(element["activitytype"] == SearchType.recording.name){
              //         collection["recordings"]!.add(element["activityid"]);
              //         // recordings.add({
              //         //   "id" : element["activityid"],
              //         //   "uid" : element["creatorid"]
              //         // });
              //       } else if(element["activitytype"] == SearchType.post.name){
              //         collection["posts"]!.add(element["activityid"]);
              //         // posts.add({
              //         //   "id" : element["activityid"],
              //         //   "uid" : element["creatorid"]
              //         // });
              //       } else if(element["activitytype"] == SearchType.album.name){
              //         collection["albums"]!.add(element["activityid"]);
              //         // albums.add({
              //         //   "id" : element["activityid"],
              //         //   "uid" : element["creatorid"]
              //         // });
              //       }
              //     });
              //   });
              // });
            }
          });
  }

  // void getData() async {
  //   // await FirebaseFirestore.instance
  //   //     .collection("booksearch")
  //   //     .get()
  //   //     .then((value){
  //
  //     // List bookNameList = [];
  //     // value.docs.forEach((element) {bookNameList.add(element.id);});
  //     //
  //     // for(int i=0; i<bookNameList.length; i++){
  //       SearchServices().getActivitesByBookName(booknameController.text.toLowerCase().trim()).then((data){
  //         setState(() {
  //           data["data"].forEach((element){
  //
  //             if(element["activitytype"] == SearchType.review.name){
  //               reviews.add({
  //                 "id" : element["activityid"],
  //                 "uid" : element["creatorid"]
  //               });
  //             } else if(element["activitytype"] == SearchType.recording.name){
  //               recordings.add({
  //                 "id" : element["activityid"],
  //                 "uid" : element["creatorid"]
  //               });
  //             } else if(element["activitytype"] == SearchType.post.name){
  //               posts.add({
  //                 "id" : element["activityid"],
  //                 "uid" : element["creatorid"]
  //               });
  //             } else if(element["activitytype"] == SearchType.album.name){
  //               albums.add({
  //                 "id" : element["activityid"],
  //                 "uid" : element["creatorid"]
  //               });
  //             }
  //           });
  //         });
  //       });
  //     // }
  //   // });
  // }

  @override
  Widget build(BuildContext buildContext) {
    final auth = Provider.of<AuthProvider>(buildContext);
    final theme = Theme.of(buildContext);
    return Scaffold(
        backgroundColor: theme.colorScheme.primary,
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) {
            return SearchBookISBN(onBookSelect: (result){});
          }
        )
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //
        //     ///search box
        //     Padding(
        //       padding: const EdgeInsets.only(
        //           top: 50, left: 10, right: 10, bottom: 10),
        //       child: Container(
        //         height: 50,
        //         child: Row(
        //           children: <Widget>[
        //             GestureDetector(
        //                 onTap: () {
        //                   setState(() {
        //                     reviews.clear();
        //                     recordings.clear();
        //                     albums.clear();
        //                     posts.clear();
        //                     // collection.clear();
        //                     list.clear();
        //                     // collection["posts"]!.clear();
        //                     // collection["reviews"]!.clear();
        //                     // collection["albums"]!.clear();
        //                     // collection["recordings"]!.clear();
        //                   });
        //                   Navigator.of(context).pop();
        //                 },
        //                 child: Icon(
        //                   Icons.arrow_back_ios,
        //                 )),
        //             // Expanded(child:Container()),
        //
        //             Expanded(
        //               child: Container(
        //                 padding: EdgeInsets.only(
        //                   top: 0,
        //                 ),
        //                 // width:MediaQuery.of(buildContext).size.width*0.9,
        //                 height: 50,
        //                 child: Form(
        //                   key: searchForm,
        //                   onChanged: (){
        //                     setState(() {
        //                       reviews.clear();
        //                       recordings.clear();
        //                       albums.clear();
        //                       posts.clear();
        //                       // collection.clear();
        //                       list.clear();
        //                       // collection["posts"]!.clear();
        //                       // collection["reviews"]!.clear();
        //                       // collection["albums"]!.clear();
        //                       // collection["recordings"]!.clear();
        //                     });
        //                     // onTextChange(booknameController.text.toLowerCase().trim());
        //                   },
        //                   child: TextFormField(
        //                     controller: booknameController,
        //                     validator: (va) {
        //                       if (va!.isEmpty) {
        //                         return "Search can't be empty";
        //                       }
        //                     },
        //                     style: h2.copyWith(
        //                         fontSize: 14.sp,
        //                         color: theme.colorScheme.onPrimary),
        //                     onEditingComplete: () {
        //                       // searchUsers(auth.user!.id);
        //                       bookClubs = [];
        //                       setState(() {
        //                         reviews.clear();
        //                         recordings.clear();
        //                         albums.clear();
        //                         posts.clear();
        //                         // collection.clear();
        //                         list.clear();
        //                         // collection["posts"]!.clear();
        //                         // collection["reviews"]!.clear();
        //                         // collection["albums"]!.clear();
        //                         // collection["recordings"]!.clear();
        //                       });
        //                       // searchBookClubs();
        //                       // searchBits();
        //                       onTextChange(booknameController.text.toLowerCase().trim());
        //                       // getData();
        //                       FocusScope.of(buildContext).unfocus();
        //                     },
        //                     onChanged: (value) {
        //                       setState(() {
        //                         query = value;
        //                         if (value.isEmpty) {
        //                           bookClubs = [];
        //                           reviews.clear();
        //                           albums.clear();
        //                           posts.clear();
        //                           recordings.clear();
        //                           // collection.clear();
        //                           list.clear();
        //                           // collection["posts"]!.clear();
        //                           // collection["reviews"]!.clear();
        //                           // collection["albums"]!.clear();
        //                           // collection["recordings"]!.clear();
        //                         }
        //                       });
        //                       if (value.isNotEmpty && value.length >= 1) {
        //                         // searchUsers(auth.user!.id);
        //                         setState(() {
        //                           reviews.clear();
        //                           albums.clear();
        //                           posts.clear();
        //                           recordings.clear();
        //                           // collection.clear();
        //                           list.clear();
        //                           // collection["posts"]!.clear();
        //                           // collection["reviews"]!.clear();
        //                           // collection["albums"]!.clear();
        //                           // collection["recordings"]!.clear();
        //                         });
        //                         bookClubs = [];
        //                         // searchBookClubs();
        //                         // searchBits();
        //                         // onTextChange(value);
        //                         // getData();
        //                       }
        //                     },
        //                     decoration: registerInputDecoration.copyWith(
        //                         hintText:
        //                             'Search for bits, readings and more',
        //                         fillColor: theme.inputDecorationTheme.fillColor),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //             SizedBox(
        //               width: 10,
        //             ),
        //
        //             // Text("Search"),
        //             //
        //             // Expanded(child:Container()),
        //             InkWell(
        //               onTap: () async {
        //
        //                 ///recordings into booksearch
        //                 // await FirebaseFirestore.instance
        //                 //     .collection("recordings")
        //                 //     .where("isActive", isEqualTo: true)
        //                 //     .get()
        //                 //     .then((value) async {
        //                 //       List list = [];
        //                 //       value.docs.forEach((element) async {
        //                 //         list.add({
        //                 //           "recid" : element.id,
        //                 //           "userid" : element["userId"],
        //                 //           "roomid" : element["roomId"],
        //                 //           "type" : element["type"]
        //                 //         });
        //                 //       });
        //                 //       print(list);
        //                 //
        //                 //       for(int i=0; i<list.length; i++){
        //                 //         await FirebaseFirestore.instance
        //                 //             .collection("rooms")
        //                 //             .doc(list[i]['userid'])
        //                 //             .collection(list[i]['type'] == "ROOM" ? "rooms" : "amphitheatre")
        //                 //             .doc(list[i]['roomid'])
        //                 //             .get()
        //                 //             .then((room) async {
        //                 //
        //                 //               await FirebaseFirestore.instance
        //                 //                   .collection("booksearch")
        //                 //                   .doc(room["title"].toString().toLowerCase().trim())
        //                 //               .set({
        //                 //                 "book_title" : room["title"].toString().toLowerCase().trim()
        //                 //               }).then((value) async {
        //                 //                 await FirebaseFirestore.instance
        //                 //                     .collection("booksearch")
        //                 //                     .doc(room["title"].toString().toLowerCase().trim())
        //                 //                     .collection("activities")
        //                 //                     .doc(list[i]['recid'])
        //                 //                     .set({
        //                 //                   "activityid" : list[i]['recid'],
        //                 //                   "activitytype" : SearchType.recording.name,
        //                 //                   "creatorid" : list[i]['userid']
        //                 //                 });
        //                 //               });
        //                 //
        //                 //         });
        //                 //       }
        //                 //
        //                 // });
        //
        //                 ///reviews into booksearch
        //                 // await FirebaseFirestore.instance
        //                 //     .collection("reviews")
        //                 //     .where("isActive", isEqualTo: true)
        //                 //     .get()
        //                 //     .then((review) async {
        //                 //
        //                 //       List list = [];
        //                 //
        //                 //       review.docs.forEach((element) async {
        //                 //
        //                 //         list.add(element.data());
        //                 //
        //                 //       });
        //                 //
        //                 //       print(list);
        //                 //
        //                 //       for(int i=0; i<list.length; i++){
        //                 //         await FirebaseFirestore.instance
        //                 //             .collection("booksearch")
        //                 //             .doc(list[i]["bookNameLowerCase"])
        //                 //             .set({
        //                 //           "book_title" : list[i]["bookNameLowerCase"]
        //                 //         }).then((value) async {
        //                 //           await FirebaseFirestore.instance
        //                 //               .collection("booksearch")
        //                 //               .doc(list[i]["bookNameLowerCase"])
        //                 //               .collection("activities")
        //                 //               .doc(list[i]["id"])
        //                 //               .set({
        //                 //             "activityid" : list[i]["id"],
        //                 //             "activitytype" : SearchType.review.name,
        //                 //             "creatorid" : list[i]['editorId']
        //                 //           });
        //                 //         });
        //                 //       }
        //                 //
        //                 // });
        //
        //                 ///albums into booksearch
        //                 //                       await FirebaseFirestore.instance
        //                 //                           .collection("albums")
        //                 //                           .where("isActive", isEqualTo: true)
        //                 //                           .get()
        //                 //                           .then((review) async {
        //                 //
        //                 //                             List list = [];
        //                 //
        //                 //                             review.docs.forEach((element) async {
        //                 //
        //                 //                               list.add(element.data());
        //                 //
        //                 //                             });
        //                 //
        //                 //                             print(list);
        //                 //
        //                 //                             for(int i=0; i<list.length; i++){
        //                 //                               await FirebaseFirestore.instance
        //                 //                                   .collection("booksearch")
        //                 //                                   .doc(list[i]["title"].toString().toLowerCase().trim())
        //                 //                                   .set({
        //                 //                                 "book_title" : list[i]["title"].toString().toLowerCase().trim()
        //                 //                               }).then((value) async {
        //                 //                                 await FirebaseFirestore.instance
        //                 //                                     .collection("booksearch")
        //                 //                                     .doc(list[i]["title"].toString().toLowerCase().trim())
        //                 //                                     .collection("activities")
        //                 //                                     .doc(list[i]["id"])
        //                 //                                     .set({
        //                 //                                   "activityid" : list[i]["id"],
        //                 //                                   "activitytype" : SearchType.album.name,
        //                 //                                   "creatorid" : list[i]['authorId']
        //                 //                                 });
        //                 //                               });
        //                 //                             }
        //                 //
        //                 //                       });
        //
        //
        //                 Navigator.push(
        //                   context,
        //                   new MaterialPageRoute(
        //                     builder: (context) => UserProfilePage(),
        //                   ),
        //                 );
        //               },
        //               child: RoundedImage(
        //                 width: 38,
        //                 height: 38,
        //                 borderRadius: 35,
        //                 url: auth.user?.userProfile?.profileImage,
        //               ),
        //             )
        //           ],
        //         ),
        //       ),
        //     ),
        //     // Container(
        //     //   padding: EdgeInsets.only(
        //     //     top: 0,
        //     //   ),
        //     //   width:MediaQuery.of(buildContext).size.width*0.9,
        //     //   child: Form(
        //     //     key: searchForm,
        //     //     child: TextFormField(
        //     //       validator: (va) {
        //     //         if (va!.isEmpty) {
        //     //           return "Search can't be empty";
        //     //         }
        //     //       },
        //     //       style: h2.copyWith(fontSize: 14.sp),
        //     //       onEditingComplete: () {
        //     //         searchUsers(auth.user!.id);
        //     //         bookClubs = [];
        //     //         searchBookClubs();
        //     //         FocusScope.of(buildContext).unfocus();
        //     //       },
        //     //       onChanged: (value) {
        //     //         setState(() {
        //     //           query = value;
        //     //           if(value.isEmpty){
        //     //             bookClubs = [];
        //     //           }
        //     //         });
        //     //         if (value.isNotEmpty && value.length >= 1) {
        //     //           searchUsers(auth.user!.id);
        //     //           bookClubs = [];
        //     //           searchBookClubs();
        //     //         }
        //     //         // if (value.isNotEmpty) {
        //     //         //   bookClubs = [];
        //     //         //   searchBookClubs();
        //     //         // }
        //     //       },
        //     //       decoration: registerInputDecoration.copyWith(
        //     //         hintText: 'Search for clubs, people, events',
        //     //       ),
        //     //     ),
        //     //   ),
        //     // ),
        //
        //     ///search body
        //     Container(
        //       height: MediaQuery.of(buildContext).size.height - 125,
        //       padding: EdgeInsets.symmetric(
        //           horizontal: MediaQuery.of(buildContext).size.width * 0.05),
        //       child: SingleChildScrollView(
        //         child: Column(
        //           children: [
        //             // Wrap(
        //             //   alignment: WrapAlignment.start,
        //             //   children:options.map(
        //             //           (e) => InkResponse(
        //             //             highlightShape:BoxShape.rectangle,
        //             //             onTap: ()=>{
        //             //               setState((){
        //             //                 for(int i=0;i<options.length;i++){
        //             //                   if(options[i]["text"]==e["text"]){
        //             //                     options[i]['selected']=!options[i]['selected'];
        //             //                   }
        //             //                 }
        //             //               })
        //             //             },
        //             //             child: Padding(
        //             //               padding: const EdgeInsets.all(4.0),
        //             //               child: Chip(
        //             //                 padding: EdgeInsets.symmetric(vertical: 4,horizontal: 10),
        //             //                   backgroundColor: e['selected']?Colors.black:Colors.white,
        //             //                   label: Text(e["text"],
        //             //                     style: TextStyle(
        //             //                       color: e['selected']?Colors.white:Colors.black,
        //             //                     ),
        //             //                   )
        //             //               ),
        //             //             ),
        //             //           )
        //             //   ).toList(),
        //             // ),
        //             // SizedBox(height: 10,),
        //
        //             //searching profiles
        //
        //             (
        //             //     reviews.isEmpty &&
        //             // posts.isEmpty &&
        //             // recordings.isEmpty &&
        //             // albums.isEmpty &&
        //             //     collection["posts"]!.isEmpty &&
        //             //     collection["reviews"]!.isEmpty &&
        //             //     collection["albums"]!.isEmpty &&
        //             //     collection["recordings"]!.isEmpty &&
        //                 list.isEmpty &&
        //             booknameController.text.isNotEmpty) ?
        //                 Text("Press enter"
        //                 ,style: TextStyle(
        //                     color: Colors.grey,
        //                     fontStyle: FontStyle.italic
        //                   ),) :
        //           SizedBox.shrink(),
        //
        //             // users.length > 0
        //             //     ? Padding(
        //             //         padding: const EdgeInsets.only(left: 10, top: 10),
        //             //         child: Row(
        //             //           children: [
        //             //             Text(
        //             //               users.length > 0 ? "Users" : "",
        //             //               style: TextStyle(
        //             //                 fontSize: 18,
        //             //                 fontWeight: FontWeight.bold,
        //             //               ),
        //             //             ),
        //             //           ],
        //             //         ),
        //             //       )
        //             //     : SizedBox.shrink(),
        //             // users.length > 0
        //             //     ? (users.length > 0)
        //             //         ? ListView.builder(
        //             //   shrinkWrap: true,
        //             //   physics: ClampingScrollPhysics(),
        //             //             itemCount: users.length,
        //             //             itemBuilder: (context, idx) {
        //             //               var user = User.fromJson(users[idx]);
        //             //               containedUsers.add(user.id);
        //             //               return UserCard(
        //             //                 user: user,
        //             //               );
        //             //             },
        //             //           )
        //             //         : (searched)
        //             //             ? SizedBox.shrink()
        //             //             : Center(
        //             //                 child: Text(
        //             //                   "You can follow some readers here",
        //             //                 ),
        //             //               )
        //             //     : SizedBox.shrink(),
        //             //
        //             // //searching book clubs
        //             // bookClubs.length > 0?
        //             // Padding(
        //             //   padding: const EdgeInsets.only(left: 10, top: 10),
        //             //   child: Row(
        //             //     children: [
        //             //       Text(
        //             //         bookClubs.length > 0 ? "Book Clubs" : "",
        //             //         style: TextStyle(
        //             //           fontSize: 18,
        //             //           fontWeight: FontWeight.bold,
        //             //         ),
        //             //       ),
        //             //     ],
        //             //   ),
        //             // )
        //             //     : SizedBox.shrink(),
        //             // bookClubs.length > 0
        //             //     ? ListView.builder(
        //             //         itemCount: bookClubs.length,
        //             //     shrinkWrap: true,
        //             //     physics: ClampingScrollPhysics(),
        //             //         itemBuilder: (context, index) {
        //             //           return GestureDetector(
        //             //             onTap: () {
        //             //               naviagteToBookClub(
        //             //                   bookClubs[index], buildContext);
        //             //             },
        //             //             child: BookClubCard(
        //             //                 bookClubModel: bookClubs[index]),
        //             //           );
        //             //         })
        //             //     : SizedBox.shrink(),
        //
        //             ///searching bits
        //             // reviews.length > 0?
        //             // Padding(
        //             //   padding: const EdgeInsets.only(left: 10, top: 10),
        //             //   child: Row(
        //             //     children: [
        //             //       Text(
        //             //         reviews.length > 0 ? "Reviews" : "",
        //             //         style: TextStyle(
        //             //           fontSize: 18,
        //             //           fontWeight: FontWeight.bold,
        //             //         ),
        //             //       ),
        //             //     ],
        //             //   ),
        //             // )
        //             //     : SizedBox.shrink(),
        //             // reviews.length > 0
        //             //     ? ListView.builder(
        //             //         itemCount: reviews.length,
        //             //         padding: EdgeInsets.zero,
        //             //     shrinkWrap: true,
        //             //     physics: ClampingScrollPhysics(),
        //             //         itemBuilder: (context, index) {
        //             //
        //             //           if(index >= reviews.length){
        //             //             return SizedBox.shrink();
        //             //           }
        //             //
        //             //           // print(reviews[index]);
        //             //
        //             //           return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
        //             //             stream: FirebaseFirestore.instance
        //             //               .collection("reviews")
        //             //               .doc(reviews[index]["id"])
        //             //               .snapshots(),
        //             //             builder: (context, snapshot) {
        //             //               if(!snapshot.hasData){
        //             //                 return SizedBox.shrink();
        //             //               }
        //             //               return BitTile(bit: snapshot.data!.data()!, authId: auth.user!.id);
        //             //             }
        //             //           );
        //             //         })
        //             //     : SizedBox.shrink(),
        //
        //             ///searching recordings
        //             // recordings.length > 0?
        //             // Padding(
        //             //   padding: const EdgeInsets.only(left: 10, top: 10),
        //             //   child: Row(
        //             //     children: [
        //             //       Text(
        //             //         recordings.length > 0 ? "Recordings" : "",
        //             //         style: TextStyle(
        //             //           fontSize: 18,
        //             //           fontWeight: FontWeight.bold,
        //             //         ),
        //             //       ),
        //             //     ],
        //             //   ),
        //             // )
        //             //     : SizedBox.shrink(),
        //             // recordings.length > 0
        //             //     ? ListView.builder(
        //             //         itemCount: recordings.length,
        //             //         padding: EdgeInsets.zero,
        //             //     shrinkWrap: true,
        //             //     physics: ClampingScrollPhysics(),
        //             //         itemBuilder: (context, index) {
        //             //
        //             //           if(index >= recordings.length){
        //             //             return SizedBox.shrink();
        //             //           }
        //             //
        //             //           // print(recordings[index]);
        //             //
        //             //           return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
        //             //               stream: FirebaseFirestore.instance
        //             //                   .collection("recordings")
        //             //                   .doc(recordings[index]["id"])
        //             //                   .snapshots(),
        //             //               builder: (context, snapshot) {
        //             //                 if(!snapshot.hasData){
        //             //                   return SizedBox.shrink();
        //             //                 }
        //             //                 return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
        //             //                   stream: FirebaseFirestore.instance
        //             //                       .collection("rooms")
        //             //                       .doc(snapshot.data!["userId"])
        //             //                       .collection("rooms")
        //             //                       .doc(snapshot.data!["roomId"])
        //             //                     .snapshots(),
        //             //                   builder: (context, room){
        //             //                     if(!room.hasData){
        //             //                       return SizedBox.shrink();
        //             //                     }
        //             //
        //             //                     return GestureDetector(
        //             //
        //             //                       onTap: () async {
        //             //                         List list = [];
        //             //                         await FirebaseFirestore.instance
        //             //                         .collection("recordings")
        //             //                         .get()
        //             //                         .then((value){
        //             //
        //             //                           for(int i=0; i<value.docs.length; i++){
        //             //                             // print(i);
        //             //                             if(value.docs[i].id == recordings[index]["id"]){
        //             //                               int INDEX = i;
        //             //                               // print(value.docs[i].id);
        //             //                               // print(recordings[index]["id"]);
        //             //                               Navigator.push(
        //             //                                 context,
        //             //                                 new MaterialPageRoute(
        //             //                                   builder: (context) =>
        //             //                                       UserRecorings(
        //             //                                           page: INDEX
        //             //                                       ),
        //             //                                 ),
        //             //                               );
        //             //                             }
        //             //                           }
        //             //
        //             //                         //   value.docs.forEach((element) {
        //             //                         //     list.add(element.id);
        //             //                         //   });
        //             //                         // }).then((value){
        //             //                         //   Navigator.push(
        //             //                         //     context,
        //             //                         //     new MaterialPageRoute(
        //             //                         //       builder: (context) =>
        //             //                         //           UserRecorings(
        //             //                         //               page: list.indexOf(recordings[index]["id"])
        //             //                         //           ),
        //             //                         //     ),
        //             //                         //   );
        //             //                         });
        //             //                       },
        //             //
        //             //                       child: PodcastTile(
        //             //                             podImage: room.data!["image"],
        //             //                             podTitle: room.data!["title"],
        //             //                             podAuthor: room.data!["roomCreator"],
        //             //                             podId: recordings[index]["id"]
        //             //                         ),
        //             //                     );
        //             //                   }
        //             //                 );
        //             //               }
        //             //           );
        //             //         })
        //             //     : SizedBox.shrink(),
        //
        //             ///searching albums
        //             // albums.length > 0?
        //             // Padding(
        //             //   padding: const EdgeInsets.only(left: 10, top: 10),
        //             //   child: Row(
        //             //     children: [
        //             //       Text(
        //             //         albums.length > 0 ? "Albums" : "",
        //             //         style: TextStyle(
        //             //           fontSize: 18,
        //             //           fontWeight: FontWeight.bold,
        //             //         ),
        //             //       ),
        //             //     ],
        //             //   ),
        //             // )
        //             //     : SizedBox.shrink(),
        //             // albums.length > 0
        //             //     ? GridView.builder(
        //             //         itemCount: albums.length,
        //             //         shrinkWrap: true,
        //             //         padding: EdgeInsets.zero,
        //             //         physics: ClampingScrollPhysics(),
        //             //         scrollDirection: Axis.vertical,
        //             //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
        //             //         itemBuilder: (context, index){
        //             //           return StreamBuilder<DocumentSnapshot>(
        //             //             stream: FirebaseFirestore.instance
        //             //               .collection("albums")
        //             //               .doc(albums[index]["id"])
        //             //               .snapshots(),
        //             //             builder: (context, album) {
        //             //
        //             //               if(!album.hasData){
        //             //                 return SizedBox.shrink();
        //             //               }
        //             //
        //             //               return GestureDetector(
        //             //
        //             //                 onTap: (){
        //             //                   showModalBottomSheet(
        //             //                     context: context,
        //             //                     isScrollControlled: true,
        //             //                     backgroundColor: Colors.transparent,
        //             //                     builder: (context) => Padding(
        //             //                       padding: EdgeInsets.only(top: 100),
        //             //                       child: AlbumPage(
        //             //                         albumId: albums[index]["id"],
        //             //                         authId: album.data!["authorId"],
        //             //                         fromShare: false,
        //             //                       ),
        //             //                     ),
        //             //                   );
        //             //                 },
        //             //
        //             //                 child: Container(
        //             //                   height: 220,
        //             //                   child: Column(
        //             //                     children: [
        //             //                       Expanded(child: Container()),
        //             //
        //             //                       //image
        //             //                       Container(
        //             //                         width: 140,
        //             //                         height: 140,
        //             //                         decoration: BoxDecoration(
        //             //                             color: Colors.transparent,
        //             //                             border: Border.all(
        //             //                                 width: 1,
        //             //                                 color: album.data!["image"].isEmpty ? Colors.grey : Colors.transparent
        //             //                             ),
        //             //                             borderRadius: BorderRadius.circular(10)
        //             //                         ),
        //             //                         child: ClipRRect(
        //             //                           borderRadius: BorderRadius.circular(10),
        //             //                           child: album.data!["image"].toString().isEmpty ?
        //             //                           Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
        //             //                           Image.network(album.data!["image"], fit: BoxFit.fill,),
        //             //                         ),
        //             //                       ),
        //             //
        //             //                       //data
        //             //                       Padding(
        //             //                         padding: const EdgeInsets.only(left: 0),
        //             //                         child: Container(
        //             //                           height: 60,
        //             //                           width: 130,
        //             //                           child: Column(
        //             //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             //                             crossAxisAlignment: CrossAxisAlignment.start,
        //             //                             children: [
        //             //                               SizedBox(),
        //             //                               Text(album.data!["title"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
        //             //                               Text(album.data!["authorName"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
        //             //                               Text("${album.data!["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
        //             //                               SizedBox(),
        //             //                             ],
        //             //                           ),
        //             //                         ),
        //             //                       )
        //             //                     ],
        //             //                   ),
        //             //                 ),
        //             //               );
        //             //             }
        //             //           );
        //             //         }
        //             //     )
        //             //     : SizedBox.shrink(),
        //
        //             ///searching posts
        //             // posts.length > 0
        //             //     ? Padding(
        //             //   padding: const EdgeInsets.only(left: 10, top: 10),
        //             //   child: Row(
        //             //     children: [
        //             //       Text(
        //             //         posts.length > 0 ? "Posts" : "",
        //             //         style: TextStyle(
        //             //           fontSize: 18,
        //             //           fontWeight: FontWeight.bold,
        //             //         ),
        //             //       ),
        //             //     ],
        //             //   ),
        //             // )
        //             //     : SizedBox.shrink(),
        //             // posts.length > 0
        //             //     ? GridView.builder(
        //             //         itemCount: posts.length,
        //             //         shrinkWrap: true,
        //             //     physics: ClampingScrollPhysics(),
        //             //         padding: EdgeInsets.zero,
        //             //         scrollDirection: Axis.vertical,
        //             //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
        //             //         itemBuilder: (context, index){
        //             //           return StreamBuilder<DocumentSnapshot>(
        //             //               stream: FirebaseFirestore.instance
        //             //                   .collection("posts")
        //             //                   .doc(posts[index]["id"])
        //             //                   .snapshots(),
        //             //               builder: (context, post) {
        //             //
        //             //                 if(!post.hasData){
        //             //                   return SizedBox.shrink();
        //             //                 }
        //             //
        //             //                 return GestureDetector(
        //             //
        //             //                   onTap: (){
        //             //                     Navigator.push(
        //             //                       context,
        //             //                       CupertinoPageRoute(
        //             //                         builder: (context) {
        //             //                           return PageSinglePost(
        //             //                             postId: post.data!["id"],
        //             //                             dateTime: post.data!["dateTime"],
        //             //                             userid: post.data!["userid"],
        //             //                             userProfile: post.data!["userProfile"],
        //             //                             username: post.data!["username"],
        //             //                             image: post.data!["image"],
        //             //                             caption: post.data!["caption"],
        //             //                             likes: post.data!["likes"].toString(),
        //             //                             comments: post.data!["comments"].toString(),
        //             //                           );
        //             //                         },
        //             //                       ),
        //             //                     );
        //             //                   },
        //             //
        //             //                   child: Container(
        //             //                     height: 220,
        //             //                     child: Column(
        //             //                       children: [
        //             //                         Expanded(child: Container()),
        //             //
        //             //                         //image
        //             //                         Container(
        //             //                           width: 140,
        //             //                           height: 140,
        //             //                           decoration: BoxDecoration(
        //             //                               color: Colors.transparent,
        //             //                               border: Border.all(
        //             //                                   width: 1,
        //             //                                   color: post.data!["image"].isEmpty ? Colors.grey : Colors.transparent
        //             //                               ),
        //             //                               borderRadius: BorderRadius.circular(10)
        //             //                           ),
        //             //                           child: ClipRRect(
        //             //                             borderRadius: BorderRadius.circular(10),
        //             //                             child: post.data!["image"].toString().isEmpty ?
        //             //                             Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
        //             //                             Image.network(post.data!["image"], fit: BoxFit.fill,),
        //             //                           ),
        //             //                         ),
        //             //
        //             //                         //data
        //             //                         Padding(
        //             //                           padding: const EdgeInsets.only(left: 0),
        //             //                           child: Container(
        //             //                             height: 60,
        //             //                             width: 130,
        //             //                             child: Column(
        //             //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             //                               crossAxisAlignment: CrossAxisAlignment.start,
        //             //                               children: [
        //             //                                 SizedBox(),
        //             //                                 Text(post.data!["bookName"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
        //             //                                 Text(post.data!["username"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
        //             //                                 SizedBox(),
        //             //                               ],
        //             //                             ),
        //             //                           ),
        //             //                         )
        //             //                       ],
        //             //                     ),
        //             //                   ),
        //             //                 );
        //             //               }
        //             //           );
        //             //         }
        //             //     )
        //             //     : SizedBox.shrink(),
        //
        //             ///searching collections
        //             list.length > 0?
        //             Padding(
        //               padding: const EdgeInsets.only(left: 10, top: 10),
        //               child: Row(
        //                 children: [
        //                   Text(
        //                     list.length > 0 ? "Collections" : "",
        //                     style: TextStyle(
        //                       fontSize: 18,
        //                       fontWeight: FontWeight.bold,
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             )
        //                 : SizedBox.shrink(),
        //             (list.isEmpty
        //                 // collection["posts"]!.isEmpty &&
        //                 // collection["reviews"]!.isEmpty &&
        //                 // collection["albums"]!.isEmpty &&
        //                 // collection["recordings"]!.isEmpty
        //             ) ?
        //                 SizedBox.shrink() :
        //             GridView.builder(
        //                 itemCount: list.length,
        //                 shrinkWrap: true,
        //                 physics: ClampingScrollPhysics(),
        //                 padding: EdgeInsets.zero,
        //                 scrollDirection: Axis.vertical,
        //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //                     crossAxisCount: 2,
        //                     // mainAxisExtent: 220
        //                 ),
        //                 itemBuilder: (context, index){
        //                   return GestureDetector(
        //
        //                     onTap: () {
        //                       Navigator.push(context,
        //                           MaterialPageRoute(builder: (context)=>
        //                               CollectionPage(bookname: list[index])
        //                           ));
        //                     },
        //
        //                     child: Container(
        //                       height: 140,
        //                       child: Column(
        //                         children: [
        //                           Expanded(child: Container()),
        //
        //                           //image
        //                           Container(
        //                             width: 140,
        //                             height: 100,
        //                             decoration: BoxDecoration(
        //                                 color: Colors.transparent,
        //                                 border: Border.all(
        //                                     width: 1,
        //                                     color: //post.data!["image"].isEmpty ? Colors.grey :
        //                                     Colors.grey
        //                                 ),
        //                                 borderRadius: BorderRadius.circular(10)
        //                             ),
        //                             child: ClipRRect(
        //                               borderRadius: BorderRadius.circular(10),
        //                               child:
        //                               // true ?
        //                               Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,))
        //                                   // :
        //                               // Image.network(post.data!["image"], fit: BoxFit.fill,),
        //                             ),
        //                           ),
        //
        //                           //data
        //                           Padding(
        //                             padding: const EdgeInsets.only(left: 0),
        //                             child: Container(
        //                               height: 40,
        //                               width: 130,
        //                               child: Column(
        //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                                 crossAxisAlignment: CrossAxisAlignment.start,
        //                                 children: [
        //                                   SizedBox(),
        //                                   Text(list[index],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
        //                                   SizedBox(),
        //                                 ],
        //                               ),
        //                             ),
        //                           )
        //                         ],
        //                       ),
        //                     ),
        //                   );
        //                 }
        //             )
        //
        //             //isbn search
        //             // SearchBookBits(
        //             //   onBookSelect: (result) {
        //             //     if (result != null) {
        //             //       setState(() {
        //             //         // bookNameTextEditingController
        //             //         //     .text = "";
        //             //         // searchBookController
        //             //         //     .text =
        //             //         // result[0];
        //             //         // imageLink =
        //             //         //     result[2]
        //             //         //         .toString();
        //             //         // authorNameTextEditingController
        //             //         //     .text =
        //             //         // result[3];
        //             //       });
        //             //     }
        //             //   },
        //             // ),
        //           ],
        //         ),
        //       ),
        //     ),
        //
        //
        //   ],
        // )
    );
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 60.w,
      constraints: BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xffffffff),
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
                      color: Colors.black87),
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




// InkWell(
//             onTap: () async {
//               try {
//                 if (!followed) {
//                   var user =
//                       await userService.followUser(auth.user!, widget.user);
//                   auth.refreshUser(user);
//                   setState(() {
//                     followed = true;
//                   });
//                   Fluttertoast.showToast(
//                       msg: "Followed Successfully!",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.BOTTOM,
//                       timeInSecForIosWeb: 1,
//                       backgroundColor: gradientBottom,
//                       textColor: Colors.white,
//                       fontSize: 16.0);
//                 }
//               } catch (e) {
//                 print(e);
//               }
//             },
//             child: Container(
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 border: Border.all(width: 2, color: h1.color!),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 (followed) ? Icons.check : Icons.add,
//                 color: h1.color,
//                 size: 28.sp,
//                 // size: 30,
//               ),
//             ),
//           )