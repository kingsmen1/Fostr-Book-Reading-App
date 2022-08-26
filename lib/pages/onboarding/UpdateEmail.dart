import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../utils/widget_constants.dart';
import '../../widgets/ToastMessege.dart';
import 'EmailVerification.dart';

class UpdateEmailDetails extends StatefulWidget {
  final bool fromSettings;
  const UpdateEmailDetails({Key? key, this.fromSettings = false})
      : super(key: key);

  @override
  _UpdateEmailDetailsState createState() => _UpdateEmailDetailsState();
}

class _UpdateEmailDetailsState extends State<UpdateEmailDetails>
    with FostrTheme {
  final UserService _userService = GetIt.I<UserService>();

  final _formKey = GlobalKey<FormState>();
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: theme.colorScheme.primary,
            title: Text(
              "Add Email Details",
              style: TextStyle(fontSize: 18),
            ),
            centerTitle: true,
            actions: (!widget.fromSettings)
                ? [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15),
                      child: InkWell(
                        onTap: () {
                          FostrRouter.goto(context, Routes.addDetails);
                        },
                        child: Text("Skip", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ]
                : null,
          ),
          backgroundColor: theme.colorScheme.primary,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        onEditingComplete: () {
                          FocusScope.of(context).nextFocus();
                        },
                        controller: _controller,
                        style: h2.copyWith(
                            color: theme.colorScheme.inversePrimary),
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
                        decoration: registerInputDecoration.copyWith(
                            hintText: 'Enter Email Id',
                            fillColor: theme.inputDecorationTheme.fillColor),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final firebaseUser = auth.firebaseUser;
                              if (firebaseUser != null) {
                                // auth

                                try {
                                  final email = firebaseUser.email;

                                  // if (email == null) {
                                  //   await firebaseUser
                                  //       .updateEmail(_controller.text.trim());
                                  // } else if (email.split("@")[1] !=
                                  //     "foster.com") {
                                  //   await firebaseUser
                                  //       .updateEmail(_controller.text.trim());
                                  // }

                                  // update the user email

                                  await firebaseUser
                                      .updateEmail(_controller.text.trim());

                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(firebaseUser.uid)
                                      .update({
                                    "email": _controller.text.trim(),
                                  });

                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => EmailVerification(
                                        isPhoneVerified: true,
                                        fromSettings: widget.fromSettings,
                                      ),
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == "requires-recent-login") {
                                    print(e);
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Material(
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              color: Color(0xff1F1F1F),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Updating is sensitive and requires recent authentication. Log in again before retrying this reques",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  ElevatedButton(
                                                    style: buildButtonStyle(
                                                        theme.colorScheme
                                                            .secondary),
                                                    onPressed: () {
                                                      auth.signOut();
                                                    },
                                                    child: Text("Login"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                } catch (e) {
                                  ToastMessege("Something went wrong",context: context);
                                }
                              }
                            }
                          },
                          style: buildButtonStyle(theme.colorScheme.secondary),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Update Email",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
      backgroundColor: MaterialStateProperty.all<Color>(color),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0),
        ),
      ),
    );
  }
}
