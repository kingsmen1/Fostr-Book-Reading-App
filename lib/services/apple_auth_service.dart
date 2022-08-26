import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fostr/services/AuthService.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../core/constants.dart';
import 'UserService.dart';
import 'package:fostr/models/UserModel/User.dart' as UserModel;


class AppleAuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<UserModel.User?> signInWithApple({List<Scope> scopes = const [Scope.email, Scope.fullName]}) async {
    // 1. perform the sign-in request
    TheAppleSignIn.isAvailable().then((value) => print("apple-signin " + value.toString()));

    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
          String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;
        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';
            await firebaseUser.updateDisplayName(displayName);
          }
        }
        if (userCredential.additionalUserInfo!.isNewUser) {
          // var user = await createUser(userCredential.user!);
          var user = await AuthService().createUser(userCredential.user!,UserType.USER);
          await _userService.subscribeNotifications();
          await _userService.setDeviceToken(user!);

          return user;
        } else {
          var user = await _userService.getUserById(userCredential.user!.uid);
          if (user != null) {
            var updatedUser = AuthService().updateLastLogin(user);
            await _userService.setDeviceToken(updatedUser);

            return updatedUser;
          }
        }
        break;
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }
}
