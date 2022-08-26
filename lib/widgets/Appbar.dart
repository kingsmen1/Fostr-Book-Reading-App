import 'package:flutter/material.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget {
  const Appbar({Key? key}) : super(key: key);

  final double height = 75;
  final double width = double.infinity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Stack(
        children: [],
      ),
    );
  }

  @override
  Size get preferredSize => Size(width, height);
}
