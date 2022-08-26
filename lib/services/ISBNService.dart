import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';

class ISBNService {
  String? _TOKEN;// = "47520_3fd18a981c606ae516c119e99f02cdce";
  // final parseUrl = (String bookName) => ;



  Future<List<dynamic>?> getBooksDetails(String query) async {
    try {

      await FirebaseFirestore.instance
      .collection("config")
      .doc("ISBN")
      .get().then((value){
        _TOKEN = value["token"];
      });

      final formatedQuery = query.toLowerCase().replaceAll(" ", '%20');

      var authorQueryUrl = "https://api2.isbndb.com/authors/$formatedQuery";
      final authorRes = await http.get(Uri.parse(authorQueryUrl), headers: {
        'Authorization': _TOKEN!,
      });

      var authorName = "";
      var bookName = formatedQuery;
      if (authorRes.statusCode == 200) {
        final data = json.decode(authorRes.body);
        if (data['total'] > 0) {
          final authors =
              data['authors'].map((s) => s.toString().toLowerCase()).toList();
          final match =
              query.toLowerCase().bestMatch(List<String>.from(authors));
          if (match.bestMatch.rating != null && match.bestMatch.rating! > 0.5) {
            authorName = match.bestMatch.target!;
            bookName = "";
          }
        }
      }

      var url =
          'https://api2.isbndb.com/search/books?text=$bookName&author=$authorName';

      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': _TOKEN!,
      });

      if (res.statusCode == 200) {
        List allList = json.decode(res.body)['data'] ?? [];
        return allList;
      } else {
        print(res.body);
        return [];
      }
    } catch (e) {
      print("------");
      print(e);
      return null;
    }
  }

  Future<List> getBookDetailsByISBN(String isbn) async {
    var formatedISBN = isbn.trim();

    await FirebaseFirestore.instance
        .collection("config")
        .doc("ISBN")
        .get().then((value){
      _TOKEN = value["token"];
    });

    final url = "https://api2.isbndb.com/book/$formatedISBN";

    final res = await http.get(Uri.parse(url), headers: {
      'Authorization': _TOKEN!,
    });
    if (res.statusCode == 200) {
      List allList = [json.decode(res.body)['book']];
      print(allList);
      return allList;
    } else {
      print(res.body);
      return [];
    }
  }
}



//  final List list = allList.map((element) {
//           return element?['title'].toString().toLowerCase();
//         }).toList();
//         print(list);
//         var matches = bookName.toLowerCase().bestMatch(List<String>.from(list));
//         print(matches.toString());
//         final author = allList[matches.bestMatchIndex]['authors'] != null &&
//                 allList[matches.bestMatchIndex]['authors'].length > 0
//             ? allList[matches.bestMatchIndex]['authors'].first
//             : null;

//         final book = allList[matches.bestMatchIndex]["title"];

//         if (author == null || author.isEmpty) {
//           return allList;
//         }
//         final secondRes = await http.get(
//             Uri.parse(
//                 'https://api2.isbndb.com/search/books?author=$author&text=$book'),
//             headers: {
//               'Authorization': _TOKEN,
//             });

//         if (secondRes.statusCode == 200) {
//           final allList = json.decode(secondRes.body)['data'];
//           return allList;
//         }