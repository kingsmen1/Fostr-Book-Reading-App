import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/models/UserNotification.dart';
import 'package:fostr/pages/rooms/ThemePage.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:http/http.dart' as http;

import '../Posts/PageSinglePost.dart';
import '../pages/user/NotificationsPage.dart';
import '../reviews/PageSingleReview.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AndroidNotificationChannel channel =
      const AndroidNotificationChannel(
    'foster_notifications',
    'Foster Notifications',
    description: 'This channel is used for user notifications.', // description
    importance: Importance.high,
  );

  sendNewRoomPhoneNotification(
      String authorName,
      String roomName,
      String userId,
      String roomId
      ) async {
    String url ='https://us-central1-fostr2021.cloudfunctions.net/devicenotifications';
    // await FirebaseFirestore.instance
    // .collection("users")
    // .doc()
    var body = jsonEncode(
        {
          'data':{
                    "authorName":authorName,
                    "roomName":roomName,
                    "userId":userId,
                    "roomId":roomId,
                    "tokens":[
                      "evmyT8uOOkBoufgz7Q1NMF:APA91bEmb16pJh4bVfkGaS7L6vs64jh5CN-pnLme685WLNdhoo2aurfAnRGUhc7LGH1KVWRzSN91c5T5_DyINsp1m6lMdck7v7hbMXLxxM45KXOc9BtgYqnqLlVF4m2wONa7V6FTwQbf"
                    ]
                },
        }
    );
    var token = await firebaseAuth.FirebaseAuth.instance.currentUser!.getIdToken();

    await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          },
        body: body
    ).then((http.Response response) {
      print("=============================================");
      print("notification");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      print(response.headers);
      print(response.request);
      print("=============================================");
    });
  }

  Future<void> subscribeToTopic(NotificationTopic topic) async {
    await _fcm.subscribeToTopic(topic.name);
  }

  Future<void> unsubscribeFromTopic(NotificationTopic topic) async {
    await _fcm.unsubscribeFromTopic(topic.name);
  }

  static User subscribeToAll(User user) {
    user.notificationsSettings = {};
    NotificationTopic.values.forEach((topic) {
      _fcm.subscribeToTopic(topic.name);
      user.notificationsSettings![topic.name] = true;
    });
    return user;
  }

  static Future<void> start() async {
    await _fcm.requestPermission();
    _fcm.getToken().then((value) => {
      print("FCM Token: $value")
    });
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
    await createAndroidNotificationChannel();
  }

  static Future<void> createAndroidNotificationChannel() async {
    if (!kIsWeb) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  static Future<void> listen(context) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launch_background');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) {
      print('onDidReceiveLocalNotification');
    });

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      final Map<String, dynamic> data = json.decode(payload!);
      print(data['type']);
      if (data['type'] == NotificationTypes.UserUpdates.val) {
        final User? user = await UserService().getUserById(data['typeID']);

        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => ExternalProfilePage(
                      user: user!,
                    )));
      } else if (data['type'] == NotificationTypes.RoomUpdates.val) {
        final Room? room =
            await RoomService().getRoomById(data['typeID'], data['userID']);

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => ThemePage(
              room: room!,
            ),
          ),
        );
      }
    });

    FirebaseMessaging?.onBackgroundMessage(backgroudnMesssageHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print(notification?.body);
      print(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {

      if (event.data['type'] == NotificationType.Event.name) {
        print(event.data['type']);
        final eventType = event.data['eventType'];
        print(event.data['userId']);
        if (eventType == "room") {
          String roomId = event.data['roomId'];
          String userId = event.data['userId'];

          final Room? room = await RoomService().getRoomById(roomId, userId);

          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => ThemePage(
                room: room!,
              ),
            ),
          );
        } else if (eventType == "review") {
          String reviewId = event.data['reviewId'];
          String userId = event.data['userId'];
          await FirebaseFirestore.instance
              .collection("reviews")
              .doc(reviewId)
              .get()
              .then((value) async {
            String finalDateTime = "";

            var dateDiff =
                DateTime.now().difference(value.get("dateTime").toDate());
            if (dateDiff.inDays >= 1) {
              finalDateTime = DateFormat.yMMMd()
                  .addPattern(" | ")
                  .add_jm()
                  .format(value.get("dateTime").toDate())
                  .toString();
            } else {
              finalDateTime = timeago.format(value.get("dateTime").toDate());
            }

            await FirebaseFirestore.instance
                .collection("users")
                .doc(value.get("editorId"))
                .get()
                .then((user) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PageSingleReview(
                    url: value.get("url"),
                    profile: user.get("userProfile.profileImage"),
                    username: user.get("userName"),
                    bookName: value.get("bookName"),
                    bookAuthor: value.get("bookAuthor"),
                    bookBio: value.get("bookNote"),
                    dateTime: finalDateTime,
                    id: value.get("id"),
                    uid: value.get("editorId"),
                    imageUrl: value.data()?["imageUrl"],
                  ),
                ),
              );
            });
          });
        } else if (eventType == "post") {
          final postId = event.data["postId"];
          final userId = event.data["userId"];

          await FirebaseFirestore.instance
              .collection("posts")
              .doc(postId)
              .get()
              .then(
            (value) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PageSinglePost(
                      postId: postId,
                      dateTime: value.get("dateTime"),
                      userid: value.get("userid"),
                      userProfile: value.get("userProfile"),
                      username: value.get("username"),
                      image: value.get("image"),
                      caption: value.get("caption"),
                      likes: value.get("likes").toString(),
                      comments: value.get("comments").toString()),
                ),
              );
            },
          );
        }
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => NotificationPage()),
        );
      }
    });
  }
}

Future backgroudnMesssageHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  if (notification != null && !kIsWeb) {
    // NOTE: commenting this code prevents the app from showing the duplicate notification

    // FlutterLocalNotificationsPlugin().show(
    //     notification.hashCode,
    //     notification.title,
    //     notification.body,
    //     NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'user_notifications',
    //         'User_Notifications',
    //         channelDescription: 'This channel is used for user notifications.',
    //         icon: 'launch_background',
    //       ),
    //     ),
    //     payload: json.encode(message.data));
  }
}
