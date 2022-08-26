import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/Posts/PageSinglePost.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/albums/SinglePodcastPlay.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:fostr/pages/user/AllLandingPage.dart';
import 'package:fostr/pages/user/Book.dart';
import 'package:fostr/pages/user/ISBNPage.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/goToReviews.dart';
import 'package:fostr/screen/AddBookCollection.dart';
import 'package:fostr/services/ISBNService.dart';
import 'package:fostr/services/SearchServices.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/CollectionCard.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:sizer/sizer.dart';

import '../../core/constants.dart';

class SearchBookISBN extends StatefulWidget {
  const SearchBookISBN({Key? key, required this.onBookSelect})
      : super(key: key);
  final Function(List<String>? args) onBookSelect;

  @override
  State<SearchBookISBN> createState() => _SearchBookISBNState();
}

class _SearchBookISBNState extends State<SearchBookISBN> with FostrTheme{
  List<VolumeInfo> _items = [];
  List bnamelist = [];
  List list = [];
  List allRecordingsTitles = [];

  final ISBNService _isbnService = GetIt.I<ISBNService>();

  int booksCount = 0;
  TextEditingController controller = TextEditingController();
  TextEditingController authorController = TextEditingController();

  bool _isLoading = false;
  bool searched = false;
  final subject = PublishSubject<String>();

  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> recordings = [];
  List<Map<String, dynamic>> albums = [];
  // List<Map<String, dynamic>> rooms = [];
  // List<Map<String, dynamic>> theatres = [];

  int selectedIndex = 0;
  final genres = [
    'All',
    'Books',
    'Reviews',
    // 'Rooms/Theatres',
    'Readings',
    'Collections',
    'Recordings',
    'Podcasts',
  ];

  // void getAllRecordingIds() async {
  //   await FirebaseFirestore.instance
  //       .collection("recordings")
  //       .get()
  //       .then((value){
  //     value.docs.forEach((element) {
  //
  //     });
  //   });
  // }

  void searchPosts(String query) async {
    await FirebaseFirestore.instance
        .collection("posts")
        .where("bookNameLowerCase",
        isGreaterThanOrEqualTo: query.toLowerCase().trimLeft())
        .where("bookNameLowerCase",
        isLessThan: query.toLowerCase().trimLeft() + 'z')
        .get()
        .then((value){
      posts.clear();
      value.docs.forEach((element) {
        if(element["isActive"]){
          posts.add(element.data());
        }
      });
    });
  }

  void searchReviews(String query) async {
    await FirebaseFirestore.instance
        .collection("reviews")
        .where("bookNameLowerCase",
            isGreaterThanOrEqualTo: query.toLowerCase().trimLeft())
        .where("bookNameLowerCase",
            isLessThan: query.toLowerCase().trimLeft() + 'z')
        .get()
        .then((value){
          reviews.clear();
          value.docs.forEach((element) {
            if(element["isActive"]){
              reviews.add(element.data());
            }
          });
    });
  }

  void searchAlbums(String query) async {
    await FirebaseFirestore.instance
        .collection("albums")
        .where("titleLowerCase",
        isGreaterThanOrEqualTo: query.toLowerCase().trim())
        .where("titleLowerCase",
        isLessThan: query.toLowerCase().trim() + 'z')
        .get()
        .then((value){
      albums.clear();
      value.docs.forEach((element) {
        if(element["isActive"]){
          albums.add(element.data());
        }
      });
    });
  }

  void searchRecordings(String query) async {
    setState(() {
      recordings.clear();
    });

    // allRecordingsTitles.forEach((element) {});

    SearchServices().getActivitesByBookName(query).then((data){
      // print("data $data");
      setState(() {
        data["data"].forEach((element){
          if(element["activitytype"] == SearchType.recording.name){
            // print("data $data");
            recordings.add({
              "id" : element["activityid"],
              "uid" : element["creatorid"]
            });
          }
        });
      });
    });

    // await FirebaseFirestore.instance
    //     .collectionGroup("rooms")
    //     .get()
    // .then((value){
    //   value.docs.forEach((element) async {
    //
    //     await FirebaseFirestore.instance
    //         .collection("rooms")
    //         .doc(element.id)
    //         .collection("rooms")
    //         .where("title",
    //         isGreaterThanOrEqualTo: query.toLowerCase().trimLeft())
    //         .where("title",
    //         isLessThan: query.toLowerCase().trimLeft() + 'z')
    //         .get()
    //         .then((rooms) async {
    //
    //       rooms.docs.forEach((room) async {
    //
    //         print("Room ${room["title"]} ${room.id}");
    //
    //         await FirebaseFirestore.instance
    //             .collection("recordings")
    //             .where("roomId", isEqualTo: room.id)
    //             .get()
    //             .then((value){
    //
    //           recordings.clear();
    //           value.docs.forEach((element) {
    //
    //             print("Recording ${element["sid"]} ${element.id} ${room.id}");
    //
    //             if(element["isActive"]){
    //               print("");
    //               recordings.add(element.data());
    //             }
    //           });
    //         });
    //
    //       });
    //     });
    //
    //   });
    // });
  }

  // void getRooms() async {
  //   await FirebaseFirestore.instance
  //       .collectionGroup("rooms")
  //       .where("isUpcoming", isEqualTo: true)
  //       .get()
  //       .then((value){
  //         value.docs.forEach((element) {
  //           if(element["isActive"]){
  //             setState(() {
  //               rooms.add(element.data());
  //             });
  //             // print("room ${element.id} ${element["dateTime"].toDate()} ${element["isUpcoming"]}");
  //           }
  //         });
  //   });
  // }

  // void getRooms() async {
  //   await FirebaseFirestore.instance
  //       .collectionGroup("rooms")
  //       .where("isUpcoming", isEqualTo: true)
  //       .get()
  //       .then((value){
  //     value.docs.forEach((element) {
  //       print("room ${element.id} ${element["isActive"]} ${element["isUpcoming"]}");
  //     });
  //   });
  // }

  void _textChanged(String text) async {
    if (text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _clearList();
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _clearList();
    if (Validator.isNumber(text)) {
      final res = await _isbnService.getBookDetailsByISBN(text);

      final rawItems = res.map(_addBook).toList();
      setState(() {
        // _items = rawItems;
        _isLoading = false;
        rawItems.forEach((element) {
          if(element.pubDate != "null" && element.description != "No Summary"){
            _items.add(element);
          }
        });
        _items.sort((a, b) => int.parse(b.pubDate.substring(0,4)).compareTo(int.parse(a.pubDate.substring(0,4))));
      });
    } else {
      final res = await _isbnService.getBooksDetails(text);

      final rawItems = res?.map(_addBook).toList() ?? [];
      setState(() {
        // _items = rawItems;
        _isLoading = false;
        rawItems.forEach((element) {
          if(element.pubDate != "null" && element.description != "No Summary"){
            // print("------------------------");
            // print(element.title);
            // print(element.image.hashCode);
            _items.add(element);
          }
        });
        _items.sort((a, b) => int.parse(b.pubDate.substring(0,4)).compareTo(int.parse(a.pubDate.substring(0,4))));
      });
    }
  }

  VolumeInfo _addBook(dynamic book) {
    final author = book['authors'] != null && book['authors'].length > 0
        ? book['authors'].first
        : "unknown";

    return VolumeInfo(
        book?['publisher'] ?? "unknown",
        book?['title'] ?? "unknown",
        book?['publisher'] ?? "unknown",
        ImageLinks(book['image']),
        book['isbn13'] ?? book['isbn'] ?? "unknown",
        book?['synopsys'] ?? book?['synopsis'] ?? "No Summary",
        book['date_published'].toString(),
        author);
  }

  void _onError(dynamic d) {
    setState(() {
      _isLoading = false;
    });
  }

  void _clearList() {
    setState(() {
      _items.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    getbnamelist();
    // getRooms();
    // getAllRecordingIds();
    subject.stream.listen(_textChanged);
  }

  @override
  void dispose() {
    subject.close();
    _items.clear();
    list.clear();
    super.dispose();
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

  void onTextChange(String text) async {
    // print("entered $text");
    setState(() {
      list.clear();
    });

    bnamelist.forEach((element) async {
      if(element.contains(text)){
        setState(() {
          list.add(element);
        });
      }
    });

    if(list.isEmpty){
      final create = await confirmDialogAlbum(context, h2, text);
      if (create != null && create) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>
            AddBookCollection(
              title: controller.text.toLowerCase().trim(),
            )
        ));

        // await FirebaseFirestore.instance
        //     .collection("booksearch")
        //     .doc(text)
        //     .set({
        //   "book_title" : text
        // }).then((value){
        //   setState(() {
        //     bnamelist.add(text);
        //     list.add(text);
        //   });
        // });

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: theme.colorScheme.primary,
        // child:
        //   DefaultTabController(
        //   length: 2,
          child: Scaffold(

            appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 120),
              child: Container(
                color: dark_blue,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              )),
                          Flexible(
                            child: TextFormField(
                              controller: controller,
                              style: TextStyle(
                                fontFamily: 'drawerbody',
                                fontSize: 16,
                              ),
                              onChanged: (value){
                                setState(() {
                                  list.clear();
                                });
                              },
                              onFieldSubmitted: (value) {
                                setState(() {
                                  searched = true;
                                });
                                subject.add(controller.text);
                                onTextChange(controller.text.toLowerCase().trim());
                                searchReviews(value);
                                searchRecordings(value);
                                searchAlbums(value);
                                searchPosts(value);
                              },
                              decoration: registerInputDecoration.copyWith(
                                  fillColor: theme.inputDecorationTheme.fillColor,
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.secondary,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                      borderSide: BorderSide(
                                        width: 0.5,
                                      )),
                                  hintText: "Search books, collections, reviews, podcasts, etc.",
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'drawerbody',
                                  )),
                            ),
                          ),

                          //profile
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                                      onTap: () async {
                                        
                                        // await FirebaseFirestore.instance
                                        //     .collection("recordings")
                                        //     .get()
                                        //     .then((recordings){
                                        //       recordings.docs.forEach((recording) async {
                                        //
                                        //         print("roomids");
                                        //         print(recording["roomId"]);
                                        //
                                        //         try{
                                        //
                                        //           await FirebaseFirestore.instance
                                        //               .collectionGroup("rooms")
                                        //               // .where("roomID", isEqualTo: recording["roomId"])
                                        //               .get()
                                        //               .then((rooms) async {
                                        //
                                        //                 rooms.docs.forEach((r) {
                                        //                   print("${r["roomID"]} ${recording["roomId"]}");
                                        //                   if(r["roomID"] == recording["roomId"]){
                                        //                     print("416 ${recording["roomId"]}");
                                        //                   }
                                        //                 });
                                        //
                                        //             // await FirebaseFirestore.instance
                                        //             //     .collection("recordings")
                                        //             //     .where("roomId", isEqualTo: room.docs.first["roomID"])
                                        //             //     .get()
                                        //             //     .then((value){
                                        //             //   value.docs.forEach((element) async {
                                        //             //     await FirebaseFirestore.instance
                                        //             //         .collection("recordings")
                                        //             //         .doc(element.id)
                                        //             //         .set({
                                        //             //       "titleLowerCase" : room.docs.first["title"].toString().toLowerCase().trim()
                                        //             //     }, SetOptions(merge: true));
                                        //             //   });
                                        //             // });
                                        //
                                        //           });
                                        //
                                        //         } catch(e) {
                                        //           // print("error");
                                        //           // print(e);
                                        //         }
                                        //
                                        //       });
                                        // });
                                        
                                        Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                            builder: (context) => UserProfilePage(),
                                          ),
                                        );
                                      },
                                      child: RoundedImage(
                                        width: 38,
                                        height: 38,
                                        borderRadius: 35,
                                        url: auth.user?.userProfile?.profileImage,
                                      ),
                                    ),
                          )
                        ],
                      ),

                      //chips
                      Container(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 20, top: 16),
                                height: 51,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics: ClampingScrollPhysics(),
                                    itemCount: genres.length,
                                    itemBuilder: (context, i) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = i;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          decoration: BoxDecoration(
                                              color: i != selectedIndex
                                                  ? dark_blue
                                                  : Colors.white,
                                              border: Border.all(width: 0.5,color: Colors.white),
                                              borderRadius: BorderRadius.circular(24)),
                                          child: Center(
                                            child: Text(
                                              genres[i],
                                              style: TextStyle(
                                                  color: i != selectedIndex
                                                      ? Colors.white
                                                      : dark_blue,
                                                  fontFamily: "drawerbody"),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),

                      // Container(
                      //   height: 50,
                      //   child: TabBar(
                      //     indicatorColor: theme.colorScheme.secondary,
                      //     labelStyle: TextStyle(
                      //         color: theme.colorScheme.secondary,
                      //         fontSize: 16,
                      //         fontFamily: "drawerbody"),
                      //     tabs: [
                      //       Tab(
                      //         child: Text(
                      //           "ISBN",
                      //           style: TextStyle(
                      //               color: theme.colorScheme.secondary,
                      //               fontSize: 16,
                      //               fontFamily: "drawerhead"
                      //           ),
                      //         ),
                      //       ),
                      //       Tab(
                      //         child: Text(
                      //           "Collections",
                      //           style: TextStyle(
                      //               color: theme.colorScheme.secondary,
                      //               fontFamily: "drawerhead"
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),

            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      dark_blue,
                      theme.colorScheme.primary
                      //Color(0xFF2E3170)
                    ],
                    begin : Alignment.topCenter,
                    end : Alignment(0,0.5),
                    stops: [0,0.92]
                ),
              ),
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child:

                  ///all
                  selectedIndex == 0 ?
                  Column(
                    children: [

                      list.length < 1  && _items.length < 1  && controller.text.isNotEmpty && searched ?
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("no data available",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic
                              ),)
                          ],
                        ),
                      ) :

                      ///collections
                      ListView.separated(
                        itemCount: list.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index){

                          return new CollectionCard(bookName: list[index]);

                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return
                            // index != list.length-1 ?
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 20,
                              height: 1,
                              color: Colors.grey,
                            ),
                          ) ;
                          // : SizedBox.shrink();
                        },
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(5),
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width - 20,
                      //     height: 1,
                      //     color: Colors.grey,
                      //   ),
                      // ),

                      ///isbn books
                      _isLoading
                          ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: AppLoading(
                              height: 70,
                              width: 70,
                            )),
                      ) :
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        // padding: EdgeInsets.all(8.0),
                        itemCount: _items.length < 0 ? 0 : _items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              widget.onBookSelect([
                                _items[index].title,
                                _items[index].description,
                                _items[index].image.thumb,
                                _items[index].author,
                              ]);

                              Navigator.push(
                                  context, MaterialPageRoute(
                                  builder: (context) => ISBNPage(
                                    title: _items[index].title,
                                    description: _items[index].description,
                                    image: _items[index].image.thumb,
                                    authorname: _items[index].author,
                                    year: _items[index].pubDate,
                                    isbn13: _items[index].isbn13,
                                  )
                              ));
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey, width: 1)
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 75,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: FosterImage(
                                          fit: BoxFit.cover,
                                          height: 100,
                                          imageUrl: _items[index]
                                              .image
                                              .thumb
                                              .toString()),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _items[index].title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'drawerhead',
                                            ),
                                          ),
                                          Text(
                                            "By " + _items[index].author,
                                            maxLines: 10,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontFamily: 'drawerbody',
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Year : " + _items[index].pubDate.substring(0,4) + "   ISBN :" + _items[index].isbn13,
                                            maxLines: 10,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontFamily: 'drawerbody',
                                            ),
                                          ),
                                          // SizedBox(
                                          //   height: 20,
                                          // ),
                                          // Text(
                                          //   _items[index].description,
                                          //   maxLines: 3,
                                          //   overflow: TextOverflow.ellipsis,
                                          //   style: TextStyle(
                                          //     fontSize: 12,
                                          //     fontFamily: 'drawerbody',
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          //  return  BookCardMinimalistic(_items[index]);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return //index != list.length ?
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 20,
                              height: 1,
                              color: Colors.grey,
                            ),
                          ) ;
                          // ) : SizedBox.shrink();
                        },
                      ),
                    ],
                  ) :

                  ///books isbn
                  selectedIndex == 1 ?
                  Column(
                      children: [
                        _items.length < 1  && controller.text.isNotEmpty && searched ?
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("no data available",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic
                                ),)
                            ],
                          ),
                        ) :

                        ///isbn books
                        _isLoading
                            ? Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: AppLoading(
                                height: 70,
                                width: 70,
                              )),
                        ) :
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          // padding: EdgeInsets.all(8.0),
                          itemCount: _items.length < 0 ? 0 : _items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                widget.onBookSelect([
                                  _items[index].title,
                                  _items[index].description,
                                  _items[index].image.thumb,
                                  _items[index].author,
                                ]);

                                Navigator.push(
                                    context, MaterialPageRoute(
                                    builder: (context) => ISBNPage(
                                      title: _items[index].title,
                                      description: _items[index].description,
                                      image: _items[index].image.thumb,
                                      authorname: _items[index].author,
                                      year: _items[index].pubDate,
                                      isbn13: _items[index].isbn13,
                                    )
                                ));
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey, width: 1)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 75,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: FosterImage(
                                            fit: BoxFit.cover,
                                            height: 100,
                                            imageUrl: _items[index]
                                                .image
                                                .thumb
                                                .toString()),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _items[index].title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'drawerhead',
                                              ),
                                            ),
                                            Text(
                                              "By " + _items[index].author,
                                              maxLines: 10,
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontFamily: 'drawerbody',
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Year : " + _items[index].pubDate.substring(0,4) + "   ISBN :" + _items[index].isbn13,
                                              maxLines: 10,
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontFamily: 'drawerbody',
                                              ),
                                            ),
                                            // SizedBox(
                                            //   height: 20,
                                            // ),
                                            // Text(
                                            //   _items[index].description,
                                            //   maxLines: 3,
                                            //   overflow: TextOverflow.ellipsis,
                                            //   style: TextStyle(
                                            //     fontSize: 12,
                                            //     fontFamily: 'drawerbody',
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            //  return  BookCardMinimalistic(_items[index]);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return //index != list.length ?
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 20,
                                  height: 1,
                                  color: Colors.grey,
                                ),
                              ) ;
                            // ) : SizedBox.shrink();
                          },
                        ),
                      ],
                    ) :

                  ///reviews
                  selectedIndex == 2 ?
                  Column(
                    children: [

                      reviews.length < 1  && controller.text.isNotEmpty && searched ?
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("no data available",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic
                              ),)
                          ],
                        ),
                      ) :

                      reviews.length > 0
                          ? ListView.builder(
                          itemCount: reviews.length,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) {

                            if(index >= reviews.length){
                              return SizedBox.shrink();
                            }

                            // print(reviews[index]);

                            return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection("reviews")
                                    .doc(reviews[index]["id"])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if(!snapshot.hasData){
                                    return SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10
                                          ),
                                          child: BitTile(bit: snapshot.data!.data()!, authId: snapshot.data!["editorId"]),
                                        )
                                    ),
                                  );
                                }
                            );
                          })
                          : SizedBox.shrink(),
                    ],
                  ) :

                  // ///room
                  // selectedIndex == 3 ?
                  // Column(
                  //   children: [
                  //     ListView.builder(
                  //       shrinkWrap: true,
                  //       physics: NeverScrollableScrollPhysics(),
                  //       itemCount: rooms.length,
                  //       itemBuilder: (context, index) {
                  //         // if (index == snapshot.data!.length) {
                  //         //   if (index == 0) {
                  //         //     return SizedBox.shrink();
                  //         //   }
                  //         //   return SizedBox(
                  //         //     height: 200,
                  //         //   );
                  //         // }
                  //
                  //         bool active = rooms[index]["isActive"];
                  //         return active
                  //             ? Padding(
                  //           padding: const EdgeInsets.only(top: 10),
                  //           child: Container(
                  //             margin: EdgeInsets.symmetric(
                  //                 horizontal:
                  //                 MediaQuery.of(context).size.width *
                  //                     0.02),
                  //             decoration: BoxDecoration(
                  //                 image: DecorationImage(
                  //                     fit: BoxFit.cover,
                  //                     image: rooms[index]
                  //                     ["image"] ==
                  //                         ''
                  //                         ? Image.asset(
                  //                         IMAGES + "logo_white.png")
                  //                         .image
                  //                         : NetworkImage(snapshot
                  //                         .data![index]['image'])),
                  //                 gradient: LinearGradient(
                  //                   begin: Alignment.topLeft,
                  //                   end: Alignment.bottomRight,
                  //                   colors: [
                  //                     gradientBottom,
                  //                     gradientTop,
                  //                   ],
                  //                 ),
                  //                 borderRadius: BorderRadius.circular(24)),
                  //             child: Container(
                  //               padding: const EdgeInsets.all(16),
                  //               decoration: BoxDecoration(
                  //                 gradient: LinearGradient(
                  //                     colors: [
                  //                       Colors.black.withOpacity(0.2),
                  //                       Colors.black.withOpacity(0.9)
                  //                     ],
                  //                     begin: Alignment.centerRight,
                  //                     end: Alignment.centerLeft),
                  //                 borderRadius: BorderRadius.circular(24),
                  //               ),
                  //               child: Column(
                  //                 crossAxisAlignment:
                  //                 CrossAxisAlignment.start,
                  //                 children: [
                  //                   Row(
                  //                     mainAxisAlignment:
                  //                     MainAxisAlignment.spaceBetween,
                  //                     crossAxisAlignment:
                  //                     CrossAxisAlignment.start,
                  //                     children: [
                  //                       //title
                  //                       Flexible(
                  //                         fit: FlexFit.loose,
                  //                         child: Text(
                  //                           snapshot.data![index]['title'],
                  //                           overflow: TextOverflow.fade,
                  //                           maxLines: 2,
                  //                           softWrap: false,
                  //                           style: TextStyle(
                  //                               color: Colors.white,
                  //                               fontSize: 20,
                  //                               fontWeight:
                  //                               FontWeight.bold),
                  //                         ),
                  //                       ),
                  //                       SizedBox(
                  //                         width: 10,
                  //                       ),
                  //                       //genre
                  //                       Container(
                  //                         padding: const EdgeInsets.all(8),
                  //                         decoration: BoxDecoration(
                  //                             color: Colors.black45,
                  //                             border: Border.all(
                  //                                 width: 1,
                  //                                 color: Colors.black),
                  //                             borderRadius:
                  //                             BorderRadius.circular(
                  //                                 24)),
                  //                         child: Text(
                  //                             snapshot.data![index]
                  //                             ['genre'],
                  //                             style: TextStyle(
                  //                                 color: Colors.white,
                  //                                 fontWeight:
                  //                                 FontWeight.bold)),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                   //author
                  //                   Padding(
                  //                     padding:
                  //                     const EdgeInsets.only(top: 8.0),
                  //                     child: Row(
                  //                       mainAxisAlignment:
                  //                       MainAxisAlignment.spaceBetween,
                  //                       children: [
                  //                         Text(
                  //                           "by " +
                  //                               snapshot.data![index]
                  //                               ['roomCreator'],
                  //                           style: TextStyle(
                  //                             color: Colors.white,
                  //                             fontSize: 12,
                  //                             fontFamily: "Lato",
                  //                           ),
                  //                         ),
                  //                         GestureDetector(
                  //                             onTap: () {
                  //                               Navigator.push(
                  //                                 context,
                  //                                 CupertinoPageRoute(
                  //                                   builder: (context) =>
                  //                                       RoomInfo(
                  //                                         data: snapshot
                  //                                             .data?[index]!,
                  //                                         insideRoom: false,
                  //                                       ),
                  //                                 ),
                  //                               );
                  //                             },
                  //                             child: Icon(
                  //                               Icons.info_outline_rounded,
                  //                               color: Colors.white,
                  //                             ))
                  //                       ],
                  //                     ),
                  //                   ),
                  //                   const SizedBox(
                  //                     height: 24,
                  //                   ),
                  //
                  //                   if (snapshot.data![index]
                  //                   ['followersOnly'] ==
                  //                       true ||
                  //                       snapshot.data![index]
                  //                       ['inviteOnly'] ==
                  //                           true) ...[
                  //                     Chip(
                  //                       label: Text(snapshot.data![index]
                  //                       ['inviteOnly'] ==
                  //                           true
                  //                           ? 'Invite Only'
                  //                           : 'Followers Only'),
                  //                       backgroundColor: Colors.grey[300]!
                  //                           .withOpacity(.5),
                  //                       elevation: 0,
                  //                       shadowColor: Colors.transparent,
                  //                     ),
                  //                   ],
                  //
                  //                   //datetime
                  //                   Row(
                  //                     children: [
                  //                       Text(
                  //                         DateFormat.yMMMd()
                  //                             .add_jm()
                  //                             .format(snapshot.data![index]
                  //                         ['dateTime']
                  //                             .toDate()
                  //                             .toLocal()),
                  //                         style: TextStyle(
                  //                             fontSize: 14,
                  //                             color: Colors.white),
                  //                       ),
                  //                       Expanded(child: Container()),
                  //                       GestureDetector(
                  //                         onTap: () async {
                  //                           Add2Calendar.addEvent2Cal(
                  //                               buildEvent(
                  //                                   'room',
                  //                                   snapshot.data![index]['title']
                  //                                   ,snapshot
                  //                                   .data![index]
                  //                               ['dateTime']
                  //                                   .toDate()));
                  //                         },
                  //                         child: Icon(
                  //                           Icons.calendar_today,
                  //                           color: Colors.white,
                  //                           size: 25,
                  //                         ),
                  //                       ),
                  //                       SizedBox(
                  //                         width: 10,
                  //                       ),
                  //                       GestureDetector(
                  //                         onTap: () async {
                  //                           // Opacity will become zero
                  //                           // if (!isInviteOnly) return;
                  //                           Share.share(
                  //                               await DynamicLinksApi
                  //                                   .inviteOnlyRoomLink(
                  //                                 snapshot.data![index]
                  //                                 ["roomID"],
                  //                                 snapshot.data![index]["id"],
                  //                                 roomName: snapshot
                  //                                     .data![index]["title"],
                  //                                 imageUrl: snapshot
                  //                                     .data![index]["image"],
                  //                               ));
                  //                         },
                  //                         child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                  //                         // Icon(
                  //                         //   Icons.share_rounded,
                  //                         //   color: Colors.white,
                  //                         // ),
                  //                       ),
                  //                       SizedBox(
                  //                         width: 10,
                  //                       ),
                  //
                  //                       //delete
                  //                       snapshot.data![index]['id'] ==
                  //                           auth.user!.id
                  //                           ? GestureDetector(
                  //                         onTap: () async {
                  //                           // _roomService
                  //                           //     .updateIsActive(snapshot.data![index]);
                  //                           await roomCollection
                  //                               .doc(snapshot
                  //                               .data![index]
                  //                           ['id'])
                  //                               .collection("rooms")
                  //                               .doc(snapshot
                  //                               .data![index]
                  //                           ['roomID'])
                  //                               .update({
                  //                             'isActive': false
                  //                           });
                  //                           await FirebaseFirestore
                  //                               .instance
                  //                               .collection("feeds")
                  //                               .doc(snapshot
                  //                               .data![index]
                  //                           ['roomID'])
                  //                               .delete();
                  //                           setState(() {
                  //                             active = false;
                  //                           });
                  //                         },
                  //                         child: Icon(
                  //                           Icons
                  //                               .delete_outline_outlined,
                  //                           color: Colors.white,
                  //                           size: 30,
                  //                         ),
                  //                       )
                  //                           : SizedBox.shrink(),
                  //
                  //                       //report
                  //                       snapshot.data![index]['id'] !=
                  //                           auth.user!.id
                  //                           ? GestureDetector(
                  //                         onTap: () async {
                  //                           Navigator.push(
                  //                               context,
                  //                               MaterialPageRoute(
                  //                                   builder: (context) =>
                  //                                       ReportContent(
                  //                                         contentId: snapshot.data![index]["roomID"],
                  //                                         contentType: 'Room',
                  //                                         contentOwnerId: snapshot.data![index]["id"],
                  //                                       )
                  //                               ));
                  //                         },
                  //                         child: Icon(
                  //                           Icons
                  //                               .flag,
                  //                           color: Colors.red,
                  //                           size: 20,
                  //                         ),
                  //                       )
                  //                           : SizedBox.shrink(),
                  //                     ],
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         )
                  //             : SizedBox.shrink();
                  //       },
                  //     ),
                  //   ],
                  // ) :

                  ///posts
                  selectedIndex == 3 ?
                  Column(
                    children: [
                      posts.length < 1  && controller.text.isNotEmpty && searched ?
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("no data available",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic
                              ),)
                          ],
                        ),
                      ) :

                      posts.length > 0
                          ? GridView.builder(
                          itemCount: posts.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          padding: EdgeInsets.all(10),
                          scrollDirection: Axis.vertical,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
                          itemBuilder: (context, index){
                            return StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("posts")
                                    .doc(posts[index]["id"])
                                    .snapshots(),
                                builder: (context, post) {

                                  if(!post.hasData){
                                    return SizedBox.shrink();
                                  }

                                  return GestureDetector(

                                    onTap: (){

                                      if(post.data!["isActive"]){
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) {
                                              return PageSinglePost(
                                                postId: post.data!["id"],
                                                dateTime: post.data!["dateTime"],
                                                userid: post.data!["userid"],
                                                userProfile: post.data!["userProfile"],
                                                username: post.data!["username"],
                                                image: post.data!["image"],
                                                caption: post.data!["caption"],
                                                likes: post.data!["likes"].toString(),
                                                comments: post.data!["comments"].toString(),
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        ToastMessege("This Reading has been deleted.", context: context);
                                      }
                                    },

                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Container(
                                        height: 220,
                                        decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(child: Container()),

                                            //image
                                            Container(
                                              width: 140,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: post.data!["image"].isEmpty ? Colors.grey : Colors.transparent
                                                  ),
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: post.data!["image"].toString().isEmpty ?
                                                Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                                                Image.network(post.data!["image"], fit: BoxFit.cover,),
                                              ),
                                            ),

                                            //data
                                            Padding(
                                              padding: const EdgeInsets.only(left: 0),
                                              child: Container(
                                                height: 60,
                                                width: 130,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(),
                                                    Text(post.data!["bookName"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
                                                    Text(post.data!["username"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
                                                    SizedBox(),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            );
                          }
                      )
                          : SizedBox.shrink(),
                    ],
                  ) :

                  ///collection
                  selectedIndex == 4 ?
                  Column(
                    children: [

                      list.length < 1  && controller.text.isNotEmpty && searched ?
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("no data available",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic
                                ),)
                              ],
                            ),
                          ) :

                      ///collections
                      ListView.separated(
                        itemCount: list.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index){

                          return new CollectionCard(bookName: list[index]);

                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return
                            // index != list.length-1 ?
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                width: MediaQuery.of(context).size.width - 20,
                                height: 1,
                                color: Colors.grey,
                              ),
                            ) ;
                          // : SizedBox.shrink();
                        },
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(5),
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width - 20,
                      //     height: 1,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                    ],
                  ) :

                  ///recordings
                  selectedIndex == 5 ?
                  Column(
                    children: [
                      recordings.length < 1  && controller.text.isNotEmpty && searched ?
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("no data available",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic
                              ),)
                          ],
                        ),
                      ) :

                      recordings.length > 0
                          ? ListView.builder(
                          itemCount: recordings.length,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) {

                            if(index >= recordings.length){
                              return SizedBox.shrink();
                            }

                            return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection("recordings")
                                    .doc(recordings[index]["id"])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if(!snapshot.hasData){
                                    return SizedBox.shrink();
                                  }
                                  return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                                      stream: FirebaseFirestore.instance
                                          .collection("rooms")
                                          .doc(snapshot.data!["userId"])
                                          .collection("rooms")
                                          .doc(snapshot.data!["roomId"])
                                          .snapshots(),
                                      builder: (context, room){
                                        if(!room.hasData){
                                          return SizedBox.shrink();
                                        }

                                        return GestureDetector(

                                          onTap: () async {

                                            Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                builder: (context) =>
                                                    SinglePodcastPlay(recId: recordings[index]["id"]),
                                              ),
                                            );

                                            // List list = [];
                                            // await FirebaseFirestore.instance
                                            // .collection("recordings")
                                            // .get()
                                            // .then((value){
                                            //
                                            //   for(int i=0; i<value.docs.length; i++){
                                            //     // print(i);
                                            //     if(value.docs[i].id == recordings[index]["id"]){
                                            //       int INDEX = i;
                                            //       // print(value.docs[i].id);
                                            //       // print(recordings[index]["id"]);
                                            //       Navigator.push(
                                            //         context,
                                            //         new MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               UserRecorings(
                                            //                   page: 0
                                            //               ),
                                            //         ),
                                            //       );
                                            //     }
                                            //   }
                                            // });
                                          },

                                          child: PodcastTile(
                                              podImage: room.data!["image"],
                                              podTitle: room.data!["title"],
                                              podAuthor: room.data!["roomCreator"],
                                              podId: recordings[index]["id"]
                                          ),
                                        );
                                      }
                                  );
                                }
                            );
                          })
                          : SizedBox.shrink(),
                    ],
                  ) :

                  ///albums
                  selectedIndex == 6 ?
                  Column(
                    children: [
                      albums.length < 1  && controller.text.isNotEmpty && searched ?
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("no data available",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic
                              ),)
                          ],
                        ),
                      ) :

                      albums.length > 0
                          ? GridView.builder(
                          itemCount: albums.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.all(10),
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
                          itemBuilder: (context, index){
                            return StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("albums")
                                    .doc(albums[index]["id"])
                                    .snapshots(),
                                builder: (context, album) {

                                  if(!album.hasData){
                                    return SizedBox.shrink();
                                  }

                                  return GestureDetector(

                                    onTap: (){

                                      if(album.data!["isActive"]){
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) =>
                                                AlbumPage(
                                                  albumId: albums[index]["id"],
                                                  authId: album.data!["authorId"],
                                                  fromShare: true,
                                                )
                                            ));
                                      } else {
                                        ToastMessege("This Album has been deleted", context: context);
                                      }
                                    },

                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Container(
                                        height: 220,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(child: Container()),

                                            //image
                                            Container(
                                              width: 140,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: album.data!["image"].isEmpty ? Colors.grey : Colors.transparent
                                                  ),
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: album.data!["image"].toString().isEmpty ?
                                                Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                                                Image.network(album.data!["image"], fit: BoxFit.fill,),
                                              ),
                                            ),

                                            //data
                                            Padding(
                                              padding: const EdgeInsets.only(left: 0),
                                              child: Container(
                                                height: 60,
                                                width: 130,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(),
                                                    Text(album.data!["title"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
                                                    Text(album.data!["authorName"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
                                                    Text("${album.data!["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
                                                    SizedBox(),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            );
                          }
                      )
                          : SizedBox.shrink(),
                    ],
                  ) : SizedBox.shrink()
                ),
              ),
            )

          ),
        // ),
      ),
    );
  }
}

Future<bool?> confirmDialogAlbum(BuildContext context, TextStyle h2, String title) async {
  return showDialog<bool>(
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
            alignment: Alignment(0, 0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: size.width * 0.9,
                constraints: BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a book title by the name "$title"',
                      style: h2.copyWith(
                        fontSize: 15.sp,
                        color: theme.colorScheme.inversePrimary,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.secondary),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            "Later",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.secondary),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            "Sure",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.white,
                            ),
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