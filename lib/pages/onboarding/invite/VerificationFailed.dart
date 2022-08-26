import 'package:flutter/material.dart';
import 'package:fostr/widgets/Layout.dart';

import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/Buttons.dart';

class VerificationFailed extends StatelessWidget with FostrTheme {
  VerificationFailed({Key? key}) : super(key: key);

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
          Text("Sorry,", style: h1.apply(fontSizeDelta: 12)),
          SizedBox(
            height: 10,
          ),
          Text(
            "you are not verified yet!",
            style: h1.apply(fontSizeDelta: 12),
          ),
          SizedBox(
            height: 90,
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 111),
            child: Column(
              children: [
                PrimaryButton(
                  text: "Contact Us",
                  onTap: () {},
                ),
                SizedBox(
                  height: 20,
                ),
                PrimaryButton(
                  text: "Join as a User",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
