import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/utils/theme.dart';
import 'package:sizer/sizer.dart';

import '../core/constants.dart';

class InputField extends StatefulWidget {
  final String? hintText;
  final String? helperText;
  final int? maxLine;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String? value)? validator;
  final TextInputType keyboardType;
  final Function(String value)? onChange;
  final VoidCallback? onEditingCompleted;
  final String? initialText;
  final bool? readOnly;
  InputField({
    Key? key,
    this.hintText = "",
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.controller,
    this.onChange,
    this.isPassword = false,
    this.maxLine = 1,
    this.onEditingCompleted,
    this.initialText,
    this.readOnly,
  }) : super(
          key: key,
        );

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> with FostrTheme {
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        showPassword = widget.isPassword;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    assert(widget.controller != null || widget.initialText != null);
    return SizedBox(
      width: 90.w,
      child: TextFormField(
        readOnly: widget.readOnly ?? false,
        initialValue: widget.initialText,
        onEditingComplete: widget.onEditingCompleted,
        maxLines: widget.maxLine ?? 1,
        onChanged: (e) {
          if (widget.onChange != null) {
            widget.onChange!(e);
          }
        },
        controller: widget.controller,
        validator: widget.validator,
        obscureText: showPassword,
        keyboardType: widget.keyboardType,
        cursorColor: textFieldStyle.color,
        style: textFieldStyle.copyWith(
          fontSize: 14.sp,
          color: theme.colorScheme.inversePrimary,
        ),
        decoration: registerInputDecoration.copyWith(
            hintText: widget.hintText,
            fillColor: theme.inputDecorationTheme.fillColor),
      ),
    );
  }
}
