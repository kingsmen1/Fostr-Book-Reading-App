import 'package:fostr/core/constants.dart';
import 'package:json_annotation/json_annotation.dart';

import 'UserProfile.dart';

part 'User.g.dart';

@JsonSerializable(explicitToJson: true,anyMap: true)
class User {
  final String id;
  String userName;
  String? appVersion;
  String? deviceToken;
  String name = "";
  String? bookClubName = "";
  String? toLowerUserName;
  String? toLowerBookClubName;
  String? toLowerName;
  String? notificationToken;
  UserType userType;
  DateTime createdOn;
  DateTime lastLogin;
  int invites;
  int points;
  UserProfile? userProfile = UserProfile.empty();
  List<String>? followers = [];
  List<String>? followings = [];
  int? totalRooms = 0;
  double? totlaHours = 0.0;
  Map<dynamic,dynamic>? notificationsSettings;
  int rewardcountforbookclub;
  int rewardcountfordailycheckin;
  int rewardcountforpost;
  int rewardcountforreferral;
  int rewardcountforreview;
  int rewardcountforroom;
  int rewardcountfortheatre;

  User(
      {required this.id,
      this.appVersion,
      this.toLowerUserName,
      this.toLowerBookClubName,
      this.toLowerName,
      this.deviceToken,
      required this.userName,
      required this.userType,
      required this.createdOn,
      required this.lastLogin,
      this.points = 20,
      this.invites = 10,
      this.userProfile,
      this.rewardcountforbookclub = 1,
      this.rewardcountfordailycheckin = 100,
      this.rewardcountforpost = 10,
      this.rewardcountforreferral = 10,
      this.rewardcountforreview = 10,
      this.rewardcountforroom = 5,
      this.rewardcountfortheatre = 5,});

  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.fromUser(User user) {
    var json = user.toJson();
    return User.fromJson(json);
  }
}
