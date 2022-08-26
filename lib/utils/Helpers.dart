import 'dart:ui';

import 'package:flutter/material.dart';

import 'widget_constants.dart';
import 'package:sizer/sizer.dart';

class Validator {
  static bool isEmail(String email) => RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);
  static bool isPhone(String phone) =>
      phone.length >= 8 && phone.length <= 12 && int.tryParse(phone) != null;

  static bool isUsername(String username) =>
      RegExp(r"^(?=.{3,20}$)(?![_.])(?!.*[_.]{3})[A-Za-z0-9._]+(?<![_.])$")
          .hasMatch(username);

  static bool isNumber(String value) => RegExp(r"^[0-9]{6}").hasMatch(value);
}

String showAuthError(String errorCode) {
  print(errorCode);
  switch (errorCode) {
    case "user-type-mismatch":
      return "User already exists with another type";
    case "invalid-email":
      return "Given email is invalid";
    case "email-already-in-use":
      return "Account already exists, try to login";
    case "phone-already-in-use":
      return "Account already exists, try to login";
    case "user-disabled":
      return "User is disabled";
    case "user-not-found":
      return "No user found with this email";
    case "wrong-password":
      return "Wrong password";
    case "invalid-verification-code":
      return "Wrong otp entered";
    case "session-expired":
      return "Session expired, try to resend otp";
    case "credential-already-in-use":
      return "Account already exists with this number";
    default:
      return "Something went wrong";
  }
}

Future<bool?> fosterDialog(
    BuildContext context, String question, Function? onFinish) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final size = MediaQuery.of(context).size;
      return Container(
        height: size.height,
        width: size.width,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Align(
            alignment: Alignment(0, 0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: size.width * 0.9,
                constraints: BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Color(0xff3A3845),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Color(0xffffffff),
                          fontFamily: "drawerbody",
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                GlobalColors.signUpSignInButton),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text("Yes",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Color(0xffffffff),
                                fontFamily: "drawerbody",
                              )),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
