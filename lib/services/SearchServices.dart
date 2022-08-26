import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:http/http.dart' as http;
import 'package:fostr/core/data.dart';
import 'package:fostr/enums/role_enum.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/core/functions.dart';
import 'package:fostr/models/UserModel/User.dart';

class SearchServices{

  Future<dynamic> getActivitesByBookName(
      String bookname,
      ) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/booksearch/v1/activitiesbybook/$bookname";
    var body = jsonEncode({

    });

    var token = await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();
    var data;

    await http
        .get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        // body: body
    ).then((http.Response response) async {
      print("Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");
      // print(response.headers);
      // print(response.request);

      data = jsonDecode(response.body);

    });
    return data;
  }

  saveActivityToBook(
      String bookname,
      ) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/booksearch/v1/saveactivitytobook/${bookname}";
    var body = jsonEncode({

    });

    var token = await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();

    await http
        .post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body
    ).then((http.Response response) async {
      print("Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");
      // print(response.headers);
      // print(response.request);
    });
  }

}