import 'package:flutter/foundation.dart';

class RoomsMetaProvider with ChangeNotifier {
  int _totalRooms = 0;

  int get totalRooms => _totalRooms;
  set totalRooms(int value) {
    _totalRooms = value;
    notifyListeners();
  }
  void increaseRoomCount(int value) {
    _totalRooms += value;
    notifyListeners();
  }
  set decreaseRoomCount(int value) {
    _totalRooms -= value;
    notifyListeners();
  }
}
