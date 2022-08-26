import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:fostr/core/settings.dart';

Future<String> getToken(String channelName, String uid) async {
  final response = await http.get(
    Uri.parse("https://fostrtokenserver.herokuapp.com/access_token?channel=" +
        channelName),
  );

  if (response.statusCode == 200) {
    print("response.body");
    print(response.body);
    token = response.body;
    token = jsonDecode(token)['token'];
  } else {
    print('Failed to fetch the token');
  }
  return token;
}

class KeyBoardUnfocus {
  KeyBoardUnfocus(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }
}

Future<String> getRTMToken(String channelName, String uid, String username) async {
  String RtmToken = "";
  await FirebaseAuth.instance.currentUser!.getIdToken().then((value) async {
    print("--------------auth token--------------");
    print(value);
    await http.get(
      Uri.parse(
          "https://us-central1-fostr2021.cloudfunctions.net/agorartm/rtmToken?account=$username&RtmRole=something"),
      headers: {
        'Authorization': 'Bearer $value',
      },
    ).then((http.Response response) {
      print("-------------------------------------------------------------");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print(response.headers);
      print(response.request);
      if (response.statusCode == 200) {
        print("jsonDecoded response.body");
        print(
            (jsonDecode(response.body).toString().split(" ")[1].split("}")[0]));

        RtmToken =
        jsonDecode(response.body).toString().split(" ")[1].split("}")[0];
      } else {
        print('Failed to fetch the token : ${response.statusCode}');
      }
      print("-------------------------------------------------------------");
    });
  });
  return RtmToken;
}

Future<String> getRTCToken(String channelName) async {
  String RtcToken = "";
  await FirebaseAuth.instance.currentUser!.getIdToken().then((value) async {
    print("--------------auth token--------------");
    print(value);
    await http.get(
      Uri.parse(
          "https://us-central1-fostr2021.cloudfunctions.net/agorartm/rtcToken?channelName=$channelName"),
      headers: {
        'Authorization': 'Bearer $value',
      },
    ).then((http.Response response) {
      print("-------------------------------------------------------------");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print(response.headers);
      print(response.request);
      if (response.statusCode == 200) {
        print("jsonDecoded response.body");
        print(
            (jsonDecode(response.body).toString().split(" ")[1].split("}")[0]));

        RtcToken =
        jsonDecode(response.body).toString().split(" ")[1].split("}")[0];
      } else {
        print('Failed to fetch the token : ${response.statusCode}');
      }
      print("-------------------------------------------------------------");
    });
  });
  return RtcToken;
}