import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double radius;
  const UserAvatar(
      {required this.name, required this.imageUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CircleAvatar(
            radius: radius,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(fontSize: 36),
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Center(child: Text(name)),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
