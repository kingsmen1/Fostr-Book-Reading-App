import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/models/UserModel/bookMarks.dart';
import 'package:fostr/pages/comingSoon/librarymore.dart';
import 'package:fostr/pages/user/Book.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:googleapis/appengine/v1.dart';
import 'package:googleapis/workflowexecutions/v1.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/UserModel/User.dart';
import '../../providers/AuthProvider.dart';
import '../../widgets/ImageContainer.dart';
// import 'package:marquee/marquee.dart';

const selfhelpUrl =
    'https://www.googleapis.com/books/v1/volumes?q=subject:self+help';
const fantasyUrl =
    'https://www.googleapis.com/books/v1/volumes?q=subject:fantasy';
const fictionUrl =
    'https://www.googleapis.com/books/v1/volumes?q=subject:fiction';
const scifiUrl =
    'https://www.googleapis.com/books/v1/volumes?q=subject:Science+Fiction';
List<VolumeInfo> _selfhelpitems = [];
List<VolumeInfo> _fantitems = [];
List<VolumeInfo> _fictitems = [];
List<VolumeInfo> _scifiitems = [];
// List<List<VolumeInfo>> _genreitems = List.filled(21, [], growable: true);
Map<String, List<VolumeInfo>> _genreitems = {};

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  bool _isLoading = false;

  void initState() {
    super.initState();
    dynamic book;
    _clearList();
    _fetchselfhelp();
    _fetchfant();
    _fetchfict();
    _fetchscifi();
    fetchGenres();
    // _fetchGenreBooks(book);
  }

  void _clearList() {
    setState(() {
      _selfhelpitems.clear();
      _fictitems.clear();
      _fantitems.clear();
      _scifiitems.clear();
    });
  }

  void _fetchselfhelp() {
    http
        .get(Uri.parse(selfhelpUrl))
        .then((response) => response.body)
        .then(json.decode)
        .then((map) => map["items"])
        .then((list) {
      list.forEach(_selfhelpadd);
    }).then((e) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _fetchfant() {
    http
        .get(Uri.parse(fantasyUrl))
        .then((response) => response.body)
        .then(json.decode)
        .then((map) => map["items"])
        .then((list) {
      list.forEach(_fantadd);
    }).then((e) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _fetchfict() {
    http
        .get(Uri.parse(fictionUrl))
        .then((response) => response.body)
        .then(json.decode)
        .then((map) => map["items"])
        .then((list) {
      list.forEach(_fictadd);
    }).then((e) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _fetchscifi() {
    http
        .get(Uri.parse(scifiUrl))
        .then((response) => response.body)
        .then(json.decode)
        .then((map) => map["items"])
        .then((list) {
      list.forEach(_scifiadd);
    }).then((e) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _selfhelpadd(dynamic book) {
    setState(() {
      _selfhelpitems.add(VolumeInfo(
          book['publisher'],
          book['title'],
          book['publisher'],
          ImageLinks(book['image']),
          book['isbn13'],
          book['synopsys'],
          book['date_published'],
          book['authors'][0]));
    });
  }

  void _fantadd(dynamic book) {
    setState(() {
      _fantitems.add(VolumeInfo(
          book['publisher'],
          book['title'],
          book['publisher'],
          ImageLinks(book['image']),
          book['isbn13'],
          book['synopsys'],
          book['date_published'],
          book['authors'][0]));
    });
  }

  void _fictadd(dynamic book) {
    setState(() {
      _fictitems.add(VolumeInfo(
          book['publisher'],
          book['title'],
          book['publisher'],
          ImageLinks(book['image']),
          book['isbn13'],
          book['synopsys'],
          book['date_published'],
          book['authors'][0]));
    });
  }

  void _scifiadd(dynamic book) {
    setState(() {
      _scifiitems.add(VolumeInfo(
          book['publisher'],
          book['title'],
          book['publisher'],
          ImageLinks(book['image']),
          book['isbn13'],
          book['synopsys'],
          book['date_published'],
          book['authors'][0]));
    });
  }

  UserService userServices = GetIt.I<UserService>();

  void updateProfile(Map<String, dynamic> data) async {
    await userServices.updateUserField(data);
  }

  List<dynamic> bookmarks = [];
  List<dynamic> genres = [];

  Future<List<dynamic>> fetchbookmarks(User? user) async {
    var doc =
        FirebaseFirestore.instance.collection("users").doc(user!.id).get();
    var list;
    doc.then((value) => {
          list = value.data()?['bookmarks'],
          bookmarks = list == null ? [] : list
        });
    return bookmarks;
  }

  void fetchGenres() async {
    dynamic book;
    try {
      var doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(auth.FirebaseAuth.instance.currentUser!.uid)
          .get();
      List<dynamic> list;
      list = doc.data()?['userProfile']['genres'];
      setState(() {
        genres = list;
      });
      print("list $list");
      if (doc.data() != null) {
        for (var el in genres) {
          String val = el.toString().replaceAll(" ", "+");
          _fetchGenreBooks(book, val);
        }
        // setState(() {
        //   _isLoading = false;
        // });
      }
    } catch (e) {
      print(e.toString());
    }

    //return genres;
  }

  void _fetchGenreBooks(dynamic book, String genre) async {
    // setState(() {
    //   genres = await fetchGenres();
    // });
    print('genres $genres');
    // genres.forEach((e) {
    // String val = e.toString().replaceAll(" ", "+");
    String genreUrl =
        'https://www.googleapis.com/books/v1/volumes?q=subject:$genre';
    // try {
    //   final res = await http.get(Uri.parse(genreUrl));

    // } catch (e) {
    //   print(e.toString());
    // }
    http
        .get(Uri.parse(genreUrl))
        .then((response) => response.body)
        .then(json.decode)
        .then((map) => map["items"])
        .then((list) {
      List<VolumeInfo> tempList = [];
      for (var element in list) {
        tempList.add(VolumeInfo(
            book['publisher'],
            book['title'],
            book['publisher'],
            ImageLinks(book['image']),
            book['isbn13'],
            book['synopsys'],
            book['date_published'],
            book['authors'][0]));
        // _genreadd(e);

      }
      setState(() {
        _genreitems.putIfAbsent(genre, () => tempList);
      });
      // list.forEach(() {
      //   setState(() {
      //     _genreitems[genres.indexOf(e)].add(new VolumeInfo(
      //           book['volumeInfo']['publisher'],
      //           book['volumeInfo']['title'],
      //           book['volumeInfo']['publisher'],
      //           new ImageLinks(book['volumeInfo']['imageLinks']['thumbnail']),
      //           book['volumeInfo']['infoLink'],
      //           book['volumeInfo']['description'],
      //           book['volumeInfo']['publishedDate']));
      //     });
      //   // _genreadd(e);
      // }
      // );
    });
    // .then((e) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
    // });
  }

  // List<dynamic> genrelist = [];
  // _fetchData() {
  //   var doc = FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(auth.FirebaseAuth.instance.currentUser!.uid)
  //         .get();
  //     doc.then((value) {
  //       if (value.data()?['userProfile']?["genres"] != null) {
  //         setState(() {
  //           genrelist = value.data()?['userProfile']?["genres"];
  //         });
  //       }
  //     });
  //     print("Genrelist $genrelist");
  // }

  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    // var doc = FirebaseFirestore.instance
    //       .collection("users")
    //       .doc(auth.user!.id)
    //       .get();
    //   doc.then((value) {
    //     if (value.data()?['userProfile']?["genres"] != null) {
    //       setState(() {
    //         genrelist = value.data()?['userProfile']?["genres"];
    //       });
    //     }
    //   });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('Foster Library'),
            leading: GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Interests',
                ),
                Tab(
                  text: 'Explore',
                ),
                Tab(
                  text: 'Your Reads',
                ),
              ],
            ),
          ),
          body: TabBarView(children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                        child: Text(
                          'Recommendations from your favorite genres',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height * .8,
                      child: genres.length > 0
                          ? ListView.builder(
                              // scrollDirection: Axis.vertical,
                              itemCount: genres.length,
                              itemBuilder: (BuildContext context, int index1) {
                                final modifiedGenre = genres[index1]
                                    .toString()
                                    .replaceAll(" ", "+");
                                return Column(children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                                    child: Text(
                                      '${genres[index1]}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.45,
                                    child: SingleChildScrollView(
                                      // scrollDirection: Axis.vertical,
                                      child: Row(
                                        children: [
                                          if (_genreitems.length > 0)
                                            ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                padding:
                                                    new EdgeInsets.all(8.0),
                                                itemCount:
                                                    _genreitems[modifiedGenre]
                                                            ?.length ??
                                                        0,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                          builder: (context) => LibraryMore(
                                                              image: _genreitems[
                                                                          modifiedGenre]![
                                                                      index]
                                                                  .image
                                                                  .thumb,
                                                              title: _genreitems[
                                                                          modifiedGenre]![
                                                                      index]
                                                                  .title,
                                                              publisher:
                                                                  _genreitems[modifiedGenre]![
                                                                          index]
                                                                      .publisher,
                                                              pubdate: _genreitems[
                                                                          modifiedGenre]![
                                                                      index]
                                                                  .pubDate,
                                                              desc: _genreitems[
                                                                      modifiedGenre]![index]
                                                                  .description),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      color: Colors.black,
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                              top: 30,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  color: Colors
                                                                      .grey
                                                                      .shade900,
                                                                ),
                                                                constraints:
                                                                    BoxConstraints(
                                                                  maxHeight: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.25,
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8,
                                                                ),
                                                              )),
                                                          Positioned(
                                                            bottom: 80,
                                                            right: 10,
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                final _userCollection =
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "users");
                                                                BookMarks br = BookMarks(
                                                                    _genreitems[modifiedGenre]![
                                                                            index]
                                                                        .title,
                                                                    _genreitems[modifiedGenre]![
                                                                            index]
                                                                        .publisher,
                                                                    _genreitems[modifiedGenre]![
                                                                            index]
                                                                        .image
                                                                        .thumb,
                                                                    _genreitems[modifiedGenre]![
                                                                            index]
                                                                        .description,
                                                                    _genreitems[modifiedGenre]![
                                                                            index]
                                                                        .pubDate);
                                                                _userCollection
                                                                    .doc(
                                                                        user.id)
                                                                    .set({
                                                                  "bookmarks":
                                                                      FieldValue
                                                                          .arrayUnion([
                                                                    br.toMap()
                                                                  ])
                                                                }, SetOptions(merge: true));
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "Book added to your collection!",
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade800,
                                                                    textColor:
                                                                        Colors
                                                                            .white);
                                                              },
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 10,
                                                            left: 20,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Image(
                                                                  image: NetworkImage(
                                                                      "${_genreitems[modifiedGenre]![index].image.thumb}"),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  height: 150,
                                                                  width: 100),
                                                            ),
                                                          ),
                                                          Positioned(
                                                              top: 50,
                                                              left: 130,
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            40),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "${_genreitems[modifiedGenre]![index].title}",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    // Marquee(
                                                                    //   text : "${_scifiitems[index].title}",
                                                                    //   style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold,
                                                                    // ),
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Text(
                                                                      "${_genreitems[modifiedGenre]![index].publisher}",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white70,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                    //Text("Elisabeth Young-Bruehl illuminates the psychological and intellectual demands writing biography makes on the biographer and explores the complex and frequently conflicted relationship between feminism and psychoanalysis. She considers what remains valuable in Sigmund Freud's work, and what areas - theory of character, for instance - must be rethought to be useful for current psychoanalytic work, for feminist studies, and for social theory. Psychoanalytic theory used for biography, she argues, can yield insights for psychoanalysis itself, particularly in the understanding of creativity.", style: TextStyle(color: Colors.white,fontSize: 1), overflow: TextOverflow.ellipsis,)
                                                                  ],
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]);
                              },
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                // height: MediaQuery.of(context).size.height * 20,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                        child: Text(
                          'Other Recommendations',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                        child: Text(
                          'Science Fiction',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: new EdgeInsets.all(8.0),
                                itemCount: _scifiitems.length < 0
                                    ? 0
                                    : _scifiitems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => LibraryMore(
                                              image: _scifiitems[index]
                                                  .image
                                                  .thumb,
                                              title: _scifiitems[index].title,
                                              publisher:
                                                  _scifiitems[index].publisher,
                                              pubdate:
                                                  _scifiitems[index].pubDate,
                                              desc: _scifiitems[index]
                                                  .description),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      color: Colors.black,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              top: 30,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey.shade900,
                                                ),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.25,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                ),
                                              )),
                                          Positioned(
                                            bottom: 80,
                                            right: 10,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                final _userCollection =
                                                    FirebaseFirestore.instance
                                                        .collection("users");
                                                BookMarks br = BookMarks(
                                                    _scifiitems[index].title,
                                                    _scifiitems[index]
                                                        .publisher,
                                                    _scifiitems[index]
                                                        .image
                                                        .thumb,
                                                    _scifiitems[index]
                                                        .description,
                                                    _scifiitems[index].pubDate);
                                                _userCollection
                                                    .doc(user.id)
                                                    .set({
                                                  "bookmarks":
                                                      FieldValue.arrayUnion(
                                                          [br.toMap()])
                                                }, SetOptions(merge: true));
                                                ToastMessege(
                                                    "Book added to your collection!",
                                                    context: context);
                                                // Fluttertoast.showToast(msg: "Book added to your collection!", backgroundColor: Colors.grey.shade800, textColor: Colors.white);
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            left: 20,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image(
                                                  image: NetworkImage(
                                                      "${_scifiitems[index].image.thumb}"),
                                                  fit: BoxFit.fill,
                                                  height: 150,
                                                  width: 100),
                                            ),
                                          ),
                                          Positioned(
                                              top: 50,
                                              left: 130,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(right: 40),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${_scifiitems[index].title}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    // Marquee(
                                                    //   text : "${_scifiitems[index].title}",
                                                    //   style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold,
                                                    // ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Text(
                                                      "${_scifiitems[index].publisher}",
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12),
                                                    ),
                                                    //Text("Elisabeth Young-Bruehl illuminates the psychological and intellectual demands writing biography makes on the biographer and explores the complex and frequently conflicted relationship between feminism and psychoanalysis. She considers what remains valuable in Sigmund Freud's work, and what areas - theory of character, for instance - must be rethought to be useful for current psychoanalytic work, for feminist studies, and for social theory. Psychoanalytic theory used for biography, she argues, can yield insights for psychoanalysis itself, particularly in the understanding of creativity.", style: TextStyle(color: Colors.white,fontSize: 1), overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Text(
                          'Fantasy',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: new EdgeInsets.all(8.0),
                                itemCount: _fantitems.length < 0
                                    ? 0
                                    : _fantitems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => LibraryMore(
                                              image:
                                                  _fantitems[index].image.thumb,
                                              title: _fantitems[index].title,
                                              publisher:
                                                  _fantitems[index].publisher,
                                              pubdate:
                                                  _fantitems[index].pubDate,
                                              desc: _fantitems[index]
                                                  .description),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      color: Colors.black,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              top: 30,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey.shade900,
                                                ),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.25,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                ),
                                              )),
                                          Positioned(
                                            bottom: 80,
                                            right: 10,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                final _userCollection =
                                                    FirebaseFirestore.instance
                                                        .collection("users");
                                                BookMarks br = BookMarks(
                                                    _fantitems[index].title,
                                                    _fantitems[index].publisher,
                                                    _fantitems[index]
                                                        .image
                                                        .thumb,
                                                    _fantitems[index]
                                                        .description,
                                                    _fantitems[index].pubDate);
                                                _userCollection
                                                    .doc(user.id)
                                                    .set({
                                                  "bookmarks":
                                                      FieldValue.arrayUnion(
                                                          [br.toMap()])
                                                }, SetOptions(merge: true));
                                                ToastMessege(
                                                    "Book added to your collection!",
                                                    context: context);
                                                // Fluttertoast.showToast(msg: "Book added to your collection!", backgroundColor: Colors.grey.shade800, textColor: Colors.white);
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            left: 20,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image(
                                                  image: NetworkImage(
                                                      "${_fantitems[index].image.thumb}"),
                                                  fit: BoxFit.fill,
                                                  height: 150,
                                                  width: 100),
                                            ),
                                          ),
                                          Positioned(
                                              left: 130,
                                              top: 50,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${_fantitems[index].title}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Text(
                                                      "${_fantitems[index].publisher}",
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12),
                                                    ),
                                                    //Text("Elisabeth Young-Bruehl illuminates the psychological and intellectual demands writing biography makes on the biographer and explores the complex and frequently conflicted relationship between feminism and psychoanalysis. She considers what remains valuable in Sigmund Freud's work, and what areas - theory of character, for instance - must be rethought to be useful for current psychoanalytic work, for feminist studies, and for social theory. Psychoanalytic theory used for biography, she argues, can yield insights for psychoanalysis itself, particularly in the understanding of creativity.", style: TextStyle(color: Colors.white,fontSize: 1), overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                        child: Text(
                          'Self Help',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: new EdgeInsets.all(8.0),
                                itemCount: _selfhelpitems.length < 0
                                    ? 0
                                    : _selfhelpitems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => LibraryMore(
                                              image: _selfhelpitems[index]
                                                  .image
                                                  .thumb,
                                              title:
                                                  _selfhelpitems[index].title,
                                              publisher: _selfhelpitems[index]
                                                  .publisher,
                                              pubdate:
                                                  _selfhelpitems[index].pubDate,
                                              desc: _selfhelpitems[index]
                                                  .description),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      color: Colors.black,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              top: 30,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey.shade900,
                                                ),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.25,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                ),
                                              )),
                                          Positioned(
                                            bottom: 80,
                                            right: 10,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                final _userCollection =
                                                    FirebaseFirestore.instance
                                                        .collection("users");
                                                BookMarks br = BookMarks(
                                                    _selfhelpitems[index].title,
                                                    _selfhelpitems[index]
                                                        .publisher,
                                                    _selfhelpitems[index]
                                                        .image
                                                        .thumb,
                                                    _selfhelpitems[index]
                                                        .description,
                                                    _selfhelpitems[index]
                                                        .pubDate);
                                                _userCollection
                                                    .doc(user.id)
                                                    .set({
                                                  "bookmarks":
                                                      FieldValue.arrayUnion(
                                                          [br.toMap()])
                                                }, SetOptions(merge: true));
                                                ToastMessege(
                                                    "Book added to your collection!",
                                                    context: context);
                                                // Fluttertoast.showToast(msg: "Book added to your collection!", backgroundColor: Colors.grey.shade800, textColor: Colors.white);
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            left: 20,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image(
                                                  image: NetworkImage(
                                                      "${_selfhelpitems[index].image.thumb}"),
                                                  fit: BoxFit.fill,
                                                  height: 150,
                                                  width: 100),
                                            ),
                                          ),
                                          Positioned(
                                              top: 50,
                                              left: 130,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(right: 40),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${_selfhelpitems[index].title}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    // Marquee(
                                                    //   text : "${_scifiitems[index].title}",
                                                    //   style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold,
                                                    // ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Text(
                                                      "${_selfhelpitems[index].publisher}",
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12),
                                                    ),
                                                    //Text("Elisabeth Young-Bruehl illuminates the psychological and intellectual demands writing biography makes on the biographer and explores the complex and frequently conflicted relationship between feminism and psychoanalysis. She considers what remains valuable in Sigmund Freud's work, and what areas - theory of character, for instance - must be rethought to be useful for current psychoanalytic work, for feminist studies, and for social theory. Psychoanalytic theory used for biography, she argues, can yield insights for psychoanalysis itself, particularly in the understanding of creativity.", style: TextStyle(color: Colors.white,fontSize: 1), overflow: TextOverflow.ellipsis,)
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Text(
                          'Fiction',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: new EdgeInsets.all(8.0),
                                itemCount: _fictitems.length < 0
                                    ? 0
                                    : _fictitems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => LibraryMore(
                                              image:
                                                  _fictitems[index].image.thumb,
                                              title: _fictitems[index].title,
                                              publisher:
                                                  _fictitems[index].publisher,
                                              pubdate:
                                                  _fictitems[index].pubDate,
                                              desc: _fictitems[index]
                                                  .description),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      color: Colors.black,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              top: 30,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey.shade900,
                                                ),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.25,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                ),
                                              )),
                                          Positioned(
                                            bottom: 80,
                                            right: 10,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                final _userCollection =
                                                    FirebaseFirestore.instance
                                                        .collection("users");
                                                BookMarks br = BookMarks(
                                                    _fictitems[index].title,
                                                    _fictitems[index].publisher,
                                                    _fictitems[index]
                                                        .image
                                                        .thumb,
                                                    _fictitems[index]
                                                        .description,
                                                    _fictitems[index].pubDate);
                                                _userCollection
                                                    .doc(user.id)
                                                    .set({
                                                  "bookmarks":
                                                      FieldValue.arrayUnion(
                                                          [br.toMap()])
                                                }, SetOptions(merge: true));
                                                ToastMessege(
                                                    "Book added to your collection!",
                                                    context: context);
                                                // Fluttertoast.showToast(msg: "Book added to your collection!", backgroundColor: Colors.grey.shade800, textColor: Colors.white);
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            left: 20,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image(
                                                  image: NetworkImage(
                                                      "${_fictitems[index].image.thumb}"),
                                                  fit: BoxFit.fill,
                                                  height: 150,
                                                  width: 100),
                                            ),
                                          ),
                                          Positioned(
                                              top: 50,
                                              left: 130,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${_fictitems[index].title}",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "${_fictitems[index].publisher}",
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
                child: Column(children: [
              Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Collection',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ],
                    ),
                  )),
              SizedBox(
                height: 30,
              ),
              FutureBuilder(
                  future: fetchbookmarks(user),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    return (snapshot.data != null)
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.all(10),
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 20.0),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => LibraryMore(
                                              image: snapshot.data![index]
                                                  ['image_link'],
                                              title: snapshot.data![index]
                                                  ['book_name'],
                                              publisher: snapshot.data![index]
                                                  ['publisher'],
                                              pubdate: snapshot.data![index]
                                                  ['pub_date'],
                                              desc: snapshot.data![index]
                                                  ['desc']),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      color: Colors.black,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              top: 30,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey.shade900,
                                                ),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.25,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          1,
                                                ),
                                              )),
                                          Positioned(
                                            top: 10,
                                            left: 20,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image(
                                                  image: NetworkImage(
                                                      "${snapshot.data![index]['image_link']}"),
                                                  fit: BoxFit.fill,
                                                  height: 150,
                                                  width: 100),
                                            ),
                                          ),
                                          Positioned(
                                              top: 50,
                                              left: 130,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${snapshot.data![index]['book_name']}",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "${snapshot.data![index]['publisher']}",
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : Center(
                            child: Text(
                              'You have no books in your collection',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 80),
                            ),
                          );
                  })
            ]))
          ]),
        ),
      ),
    );
  }
}
