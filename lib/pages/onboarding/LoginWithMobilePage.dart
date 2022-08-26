import 'dart:async';
import 'dart:developer';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/bookClub/dashboard.dart';
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

class LoginWithMobilePage extends StatefulWidget {
  const LoginWithMobilePage({Key? key}) : super(key: key);

  @override
  _LoginWithMobilePageState createState() => _LoginWithMobilePageState();
}

class _LoginWithMobilePageState extends State<LoginWithMobilePage>
    with FostrTheme {
  final loginForm = GlobalKey<FormState>();

  TextEditingController idController = TextEditingController();
  bool isError = false;
  String error = "";
  String countryCode = "+91";

  void handleRoute(User? user, UserType userType) {
    if ((user!.name.isEmpty || user.userName.isEmpty) &&
        userType == UserType.USER) {
      FostrRouter.goto(context, Routes.addDetails);
    } else if (user.bookClubName != null &&
        (user.bookClubName!.isEmpty || user.userName.isEmpty) &&
        userType == UserType.CLUBOWNER) {
      FostrRouter.goto(context, Routes.addDetails);
    } else {
      if (userType == UserType.USER) {
        FostrRouter.removeUntillAndGoto(
            context, Routes.userDashboard, (route) => false);
      } else if (userType == UserType.CLUBOWNER) {
        FostrRouter.removeUntillAndGoto(
          context,
          Routes.allBookClubs,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Layout(
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
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
                      "Welcome Back!",
                      style: h1.copyWith(
                        fontSize: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    "Please Login into your account ",
                    style: h2.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(
                    height: 9.h,
                  ),
                  Form(
                    key: loginForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your mobile number";
                            }
                            if (!Validator.isPhone(value)) {
                              return "Enter Valid Mobile Number";
                            }
                            return null;
                          },
                          controller: idController,
                          hintText: "Enter your mobile number",
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                FostrRouter.goto(context, Routes.login);
                              },
                              child: Text(
                                "Login With Email Instead",
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
                          text: "Login With Google",
                          onTap: () async {
                            try {
                              var user =
                                  await auth.signInWithGoogle(auth.userType!);
                              if (user != null) {
                                handleRoute(user, auth.userType!);
                              }
                            } catch (e) {
                              handleError(e);
                            }
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        PrimaryButton(
                          text: "Send OTP",
                          onTap: () async {
                            if (loginForm.currentState!.validate() &&
                                !auth.isLoading) {
                              if (Validator.isPhone(idController.text.trim()) &&
                                  !auth.isLoading) {
                                try {
                                  await auth.signInWithPhone(
                                      context,
                                      countryCode.trim() +
                                          idController.text.trim());

                                  FostrRouter.goto(
                                      context, Routes.otpVerification);
                                } catch (e) {
                                  handleError(e);
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
                              "Don't have an account?  ",
                              style: TextStyle(
                                fontFamily: "Lato",
                                color: Colors.white,
                                fontSize: 13.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                FostrRouter.goto(context, Routes.singup);
                              },
                              child: Text(
                                "Sign Up",
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
          ),
          Loader(
            isLoading: auth.isLoading,
          )
        ],
      ),
    );
  }

  FutureOr<Null> handleError(Object error) async {
    log(error.toString());
    setState(() {
      isError = true;
      this.error = showAuthError(error.toString());
    });
    loginForm.currentState!.validate();
  }
}
