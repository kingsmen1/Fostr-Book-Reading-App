import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/utils/widget_constants.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
          child:Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top:30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                        child: Container(
                            width: MediaQuery.of(context).size.width *0.7,
                            height: MediaQuery.of(context).size.height *0.7,
                            child: Image.asset(
                              "assets/images/profile.jpeg",
                              fit: BoxFit.cover,
                            )
                        )
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:MediaQuery.of(context).size.height/10),
                      child: Center(
                        child: Container(
                            height: MediaQuery.of(context).size.height/15,
                            width: width*0.35,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: ElevatedButton.icon(
                                onPressed: (){
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => SecondScreen()),
                                  // );
                                },
                                style: buildButtonStyle(GlobalColors.signUpSignInButton),
                                label:Text("Next ",style: TextStyle(fontSize: 17),),
                                icon: Icon(FontAwesomeIcons.arrowRight,size:17),
                              ),
                            )
                        ),
                      ),
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: <Widget>[
                    //     // Align(
                    //     //   alignment: Alignment.bottomLeft,
                    //     //   child: Padding(
                    //     //     padding: EdgeInsets.only(left:20.0,top:MediaQuery.of(context).size.height/13),
                    //     //     child: Text(
                    //     //       "Connect",
                    //     //       style: TextStyle(
                    //     //           fontWeight: FontWeight.bold,
                    //     //           fontSize: 25
                    //     //       ),
                    //     //     ),
                    //     //   ),
                    //     // ),
                    //     // Padding(
                    //     //   padding: EdgeInsets.only(left:20.0,top:8),
                    //     //   child: Text("Explore all things literature."),
                    //     // ),
                    //     // Padding(
                    //     //   padding: const EdgeInsets.only(left:20),
                    //     //   child: Text("Connect and have engaging conversations."),
                    //     // ),
                    //
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          )
      ),
    );

  }

  ButtonStyle buildButtonStyle(Color color) {
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.0),
            )
        )
    );
  }
}
