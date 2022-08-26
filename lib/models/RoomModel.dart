import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String? title,
      roomCreator,
      token,
      agenda,
      imageUrl,
      roomID,
      id,
      authorName,
      summary,
      adTitle,
      adDescription,
      redirectLink,
      imageUrl2;
  final bool? isActive, isUpcoming, isBookClub;
  final int? participantsCount, speakersCount;
  final DateTime? dateTime;
  final bool isInviteOnly;
  final bool isFollowersOnly;

  Room(
      {this.title,
      required this.isInviteOnly,
      required this.isFollowersOnly,
      this.participantsCount,
      this.speakersCount,
      // this.users,
      this.authorName,
      this.summary,
      this.roomCreator,
      this.isActive,
      this.isUpcoming,
      this.isBookClub,
      this.token,
      this.agenda,
      this.imageUrl,
      this.dateTime,
      this.id,
      this.roomID,
      this.adTitle,
      this.adDescription,
      this.redirectLink,
      this.imageUrl2});

  factory Room.fromJson(json, date) {
    var value;
    // print(json["dateTime"]);

    if (date == "change" && !(json["dateTime"].runtimeType == Timestamp)) {
      int seconds = int.parse(
          json["dateTime"].toString().split("_seconds: ")[1].split(", _")[0]);
      int nanoseconds = int.parse(
          json["dateTime"].toString().split("_nanoseconds: ")[1].split("}")[0]);
      value = Timestamp(seconds, nanoseconds);
    } else {
      value = json["dateTime"];
    }

    // print(DateTime.parse(value.toDate().toString()).toUtc());
    return Room(
      authorName: json['authorName'],
      summary: json['summary'],
      title: json['title'],
      participantsCount: json['participantsCount'],
      speakersCount: json['speakersCount'],
      roomCreator: json['roomCreator'],
      token: json['token'],
      agenda: json['agenda'],
      imageUrl: json['image'],
      dateTime: DateTime.parse(value.toDate().toString()).toUtc(),
      isActive: json['isActive'],
      isBookClub: json['isBookClub'],
      isUpcoming: json['isUpcoming'],
      id: json['id'],
      isInviteOnly: json['inviteOnly'] ?? false,
      roomID: json['roomID'],
      adTitle: json['adTitle'],
      adDescription: json['adDescription'],
      redirectLink: json['redirectLink'],
      imageUrl2: json['imageUrl2'],
      isFollowersOnly: json['followersOnly'] ?? false,
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'authorName': authorName,
      'summary': summary,
      'title': title,
      'participantsCount': participantsCount,
      'speakersCount': speakersCount,
      'roomCreator': roomCreator,
      'token': token,
      'agenda': agenda,
      'image': imageUrl,
      'dateTime': dateTime,
      'isActive': isActive,
      'isBookClub': isBookClub,
      'isUpcoming': isUpcoming,
      'id': id,
      'inviteOnly': isInviteOnly,
      'roomID': roomID,
      'adTitle': adTitle,
      'adDescription': adDescription,
      'redirectLink': redirectLink,
      'imageUrl2': imageUrl2,
      'followersOnly': isFollowersOnly,
    };
  }
}
