import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as us;
import 'package:get_it/get_it.dart';

import 'package:fostr/core/data.dart';
import 'package:fostr/core/functions.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/services/UserService.dart';

class RoomService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? roomStream;
  initRoom(room, Function details) async {
    // get the details of room
    roomStream = roomCollection
        .doc(room.id)
        .collection("rooms")
        .doc(room.roomID)
        .snapshots()
        .listen((result) {
      var participantsCount = (result.data()?['participantsCount'] < 0
          ? 0
          : result.data()!['participantsCount']);
      var speakersCount = (result.data()?['speakersCount'] < 0
          ? 0
          : result.data()!['speakersCount']);
      var token = result.data()!['token'];
      var channelName = room.title!;
      var roompass = result.data()!['password'];
      details(participantsCount, speakersCount, token, channelName, roompass);
    });
  }

  Future<User> createRoom(
    User user,
    String eventname,
    String agenda,
    DateTime dateTime,
    bool
        humanLibrary, // added by aditya for human library in enter room details on 22 Nov
    String genre,
    String imageUrl,
    String password,
    DateTime now,
    String adTitle,
    String adDescription,
    String redirectLink,
    String imageUrl2,
    String author,
    String summary,
    bool isInviteOnly,
    bool followersOnly,
  ) async {
    await roomCollection.doc(user.id).set({'id': user.id},SetOptions(merge: true));

    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/roomsapiv2/v1/create/${user.id}";
    await roomCollection.doc(user.id).set({'id': user.id},SetOptions(merge: true));
    var body = jsonEncode({
      'duration' : 45,
      'participantsCount': 0,
      'speakersCount': 0,
      'title': '$eventname',
      'authorName': '$author',
      'summary': '$summary',
      'agenda': '$agenda',
      'image': imageUrl,
      'password': '$password',
      'dateTime': dateTime.toIso8601String(),
      'button toggle':
          '$humanLibrary', // added by aditya for human library in enter room details on 22 Nov
      'genre': genre,
      'roomCreator': (user.bookClubName == "")
          ? user.name
          : user.bookClubName, //from context
      'isUpcoming': true,
      'isActive': true,
      'isDeleted': false,
      'isBookClub': false,
      'id': user.id, //from context
      'adTitle': adTitle,
      'adDescription': adDescription,
      'redirectLink': redirectLink,
      'imageUrl2': imageUrl2,
      'inviteOnly': isInviteOnly,
      'followersOnly': followersOnly,
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
      print("Response : $response");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
    });

    return user;
  }

  Future<User> createRoomNow(
    User user,
    String eventname,
    bool
        humanLibrary, // added by aditya for human library in enter room details on 22 Nov
    String agenda,
    String genre,
    String imageUrl,
    String password,
    DateTime dateTime,
    // DateTime now,
    String author,
    String summary,
    String adTitle,
    String adDescription,
    String redirectLink,
    String imageUrl2,
    bool isInviteOnly,
    bool followersOnly,
  ) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/roomsapiv2/v1/create/${user.id}";
    await roomCollection.doc(user.id).set({'id': user.id},SetOptions(merge: true));
    var body = jsonEncode({
      'duration' : 45,
      'participantsCount': 0,
      'eventName': '$eventname',
      'speakersCount': 0,
      'title': '$eventname',
      'button toggle':
          '$humanLibrary', // added by aditya for human library in enter room details on 22 Nov
      'authorName': '$author',
      'summary': '$summary',
      'agenda': '$agenda',
      'image': imageUrl,
      'password': '$password',
      'dateTime': dateTime.toIso8601String(),
      'genre': genre,
      'roomCreator': (user.bookClubName == "") ? user.name : user.bookClubName,
      'isUpcoming': false,
      'isActive': true,
      'isBookClub': false,
      'isDeleted': false,
      'id': user.id,
      'adTitle': adTitle,
      'adDescription': adDescription,
      'redirectLink': redirectLink,
      'imageUrl2': imageUrl2,
      'inviteOnly': isInviteOnly,
      'followersOnly': followersOnly,
    });
    var token =
        await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();

    // Add new data to Firestore collection

    user.totalRooms = user.totalRooms ?? 0;
    user.totalRooms = user.totalRooms! + 1;
    user.points = user.points + 10;
    // _userService
    //     .updateUserField({"totalRooms": user.totalRooms, "id": user.id, "points": user.points});
    if (user.rewardcountforroom > -5) {
      http.post(
          Uri.parse(
              "https://us-central1-fostr2021.cloudfunctions.net/rewards/v1/rewardsupdate"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "activity_name": "create_room",
            "dateTime": DateTime.now().toIso8601String(),
            "points": 10,
            "type": "credit",
            "userId": user.id,
          }));
    } else {
      // ToastMessege('You have availed the maximum rewards for creating rewards',context: context);
    }
    await http
        .post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: body)
        .then((http.Response response) async {
      http.post(
          Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/feeds"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "id":
                "${response.body.split('roomId":"')[1].split('","userId"')[0]}",
            "idType": "rooms",
            "objectType": "room",
            "dateTime": "${DateTime.now().toUtc()}",
            "isActive": true,
            "data": {"userId": user.id}
          }));
    });
    return user;
  }

  getRooms(id) async {
    roomCollection.doc(id).collection("rooms").snapshots();
  }

  Future joinRoomAsSpeaker(
      room, user, enteredpass, roompass, speakersCount, bool isMicOn) async {
    if (enteredpass != roompass) return null;

    var rawSpeakers = await roomCollection
        .doc(room.id)
        .collection("rooms")
        .doc(room.roomID)
        .collection("speakers")
        .get();
    var speakers = rawSpeakers.docs.map((e) => e.data()).toList();
    Map<String, dynamic> u = user.toJson();
    u["rtcId"] = -1;
    u["isActiveInRoom"] = true;
    u["isKickedOut"] = false;
    u["isMutedSpeakers"] = false;
    u["isUnmutedSpeakers"] = false;
    u["isMicDisabled"] = false;
    u["isMicOn"] = isMicOn;
    await roomCollection
        .doc(room.id)
        .collection("rooms")
        .doc(room.roomID)
        .collection("speakers")
        .doc(user.userName)
        .set(u);
    bool isThere = false;
    speakers.forEach((element) {
      if (element['id'] == user.id && !isThere) {
        isThere = true;
      }
    });

    if (!isThere) {
      await roomCollection
          .doc(room.id)
          .collection("rooms")
          .doc(room.roomID)
          .update({
        'speakersCount': speakersCount + 1,
      });

      speakersCount = speakers.length + 1;
    } else if (isThere) {
      await roomCollection
          .doc(room.id)
          .collection("rooms")
          .doc(room.roomID)
          .collection("speakers")
          .doc(user.userName)
          .update({"isActiveInRoom": true});
    }
    return speakersCount;
  }

  Future joinRoomAsParticipant(room, user, participantsCount) async {
    // update the list of participants
    var rawParticipants = await roomCollection
        .doc(room.id)
        .collection("rooms")
        .doc(room.roomID)
        .collection("participants") // participants
        .get();
    var participants = rawParticipants.docs.map((e) => e.data()).toList();
    bool isThere = false;
    participants.forEach((element) {
      if (element['id'] == user.id && !isThere) {
        isThere = true;
      }
    });
    if (!isThere) {
      await roomCollection
          .doc(room.id)
          .collection("rooms")
          .doc(room.roomID)
          .update({
        'participantsCount': participantsCount + 1,
      });
      await roomCollection
          .doc(room.id)
          .collection("rooms")
          .doc(room.roomID)
          .collection("participants")
          .doc(user.userName)
          .set({
        'username': user.userName,
        'name': user.name,
        'profileImage': user.userProfile?.profileImage ?? "image",
      },SetOptions(merge: true));

      participantsCount = participants.length + 1;
    }
    return participantsCount;
  }

  Future leaveRoom(Room room, User user) async {
    await roomCollection
        .doc(room.id)
        .collection('rooms')
        .doc(room.roomID)
        .collection("speakers")
        .doc(user.userName)
        .update({'isActiveInRoom': false});

    return user;
  }

  Future<Room?> getRoomById(String roomID, String userID) async {
    try {
      final roomData = await roomCollection
          .doc(userID)
          .collection('rooms')
          .doc(roomID)
          .get();
      if (roomData.exists) {
        final room = roomData.data();
        return Room.fromJson(room, "");
      }
    } catch (e) {
      throw e;
    }
  }

  Future sendLogs(Map<String, dynamic> data) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('eventlogging');
      final result = await callable.call(data);
      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future updateIsActive(Room room) async {
    try {
      await roomCollection
          .doc(room.id)
          .collection("rooms")
          .doc(room.roomID)
          .update({'isActive': false});
      await FirebaseFirestore.instance
          .collection("feeds")
          .doc(room.roomID)
          .delete();
    } catch (e) {
      throw e;
    }
  }

  Future updateIsDelete(Room room) async {
    try {
      await roomCollection
          .doc(room.id)
          .collection("rooms")
          .doc(room.roomID)
          .update({'isDeleted': true, 'isActive': false});
      await FirebaseFirestore.instance
          .collection("feeds")
          .doc(room.roomID)
          .delete();
    } catch (e) {
      throw e;
    }
  }

  Future<void> dispose() async {
    await roomStream?.cancel();
  }
}
