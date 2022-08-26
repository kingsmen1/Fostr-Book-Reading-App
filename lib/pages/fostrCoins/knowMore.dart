import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fostr/core/constants.dart';

class KnowMore extends StatelessWidget {
  const KnowMore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fostr Coins & Rewards",
          style: TextStyle(color: Colors.black),
        ),
        leading: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bookmark("Bronze", 'bro.png', '\$3000'),
              Bookmark("Silver", 'silver.png', '\$8000'),
              Bookmark("Gold", 'gold.png', '\$18000'),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Points Breakdown",
              ),
              const SizedBox(
                height: 16,
              ),
              PointsBreakdown("Per App Shate", '2000'),
              const SizedBox(
                height: 10,
              ),
              PointsBreakdown("Hosting Rooms", '2000'),
              const SizedBox(
                height: 10,
              ),
              PointsBreakdown("Joining Rooms", '2000'),
              const SizedBox(
                height: 10,
              ),
              PointsBreakdown("Time Spend(Per Minute)", '2000'),
            ],
          ),
        ),
      ),
    );
  }
}

class PointsBreakdown extends StatelessWidget {
  const PointsBreakdown(this.title, this.points);
  final String title, points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: Color.fromRGBO(0, 0, 0, 0.1))),
      child: DefaultTextStyle(
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Spacer(),
            SvgPicture.asset(
              ICONS + 'coins.svg',
              width: 20,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(points)
          ],
        ),
      ),
    );
  }
}

class Bookmark extends StatelessWidget {
  const Bookmark(this.title, this.icon, this.reward);
  final String title, icon, reward;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          direction: Axis.vertical,
          children: [
            Text(
              title + " Bookmark",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              "Rewards worth $reward",
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
        Image.asset(ICONS + icon)
      ],
    );
  }
}
