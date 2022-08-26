import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:http/http.dart' as http;

class ReviewService{

  Future createReview(
      String token,
      String reviewId,
      String bookName,
      String bookAuthor,
      String bookNote,
      String editorId,
      String fileUrl,
      String genre,
      String imageUrl,
      ) async {

    bool success = false;
    var body = jsonEncode({
      'id' : reviewId,
      'bookName' : bookName,
      'bookNameLowerCase' : bookName.toLowerCase().trim(),
      'bookAuthor' : bookAuthor,
      'bookNote' : bookNote,
      'dateTime' : "${DateTime.now().toUtc()}",
      'editorId' : editorId,
      'isActive' : true,
      'url' : fileUrl,
      'likes' : 0,
      'ratings' : 0,
      'ratedBy' : {},
      'comments' : 0,
      'genre' : genre,
      'imageUrl' : imageUrl,
    });

    await http.post(
        Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/foster/fosterbits/reviews"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':'application/json'
        },
        body: body
    ).then((http.Response response) async {
      print("----------------------------------------");
      print("Review data stored");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print(response.headers);
      print(response.request);
      print("----------------------------------------");
      if(response.statusCode == 200){
        await http.post(
            Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/feeds"),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type':'application/json'
            },
            body: jsonEncode({
              "id": reviewId,
              "idType": "reviews",
              "objectType": "review",
              "dateTime": "${DateTime.now().toUtc()}",
              "isActive": true
            })
        ).then((http.Response response){
          print("----------------------------------------");
          print("review data stored in feed collection");
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.contentLength}");
          print(response.headers);
          print(response.request);
          print("----------------------------------------");
        });

        if(response.statusCode == 200){
          success = true;
          print(success);
        } else {
          print("----------------------------------------");
          print("reviewing unsuccessful");
          print("----------------------------------------");
        }

        ///search data
        Future.delayed(Duration(seconds: 2)).then((value) async {

            String book_name = bookName.toLowerCase().trim();

            await FirebaseFirestore.instance
                .collection("booksearch")
                .doc(book_name)
                .set({
              "book_title" : book_name
            },SetOptions(merge: true)).then((value) async {
              await FirebaseFirestore.instance
                  .collection("booksearch")
                  .doc(book_name)
                  .collection("activities")
                  .doc(reviewId)
                  .set({
                "activityid" : reviewId,
                "activitytype" : SearchType.review.name,
                "creatorid" : editorId
              },SetOptions(merge: true));
            });
        });

      }
    });
    print(success);
    return success;
  }

  Future addComment(
      String token,
      String reviewId,
      String userid,
      String username,
      String name,
      String userprofile,
      String comment,
      ) async {

    bool success = false;
    var body = jsonEncode({
      'postId' : reviewId,
      'comment' :
      {
        'by': userid,
        'username': username,
        'f_name': name,
        'profile': userprofile,
        'comment': comment,
        'active': true,
        'on': DateTime.now().millisecondsSinceEpoch
      }
    });

    await http.post(
        Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/foster/fosterbits/comments"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':'application/json'
        },
        body: body
    ).then((http.Response response) {
      print("----------------------------------------");
      print("Review comment stored");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print(response.headers);
      print(response.request);
      print("----------------------------------------");
      if(response.statusCode == 200){
        success = true;
        print(success);
      }
    });
    print(success);
    return success;
  }
}