import 'package:flutter/material.dart';
import 'package:fostr/pages/rooms/EnterBookClubDetails.dart';
import 'package:fostr/utils/theme.dart';


class BookClubDetails extends StatelessWidget with FostrTheme {
  @override
  Widget build(BuildContext context) {
    return Material(child: EnterBookClubDetails());
  }
}