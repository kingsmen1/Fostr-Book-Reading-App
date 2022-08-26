import 'dart:async';
import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/bookClub/dashboard.dart';
import 'package:fostr/widgets/CheckboxFormField.dart';
import 'package:fostr/widgets/Layout.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/Buttons.dart';
import 'package:fostr/widgets/InputField.dart';
import 'package:fostr/widgets/Loader.dart';
import 'package:fostr/widgets/SigninWithGoogle.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SignupWithMobilePage extends StatefulWidget {
  const SignupWithMobilePage({Key? key}) : super(key: key);

  @override
  _SignupWithMobilePageState createState() => _SignupWithMobilePageState();
}

class _SignupWithMobilePageState extends State<SignupWithMobilePage>
    with FostrTheme {
  final signupForm = GlobalKey<FormState>();
  bool isError = false;
  bool isAgree = false;
  String countryCode = "+91";
  String error = "";

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Layout(
        child: Stack(
      children: [
        Padding(
          padding: paddingH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  "Create New Account",
                  style: h1.copyWith(
                    fontSize: 22.sp,
                  ),
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                "Please fill the form to continue",
                style: h2.copyWith(
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(
                height: 7.h,
              ),
              Form(
                key: signupForm,
                child: Column(
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(102, 163, 153, 1),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: boxShadow,
                        ),
                        child: CountryCodePicker(
                          dialogSize: Size(350, 300),
                          onChanged: (e) {
                            setState(() {
                              countryCode = e.dialCode.toString();
                            });
                          },
                          initialSelection: 'IN',
                          textStyle: actionTextStyle,
                          // showCountryOnly: true,
                          alignLeft: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    InputField(
                      keyboardType: TextInputType.phone,
                      onEditingCompleted: () {
                        FocusScope.of(context).nextFocus();
                      },
                      controller: _controller,
                      validator: (value) {
                        if (isError) {
                          isError = false;
                          return error;
                        }
                        if (value!.isEmpty) {
                          return "enter your phone";
                        }
                        if (!Validator.isPhone(value)) {
                          return "Enter Valid Mobile Number";
                        }
                        return null;
                      },
                      hintText: "Enter your phone",
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    CheckboxFormField(
                      initialValue: false,
                      validator: (value) {
                        if (value != null && !value) {
                          return "You must agree to the terms and condition";
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          isAgree = value ?? false;
                        });
                      },
                      title: Text(
                        "By registering you agree to the terms and conditions of this app.",
                        style: textFieldStyle.copyWith(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            FostrRouter.goto(context, Routes.singup);
                          },
                          child: Text(
                            "Signup With Email Instead",
                            style: TextStyle(
                              fontFamily: "Lato",
                              color: Color(0xff476747),
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    SigninWithGoogle(
                        text: "Signup With Google",
                        onTap: () async {
                          try {
                            var user =
                                await auth.signInWithGoogle(auth.userType!);
                            if (user != null &&
                                user.createdOn == user.lastLogin) {
                              FostrRouter.goto(context, Routes.addDetails);
                            } else if (user != null) {
                              final isOk = await confirmDialog(context, h2);
                              if (isOk != null && isOk) {
                                if (auth.userType == UserType.USER) {
                                  FostrRouter.removeUntillAndGoto(context,
                                      Routes.userDashboard, (route) => false);
                                } else if (auth.userType ==
                                    UserType.CLUBOWNER) {
                                  FostrRouter.removeUntillAndGoto(
                                    context,
                                    Routes.allBookClubs,
                                    (route) => false,
                                  );
                                }
                              } else {
                                auth.signOut();
                              }
                            }
                          } catch (e) {
                            print(e);
                            handleError(e);
                          }
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    PrimaryButton(
                      text: "Send OTP",
                      onTap: () async {
                        if (signupForm.currentState!.validate()) {
                          if (Validator.isPhone(_controller.text)) {
                            if (!auth.isLoading) {
                              try {
                                auth.signInWithPhone(
                                    context,
                                    countryCode.trim() +
                                        _controller.text.trim());

                                FostrRouter.goto(
                                    context, Routes.otpVerification);
                              } catch (e) {
                                handleError(e);
                              }
                            }
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Have an account?  ",
                          style: TextStyle(
                            fontFamily: "Lato",
                            color: Colors.white,
                            fontSize: 13.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            FostrRouter.pop(context);
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontFamily: "Lato",
                              color: Color(0xff476747),
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Loader(
          isLoading: auth.isLoading,
        )
      ],
    ));
  }

  FutureOr<Null> handleError(Object error) async {
    setState(() {
      isError = true;
      this.error = showAuthError(error.toString());
    });
    signupForm.currentState!.validate();
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
                constraints: BoxConstraints(maxHeight: 240),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'An account with this email already exists. Would you like to be signed in instead?',
                      style: h2.copyWith(
                        fontSize: 17.sp,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            "CANCEL",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            "SIGN IN",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.black.withOpacity(0.6),
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
