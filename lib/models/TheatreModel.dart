import 'package:cloud_firestore/cloud_firestore.dart';

class Theatre {
  final String? title,
      token,
      imageUrl,
      genre,
      userProfileImage,
      summary,
      theatreId,
      createdBy,
      creatorUsername;
  final bool? isActive, isUpcoming;
  final DateTime? scheduleOn;

  Theatre(
      {this.title,
      this.isActive,
      this.isUpcoming,
      this.theatreId,
      this.token,
      this.summary,
      this.userProfileImage,
      this.genre,
      this.imageUrl,
      this.scheduleOn,
      this.createdBy,
      this.creatorUsername});

  factory Theatre.fromJson(json, date) {
    var value;
    if (date == "change") {
      int seconds = int.parse(json["scheduledOn"]
          .toString()
          .split("_seconds: ")[1]
          .split(", _")[0]);
      int nanoseconds = int.parse(json["scheduledOn"]
          .toString()
          .split("_nanoseconds: ")[1]
          .split("}")[0]);
      value = Timestamp(seconds, nanoseconds);
    } else {
      value = json["scheduledOn"];
    }
    return Theatre(
        title: json['title'],
        token: json['token'],
        imageUrl: json['image'],
        genre: json["genre"],
        userProfileImage: json["userProfileImage"],
        scheduleOn: value.toDate(),
        theatreId: json['theatreId'],
        summary: json['summary'],
        isActive: json['isActive'],
        isUpcoming: json['isUpcoming'],
        createdBy: json['createdBy'],
        creatorUsername: json['creatorUsername']);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'token': token,
        'image': imageUrl,
        'genre': genre,
        'userProfileImage': userProfileImage,
        'scheduleOn': scheduleOn,
        'theatreId': theatreId,
        'summary': summary,
        'isActive': isActive,
        'isUpcoming': isUpcoming,
        'createdBy': createdBy,
        'creatorUsername': creatorUsername
      };
}
