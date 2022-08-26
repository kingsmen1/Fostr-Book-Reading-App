import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/models/UserModel/User.dart';

class RoomProvider with ChangeNotifier {
  bool _shoudlShow = true;
  Room? _room;
  Theatre? _theatre;
  User? _user;
  bool? _isJoined;
  bool? _isMuted;
  bool? _micDisabled;
  String? _rtmToken;

  Room? get room => _room;
  bool? get isJoined => _isJoined;
  bool? get isMuted => _isMuted;
  User? get user => _user;
  bool? get isMicDisabled => _micDisabled;
  Theatre? get theatre => _theatre;
  String? get rtmToken => _rtmToken;
  bool get shouldShow => _shoudlShow;


  void showPlayer(){
    _shoudlShow = true;
    notifyListeners();
  }

  void hidePlayer(){
    _shoudlShow = false;
    notifyListeners();
  }

  void setRoom(Room room, User user) {
    _room = room;
    _user = user;
    _isJoined = true;
    _isMuted = true;
    _micDisabled = false;
    notifyListeners();
  }

  void setTheatre(Theatre theatre, User user) {
    _theatre = theatre;
    _user = user;
    _isJoined = true;
    _isMuted = true;
    _micDisabled = false;
    notifyListeners();
  }

  void setRtmToken(String rtmToken, {bool shouldNotify = false}) {
    _rtmToken = rtmToken;
    if (shouldNotify) notifyListeners();
  }

  void clearRoom() {
    _room = null;
    _isJoined = null;
    _isMuted = null;
    notifyListeners();
  }

  void setIsJoined(bool isJoined) {
    _isJoined = isJoined;
    notifyListeners();
  }

  void setMicDisabled(bool state) {
    _micDisabled = state;
    notifyListeners();
  }

  void setIsMuted(bool isMuted, {bool shouldNotify = true}) {
    _isMuted = isMuted;
    if (_room != null) {
      FirebaseFirestore.instance
          .collection("rooms")
          .doc(_room!.id)
          .collection("rooms")
          .doc(_room!.roomID)
          .collection("speakers")
          .doc(_user!.userName)
          .update({
        "isMicOn": isMuted,
      });
    }
    if (shouldNotify) notifyListeners();
  }
}
