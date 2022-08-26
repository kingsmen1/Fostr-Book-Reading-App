import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fostr/core/constants.dart';

class FostrCoins extends StatefulWidget {
  const FostrCoins({Key? key}) : super(key: key);

  @override
  _FostrCoinsState createState() => _FostrCoinsState();
}

class _FostrCoinsState extends State<FostrCoins> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Text(
                      "12000",
                      style: TextStyle(fontSize: 44, color: Colors.green),
                    ),
                    Text("FOSTER COINS")
                  ],
                ),
              ),
              SvgPicture.asset(
                ICONS + 'group.svg',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.75,
              ),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Stack(alignment: Alignment.center, children: [
                  Positioned(
                    left: 76,
                    right: 76,
                    top: 40,
                    child: Container(height: 7, color: Colors.black),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            ICONS + 'bro.png',
                            width: 64,
                          ),
                          Text("coins"),
                          Text("date")
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            ICONS + 'silver.png',
                            width: 64,
                          ),
                          Text("coins"),
                          Text("date"),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            ICONS + 'gold.png',
                            width: 64,
                          ),
                          Text("coins"),
                          Text("date"),
                        ],
                      ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(
                height: 24,
              ),
              Wrap(
                children: [
                  const Text(
                    "We are",
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text("proud of you",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Center(
                  child: Text(
                "Congratulations for unlocking medal bookmark reward",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              )),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  crossAxisCount: 2,
                  childAspectRatio: 1 / .4,
                  children: [
                    Numbers("Shares", '2000'),
                    Numbers("Rooms Joined", '2000'),
                    Numbers("Number of minutes spent", '2000'),
                    Numbers("Rooms Hosted", '2000'),
                  ],
                ),
              ),
              Center(
                  child: const Text("Know more about Fostr Coins & Rewards",
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline)))
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("PROCEED"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
        ),
      ),
    );
  }
}

class Numbers extends StatelessWidget {
  const Numbers(this.title, this.value);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Wrap(
        direction: Axis.vertical,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12),
          ),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
