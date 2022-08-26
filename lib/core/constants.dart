// assets
import 'package:flutter/material.dart';
import 'package:fostr/utils/widget_constants.dart';

const String IMAGES = "assets/images/";
const String ICONS = "assets/icons/";

//color
const Color dark_blue = Color(0xFF264465);

// enums
enum UserType { USER, CLUBOWNER }
enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }
enum NotificationType {
  Follow,
  Event,
  Invite,
  Bookmarked,
  Comment,
  Review,
  Rating,
  BookclubInvitationRequest,
  BookclubInvitationAccepted,
}
enum NotificationTopic {
  otherNotification,
  roomNotification,
  bookNotification,
  messageNotification,
  trendNotification,
  inAppNotification
}

// localStorage keys
const FIRST_OPEN = 'fostr-firstOpen';
const LOGGED_IN = 'fostr-loggedin';
const USER_TYPE = "fostr-userType";
const FEEDS_CACHE = "fostr-feedsCache";

// agora_rtc
const AGORA_APP_ID = '58ee1103fa5b4a9e98e02bacc19aa826';

const registerInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.all(20),
  border: InputBorder.none,
  hintStyle: TextStyle(fontSize: 15, color: GlobalColors.hintText),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(9)),
  ),
  filled: true,
  fillColor: GlobalColors.formBackground,
);
