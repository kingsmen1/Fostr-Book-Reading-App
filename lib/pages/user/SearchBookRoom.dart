import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/Book.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/ISBNService.dart';
import 'package:fostr/services/QrScanner.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../widgets/AppLoading.dart';

class SearchBookRoom extends StatefulWidget {
  const SearchBookRoom({Key? key}) : super(key: key);

  @override
  _SearchBookRoomState createState() => _SearchBookRoomState();
}

class _SearchBookRoomState extends State<SearchBookRoom> {
  List<VolumeInfo> _items = [];
  List<ImageLinks> _imageItems = [];
  int booksCount = 0;
  TextEditingController controller = new TextEditingController();
  final ISBNService _isbnService = GetIt.I<ISBNService>();
  bool _isLoading = false;
  final subject = new PublishSubject<String>();
  void _textChanged(String text) {
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
    _isbnService
        .getBooksDetails(text)
        .then((list) {
          list?.forEach(_addBook);
        })
        .catchError(_onError)
        .then((e) {
          setState(() {
            _isLoading = false;
          });
        });
  }

  void _addBook(dynamic book) {
    setState(() {
      _items.add(
        VolumeInfo(
            book['publisher'],
            book['title'],
            book['publisher'],
            ImageLinks(book['image']),
            book['isbn13'],
            book['synopsys'],
            book['date_published'],
            book['authors'][0]),
      );
    });
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
    // TODO: implement dispose
    super.dispose();
    subject.close();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: Colors.black,
            body: SingleChildScrollView(
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
                                color: Colors.white,
                              )),
                        ),
                        Expanded(
                          child: Container(
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: TextFormField(
                                controller: controller,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'drawerbody',
                                ),
                                onChanged: (string) {
                                  subject.add(string);
                                },
                                decoration: registerInputDecoration.copyWith(
                                    hintText: "Search for book",
                                    fillColor: Colors.white12,
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'drawerbody',
                                    )),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => UserProfilePage(),
                                ));
                            // if(result!=null) {
                            //   setState(() {
                            //     controller.text = result;
                            //     subject.add(result);
                            //   });
                            // }
                          },
                          child: RoundedImage(
                            width: 38,
                            height: 38,
                            borderRadius: 35,
                            url: auth.user?.userProfile?.profileImage,
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
                                Navigator.of(context).pop([
                                  _items[index].title,
                                  _items[index].description,
                                  _items[index].image.thumb,
                                ]);
                              },
                              child: new Card(
                                  child: new Padding(
                                      padding: new EdgeInsets.all(8.0),
                                      child: new Row(
                                        children: <Widget>[
                                          FosterImage(
                                              imageUrl: _items[index]
                                                  .image
                                                  .thumb
                                                  .toString()),
                                          Flexible(
                                            child: new Text(
                                              _items[index].title,
                                              maxLines: 10,
                                              style: TextStyle(
                                                fontFamily: 'drawerbody',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                            );
                            //  return new BookCardMinimalistic(_items[index]);
                          },
                        ),
                ],
              ),
            )),
      ),
    );
  }
}
