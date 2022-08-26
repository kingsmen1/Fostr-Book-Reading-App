import 'package:flutter/material.dart';
import 'package:fostr/utils/theme.dart';
import 'package:sizer/sizer.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;

  PrimaryButton({Key? key, required this.text, required this.onTap, this.width})
      : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with FostrTheme {
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
        width: (widget.width) ?? 90.w,
        height: 10.h,
        decoration: BoxDecoration(
          borderRadius: buttonBorderRadius,
          gradient: primaryButton,
        ),
        child: Text(
          widget.text,
          style: actionTextStyle.copyWith(
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final Color? disabledColor;
  final EdgeInsets? padding;
  final Function? onPressed;
  final Widget child;
  final bool? isCircle;
  final double? minimumWidth;
  final double? minimumHeight;

  const RoundedButton({
    Key? key,
    this.text = '',
    this.fontSize = 20,
    this.color,
    this.disabledColor,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
    this.onPressed,
    this.isCircle = false,
    this.minimumWidth = 0,
    this.minimumHeight = 0,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(
            Size(minimumWidth!, minimumHeight!)),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return disabledColor!;
            }
            return color!;
          },
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          isCircle!
              ? CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
        ),
        padding: MaterialStateProperty.all<EdgeInsets>(padding!),
        elevation: MaterialStateProperty.all<double>(0.5),
      ),
      onPressed: () => onPressed!(),
      child: text.isNotEmpty
          ? Text(
              text,
              style: TextStyle(fontSize: fontSize, color: Colors.white),
            )
          : child,
    );
  }
}
