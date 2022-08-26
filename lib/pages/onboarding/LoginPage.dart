import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart' as UserModel;
import 'package:fostr/pages/onboarding/ForgotPassword.dart';
import 'package:fostr/pages/onboarding/SignupPage.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with FostrTheme {
  final loginForm = GlobalKey<FormState>();
  late FirebaseAuth firebaseAuth;
  String email = "";

  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isError = false;
  String error = "";
  bool hidePassword = true;
  bool isLoading = false, isLoadingGoogle = false, isLoadingApple = false;

  bool isPhone = true;
  String countryCode = "+91";

  UserService userServices = GetIt.I<UserService>();

  @override
  void initState() {
    super.initState();
    getAuth();
  }

  void getAuth() async {
    firebaseAuth = await FirebaseAuth.instance;
    // setState(() {
    //   email = firebaseAuth.currentUser!.email ?? "";
    // });
  }

  void updateProfile(Map<String, dynamic> data) async {
    await userServices.updateUserField(data);
  }

  void handleRoute(UserModel.User? user, UserType userType) {
    if (user!.createdOn == user.lastLogin) {
      FostrRouter.goto(context, Routes.addDetails);
    } else if ((user.name.isEmpty == true || user.userName.isEmpty == true) &&
        userType == UserType.USER) {
      FostrRouter.goto(context, Routes.addDetails);
    } else {
      FostrRouter.removeUntillAndGoto(
          context, Routes.userDashboard, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final width = MediaQuery.of(context).size.width;
    TextStyle linkStyle = TextStyle(color: GlobalColors.highlightedText);
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: theme.backgroundColor,
          body: SingleChildScrollView(
            child: Form(
              key: loginForm,
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
                            "Welcome Back!",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            "Sign in to continue",
                          )
                        ],
                      ),
                    ),
                    DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            onTap: (i) {
                              idController.clear();
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
                                  )),
                              Tab(
                                icon: Icon(
                                  Icons.email,
                                  color: theme.colorScheme.secondary,
                                ),
                                child: Text(
                                  "Email",
                                  style: TextStyle(
                                      color: theme.colorScheme.secondary),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 250,
                            width: MediaQuery.of(context).size.width - 30,
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
                                              : Colors.black.withOpacity(0.03),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10)),
                                        ),
                                        height: 63.5,
                                        width: 80,
                                        child: CountryCodePicker(
                                          showFlag: false,
                                          dialogTextStyle: TextStyle(),
                                          boxDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: theme.colorScheme.tertiary
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
                                          textStyle: actionTextStyle.copyWith(
                                              fontSize: 14,
                                              color: theme
                                                  .colorScheme.inversePrimary
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
                                              });
                                            } else {
                                              setState(() {
                                                isPhone = false;
                                              });
                                            }
                                          },
                                          onEditingComplete: () {
                                            FocusScope.of(context).nextFocus();
                                          },
                                          controller: idController,
                                          style: theme.textTheme.button,
                                          validator: (value) {
                                            if (isError &&
                                                error != "Wrong password") {
                                              isError = false;
                                              return error;
                                            }
                                            if (value!.isEmpty) {
                                              return "enter your email";
                                            }
                                            if (!Validator.isEmail(value) &&
                                                !Validator.isPhone(value)) {
                                              return "invalid email or phone";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(20),
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                                fontSize: 15,
                                                color: theme.hintColor),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.transparent),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: theme
                                                      .colorScheme.tertiary),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: theme
                                                      .colorScheme.secondary),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      theme.colorScheme.error),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      theme.colorScheme.error),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                            ),
                                            hintText: "Phone number",
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                  //   TextFormField(
                                  //     obscureText: hidePassword,
                                  //     style: theme.textTheme.button,
                                  //     onEditingComplete: () {
                                  //       FocusScope.of(context).nextFocus();
                                  //     },
                                  //     validator: (value) {
                                  //       if (isError) {
                                  //         isError = false;
                                  //         return error;
                                  //       }
                                  //       if (value!.isEmpty) {
                                  //         return "Enter password";
                                  //       }
                                  //       if (passwordController.text.length < 6) {
                                  //         return "Password must be more than 6 characters";
                                  //       }

                                  //       return null;
                                  //     },
                                  //     controller: passwordController,
                                  //     decoration:
                                  //         registerInputDecoration.copyWith(
                                  //       focusedBorder: OutlineInputBorder(
                                  //         borderSide: BorderSide(
                                  //             color: theme.colorScheme.secondary),
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(10)),
                                  //       ),
                                  //       fillColor:
                                  //           theme.inputDecorationTheme.fillColor,
                                  //       hintText: 'Enter Password',
                                  //       suffixIcon: GestureDetector(
                                  //         child: hidePassword
                                  //             ? Icon(
                                  //                 Icons.visibility_off,
                                  //               )
                                  //             : Icon(
                                  //                 Icons.visibility,
                                  //               ),
                                  //         onTap: () {
                                  //           setState(() {
                                  //             hidePassword = !hidePassword;
                                  //           });
                                  //         },
                                  //       ),
                                  //     ),
                                  //   ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    onEditingComplete: () {
                                      FocusScope.of(context).nextFocus();
                                    },
                                    controller: idController,
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
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: theme.colorScheme.secondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      fillColor:
                                          theme.inputDecorationTheme.fillColor,
                                      hintText: 'Enter Email Id',
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
                                      if (passwordController.text.length < 6) {
                                        return "Password must be more than 6 characters";
                                      }

                                      return null;
                                    },
                                    controller: passwordController,
                                    decoration:
                                        registerInputDecoration.copyWith(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: theme.colorScheme.secondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      fillColor:
                                          theme.inputDecorationTheme.fillColor,
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ForgotPassword();
                                              },
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Forgot Password?",
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: isLoading
                            ? AppLoading()
                            : Container(
                                width: width * 0.7,
                                height: 50,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if (loginForm.currentState!.validate() &&
                                          !auth.isLoading) {
                                        if (Validator.isEmail(
                                            idController.text.trim())) {
                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            var user = await auth
                                                .signInWithEmailPassword(
                                              idController.text.trim(),
                                              passwordController.text.trim(),
                                              auth.userType!,
                                            );
                                            setState(() {
                                              isLoading = false;
                                            });
                                            handleRoute(user, auth.userType!);
                                          } catch (e) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            handleError(e);
                                          }
                                        } else {
                                          if (Validator.isNumber(
                                              idController.text)) {
                                            try {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              String number =
                                                  countryCode.trim() +
                                                      idController.text.trim();
                                              // var user = await auth
                                              //     .signInWithEmailPassword(
                                              //         number + "@foster.com",
                                              //         passwordController.text
                                              //             .trim(),
                                              //         auth.userType!);

                                              await auth.signInWithPhone(
                                                  context, number);

                                              setState(() {
                                                isLoading = false;
                                              });
                                              FostrRouter.goto(context,
                                                  Routes.otpVerification);
                                            } catch (e) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              handleError(e);
                                            }
                                          }
                                        }
                                      }
                                    },
                                    style: buildButtonStyle(
                                        theme.colorScheme.secondary),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: (isPhone)
                                              ? Icon(Icons.phone,
                                                  color: Colors.white)
                                              : Icon(
                                                  Icons.mail,
                                                  color: Colors.white,
                                                ),
                                        ),
                                        (isPhone)
                                            ? Text(
                                                "Sign In with Phone",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : Text("Sign In with Email",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                      ],
                                    )),
                              ),
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 20, right: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          isLoadingGoogle
                              ? Center(
                                  child: AppLoading(),
                                  // CircularProgressIndicator(color: GlobalColors.signUpSignInButton,)
                                )
                              : Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          loginForm.currentState!.reset();
                                          setState(() {
                                            isLoadingGoogle = true;
                                          });
                                          try {
                                            var user =
                                                await auth.signInWithGoogle(
                                                    auth.userType!);
                                            setState(() {
                                              isLoadingGoogle = false;
                                            });
                                            if (user != null) {
                                              setState(() {
                                                isLoadingGoogle = false;
                                              });
                                              handleRoute(user, auth.userType!);
                                            }
                                          } catch (e) {
                                            setState(() {
                                              isLoadingGoogle = false;
                                            });
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
                                              "Sign in with Google",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: GlobalColors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    isLoadingApple
                                        ? Center(
                                            child: AppLoading(
                                              height: 70,
                                              width: 70,
                                            ),
                                            // CircularProgressIndicator(color:GlobalColors.signUpSignInButton)
                                          )
                                        : Platform.isIOS
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.7,
                                                  height: 50,
                                                  child: ElevatedButton(
                                                    // onPressed: () => _signInWithApple(context),
                                                    onPressed: () async {
                                                      loginForm.currentState!
                                                          .reset();
                                                      PackageInfo packageInfo =
                                                          await PackageInfo
                                                              .fromPlatform();

                                                      String version =
                                                          packageInfo.version;
                                                      setState(() {
                                                        isLoadingApple = true;
                                                      });
                                                      try {
                                                        var user = await auth
                                                            .signInWithApple();
                                                        setState(() {
                                                          isLoadingApple =
                                                              false;
                                                        });
                                                        if (user != null) {
                                                          setState(() {
                                                            isLoadingApple =
                                                                false;
                                                          });
                                                          updateProfile({
                                                            "appVersion":
                                                                version,
                                                            "id": user.id
                                                          });
                                                          handleRoute(user,
                                                              auth.userType!);
                                                        }
                                                      } catch (e) {
                                                        setState(() {
                                                          isLoadingApple =
                                                              false;
                                                        });
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("logs")
                                                            .add({
                                                          "type": "error",
                                                          "message":
                                                              e.toString(),
                                                          "which-type": "apple",
                                                          "time": DateTime.now()
                                                              .millisecondsSinceEpoch
                                                        });
                                                        fosterDialog(
                                                            context,
                                                            "We couldn't connect with the Apple servers. Please Sign In with Google instead.",
                                                            () {});
                                                      }
                                                    },
                                                    style: buildButtonStyle(
                                                        Colors.white),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
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
                                                          "Sign in with Apple",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  GlobalColors
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    Center(
                      child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: RichText(
                            text: TextSpan(
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'New to Foster Reads?  ',
                                  style: theme.textTheme.bodyText1,
                                ),
                                TextSpan(
                                    text: 'Sign Up',
                                    style: linkStyle,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => SignupPage()));
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

  FutureOr<Null> handleError(Object error) async {
    log(error.toString());
    setState(() {
      isError = true;
      this.error = showAuthError(error.toString());
    });

    loginForm.currentState!.validate();
  }

  ButtonStyle buildButtonStyle(Color color) {
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0),
        )));
  }
}
