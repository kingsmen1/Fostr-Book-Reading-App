import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/Book.dart';
import 'package:fostr/services/ISBNService.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../../widgets/AppLoading.dart';

class SearchBookBits extends StatefulWidget {

  const SearchBookBits({Key? key, required this.onBookSelect})
      : super(key: key);
  final Function(List<String>? args) onBookSelect;

  @override
  _SearchBookBitsState createState() => _SearchBookBitsState();
}

class _SearchBookBitsState extends State<SearchBookBits> {
  List<VolumeInfo> _items = [];

  final ISBNService _isbnService = GetIt.I<ISBNService>();

  int booksCount = 0;
  TextEditingController controller = TextEditingController();
  TextEditingController authorController = TextEditingController();

  bool _isLoading = false;
  final subject = PublishSubject<String>();

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
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      child: Container(
        height: 600,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30)
          )
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 15,),
                  Row(
                    children: [

                      GestureDetector(

                        onTap: (){
                          Navigator.pop(context);
                        },

                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 15,),

                      Flexible(
                        child: TextFormField(
                          controller: controller,
                          style: TextStyle(
                            fontFamily: 'drawerbody',
                            fontSize: 16,
                          ),
                          // onChanged: (string) {
                          //   subject.add(string);
                          // },
                          onFieldSubmitted: (value) {
                            subject.add(controller.text);
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
                              hintText: "Enter title, author or ISBN",
                              hintStyle: TextStyle(
                                fontSize: 16,
                                fontFamily: 'drawerbody',
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Container(
                  //   height: 60,
                  //   child: TextFormField(
                  //     controller: authorController,
                  //     style: TextStyle(
                  //       fontFamily: 'drawerbody',
                  //       fontSize: 16,
                  //     ),
                  //     // onChanged: (string) {
                  //     //   subject.add(string);
                  //     // },
                  //     decoration: registerInputDecoration.copyWith(
                  //         fillColor: theme.inputDecorationTheme.fillColor,
                  //         border: OutlineInputBorder(
                  //           borderRadius: const BorderRadius.all(
                  //             Radius.circular(15.0),
                  //           ),
                  //         ),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.all(Radius.circular(15)),
                  //           borderSide: BorderSide(
                  //             color: theme.colorScheme.secondary,
                  //             width: 2,
                  //           ),
                  //         ),
                  //         enabledBorder: OutlineInputBorder(
                  //             borderRadius:
                  //                 BorderRadius.all(Radius.circular(15)),
                  //             borderSide: BorderSide(
                  //               width: 0.5,
                  //             )),
                  //         hintText: "Enter author name",
                  //         hintStyle: TextStyle(
                  //           fontSize: 16,
                  //           fontFamily: 'drawerbody',
                  //         )),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     subject.add([controller.text, authorController.text]);
                  //   },
                  //   child: const Text(
                  //     "Search",
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   style: ButtonStyle(
                  //     padding: MaterialStateProperty.all<EdgeInsets>(
                  //         EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  //     backgroundColor: MaterialStateProperty.all(
                  //         theme.colorScheme.secondary),
                  //     shape: MaterialStateProperty.all<OutlinedBorder>(
                  //       RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
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
                      : ListView.builder(
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
                                Navigator.of(context).pop([
                                  _items[index].title,
                                  _items[index].description,
                                  _items[index].image.thumb,
                                  _items[index].author,
                                ]);
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
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: FosterImage(
                                            fit: BoxFit.cover,
                                            height: 150,
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
                                        padding:
                                        const EdgeInsets.only(bottom: 20),
                                        height: 150,
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
                                              height: 20,
                                            ),
                                            Text(
                                              _items[index].description,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
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
                            //  return  BookCardMinimalistic(_items[index]);
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
