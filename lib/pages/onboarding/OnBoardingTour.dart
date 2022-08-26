import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:fostr/pages/onboarding/SignupPage.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class OnBoardingTour extends StatefulWidget {
  const OnBoardingTour({Key? key}) : super(key: key);

  @override
  _OnBoardingTourState createState() => _OnBoardingTourState();
}

class _OnBoardingTourState extends State<OnBoardingTour> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: OnBoardingSlider(
            pageBodies: [
              Container(
                child: Image.asset(
                  "assets/images/hallwaynew.png",
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                child: Image.asset("assets/images/createnew.png"),
              ),
              Container(
                child: Image.asset("assets/images/searchnew.png"),
              ),
              Container(
                child: Image.asset("assets/images/calendernew.png"),
              ),
              Container(
                child: Image.asset("assets/images/profilenew.png"),
              ),
            ],
            background: [
              Container(
                color: Colors.black,
              ),
              Container(
                color: Colors.black,
              ),
              Container(
                color: Colors.black,
              ),
              Container(
                color: Colors.black,
              ),
              Container(
                color: Colors.black,
              ),
            ],
            headerBackgroundColor: Colors.black,
            speed: 1.8,
            totalPage: 5,
            pageBackgroundColor: Colors.black,
            finishButtonText: "Sign up",
            hasSkip: true,
            onFinish: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignupPage()));
            },
            skipTextButton: Text(
              "Skip",
              style: TextStyle(color: Colors.white),
            ),
            // doneText: Text(
            //   "Sign Up",
            //   style: TextStyle(fontSize: 20),
            // ),
            // onTapDoneButton: () {
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => SignupPage()));
            // },
            // onTapSkipButton: () {
            //   Navigator.pushReplacement(context,
            //       MaterialPageRoute(builder: (context) => SignupPage()));
            // },
          ),
        ),
      ),
    );
  }
}
