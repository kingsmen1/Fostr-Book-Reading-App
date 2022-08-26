import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/services/AuthService.dart';
import 'package:fostr/services/LocalStorage.dart';
import 'package:fostr/services/NotificationService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../services/apple_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalStorage _localStorage = LocalStorage();
  final UserService _userService = UserService();
  User? _user;
  BookClubModel? _bookClub = BookClubModel.empty();
  Status _status = Status.Uninitialized;
  UserType? _userType;
  String? _email;
  bool _isLoading = true;
  List<String> _bookClubIds = ["1"];

  AuthProvider.init() {
    initAuth();
  }

  User? get user => _user;
  BookClubModel? get bookClub => _bookClub;
  Status get status => _status;
  bool get isLoading => _isLoading;
  bool get firstOpen => _localStorage.firstOpen;
  bool get logedIn => _localStorage.loggedIn;
  UserType? get userType => _userType;
  auth.User? get firebaseUser => _authService.currentUser;
  String? get email => _email;
  Stream<auth.User?> get authStateStream => _authService.authStateStream;
  List<String> get subscribedBookClubs => _bookClubIds;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setUserType(UserType userType) {
    _userType = userType;
    if (userType == UserType.CLUBOWNER) {
      _localStorage.setClub();
    } else {
      _localStorage.setUser();
    }
    notifyListeners();
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      updateSubscribedBookClubs() {
    final subs = FirebaseFirestore.instance
        .collection("subscribedBookClubs")
        .doc(_user!.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _bookClubIds = List<String>.from(snapshot.data()?["subscribedBookClubs"]);
        if(_bookClubIds.isEmpty){
          _bookClubIds = ["1"];
        }
        notifyListeners();
      }
    });
    return subs;
  }

  Future<void> initAuth() async {
    await _localStorage.readPrefs();
    if (_localStorage.isClub) {
      _userType = UserType.CLUBOWNER;
    } else {
      _userType = UserType.USER;
    }
    if (!logedIn) {
      _status = Status.Unauthenticated;
    } else if (_authService.currentUser != null) {
      _user = await _userService.getUserById(_authService.currentUser!.uid);
      _subscribeToAllNotification();
      _status = Status.Authenticated;
    }
    _setFree();
  }

  Future<void> _subscribeToAllNotification() async {
    if (_user?.notificationsSettings == null) {
      final newUser = NotificationService.subscribeToAll(_user!);
      _userService.updateUser(newUser);
      refreshUser(newUser);
    }
  }

  Future<void> signInWithPhone(BuildContext context, String number) async {
    try {
      // _setBusy();
      await _authService.verifyPhone(context, number);
      // _setFree();
    } catch (e) {
      // _setFree();
      print("from auth provider");
      print(e);
      throw e;
    }
  }

  Future<User?> verifyOtp(
      BuildContext context, String otp, UserType userType) async {
    try {
      // _setBusy();
      _user = await _authService.verifyOTP(context, otp, userType);
      _localStorage.setLoggedIn();
      _subscribeToAllNotification();
      // _setFree();
      return _user;
    } catch (e) {
      // _setFree();
      throw e;
    }
  }

  Future<auth.PhoneAuthCredential> onlyVerifyOtp(
      BuildContext context, String otp) async {
    try {
      return await _authService.onlyVerifyOTP(context, otp);
    } catch (e) {
      throw e;
    }
  }

  Future<User?> signInWithEmailPassword(
      String email, String password, UserType userType) async {
    try {
      _setBusy();
      _user =
          await _authService.signInWithEmailPassword(email, password, userType);
      _localStorage.setLoggedIn();
      _subscribeToAllNotification();
      _setFree();
      return _user;
    } catch (e) {
      _setFree();
      print("from auth provider");
      print(e);
      throw e;
    }
  }

  Future<void> sendPasswordRestLink(String email) async {
    try {
      await _authService.sendPasswordResetLink(email);
    } catch (e) {
      throw e;
    }
  }

  Future<User?> signInWithGoogle(UserType userType) async {
    try {
      // _setBusy();
      _user = await _authService.signInWithGoogle(userType);
      _localStorage.setLoggedIn();
      _subscribeToAllNotification();
      // _setFree();
      return _user;
    } catch (e) {
      _setFree();
      print("from auth provider" + e.toString());
      print(e);
      throw e;
    }
  }

  Future<User?> signInWithApple() async {
    try {
      // _setBusy();
      print("sign in with apple");
      _user = await AppleAuthService().signInWithApple();
      _localStorage.setLoggedIn();
      _subscribeToAllNotification();
      // _setFree();
      return _user;
    } catch (e) {
      _setFree();
      print("from auth provider" + e.toString());
      print(e);
      throw e;
    }
  }

  // Future<User?> signInWithFacebook(UserType usertype) async{
  //       try{
  //           _setBusy();
  //           _user = await _authService.signInWithFacebook(usertype);
  //           _localStorage.setLoggedIn();
  //           _setFree();
  //           return _user;
  //         }catch (e) {
  //            _setFree();
  //            print("from auth provider" + e.toString());
  //            print(e);
  //            throw e;
  //          }
  // }

  Future<void> signupWithEmailPassword(
      String email, String password, UserType userType) async {
    try {
      _setBusy();
      // await _authService.signOut();
      _user =
          await _authService.signUpWithEmailPassword(email, password, userType);
      _localStorage.setLoggedIn();
      _subscribeToAllNotification();
      _setFree();
    } catch (e) {
      _setFree();
      print("from auth provider");
      print(e);
      throw e;
    }
  }

  Future<void> addUserDetails(User user) async {
    try {
      _setBusy();
      await _authService.updateUser(user);
      await _userService.addUsername(user);
      _user = user;
      _setFree();
    } catch (e) {
      _setFree();
      print(e);
      throw e;
    }
  }

  _setBusy() {
    _isLoading = true;
    notifyListeners();
  }

  _setFree() {
    _isLoading = false;
    notifyListeners();
  }

  signOut() async {
    _localStorage.setLoggedOut();
    await _authService.signOut();
    _user = null;
    _status = Status.Unauthenticated;
    _setFree();
    notifyListeners();
  }

  void refreshUser(User user) {
    _user = user;
    notifyListeners();
  }
}
