import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/bookClub/dashboard.dart';
import 'package:fostr/pages/onboarding/SplashScreen.dart';
import 'package:fostr/pages/onboarding/UnderMaintenance.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with FostrTheme {
 
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoading) {
      if (auth.user != null) {
        if (auth.userType == UserType.CLUBOWNER) {
          return UserBookClubDashboard();
        } else if (auth.userType == UserType.USER) {
          return //UnderMaintenance();
            UserDashboard(tab: "all",selectDay: DateTime.now(),);
        } else {
          return SplashScreen();
        }
      } else {
        return SplashScreen();
      }
    }
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
        child: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 80.w,
              child: Image.asset(
                IMAGES + "Foster_logo.png",
                fit: BoxFit.fitWidth,
              )
          ),
          AppLoading(height: 100,width: 100,),
          // CircularProgressIndicator(
          //   backgroundColor: Colors.black,
          //   valueColor: AlwaysStoppedAnimation<Color>(gradientTop),
          // ),
        ],
      ),
    ));
  }
}
