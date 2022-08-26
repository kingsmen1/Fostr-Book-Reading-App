import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/onboarding/AddPhoneDetails.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/InputField.dart';
import 'package:fostr/widgets/Loader.dart';
import 'package:fostr/widgets/ToastMessege.dart';

import '../../utils/widget_constants.dart';
import '../../widgets/Layout.dart';
import '../user/SelectBookCLubGenre.dart';

class EmailVerification extends StatefulWidget {
  final bool isPhoneVerified;
  final bool fromSettings;
  const EmailVerification(
      {Key? key, required this.isPhoneVerified, this.fromSettings = false})
      : super(key: key);

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> with FostrTheme {
  final emailForm = GlobalKey<FormState>();

  bool isError = false;
  String error = "";

  bool isVerifying = false;
  bool isVerified = false;
  bool isTriedVerify = false;
  bool didResendVerificationMail = false;

  bool isVerificationMailSent = false;

  void handleRoute(User? user, UserType userType) async {
    if (user != null) {
      if (user.lastLogin.difference(user.createdOn) < Duration(seconds: 10)) {
        FostrRouter.goto(context, Routes.addDetails);
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
    if (!isVerificationMailSent) {
      auth.firebaseUser?.sendEmailVerification();
      isVerificationMailSent = true;
    }
    return WillPopScope(
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
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "We have sent you an email to verify your email address",
                    textAlign: TextAlign.center,
                    style: h2.copyWith(
                        fontSize: 14.sp,
                        color: theme.colorScheme.inversePrimary),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                  Form(
                    key: emailForm,
                    child: Column(
                      children: [
                        InputField(
                          readOnly: true,
                          initialText: auth.firebaseUser?.email ?? "",
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  (isVerifying)
                      ? AppLoading(
                          height: 90,
                          width: 90,
                        )
                      : (isVerified)
                          ? Text(
                              "Verified",
                              style:
                                  TextStyle(color: Colors.green, fontSize: 20),
                            )
                          : (isTriedVerify)
                              ? Text(
                                  "Could not verify. Please try again",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                )
                              : SizedBox.shrink(),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Didn't get the mail?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        auth.firebaseUser
                            ?.sendEmailVerification()
                            .then((value) {
                          setState(() {
                            isTriedVerify = true;
                            isVerificationMailSent = true;
                          });
                        });
                        ToastMessege("Verification mail sent",context: context);
                      } catch (e) {}
                    },
                    child: Text(
                      "Resend",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 111),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          if (!isVerified) {
                            setState(() {
                              isVerifying = true;
                              isTriedVerify = true;
                            });
                            final fUser = auth.firebaseUser;
                            await fUser?.reload();
                            if (fUser?.emailVerified ?? false) {
                              setState(() {
                                isVerified = true;
                              });
                            } else {}
                            setState(() {
                              isVerifying = false;
                            });
                          } else {
                            
                              if (widget.fromSettings) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              } else {
                                FostrRouter.goto(context, Routes.addDetails);
                              }
                            
                          }
                        } catch (e) {
                          setState(() {
                            isVerifying = false;
                          });
                        }
                      },
                      style: buildButtonStyle(theme.colorScheme.secondary),
                      child: (!isVerified)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, top: 15, bottom: 15),
                                    child: Icon(FontAwesomeIcons.check,
                                        color: Colors.white)),
                                Text(
                                  "Check if email is verified",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, top: 15, bottom: 15),
                                    child: Icon(
                                      FontAwesomeIcons.arrowRight,
                                      color: Colors.white,
                                    )),
                                Text(
                                  "Continue",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                    ),
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
                    color: Colors.white,
                  )),
            ),
            Loader(
              isLoading: auth.isLoading,
            )
          ],
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
    emailForm.currentState!.validate();
  }
}

Future<bool?> confirmDialog(BuildContext context, TextStyle h2) async {
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
                                GlobalColors.signUpSignInButton),
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
