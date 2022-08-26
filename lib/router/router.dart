import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/pages/bookClub/dashboard.dart';
import 'package:fostr/pages/onboarding/AddDetails.dart';
import 'package:fostr/pages/onboarding/LoginPage.dart';
import 'package:fostr/pages/onboarding/LoginWithMobilePage.dart';
import 'package:fostr/pages/onboarding/Onboardingpage.dart';
import 'package:fostr/pages/onboarding/OtpVerification.dart';
import 'package:fostr/pages/onboarding/SignUpWithMobilePage.dart';
import 'package:fostr/pages/onboarding/SignupPage.dart';
import 'package:fostr/pages/onboarding/SplashScreen.dart';
import 'package:fostr/pages/onboarding/UserChoice.dart';
import 'package:fostr/pages/promoCodes/promoCode.dart';
import 'package:fostr/pages/promoCodes/scan.dart';
import 'package:fostr/pages/onboarding/first_page.dart';
import 'package:fostr/pages/rooms/ClubRoomDetails.dart';
import 'package:fostr/pages/rooms/RoomDetails.dart';
import 'package:fostr/pages/user/AllBookClubs.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/pages/user/SearchBook.dart';
import 'package:fostr/pages/user/SearchPage.dart';
import 'package:fostr/pages/user/SelectProfileGenre.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/screen/NotificationSettings.dart';
import 'package:fostr/screen/ProfileSettings.dart';

class FostrRouter {
  static goto(BuildContext context, String route) =>
      Navigator.pushNamed(context, route);
  static gotoWithArg(BuildContext context, Widget page) => Navigator.of(context)
      .push(CupertinoPageRoute(builder: (context) => page));

  static replaceGoto(BuildContext context, String route) =>
      Navigator.pushReplacementNamed(context, route);

  static removeUntillAndGoto(BuildContext context, String route,
          bool Function(Route<dynamic> route) predicate) =>
      Navigator.pushNamedAndRemoveUntil(context, route, predicate);

  static pop(BuildContext context) => Navigator.pop(context);

  static Route<dynamic> generateRoute(
    BuildContext context,
    RouteSettings settings,
  ) =>
      CupertinoPageRoute(
        settings: settings,
        builder: (context) => _generateView(settings),
      );

  static Widget _generateView(RouteSettings settings) {
    switch (settings.name) {

      case Routes.notificationSetting:
        return NotificationSetting();

      case Routes.addGenre:
        return SelectProfileGenre();

      case Routes.searchBook:
        return SearchBook();

      case Routes.firstSpalshScreen:
        return FirstScreen();

      case Routes.settings:
        return ProfileSettings();

      case Routes.userProfile:
        return UserProfilePage();

      case Routes.entry:
        return OnboardingPage();

      case Routes.splash:
        return SplashScreen();

      case Routes.userChoice:
        return UserChoice();

      case Routes.singup:
        return SignupPage();

      case Routes.login:
        return LoginPage();

      case Routes.loginWithMobile:
        return LoginWithMobilePage();

      case Routes.signupWithMobile:
        return SignupWithMobilePage();

      case Routes.otpVerification:
        return OtpVerification();

      case Routes.addDetails:
        return AddDetails();

      case Routes.ongoingRoom:
        return OngoingRoom(tab: "all",);

      case Routes.userDashboard:
        return UserDashboard(tab: "all",selectDay: DateTime.now());

      case Routes.dashboard:
        return UserBookClubDashboard();
      case Routes.roomDetails:
        return RoomDetails();

      // case Routes.clubRoomDetails:
      //   return ClubRoomDetails();

      case Routes.settings:
        return ProfileSettings();

      // case Routes.notifications:
      //   return Notifications();

      case Routes.search:
        return SearchPage();

      case Routes.promocodes:
        return PromoCodes();

      case Routes.scanQR:
        return ScanQR();

      case Routes.allBookClubs:
        return AllBookClubs();

      default:
        return Material(
          child: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        );
    }
  }
}
