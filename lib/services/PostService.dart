import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PostService{

  Future createPost(
      String token,
      String postId,
      String bookName,
      String fileUrl,
      String caption,
      String userid,
      String username,
      String userprofile,
      ) async {

    bool success = false;
    var body = jsonEncode({
      'id' : postId,
      'image' : fileUrl,
      'caption' : caption,
      'bookName' : bookName,
      'bookNameLowerCase' : bookName.toLowerCase().trim(),
      'userid' : userid,
      'username' : username,
      'userProfile' : userprofile,
      'dateTime' : "${DateTime.now().toUtc()}",
      'likes' : 0,
      'comments' : 0,
      'isActive' : true,
    });

    await http.post(
        Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/foster/posts/add"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':'application/json'
        },
        body: body
    ).then((http.Response response) async {
      print("----------------------------------------");
      print("Post data stored in post collection");
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
              "id": postId,
              "idType": "posts",
              "objectType": "post",
              "dateTime": "${DateTime.now().toUtc()}",
              "isActive": true
            })
        ).then((http.Response response){
          print("----------------------------------------");
          print("Post data stored in feed collection");
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
          print("posting unsuccessful");
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
                .doc(postId)
                .set({
              "activityid": postId,
              "activitytype": SearchType.post.name,
              "creatorid": userid
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
      String postId,
      String userid,
      String username,
      String name,
      String userprofile,
      String comment,
      ) async {

    bool success = false;
    var body = jsonEncode({
      'postId' : postId,
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
        Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/foster/posts/comments"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':'application/json'
        },
        body: body
    ).then((http.Response response) {
      print("----------------------------------------");
      print("Post comment stored");
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

  Future addLike(
      String token,
      String postId,
      String userid,
      String username,
      String name,
      ) async {

    bool success = false;
    var body = jsonEncode({
      'postId' : postId,
      'userId': userid,
      'like' :
      {
        'username': username,
        'f_name': name,
        'liked': true,
        'on': "${DateFormat.yMMMd()
            .addPattern(" | ")
            .add_jm()
            .format(DateTime.now())
            .toString()}"
      }
    });

    await http.post(
        Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/foster/posts/likes"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':'application/json'
        },
        body: body
    ).then((http.Response response) {
      print("----------------------------------------");
      print("Post like stored");
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

  Future unLike(
      String token,
      String postId,
      String userid,
      ) async {

    bool success = false;

    await http.delete(
        Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/foster/posts/likes/${postId}/${userid}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':'application/json'
        },
    ).then((http.Response response) {
      print("----------------------------------------");
      print("Post unlike stored");
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