// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map json) => User(
      id: json['id'] as String,
      appVersion: json['appVersion'] as String?,
      toLowerUserName: json['toLowerUserName'] as String?,
      toLowerBookClubName: json['toLowerBookClubName'] as String?,
      toLowerName: json['toLowerName'] as String?,
      deviceToken: json['deviceToken'] as String?,
      userName: json['userName'] as String,
      userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
      createdOn: DateTime.parse(json['createdOn'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
      points: json['points'] as int? ?? 20,
      invites: json['invites'] as int? ?? 10,
      userProfile: json['userProfile'] == null
          ? null
          : UserProfile.fromJson(
              Map<String, dynamic>.from(json['userProfile'] as Map)),
      rewardcountforbookclub: json['rewardcountforbookclub'] as int? ?? 1,
      rewardcountfordailycheckin:
          json['rewardcountfordailycheckin'] as int? ?? 100,
      rewardcountforpost: json['rewardcountforpost'] as int? ?? 10,
      rewardcountforreferral: json['rewardcountforreferral'] as int? ?? 10,
      rewardcountforreview: json['rewardcountforreview'] as int? ?? 10,
      rewardcountforroom: json['rewardcountforroom'] as int? ?? 5,
      rewardcountfortheatre: json['rewardcountfortheatre'] as int? ?? 5,
    )
      ..name = json['name'] as String
      ..bookClubName = json['bookClubName'] as String?
      ..notificationToken = json['notificationToken'] as String?
      ..followers = (json['followers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..followings = (json['followings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..totalRooms = json['totalRooms'] as int?
      ..totlaHours = (json['totlaHours'] as num?)?.toDouble()
      ..notificationsSettings = json['notificationsSettings'] as Map?;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'appVersion': instance.appVersion,
      'deviceToken': instance.deviceToken,
      'name': instance.name,
      'bookClubName': instance.bookClubName,
      'toLowerUserName': instance.toLowerUserName,
      'toLowerBookClubName': instance.toLowerBookClubName,
      'toLowerName': instance.toLowerName,
      'notificationToken': instance.notificationToken,
      'userType': _$UserTypeEnumMap[instance.userType],
      'createdOn': instance.createdOn.toIso8601String(),
      'lastLogin': instance.lastLogin.toIso8601String(),
      'invites': instance.invites,
      'points': instance.points,
      'userProfile': instance.userProfile?.toJson(),
      'followers': instance.followers,
      'followings': instance.followings,
      'totalRooms': instance.totalRooms,
      'totlaHours': instance.totlaHours,
      'notificationsSettings': instance.notificationsSettings,
      'rewardcountforbookclub': instance.rewardcountforbookclub,
      'rewardcountfordailycheckin': instance.rewardcountfordailycheckin,
      'rewardcountforpost': instance.rewardcountforpost,
      'rewardcountforreferral': instance.rewardcountforreferral,
      'rewardcountforreview': instance.rewardcountforreview,
      'rewardcountforroom': instance.rewardcountforroom,
      'rewardcountfortheatre': instance.rewardcountfortheatre,
    };

const _$UserTypeEnumMap = {
  UserType.USER: 'USER',
  UserType.CLUBOWNER: 'CLUBOWNER',
};
