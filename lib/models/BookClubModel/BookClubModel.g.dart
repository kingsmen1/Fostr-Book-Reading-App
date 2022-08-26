// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookClubModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookClubModel _$BookClubModelFromJson(Map json) => BookClubModel(
      id: json['id'] as String,
      adminAccounts: json['adminAccounts'] as int,
      adminProfile: json['adminProfile'] as String?,
      adminUsers: (json['adminUsers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bookClubBio: json['bookClubBio'] as String?,
      bookClubName: json['bookClubName'] as String,
      bookClubProfile: json['bookClubProfile'] as String?,
      createdBy: json['createdBy'] as String,
      createdOn: DateTime.parse(json['createdOn'] as String),
      genres:
          (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
      instagram: json['instagram'] as String?,
      isActive: json['isActive'] as bool,
      isInviteOnly: json['isInviteOnly'] as bool,
      membersCount: json['membersCount'] as int,
      roomsCount: json['roomsCount'] as int,
      twitter: json['twitter'] as String?,
      followers:
          (json['followers'] as List<dynamic>).map((e) => e as String).toList(),
      followings: (json['followings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      members:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
      pendingMembers: (json['pendingMembers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    )..bookclubLowerName = json['bookclubLowerName'] as String;

Map<String, dynamic> _$BookClubModelToJson(BookClubModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adminAccounts': instance.adminAccounts,
      'adminProfile': instance.adminProfile,
      'adminUsers': instance.adminUsers,
      'bookClubBio': instance.bookClubBio,
      'bookClubName': instance.bookClubName,
      'bookClubProfile': instance.bookClubProfile,
      'createdBy': instance.createdBy,
      'createdOn': instance.createdOn.toIso8601String(),
      'genres': instance.genres,
      'followers': instance.followers,
      'members': instance.members,
      'pendingMembers': instance.pendingMembers,
      'followings': instance.followings,
      'instagram': instance.instagram,
      'twitter': instance.twitter,
      'isActive': instance.isActive,
      'isInviteOnly': instance.isInviteOnly,
      'bookclubLowerName': instance.bookclubLowerName,
      'membersCount': instance.membersCount,
      'roomsCount': instance.roomsCount,
    };
