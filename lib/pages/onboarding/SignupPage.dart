import 'dart:async';
import 'dart:ui';
import 'dart:io' show Platform;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/bookClub/dashboard.dart';
import 'package:fostr/pages/onboarding/EmailVerification.dart';
import 'package:fostr/pages/onboarding/LoginPage.dart';
import 'package:fostr/utils/widget_constants.dart';

import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';

import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with FostrTheme {
  final signupForm = GlobalKey<FormState>();

  bool isError = false;
  bool isAgree = false;
  String error = "";
  bool hideConfirmPassword = true;
  bool isLoading = false, isLoadingGoogle = false, isLoadingApple = false;

  bool isPhone = true;
  bool isEmail = false;
  String countryCode = "+91";

  TextEditingController _controller = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool hidePassword = true;

  Future<bool> checkIfUserExist(String number) async {
    try {
      final fnName = "isUserExist";
      final fn = FirebaseFunctions.instance.httpsCallable(fnName);

      final res = await fn.call({
        "phoneNumber": number,
      });

      return res.data["isExist"];
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final width = MediaQuery.of(context).size.width;
    TextStyle linkStyle =
        TextStyle(color: GlobalColors.highlightedText, fontSize: 16);
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: theme.backgroundColor,
          body: SingleChildScrollView(
            child: Form(
              key: signupForm,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 50, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Hello there,",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Sign up to continue",
                            style: TextStyle(),
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 20, right: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              isLoadingGoogle
                                  ? Center(
                                      child: AppLoading(
                                        height: 70,
                                        width: 70,
                                      )
                                      // CircularProgressIndicator(color:GlobalColors.signUpSignInButton)
                                      ,
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            signupForm.currentState!.reset();
                                            setState(() {
                                              isLoadingGoogle = true;
                                            });
                                            var user =
                                                await auth.signInWithGoogle(
                                                    auth.userType!);
                                            setState(() {
                                              isLoadingGoogle = false;
                                            });
                                            if (user != null &&
                                                user.createdOn ==
                                                    user.lastLogin) {
                                              setState(() {
                                                isLoadingGoogle = false;
                                              });
                                              FostrRouter.goto(
                                                  context, Routes.addDetails);
                                            } else if (user != null) {
                                              setState(() {
                                                isLoadingGoogle = false;
                                              });
                                              final isOk = await confirmDialog(
                                                  context, h2);
                                              if (isOk != null && isOk) {
                                                if (auth.userType ==
                                                    UserType.USER) {
                                                  setState(() {
                                                    isLoadingGoogle = false;
                                                  });
                                                  FostrRouter
                                                      .removeUntillAndGoto(
                                                          context,
                                                          Routes.userDashboard,
                                                          (route) => false);
                                                } else if (auth.userType ==
                                                    UserType.CLUBOWNER) {
                                                  setState(() {
                                                    isLoadingGoogle = false;
                                                  });
                                                  FostrRouter
                                                      .removeUntillAndGoto(
                                                    context,
                                                    Routes.allBookClubs,
                                                    (route) => false,
                                                  );
                                                }
                                              } else {
                                                setState(() {
                                                  isLoadingGoogle = false;
                                                });
                                                // showLoaderDialog(context);
                                                auth.signOut();
                                              }
                                            }
                                          } catch (e) {
                                            setState(() {
                                              isLoadingGoogle = false;
                                            });
                                            print(e);
                                          }
                                        },
                                        style: buildButtonStyle(Colors.white),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  child: SvgPicture.asset(
                                                      "assets/icons/google.svg")),
                                            ),
                                            Text(
                                              "Sign up with Google",
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: GlobalColors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        isLoadingApple
                            ? Center(
                                child: AppLoading(
                                  height: 70,
                                  width: 70,
                                )
                                // CircularProgressIndicator(color:GlobalColors.signUpSignInButton)
                                ,
                              )
                            : Platform.isIOS
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          signupForm.currentState!.reset();
                                          setState(() {
                                            isLoadingApple = true;
                                          });
                                          final user =
                                              await auth.signInWithApple();
                                          setState(() {
                                            isLoadingApple = false;
                                          });
                                          if (user != null &&
                                              user.createdOn ==
                                                  user.lastLogin) {
                                            setState(() {
                                              isLoadingApple = false;
                                            });
                                            FostrRouter.goto(
                                                context, Routes.addDetails);
                                          } else if (user != null) {
                                            setState(() {
                                              isLoadingApple = false;
                                            });
                                            final isOk = await confirmDialog(
                                                context, h2);
                                            if (isOk != null && isOk) {
                                              if (auth.userType ==
                                                  UserType.USER) {
                                                setState(() {
                                                  isLoadingApple = false;
                                                });
                                                print("object");
                                                FostrRouter.removeUntillAndGoto(
                                                    context,
                                                    Routes.userDashboard,
                                                    (route) => false);
                                              } else if (auth.userType ==
                                                  UserType.CLUBOWNER) {
                                                setState(() {
                                                  isLoadingApple = false;
                                                });
                                                FostrRouter.removeUntillAndGoto(
                                                  context,
                                                  Routes.allBookClubs,
                                                  (route) => false,
                                                );
                                              }
                                            } else {
                                              setState(() {
                                                isLoadingApple = false;
                                              });
                                              // showLoaderDialog(context);
                                              auth.signOut();
                                            }
                                          }
                                        } catch (e) {
                                          setState(() {
                                            isLoadingApple = false;
                                          });
                                          fosterDialog(
                                              context,
                                              "We couldn't connect with the Apple servers. Please Sign Up using Google.",
                                              () {});
                                        }
                                      },
                                      // => _signInWithApple(context),

                                      style: buildButtonStyle(Colors.white),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              child: Image.asset(
                                                'assets/images/1200px-Apple_logo_white.png',
                                                height: 40,
                                                width: 40,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Sign up with Apple",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: GlobalColors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(children: <Widget>[
                            Expanded(
                              child: new Container(
                                  margin: const EdgeInsets.only(
                                      left: 10.0, right: 20.0),
                                  child: Divider(
                                    color: Colors.grey,
                                    height: 36,
                                  )),
                            ),
                            Text(
                              "OR",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Expanded(
                              child: new Container(
                                  margin: const EdgeInsets.only(
                                      left: 20.0, right: 10.0),
                                  child: Divider(
                                    color: Colors.grey,
                                    height: 36,
                                  )),
                            ),
                          ]),
                        ),
                        DefaultTabController(
                          animationDuration: Duration(milliseconds: 600),
                          length: 2,
                          child: Column(
                            children: [
                              TabBar(
                                onTap: (i) {
                                  _controller.clear();
                                  if (i == 1) {
                                    setState(() {
                                      isPhone = false;
                                    });
                                  } else {
                                    setState(() {
                                      isPhone = true;
                                    });
                                  }
                                },
                                indicatorColor: theme.colorScheme.secondary,
                                tabs: [
                                  Tab(
                                    icon: Icon(
                                      Icons.phone,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    child: Text(
                                      "Phone",
                                      style: TextStyle(
                                          color: theme.colorScheme.secondary),
                                    ),
                                  ),
                                  Tab(
                                      icon: Icon(
                                        Icons.email,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      child: Text(
                                        "Email",
                                        style: TextStyle(
                                          color: theme.colorScheme.secondary,
                                        ),
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                width: MediaQuery.of(context).size.width - 30,
                                height: (isPhone) ? 230 : 300,
                                child: TabBarView(children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: (theme.brightness ==
                                                      Brightness.dark)
                                                  ? Colors.white12
                                                  : Colors.black
                                                      .withOpacity(0.05),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                            ),
                                            height: 63.5,
                                            width: 80,
                                            child: CountryCodePicker(
                                              showFlag: false,
                                              dialogTextStyle: TextStyle(),
                                              boxDecoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: theme
                                                    .colorScheme.tertiary
                                                    .withOpacity(1),
                                                boxShadow: null,
                                              ),
                                              dialogSize: Size(350, 600),
                                              onChanged: (e) {
                                                setState(() {
                                                  countryCode =
                                                      e.dialCode.toString();
                                                  print(e.dialCode.toString());
                                                });
                                              },
                                              initialSelection: 'IN',
                                              textStyle:
                                                  actionTextStyle.copyWith(
                                                      fontSize: 14,
                                                      color: theme.colorScheme
                                                          .inversePrimary
                                                          .withOpacity(0.8)),
                                              // showCountryOnly: true,
                                              alignLeft: true,
                                            ),
                                          ),
                                          Flexible(
                                            child: TextFormField(
                                              onChanged: (value) {
                                                if (Validator.isPhone(value)) {
                                                  setState(() {
                                                    isPhone = true;
                                                    isEmail = false;
                                                  });
                                                }
                                              },
                                              onEditingComplete: () {
                                                FocusScope.of(context)
                                                    .nextFocus();
                                              },
                                              controller: _controller,
                                              style: theme.textTheme.button,
                                              validator: (value) {
                                                if (isError) {
                                                  isError = false;
                                                  return error;
                                                }
                                                if (value!.isEmpty) {
                                                  return "Enter your phone number";
                                                }
                                                if (!Validator.isPhone(value)) {
                                                  return "Invalid phone number";
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(20),
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                    fontSize: 15,
                                                    color: theme.hintColor),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.transparent),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                disabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: theme.colorScheme
                                                          .tertiary),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: theme.colorScheme
                                                          .secondary),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: theme
                                                          .colorScheme.error),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: theme
                                                          .colorScheme.error),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                hintText: "Phone number",
                                                filled: true,
                                                fillColor: theme
                                                    .inputDecorationTheme
                                                    .fillColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextFormField(
                                        onEditingComplete: () {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        controller: _controller,
                                        style: theme.textTheme.button,
                                        validator: (value) {
                                          if (isError) {
                                            isError = false;
                                            return error;
                                          }
                                          if (value!.isEmpty) {
                                            return "Enter your email";
                                          }
                                          if (!Validator.isEmail(value)) {
                                            return "Invalid Email";
                                          }
                                          return null;
                                        },
                                        decoration:
                                            registerInputDecoration.copyWith(
                                          hintText: 'Enter Email Id',
                                          fillColor: theme
                                              .inputDecorationTheme.fillColor,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: theme
                                                    .colorScheme.secondary),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextFormField(
                                        obscureText: hidePassword,
                                        style: theme.textTheme.button,
                                        onEditingComplete: () {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        validator: (value) {
                                          if (isError) {
                                            isError = false;
                                            return error;
                                          }
                                          if (value!.isEmpty) {
                                            return "Enter password";
                                          }
                                          if (_passwordController.text.length <
                                              6) {
                                            return "Password must be more than 6 characters";
                                          }

                                          return null;
                                        },
                                        controller: _passwordController,
                                        decoration:
                                            registerInputDecoration.copyWith(
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: theme
                                                    .colorScheme.secondary),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                          fillColor: theme
                                              .inputDecorationTheme.fillColor,
                                          hintText: 'Enter Password',
                                          suffixIcon: GestureDetector(
                                            child: hidePassword
                                                ? Icon(
                                                    Icons.visibility_off,
                                                  )
                                                : Icon(
                                                    Icons.visibility,
                                                  ),
                                            onTap: () {
                                              setState(() {
                                                hidePassword = !hidePassword;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: hideConfirmPassword,
                                        style: theme.textTheme.button,
                                        validator: (value) {
                                          if (isError) {
                                            isError = false;
                                            return error;
                                          }
                                          if (value!.isEmpty) {
                                            return "Enter password";
                                          }
                                          if (_passwordController.text !=
                                              _confirmPasswordController.text) {
                                            return "Password do not match";
                                          }
                                          return null;
                                        },
                                        decoration:
                                            registerInputDecoration.copyWith(
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: theme
                                                    .colorScheme.secondary),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                          fillColor: theme
                                              .inputDecorationTheme.fillColor,
                                          hintText: 'Confirm password',
                                          suffixIcon: GestureDetector(
                                            child: hideConfirmPassword
                                                ? Icon(
                                                    Icons.visibility_off,
                                                  )
                                                : Icon(
                                                    Icons.visibility,
                                                  ),
                                            onTap: () {
                                              setState(() {
                                                hideConfirmPassword =
                                                    !hideConfirmPassword;
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.only(top: (isPhone) ? 00.0 : 20.0),
                        child: isLoading
                            ? AppLoading(
                                height: 70,
                                width: 70,
                              )
                            : Container(
                                width: width * 0.7,
                                height: 50,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if (signupForm.currentState!.validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        if (!isPhone) {
                                          if (Validator.isEmail(
                                              _controller.text)) {
                                            try {
                                              await auth
                                                  .signupWithEmailPassword(
                                                      _controller.text.trim(),
                                                      _passwordController.text
                                                          .trim(),
                                                      UserType.USER);
                                              signupForm.currentState!.reset();
                                              setState(() {
                                                isLoading = false;
                                              });
                                              Navigator.of(context).push(
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      EmailVerification(
                                                    isPhoneVerified: false,
                                                  ),
                                                ),
                                              );
                                              // FostrRouter.goto(
                                              //     context, Routes.addDetails);
                                            } catch (error) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              handleError(error);
                                            }
                                          }
                                        } else {
                                          if (Validator.isNumber(
                                              _controller.text)) {
                                            try {
                                              String number =
                                                  countryCode.trim() +
                                                      _controller.text.trim();

                                              if (await checkIfUserExist(
                                                  number)) {
                                                handleError(
                                                    "phone-already-in-use");
                                              } else {
                                                await auth.signInWithPhone(
                                                    context, number);
                                                FostrRouter.goto(context,
                                                    Routes.otpVerification);
                                              }
                                            } catch (e) {
                                              handleError(e);
                                            }
                                          }
                                        }
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                                    style: buildButtonStyle(
                                      theme.colorScheme.secondary,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: (isPhone)
                                              ? Icon(
                                                  Icons.phone,
                                                  color: Colors.white,
                                                )
                                              : Icon(
                                                  Icons.mail,
                                                  color: Colors.white,
                                                ),
                                        ),
                                        (isPhone)
                                            ? Text(
                                                "Sign up with Phone",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : Text(
                                                "Sign up with Email",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                      ],
                                    )),
                              ),
                      ),
                    ),
                    Center(
                      child: Padding(
                          padding: const EdgeInsets.only(top: 50.0, bottom: 60),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Already a User? ',
                                    style: theme.textTheme.bodyText1),
                                TextSpan(
                                    text: 'Sign In',
                                    style: linkStyle,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()),
                                        );
                                      }),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle buildButtonStyle(Color color) {
    return ButtonStyle(
        shadowColor: MaterialStateProperty.all<Color>(Colors.black),
        backgroundColor: MaterialStateProperty.all<Color>(color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        )));
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
                  color: theme.colorScheme.primary,
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
                        color: theme.colorScheme.inversePrimary,
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
                                theme.colorScheme.secondary),
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

//  Padding(
//                           padding: const EdgeInsets.only(
//                               left: 20, right: 20, top: 20),
//                           child: Container(
                            // child: TextFormField(
                            //   style: h2,
                            //   validator: (val) => val!.isEmpty
                            //       ? 'Please enter full name'
                            //       : null,
                            //   decoration: registerInputDecoration.copyWith(
                            //       hintText: 'Enter Full name',
                            //       fillColor: Colors.white12),
                            // ),
//                           ),
//                         ),

// Padding(
//                           padding: const EdgeInsets.only(
//                               left: 20, right: 20, top: 20),
//                           child: Container(
                          //   child: TextFormField(
                          //     onChanged: (value) {
                          //       if (Validator.isPhone(value)) {
                          //         setState(() {
                          //           isPhone = true;
                          //         });
                          //       } else {
                          //         setState(() {
                          //           isPhone = false;
                          //         });
                          //       }
                          //     },
                          //     onEditingComplete: () {
                          //       FocusScope.of(context).nextFocus();
                          //     },
                          //     controller: _controller,
                          //     style: h2,
                          //     validator: (value) {
                          //       if (isError) {
                          //         isError = false;
                          //         return error;
                          //       }
                          //       if (value!.isEmpty) {
                          //         return "Enter your email or phone number";
                          //       }
                          //       if (!Validator.isEmail(value) &&
                          //           !Validator.isPhone(value)) {
                          //         return "Invalid Credentials";
                          //       }
                          //       return null;
                          //     },
                          //     decoration: registerInputDecoration.copyWith(
                          //         hintText: 'Enter Email Id or Phone Number',
                          //         fillColor: Colors.white12),
                          //   ),
                          // ),
//                         ),

//  (!isPhone)
                            // ? Column(
                            //     children: [
                            //       Padding(
                            //         padding: const EdgeInsets.only(
                            //             left: 20, right: 20, top: 15),
                            //         child: Container(
                            //           child: TextFormField(
                            //             obscureText: hidePassword,
                            //             style: h2,
                            //             onEditingComplete: () {
                            //               FocusScope.of(context).nextFocus();
                            //             },
                            //             validator: (value) {
                            //               if (isError) {
                            //                 isError = false;
                            //                 return error;
                            //               }
                            //               if (value!.isEmpty) {
                            //                 return "Enter password";
                            //               }
                            //               if (_passwordController.text.length <
                            //                   6) {
                            //                 return "Password must be more than 6 characters";
                            //               }

                            //               return null;
                            //             },
                            //             controller: _passwordController,
                            //             decoration:
                            //                 registerInputDecoration.copyWith(
                            //               hintText: 'Enter Password',
                            //               fillColor: Colors.white12,
                            //               suffixIcon: GestureDetector(
                            //                 child: hidePassword
                            //                     ? Icon(Icons.visibility_off,
                            //                         color: Colors.white24)
                            //                     : Icon(
                            //                         Icons.visibility,
                            //                         color: Colors.grey,
                            //                       ),
                            //                 onTap: () {
                            //                   setState(() {
                            //                     hidePassword = !hidePassword;
                            //                   });
                            //                 },
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //       Padding(
                            //         padding: const EdgeInsets.only(
                            //             left: 20, right: 20, top: 15),
                            //         child: Container(
                            //           child: TextFormField(
                            //             controller: _confirmPasswordController,
                            //             obscureText: hideConfirmPassword,
                            //             style: h2,
                            //             validator: (value) {
                            //               if (isError) {
                            //                 isError = false;
                            //                 return error;
                            //               }
                            //               if (value!.isEmpty) {
                            //                 return "Enter password";
                            //               }
                            //               if (_passwordController.text !=
                            //                   _confirmPasswordController.text) {
                            //                 return "Password do not match";
                            //               }
                            //               return null;
                            //             },
                            //             decoration:
                            //                 registerInputDecoration.copyWith(
                            //               hintText: 'Confirm password',
                            //               fillColor: Colors.white12,
                            //               suffixIcon: GestureDetector(
                            //                 child: hideConfirmPassword
                            //                     ? Icon(Icons.visibility_off,
                            //                         color: Colors.white24)
                            //                     : Icon(
                            //                         Icons.visibility,
                            //                         color: Colors.grey,
                            //                       ),
                            //                 onTap: () {
                            //                   setState(() {
                            //                     hideConfirmPassword =
                            //                         !hideConfirmPassword;
                            //                   });
                            //                 },
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   )
//                             : Container(
//                                 margin: const EdgeInsets.only(
//                                     left: 20, right: 20, top: 15),
//                                 height: 60,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white12,
//                                   borderRadius: BorderRadius.circular(10),
//                                   boxShadow: boxShadow,
//                                 ),
                              //   child: CountryCodePicker(
                              //     dialogTextStyle:
                              //         TextStyle(color: Colors.white),
                              //     boxDecoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(10),
                              //       color: Color(0xff383838),
                              //       boxShadow: null,
                              //     ),
                              //     dialogSize: Size(350, 600),
                              //     onChanged: (e) {
                              //       setState(() {
                              //         countryCode = e.dialCode.toString();
                              //         print(e.dialCode.toString());
                              //       });
                              //     },
                              //     initialSelection: 'IN',
                              //     textStyle: actionTextStyle,
                              //     // showCountryOnly: true,
                              //     alignLeft: true,
                              //   ),
                              // ),
