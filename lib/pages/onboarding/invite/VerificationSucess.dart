import 'package:flutter/material.dart';
import 'package:fostr/widgets/Layout.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/Buttons.dart';

class VerificationSucess extends StatelessWidget with FostrTheme {
  VerificationSucess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Layout(
        child: Padding(
      padding: paddingH,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 240,
          ),
          Text("You are verified!,", style: h1.apply(fontSizeDelta: 12)),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 111),
            child: PrimaryButton(
              text: "Continue",
              onTap: () {},
            ),
          ),
        ],
      ),
    ));
  }
}
