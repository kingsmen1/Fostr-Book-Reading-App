import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/Helpers.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../utils/widget_constants.dart';

class AddPhoneDetails extends StatefulWidget {
  final bool fromSettings;
  const AddPhoneDetails({Key? key, this.fromSettings = false})
      : super(key: key);

  @override
  _AddPhoneDetailsState createState() => _AddPhoneDetailsState();
}

class _AddPhoneDetailsState extends State<AddPhoneDetails> with FostrTheme {
  final UserService _userService = GetIt.I<UserService>();

  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  bool isError = false;

  String error = "";

  bool isLoading = false, isLoadingGoogle = false, isLoadingApple = false;

  String countryCode = "+91";

  bool otpSent = false;
  bool shoudlResend = false;

  TextEditingController _controller = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  static const int REMAINING_SECONDS = 30;

  Timer _timer = Timer(Duration(minutes: 5), () {});
  int _seconds = REMAINING_SECONDS;
  bool showOtpResendBtn = false;

  void startOtpCounter() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _timer.cancel();
        setState(() {
          shoudlResend = true;
          showOtpResendBtn = true;
        });
        return;
      }
      setState(() {
        _seconds = _seconds - 1;
      });
    });
  }

  void restartOtpCounter() {
    _seconds = REMAINING_SECONDS;
    startOtpCounter();
    setState(() {
      shoudlResend = false;
      showOtpResendBtn = false;
    });
  }

  void cancelOtpCounter() {
    if (_timer.runtimeType == Timer) {
      _timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    cancelOtpCounter();
    super.dispose();
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
              "Add Phone Details",
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
                          if (widget.fromSettings) {
                            Navigator.of(context).pop();
                          } else {
                            FostrRouter.goto(context, Routes.addDetails);
                          }
                        },
                        child: Text("Skip", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ]
                : null,
          ),
          backgroundColor: theme.colorScheme.primary,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: (theme.brightness == Brightness.dark)
                                ? Colors.white12
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                          ),
                          height: 63,
                          width: 80,
                          child: CountryCodePicker(
                            showFlag: false,
                            dialogTextStyle: TextStyle(),
                            boxDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: theme.colorScheme.tertiary.withOpacity(1),
                              boxShadow: null,
                            ),
                            dialogSize: Size(350, 600),
                            onChanged: (e) {
                              setState(() {
                                countryCode = e.dialCode.toString();
                                print(e.dialCode.toString());
                              });
                            },
                            initialSelection: 'IN',
                            textStyle: actionTextStyle.copyWith(
                                fontSize: 14,
                                color: theme.colorScheme.inversePrimary
                                    .withOpacity(0.8)),
                            // showCountryOnly: true,
                            alignLeft: true,
                          ),
                        ),
                        Flexible(
                          child: TextFormField(
                            onChanged: (value) {},
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
                                return "Enter your phone number";
                              }
                              if (!Validator.isPhone(value)) {
                                return "Invalid phone number";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 15, color: GlobalColors.hintText),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              hintText: "Phone number",
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  (otpSent)
                      ? Form(
                          key: _otpFormKey,
                          child: TextFormField(
                            onChanged: (value) {},
                            onEditingComplete: () {
                              FocusScope.of(context).nextFocus();
                            },
                            controller: _otpController,
                            style: h2.copyWith(
                                color: theme.colorScheme.inversePrimary),
                            validator: (value) {
                              if (isError) {
                                isError = false;
                                return error;
                              }
                              if (value!.isEmpty) {
                                return "Enter otp number";
                              }
                              if (value.length != 6) {
                                return "otp must be 6 digits";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 15, color: GlobalColors.hintText),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: "OTP number",
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (otpSent) {
                          if (_otpFormKey.currentState?.validate() ?? false) {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              final cred = await auth.onlyVerifyOtp(
                                context,
                                _otpController.text,
                              );
                              await auth.firebaseUser?.updatePhoneNumber(cred);
                              if (widget.fromSettings) {
                                Navigator.of(context).pop();
                              } else {
                                FostrRouter.goto(context, Routes.addDetails);
                              }
                            } on FirebaseAuthException catch (e) {
                              print(e.code);
                              handleError(e.code);
                            }
                            setState(() {
                              isLoading = false;
                            });
                          }
                          return;
                        }
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() {
                            otpSent = true;
                          });
                          ToastMessege("OTP sent",context: context);

                          setState(() {
                            isLoading = true;
                          });
                          await auth.signInWithPhone(
                            context,
                            countryCode + _controller.text,
                          );
                          startOtpCounter();
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      style: buildButtonStyle(theme.colorScheme.secondary),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            (!otpSent) ? "Send OTP" : "Verify OTP",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  (otpSent)
                      ? Column(
                          children: [
                            Text("Didn't get OTP?",
                                style: h2.copyWith(
                                    color: theme.colorScheme.inversePrimary)),
                            (_seconds > 0)
                                ? Text("Try again in $_seconds",
                                    style: h2.copyWith(
                                        color:
                                            theme.colorScheme.inversePrimary))
                                : SizedBox.shrink(),
                          ],
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 10,
                  ),
                  (shoudlResend)
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              try {
                                auth
                                    .signInWithPhone(
                                  context,
                                  countryCode + _controller.text,
                                )
                                    .then((value) {
                                  restartOtpCounter();
                                  ToastMessege("OTP sent",context: context);
                                });
                              } catch (e) {
                                ToastMessege("Something went wrong",context: context);
                              }
                            },
                            style:
                                buildButtonStyle(theme.colorScheme.secondary),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FutureOr<Null> handleError(Object error) async {
    setState(() {
      final err = showAuthError(error.toString());
      ToastMessege(err,context: context);
    });
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
