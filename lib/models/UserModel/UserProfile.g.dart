// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserProfile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      bio: json['bio'] as String?,
      facebook: json['facebook'] as String?,
      google: json['google'] as String?,
      instagram: json['instagram'] as String?,
      linkedIn: json['linkedIn'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      twitter: json['twitter'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      description: json['description'] as String?,
    )
      ..topRead = (json['topRead'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList()
      ..Bookmarks = (json['Bookmarks'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList();

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'instagram': instance.instagram,
      'facebook': instance.facebook,
      'linkedIn': instance.linkedIn,
      'google': instance.google,
      'twitter': instance.twitter,
      'profileImage': instance.profileImage,
      'phoneNumber': instance.phoneNumber,
      'description': instance.description,
      'genres': instance.genres,
      'topRead': instance.topRead,
      'Bookmarks': instance.Bookmarks,
    };
