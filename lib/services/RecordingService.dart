import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:http/http.dart' as http;

enum RecordingType {
  ROOM,
  AMPHITHEATRE,
}

class RecordingService {
  RecordingService();
  static const APP_ID = "58ee1103fa5b4a9e98e02bacc19aa826";
  final roomsCollection = FirebaseFirestore.instance.collection('rooms');
  final recordingCollection =
      FirebaseFirestore.instance.collection('recordings');

  StreamSubscription? _subscription;

  String? userId;
  String? roomId;
  String? resourceId;
  String? sid;
  String? uid;
  String? cname;
  String? token;

  static const String URL =
      "https://us-central1-fostr2021.cloudfunctions.net/recordingapis/recording/channels/";

  Future<void> startRecording(String channelName, String roomId, String userId,
      {RecordingType type = RecordingType.ROOM}) async {
    final response = await http.get(Uri.parse(URL + "$channelName/start"));
    if (response.statusCode == 200) {
      this.roomId = roomId;
      this.userId = userId;
      final rawData = response.body;
      final json = jsonDecode(rawData);
      print(json);
      final data = json['data'];
      resourceId = data['resourceId'];
      sid = data['sid'];
      uid = data['uid'];
      cname = data['cname'];
      token = data['token'];
      if (type == RecordingType.ROOM) {
        roomsCollection.doc(userId).collection("rooms").doc(roomId).update({
          "recording": true,
          "recordingStartTime": DateTime.now().toUtc(),
          "sid": sid,
          "uid": uid,
          "cname": cname,
          "resourceId": resourceId,
        });
      } else {
        roomsCollection
            .doc(userId)
            .collection("amphitheatre")
            .doc(roomId)
            .update({
          "recording": true,
          "recordingStartTime": DateTime.now().toUtc(),
          "sid": sid,
          "uid": uid,
          "cname": cname,
          "resourceId": resourceId,
        });
      }
    } else {
      throw Exception('Failed to start recording');
    }
    return;
  }

  Future<void> stopRecording(
      {required String roomId,
        required String roomTitle,
      required String userId,
      required RecordingType type}) async {
    final response = await http.get(Uri.parse(
        "https://us-central1-fostr2021.cloudfunctions.net/recordingapis/recording/stop/${type.name}/$userId/$roomId/$roomTitle"));

    if (response.statusCode == 200) {
      _subscription?.cancel();
      print(response.body);
      if (type == RecordingType.ROOM) {
        roomsCollection.doc(userId).collection("rooms").doc(roomId).update({
          "recording": false,
          "recordingEndTime": DateTime.now().toUtc(),
        });
      } else {
        roomsCollection
            .doc(userId)
            .collection("amphitheatre")
            .doc(roomId)
            .update({
          "recording": false,
          "recordingEndTime": DateTime.now().toUtc(),
        });
      }

      ///search data
      Future.delayed(Duration(seconds: 2)).then((value) async {
        await FirebaseFirestore.instance
            .collection("rooms")
            .doc(userId)
            .collection(type == RecordingType.ROOM ? "rooms" : "amphitheatre")
            .doc(roomId)
            .get()
            .then((room) async {

              String book_name = room["title"].toString().toLowerCase().trim();

              await FirebaseFirestore.instance
                  .collection("recordings")
                  .where("roomId", isEqualTo: roomId)
                  .get()
              .then((value){
                value.docs.forEach((recording) async {

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
                        .doc(recording.id)
                        .set({
                      "activityid" : recording.id,
                      "activitytype" : SearchType.recording.name,
                      "creatorid" : userId
                    },SetOptions(merge: true));
                  });
                });
              });

        });
      });

      // recordingCollection.add({
      //   "roomId": roomId,
      //   "userId": userId,
      //   "resourceId": resourceId,
      //   "sid": sid,
      //   "uid": uid,
      //   "cname": cname,
      //   "token": token,
      //   "isActive": true,
      //   "type": type.name,
      //   "fileName": json['data']["serverResponse"]["fileList"][0]["fileName"],
      //   "dateTime": DateTime.now().toUtc(),
      // });
      // resourceId = null;
      // sid = null;
      // uid = null;
      // cname = null;
      // token = null;
      // roomId = null;
      // userId = null;
    } else {
      throw Exception('Failed to stop recording');
    }
    return;
  }

  Future<void> saveRecordingInfo() async {}

  Future<void> deleteRecordingInfo(String roomId, String creatorId) async {
    final snapshot = await recordingCollection
        .where("roomId", isEqualTo: roomId)
        .where("userId", isEqualTo: creatorId)
        .get();
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) {
        recordingCollection.doc(doc.id).update({
          "isActive": false,
        });
      });
    }
  }
}
