import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/TopReads.dart';
import 'package:fostr/pages/user/Book.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/ISBNService.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../widgets/AppLoading.dart';

class SearchBook extends StatefulWidget {
  const SearchBook({Key? key}) : super(key: key);

  @override
  _SearchBookState createState() => _SearchBookState();
}

class _SearchBookState extends State<SearchBook> with FostrTheme {
  List<VolumeInfo> _items = [];
  List<ImageLinks> _imageItems = [];
  int booksCount = 0;
  TextEditingController controller = new TextEditingController();
  final ISBNService _isbnService = GetIt.I<ISBNService>();
  bool _isLoading = false;
  final subject = new PublishSubject<String>();
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
        _items = rawItems;
        _isLoading = false;
      });
    } else {
      final res = await _isbnService.getBooksDetails(text);

      final rawItems = res?.map(_addBook).toList() ?? [];
      setState(() {
        _items = rawItems;
        _isLoading = false;
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
    subject.stream.listen(_textChanged);
  }

  @override
  void dispose() {
    subject.close();
    super.dispose();
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
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: TextFormField(
                                controller: controller,
                                style: h2.copyWith(
                                    color: theme.colorScheme.inversePrimary),
                                onFieldSubmitted: (value) {
                                  subject.add(controller.text);
                                },
                                decoration: registerInputDecoration.copyWith(
                                  hintText: "Search for book",
                                  fillColor:
                                      theme.inputDecorationTheme.fillColor,
                                  hintStyle: TextStyle(
                                    fontFamily: 'drawerbody',
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        width: 0.5, color: Colors.black),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: theme.colorScheme.secondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.only(left:8.0),
                  //   child: IconButton(
                  //       onPressed: (){
                  //         Navigator.of(context).pop();
                  //       },
                  //       icon: Icon(Icons.arrow_back_ios, color: Colors.white,)),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  //   child: TextFormField(
                  //     controller: controller,
                  //     style: TextStyle(color: Colors.white),
                  //     onChanged: (string) => (subject.add(string)),
                  //     decoration: InputDecoration(
                  //         hintText: "Search for book",
                  //       hintStyle: TextStyle(
                  //         color: Colors.white
                  //       )
                  //     ),
                  //   ),
                  // ),
                  _isLoading
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: AppLoading(
                            height: 70,
                            width: 70,
                          )),
                        )
                      :
                      // CircularProgressIndicator(color:GlobalColors.signUpSignInButton): new Container(),
                      ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          padding: new EdgeInsets.all(8.0),
                          itemCount: _items.length < 0 ? 0 : _items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                final _userCollection = FirebaseFirestore
                                    .instance
                                    .collection("users");
                                TopReads tr = TopReads(_items[index].title,
                                    _items[index].image.thumb);
                                _userCollection.doc(user.id).set({
                                  "userProfile": {
                                    "topRead":
                                        FieldValue.arrayUnion([tr.toMap()])
                                  }
                                }, SetOptions(merge: true)).then(
                                    (value) => Navigator.of(context).pop());
                              },
                              child: Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                color: theme.colorScheme.primary,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 130,
                                      child: FosterImage(
                                          fit: BoxFit.cover,
                                          height: 200,
                                          imageUrl: _items[index]
                                              .image
                                              .thumb
                                              .toString()),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        height: 190,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _items[index].title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'drawerbody',
                                              ),
                                            ),
                                            Text(
                                              "By " + _items[index].author,
                                              maxLines: 10,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'drawerbody',
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              _items[index].description,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'drawerbody',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            //  return new BookCardMinimalistic(_items[index]);
                          },
                        ),
                ],
              ),
            ),
          )),
    );
  }
}
