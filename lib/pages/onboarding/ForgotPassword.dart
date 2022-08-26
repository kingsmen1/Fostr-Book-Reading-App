import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/constants.dart';
import 'package:fostr/utils/Helpers.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> with FostrTheme {
  TextEditingController idController = TextEditingController();
  final forgotPasswordForm = GlobalKey<FormState>();
  bool isError = false;
  String error = "";
  bool isLoading = false;

  bool isResetEmailSent = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Forgot Password", style: TextStyle(fontSize: 18)),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 30,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Form(
              key: forgotPasswordForm,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
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
                    decoration: registerInputDecoration.copyWith(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: theme.colorScheme.secondary),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      fillColor: theme.inputDecorationTheme.fillColor,
                      hintText: 'Enter Email Id',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  (isResetEmailSent)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "We have sent you an email containing a link to reset your password.",
                            textAlign: TextAlign.center,
                            style: h2.copyWith(
                                fontSize: 11.sp,
                                color: theme.colorScheme.inversePrimary),
                          ),
                        )
                      : SizedBox.shrink(),
                  Spacer(),
                  (isResetEmailSent)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                              width: width * 0.7,
                              height: 50,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: buildButtonStyle(
                                      theme.colorScheme.secondary),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Go Back",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  )),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
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
                                    if (forgotPasswordForm.currentState!
                                            .validate() &&
                                        !auth.isLoading) {
                                      try {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        await auth.sendPasswordRestLink(
                                            idController.text.trim());
                                        setState(() {
                                          isLoading = false;
                                          isResetEmailSent = true;
                                        });
                                      } catch (e) {
                                        handleError(e);
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                                  style: buildButtonStyle(
                                      theme.colorScheme.secondary),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          (isResetEmailSent)
                                              ? "Send Again?"
                                              : "Send Password Reset Link",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  )),
                            ),
                    ),
                  ),
                ],
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

    forgotPasswordForm.currentState!.validate();
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
