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

class TheatreService {
  Future updateUserProfile(
      Theatre theatre, User user, Map<String, dynamic> passedBody) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/amphitheatre/v1/rooms/${theatre.createdBy}/${theatre.theatreId}/${user.userName}";
    var token =
        await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();
    var body = jsonEncode(passedBody);
    await http
        .put(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: body)
        .then((http.Response response) {
      print(response.body);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
    });
    return user;
  }

  createTheatreNow(
    User user,
    String eventName,
    DateTime dateTime,
    String genre,
    String imageUrl,
    String summary,
    String? adLink,
    String? adUrl,
    bool isInviteOnly,
    String? author,
  ) async {
    await roomCollection.doc(user.id).set({'id': user.id},SetOptions(merge: true));
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/amphitheatrev2/v1/create/${user.id}";
    var body = jsonEncode({
      'duration' : 90,
      'title': '$eventName',
      'image': imageUrl,
      'scheduledOn': dateTime.toIso8601String(),
      'genre': genre,
      'author': author,
      'userProfileImage': user.userProfile?.profileImage ?? "",
      'createdBy': user.id, //from context
      'creatorUsername': user.userName,
      'summary': '$summary',
      'isUpcoming': false,
      'isActive': true,
      'isDeleted': false,
      'adLink': adLink,
      'adUrl': adUrl,
      'isInviteOnly': isInviteOnly,
    });

    var token =
        await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();

    await http
        .post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: body)
        .then((http.Response response) async {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      print(response.headers);
      print(response.request);

      http.post(
          Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/feeds"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "id":
                "${response.body.split('roomId":"')[1].split('","userId"')[0]}",
            "idType": "theatres",
            "objectType": "theatre",
            "dateTime": "${DateTime.now().toUtc()}",
            "isActive": true,
            "data": {"userId": user.id}
          }));
    });

    return user;
  }

  createTheatreLater(
    User user,
    String eventName,
    DateTime dateTime,
    String genre,
    String imageUrl,
    String summary,
    String? adLink,
    String? adUrl,
    bool isInviteOnly,
    String? author,
  ) async {
    // var theatreToken = await getRTCToken(eventName);
    await roomCollection.doc(user.id).set({'id': user.id},SetOptions(merge: true));
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/amphitheatre/v1/create/${user.id}";
    var body = jsonEncode({
      'duration' : 90,
      'title': '$eventName',
      'image': imageUrl,
      'scheduledOn': dateTime.toIso8601String(),
      'genre': genre,
      'author': author,
      'userProfileImage': user.userProfile?.profileImage ?? "",
      'createdBy': user.id, //from context
      'creatorUsername': user.userName,
      // 'token': theatreToken.toString(),
      'summary': '$summary',
      'isUpcoming': true,
      'isActive': true,
      'isDeleted': false,
      'adLink': adLink,
      'adUrl': adUrl,
      'isInviteOnly': isInviteOnly,
    });

    var token =
        await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();

    await http
        .post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: body)
        .then((http.Response response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
    });

    return user;
  }

  Future<Theatre?> getTheatreById(String theatreID, String userID) async {
    try {
      final theatreData = await roomCollection
          .doc(userID)
          .collection('amphitheatre')
          .doc(theatreID)
          .get();
      if (theatreData.exists) {
        final theatre = theatreData.data();
        print("THEATRE");
        print(theatre);
        return Theatre.fromJson(theatre, "");
      }
    } catch (e) {
      throw e;
    }
  }

  Future joinRoomAsSpeaker(theatre, user, Role role) async {
    var docId;
    var doc = await roomCollection
        .doc(theatre.createdBy)
        .collection('amphitheatre')
        .where("token", isEqualTo: theatre.token)
        .get();
    doc.docs.forEach((element) {
      docId = element.id;
    });

    var rawSpeakers = await roomCollection
        .doc(theatre.createdBy)
        .collection("amphitheatre")
        .doc(docId)
        .collection("users")
        .get();
    var speakers = rawSpeakers.docs.map((e) => e.data()).toList();
    Map<String, dynamic> u = user.toJson();
    u["rtcId"] = -1;
    u["isActiveInRoom"] = true;
    u["isKickedOut"] = false;
    u["isMutedSpeakers"] = false;
    u["isUnmutedSpeakers"] = false;
    u["requestToSpeak"] = false;
    u["role"] = role.index;
    u["isMicOn"] = true;

    await roomCollection
        .doc(theatre.createdBy)
        .collection("amphitheatre")
        .doc(docId)
        .collection("users")
        .doc(user.userName)
        .set(u);
    bool isThere = false;
    speakers.forEach((element) {
      if (element['id'] == user.id && !isThere) {
        isThere = true;
      }
    });

    if (isThere) {
      await roomCollection
          .doc(theatre.createdBy)
          .collection("amphitheatre")
          .doc(docId)
          .collection("users")
          .doc(user.userName)
          .update({"isActiveInRoom": true});
    }
  }

  Future updateIsActive(Theatre room) async {
    try {
      await roomCollection
          .doc(room.createdBy)
          .collection("amphitheatre")
          .doc(room.theatreId)
          .update({'isActive': false});
      await FirebaseFirestore.instance
          .collection("feeds")
          .doc(room.theatreId)
          .delete();
    } catch (e) {
      throw e;
    }
  }

  Future updateIsDelete(Theatre room) async {
    try {
      await roomCollection
          .doc(room.createdBy)
          .collection("amphitheatre")
          .doc(room.theatreId)
          .update({'isDeleted': true, 'isActive': false});
      await FirebaseFirestore.instance
          .collection("feeds")
          .doc(room.theatreId)
          .delete();
    } catch (e) {
      throw e;
    }
  }

  Future leaveRoom(Theatre theatre, User user) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/amphitheatre/v1/rooms/${theatre.createdBy}/${theatre.theatreId}/${user.userName}";
    var token =
        await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();
    var body = jsonEncode({"isActiveInRoom": false});
    print("token");
    print(token);
    await http
        .put(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: body)
        .then((http.Response response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
    });
    return user;
  }
}
