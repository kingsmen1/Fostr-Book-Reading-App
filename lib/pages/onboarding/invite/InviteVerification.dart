import 'package:flutter/material.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/Buttons.dart';
import 'package:fostr/widgets/InputField.dart';
import 'package:fostr/widgets/SigninWithGoogle.dart';

import '../../../widgets/Layout.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key}) : super(key: key);

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> with FostrTheme {
  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Padding(
        padding: paddingH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 140,
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Text("Verification", style: h1),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Please enter Invite code",
              style: h2,
            ),
            SizedBox(
              height: 90,
            ),
            Form(
              child: Column(
                children: [
                  InputField(
                    hintText: "Enter Invite code",
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 111),
              child: PrimaryButton(
                text: "Verify",
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
