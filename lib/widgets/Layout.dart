import 'package:flutter/material.dart';
import 'package:fostr/widgets/Background.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final Widget? background;
  const Layout({Key? key, required this.child, this.background})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (background == null) {
      return Material(
        child: Stack(
          children: [Background(), child],
        ),
      );
    }

    return Material(
      child: Stack(
        children: [background!, child],
      ),
    );
  }
}
