import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/onboarding/AddDetails.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/InputField.dart';
import 'package:fostr/widgets/Loader.dart';
import 'package:provider/provider.dart';

import '../../utils/widget_constants.dart';
import '../../widgets/Layout.dart';
import 'package:firebase_auth/firebase_auth.dart' as f;
import 'package:sizer/sizer.dart';

import '../user/SelectBookCLubGenre.dart';
import 'AddPasswordDetails.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key}) : super(key: key);

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> with FostrTheme {
  final otpForm = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();

  bool isError = false;
  bool isLoading = false;
  String error = "";

  void handleRoute(User? user, UserType userType, f.User fuser) async {
    if (user != null) {
      if (user.lastLogin.difference(user.createdOn) <
          Duration(seconds: 10) /*|| fuser.email == null*/) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AddDetails(),
          ),
        );
        // FostrRouter.goto(context, Routes.addDetails);
      } else {
        // final isOk = await confirmDialog(context, h2);
        // if (isOk != null && isOk) {
        FostrRouter.removeUntillAndGoto(
            context, Routes.userDashboard, (route) => false);
        // } else {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Layout(
          child: Stack(
            children: [
              Padding(
                padding: paddingH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 140,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Text("Verification",
                          style: h1.copyWith(
                            fontSize: 22.sp,
                            color: theme.colorScheme.inversePrimary,
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please enter the OTP",
                      style: h2.copyWith(
                        fontSize: 14.sp,
                        color: theme.colorScheme.inversePrimary,
                      ),
                    ),
                    SizedBox(
                      height: 90,
                    ),
                    Form(
                      key: otpForm,
                      child: Column(
                        children: [
                          InputField(
                            validator: (value) {
                              if (isError) {
                                isError = false;
                                return error;
                              }
                              if (value!.length < 6) {
                                return "OTP should be 6 digits long";
                              } else if (!Validator.isNumber(value)) {
                                return "OTP should contain only digits";
                              }
                            },
                            controller: _controller,
                            hintText: "Enter OTP",
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          // Text("Didn't get the OTP ?",
                          //     style: h2.copyWith(
                          //       fontSize: 13.sp,
                          //     )),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // InkWell(
                          //   onTap: () {
                          //     auth.resendOTP();
                          //   },
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Text("Resend OTP",
                          //           style: h2.copyWith(
                          //             fontSize: 11.sp,
                          //           )),
                          //       SizedBox(
                          //         width: 10,
                          //       ),
                          //       Icon(
                          //         FontAwesomeIcons.arrowRotateRight,
                          //         color: Colors.grey,
                          //         size: 14,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 111),
                      child: ElevatedButton(
                          onPressed: () async {
                            if (otpForm.currentState!.validate()) {
                              try {
                                setState(() {
                                  isLoading = true;
                                });
                                var user = await auth.verifyOtp(
                                    context, _controller.text, auth.userType!);
                                handleRoute(
                                    user, auth.userType!, auth.firebaseUser!);
                              } catch (e) {
                                handleError(e);
                              }
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          style: buildButtonStyle(theme.colorScheme.secondary),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0, top: 15, bottom: 15),
                                  child: Icon(
                                    FontAwesomeIcons.check,
                                    color: Colors.white,
                                  )),
                              Text(
                                "Verify OTP",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 30,
                    )),
              ),
              Loader(
                isLoading: isLoading,
              )
            ],
          ),
        ),
      ),
    );
  }

  FutureOr<Null> handleError(Object error) async {
    log(error.toString());
    setState(() {
      isError = true;
      this.error = showAuthError(error.toString());
    });
    otpForm.currentState!.validate();
  }
}

Future<bool?> confirmDialog(BuildContext context, TextStyle h2) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final theme = Theme.of(context);
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
                    Text(
                      'An account with this email already exists. Would you like to be sign in instead?',
                      style: h2.copyWith(
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.secondary),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            "Cancel",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                GlobalColors.signUpSignInButton),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            "Sign in",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.white,
                            ),
                          ),
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
