import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/utils/theme.dart';

class ToastMessege {
  ToastMessege(String text, {required BuildContext context}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
