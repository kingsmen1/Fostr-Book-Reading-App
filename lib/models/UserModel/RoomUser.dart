import 'package:cloud_firestore/cloud_firestore.dart';

class RoomUser {
  final String name;
  final String username;
  String profileImage = 'assets/images/profile.png';

  RoomUser({
    required this.name,
    required this.username,
    required this.profileImage,
  });

  factory RoomUser.fromJson(json) {
    return RoomUser(
      name: json['name'],
      username: json['username'],
      profileImage: json['profileImage'],
    );
  }

  factory RoomUser.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return RoomUser.fromJson(data);
  }
}
