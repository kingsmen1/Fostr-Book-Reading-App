import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/utils/theme.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class LightBtn extends StatelessWidget with FostrTheme {
  final String text, url;
  LightBtn({required this.text, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launch(url),
      child: Opacity(
        opacity: 0.6,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 80.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: boxShadow,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 90.w,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    enabled: false,
                    initialValue: text,
                    cursorColor: textFieldStyle.color,
                    style: textFieldStyle.copyWith(
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.h, horizontal: 20),
                      fillColor: Color.fromRGBO(102, 163, 153, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
