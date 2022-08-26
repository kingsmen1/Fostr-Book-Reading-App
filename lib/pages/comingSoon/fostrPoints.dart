import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FostrTheatreComingSoon extends StatefulWidget {
  const FostrTheatreComingSoon({Key? key}) : super(key: key);

  @override
  _FostrTheatreComingSoonState createState() => _FostrTheatreComingSoonState();
}

class _FostrTheatreComingSoonState extends State<FostrTheatreComingSoon> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 2.8,
                      color: Colors.black
                  ),
                  children: [
                    TextSpan(text:"Foster",
                      style: TextStyle(
                          color:Color(0xff2A9D8F),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    TextSpan(text:" Theatre"),
                  ]
                )
            ),
            SizedBox(height: 10,),
            Text(
                "Coming Soon!",
              style: const TextStyle(
                fontSize: 32,
                letterSpacing: 0.8
              ),
            ),
            SizedBox(height: 40,),
            Container(
              height: 350,
              width: MediaQuery.of(context).size.width*0.9,
              child: SvgPicture.asset(
                  "assets/images/comingSoonTheatre.svg",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FostrClubsComingSoon extends StatefulWidget {
  const FostrClubsComingSoon({Key? key}) : super(key: key);

  @override
  _FostrClubsComingSoonState createState() => _FostrClubsComingSoonState();
}

class _FostrClubsComingSoonState extends State<FostrClubsComingSoon> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
              text: TextSpan(
                  style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 2.8,
                      color: Colors.black
                  ),
                  children: [
                    TextSpan(text:"Fostr",
                      style: TextStyle(
                          color:Color(0xff2A9D8F),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    TextSpan(text:" Clubs"),
                  ]
              )
          ),
          SizedBox(height: 10,),
          Text(
            "Coming Soon!",
            style: const TextStyle(
                fontSize: 32,
                letterSpacing: 0.8
            ),
          ),
          SizedBox(height: 40,),
          Container(
            height: 350,
            width: MediaQuery.of(context).size.width*0.9,
            child: SvgPicture.asset(
              "assets/images/comingSoonClubs.svg",
            ),
          ),
        ],
      ),
    );
  }
}

