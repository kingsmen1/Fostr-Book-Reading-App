import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/onboarding/AddDetails.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/Loader.dart';
import 'package:provider/provider.dart';

import '../../utils/widget_constants.dart';
import '../../widgets/ToastMessege.dart';

class AddPasswordDetails extends StatefulWidget {
  const AddPasswordDetails({Key? key}) : super(key: key);

  @override
  _AddPasswordDetailsState createState() => _AddPasswordDetailsState();
}

class _AddPasswordDetailsState extends State<AddPasswordDetails>
    with FostrTheme {
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
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
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
              "Add Password",
              style: TextStyle(fontSize: 18),
            ),
            centerTitle: true,
            actions: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //       horizontal: 20.0, vertical: 15),
              //   child: InkWell(
              //     onTap: () {
              //       FostrRouter.goto(context, Routes.addDetails);
              //     },
              //     child: Text("Skip",
              //         style: TextStyle(color: Colors.white, fontSize: 18)),
              //   ),
              // ),
            ],
          ),
          backgroundColor: theme.colorScheme.primary,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        // TextFormField(
                        //   onEditingComplete: () {
                        //     FocusScope.of(context).nextFocus();
                        //   },
                        //   controller: _controller,
                        //   style: h2,
                        //   validator: (value) {
                        //     if (isError) {
                        //       isError = false;
                        //       return error;
                        //     }
                        //     if (value!.isEmpty) {
                        //       return "Enter your email";
                        //     }
                        //     if (!Validator.isEmail(value)) {
                        //       return "Invalid Email";
                        //     }
                        //     return null;
                        //   },
                        //   decoration: registerInputDecoration.copyWith(
                        //       hintText: 'Enter Email Id',
                        //       fillColor: Colors.white12),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        TextFormField(
                          obscureText: hidePassword,
                          style: h2.copyWith(
                              color: theme.colorScheme.inversePrimary),
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
                            if (_passwordController.text.length < 6) {
                              return "Password must be more than 6 characters";
                            }

                            return null;
                          },
                          controller: _passwordController,
                          decoration: registerInputDecoration.copyWith(
                            hintText: 'Enter Password',
                            fillColor: theme.inputDecorationTheme.fillColor,
                            suffixIcon: GestureDetector(
                              child: hidePassword
                                  ? Icon(Icons.visibility_off,
                                      color: Colors.white24)
                                  : Icon(
                                      Icons.visibility,
                                      color: Colors.grey,
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
                          height: 20,
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: hideConfirmPassword,
                          style: h2.copyWith(
                              color: theme.colorScheme.inversePrimary),
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
                          decoration: registerInputDecoration.copyWith(
                            hintText: 'Confirm password',
                            fillColor: theme.inputDecorationTheme.fillColor,
                            suffixIcon: GestureDetector(
                              child: hideConfirmPassword
                                  ? Icon(Icons.visibility_off,
                                      color: Colors.white24)
                                  : Icon(
                                      Icons.visibility,
                                      color: Colors.grey,
                                    ),
                              onTap: () {
                                setState(() {
                                  hideConfirmPassword = !hideConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (true) {
                                if (_passwordController.text.trim() !=
                                    _confirmPasswordController.text.trim()) {
                                  setState(() {
                                    isError = true;
                                    error = "Password do not match";
                                  });
                                  return;
                                }
                                final firebaseUser = auth.firebaseUser;
                                if (firebaseUser != null) {
                                  // auth
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try {
                                    await firebaseUser.updateEmail(
                                        firebaseUser.phoneNumber! +
                                            "@foster.com");

                                    await firebaseUser.updatePassword(
                                        _passwordController.text.trim());
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => AddDetails(),
                                      ),
                                    );
                                  } catch (e) {
                                    ToastMessege("Something went wrong",context: context);
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                            style: buildButtonStyle(theme.colorScheme.secondary),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Add Password Information",
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
              Loader(isLoading: isLoading),
            ],
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
