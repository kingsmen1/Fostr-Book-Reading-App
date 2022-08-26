import 'package:flutter/material.dart';
import 'package:fostr/utils/widget_constants.dart';

class UnderMaintenance extends StatelessWidget {
  const UnderMaintenance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Container(
              height: 150,
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                            border: Border.all(color: GlobalColors.signUpSignInButton,width: 1)
                        ),
                        child: Center(
                          child: Text(
                            "Under Maintenance",
                            style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                fontFamily: "drawerbody"
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment(0, -1),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                        child: Image.asset("assets/images/logo.png",fit: BoxFit.cover,),
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
