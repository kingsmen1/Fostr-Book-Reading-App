import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;

class UserService {
  final _userCollection = FirebaseFirestore.instance.collection("users");
  final _bookclubsCollection = FirebaseFirestore.instance.collection("bookclubs");
  final _userNames = FirebaseFirestore.instance.collection("usernames");
  final _fcm = FirebaseMessaging.instance;

  Future<void> subscribeNotifications() async {
    NotificationTopic.values.forEach((element) {
      _fcm.subscribeToTopic(element.toString());
    });
  }

  Future<void> createUser(User user) async {
    try {
      await _userCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _userCollection.doc(user.id).update(user.toJson());
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future setAppVersion(User user) async {
    try{
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      final Map<String, dynamic> userJson = user.toJson();
      userJson['appVersion'] = version;
      _userCollection.doc(user.id).update(userJson);
    }catch(e){
      print(e);
    }
  }

  Future setDeviceToken(User user) async {
    try {
      final String? token = await _fcm.getToken();
      final Map<String, dynamic> userJson = user.toJson();
      userJson['deviceToken'] = token;
      userJson['notifications'] = [];

      _userCollection.doc(user.id).update(userJson);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserField(Map<String, dynamic> json) async {
    try {
      await _userCollection.doc(json['id']).update(json);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      var rawUser = await _userCollection.doc(id).get();
      print("get user by id called on $id");
      print(rawUser);
      if (rawUser.exists) {
        return User.fromJson(rawUser.data()!);
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<User?> getUserByField(String field, String value,
      {int limit = 1}) async {
    try {
      var rawUser = await _userCollection
          .where(field, isEqualTo: value)
          .limit(limit)
          .get();
      var userData = rawUser.docs[0];
      if (userData.exists) {
        return User.fromJson(userData.data());
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<bool> checkUserName(String username) async {
    try {
      var res = await _userNames.doc(username).get();
      return res.exists;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> addUsername(User user) async {
    try {
      await _userNames.doc(user.userName).set({"id": user.id},SetOptions(merge: true));
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> searchUser(String query) async {
    try {
      var rawUsername = await _userCollection
          .where("toLowerUserName", isGreaterThanOrEqualTo: query)
          .where("toLowerUserName", isLessThan: query + 'z')
          .get();
      var rawNames = await _userCollection
          .where("toLowerName", isGreaterThanOrEqualTo: query)
          .where("toLowerName", isLessThan: query + 'z')
          .get();
      var rawBook = await _bookclubsCollection
          .where("bookclubName", isGreaterThanOrEqualTo: query)
          .where("bookclubName", isLessThan: query + 'z')
          .get();

      var usernames = rawUsername.docs.map((e) => e.data()).toList();
      var names = rawNames.docs.map((e) => e.data()).toList();
      var books = rawBook.docs.map((e) => e.data()).toList();

      Map<String, Map<String, dynamic>> users = {};

      usernames.forEach((element) {
        users[element['id']] = element;
      });
      names.forEach((element) {
        users[element['id']] = element;
      });
      books.forEach((element) {
        users[element['id']] = element;
      });

      return users.values.toList();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<User> followUser(User currentUser, User userToFollow) async {
    try {
      User user = currentUser;
      var newFollowings = currentUser.followings ?? [];
      if (!newFollowings.contains(userToFollow.id)) {
        newFollowings.add(userToFollow.id);
        var json = currentUser.toJson();
        json['followings'] = newFollowings;
        user = User.fromJson(json);
        print(json);
        await updateUserField({"followings": newFollowings, "id": json['id']});
        print("object");
      }

      var newjson = userToFollow.toJson();
      var followers = newjson['followers'] ?? [];
      if (!followers.contains(currentUser.id)) {
        followers.add(currentUser.id);
        newjson['followers'] = followers;
        await updateUserField({"followers": followers, "id": newjson['id']});
      }
      _fcm.subscribeToTopic(userToFollow.id);
      return user;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<User> unfollowUser(User currentUser, User userToUnfollow) async {
    try {
      User user = currentUser;
      var followings = currentUser.followings ?? [];
      if (followings.remove(userToUnfollow.id)) {
        var json = currentUser.toJson();
        json['followings'] = followings;
        user = User.fromJson(json);
        await updateUserField({"followings": followings, "id": json['id']});
        print(user.followings);
      }
      var followers = userToUnfollow.followers ?? [];
      if (followers.remove(currentUser.id)) {
        var json = userToUnfollow.toJson();
        json['followers'] = followers;
        await updateUserField({"followers": followers, "id": json['id']});
      }

      _fcm.unsubscribeFromTopic(userToUnfollow.id);
      return user;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  getRecentUser() async {
    String url ="https://us-central1-fostr2021.cloudfunctions.net/getLastDaysUsers";
    dynamic data;
    var body = jsonEncode({
      "day" : 10
    });
    var token =
    await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();

    await http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      body: body
    )
        .then((http.Response response) {
      // print("Response : $response");
      // if(response.statusCode == 200)
        data = jsonDecode(response.body);
      // print("body : ${jsonDecode(response.body)}");
      // print("Response status: ${response.statusCode}");
      // print("Response body: ${response.contentLength}");
    });

    return data;
  }
}
