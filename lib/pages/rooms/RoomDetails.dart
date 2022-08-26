import 'package:flutter/material.dart';
import 'package:fostr/pages/rooms/EnterRoomDetails.dart';
import 'package:fostr/pages/rooms/SelectRoomType.dart';
import 'package:fostr/utils/theme.dart';


class RoomDetails extends StatelessWidget with FostrTheme {
  @override
  Widget build(BuildContext context) {
    return Material(child: SelectRoomType());
  }
}
