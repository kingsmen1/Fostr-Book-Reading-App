import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fostr/core/data.dart';

class RatingService {
  String? _currentRoom;
  String? _currentRoomCreator;
  String? _currentUser;
  bool _isSet = false;

  String? get currentRoom => _currentRoom;
  String? get currentRoomCreator => _currentRoomCreator;
  String? get currentUser => _currentUser;
  bool get isDataSet => _isSet;
  final ratingCollection = FirebaseFirestore.instance.collection("ratings");

  void setCurrentRoom(String roomID, String creatorID, String userID) {
    _currentRoom = roomID;
    _currentRoomCreator = creatorID;
    _currentUser = userID;
    _isSet = true;
  }

  Future<void> addRating(double ratings) async {
    log(_isSet.toString());
    if (_isSet) {
      try {
        final doc = await ratingCollection.doc(_currentRoomCreator!).get();
        if (doc.exists) {
          final data = doc.data();
          int count = data!['count'];
          double oldRatings = data['ratings'];
          double newRatings = ((oldRatings * count) + ratings) / ++count;
          doc.reference.set({"ratings": newRatings, "count": count},SetOptions(merge: true));
        } else {
          await doc.reference.set({"ratings": ratings, "count": 1},SetOptions(merge: true));
        }
        doc.reference
            .collection('rooms')
            .doc(_currentRoom)
            .collection('users')
            .doc(_currentUser)
            .set({"id": _currentUser},SetOptions(merge: true));
      } catch (e) {}
    }
  }

  Future<double> getRatings(String creatorID) async {
    final ratings = await ratingCollection.doc(creatorID).get();
    return ratings.data()!['ratings'];
  }

  Future<bool> isAlreadyRated() async {
    try {
      // if (_currentRoomCreator == _currentUser) {
      //   return true;
      // }

      final doc = await ratingCollection
          .doc(_currentRoomCreator!)
          .collection('rooms')
          .doc(_currentRoom)
          .collection('users')
          .doc(_currentUser!)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
