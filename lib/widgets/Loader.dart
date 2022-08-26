import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fostr/utils/widget_constants.dart';

import 'AppLoading.dart';

class Loader extends StatefulWidget {
  final bool isLoading;
  const Loader({Key? key, this.isLoading = true}) : super(key: key);

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return Container();
    }
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Center(
              child: Container(
                height: 250,
                width: 250,
                child: Center(
                    child: AppLoading(
                  height: 70,
                  width: 70,
                )
                    // CircularProgressIndicator(
                    //   color: GlobalColors.signUpSignInButton,
                    // ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
