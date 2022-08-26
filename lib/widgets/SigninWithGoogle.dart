import 'package:flutter/material.dart';
import 'package:fostr/utils/theme.dart';
import 'package:sizer/sizer.dart';

class SigninWithGoogle extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const SigninWithGoogle({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  _SigninWithGoogleState createState() => _SigninWithGoogleState();
}

class _SigninWithGoogleState extends State<SigninWithGoogle> with FostrTheme {
  double scale = 1;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (e) {
        setState(() {
          scale = 0.8;
        });
      },
      onTapUp: (e) {
        setState(() {
          scale = 1;
        });
      },
      onTap: widget.onTap,
      child: AnimatedContainer(
        constraints: BoxConstraints(
          maxHeight: 90,
          maxWidth: 500,
        ),
        transformAlignment: Alignment.center,
        transform: Transform.scale(scale: scale).transform,
        duration: Duration(milliseconds: 200),
        alignment: Alignment.center,
        width: 90.w,
        height: 10.h,
        decoration: BoxDecoration(
          borderRadius: buttonBorderRadius,
          color: Colors.white,
          // gradient: primaryButton,
        ),
        child: Text(
          widget.text,
          style: actionTextStyle.copyWith(
            color: Colors.black,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}
