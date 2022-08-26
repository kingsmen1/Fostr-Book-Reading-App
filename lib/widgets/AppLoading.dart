import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoading extends StatelessWidget {
  final double height;
  final double width;
  const AppLoading({Key? key, this.height = 140, this.width = 140})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      width: width,
      child: (theme.brightness == Brightness.dark)
          ? LottieBuilder.asset(
              "assets/lottie/bookloading.json",
            )
          : LottieBuilder.asset(
              "assets/lottie/bookloading-light.json",
            ),
    );
  }
}
