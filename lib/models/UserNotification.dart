import 'dart:convert';

import 'package:flutter/foundation.dart';

///Type of notifications.
///
///Can be a user specific notification or some room schedule notification.
///These can be used to go to specific routes when clicked on notification.
enum NotificationTypes { UserUpdates, RoomUpdates, Others }

///Simple conversions from enum to string.
extension Convert on NotificationTypes {
  String get val => describeEnum(this);
}

class UserNotification {
  final String title;
  final String body;
  final NotificationTypes type;

  ///It can be a userID or roomID or null (when notificationType is OTHER)
  final String? typeID;

  ///When Notification is roomUpdates , then this will be respective userID.
  final String? userID;
  UserNotification(
      {required this.title,
      required this.body,
      required this.type,
      this.typeID,
      this.userID});

  UserNotification copyWith({
    String? title,
    String? body,
    NotificationTypes? type,
    String? typeID,
    String? userID,
  }) {
    return UserNotification(
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      typeID: typeID ?? this.typeID,
      userID: userID ?? this.userID,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.val,
      'typeID': typeID,
      'userID': userID,
    };
  }

  factory UserNotification.fromMap(Map<String, dynamic> map) {
    return UserNotification(
      title: map['title'],
      body: map['body'],
      type: NotificationTypes.values
          .firstWhere((element) => describeEnum(element) == (map['type'])),
      typeID: map['typeID'] != null ? map['typeID'] : null,
      userID: map['userID'] != null ? map['userID'] : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserNotification.fromJson(String source) =>
      UserNotification.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserNotification(title: $title, body: $body, type: $type, typeID: $typeID, userID: $userID)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserNotification &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.typeID == typeID &&
        other.userID == userID;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        body.hashCode ^
        type.hashCode ^
        typeID.hashCode ^
        userID.hashCode;
  }
}
