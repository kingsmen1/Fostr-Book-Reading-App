import 'package:flutter/material.dart';
import 'package:fostr/pages/rooms/EnterRoomDetails.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/utils/widget_constants.dart';

class SelectRoomType extends StatefulWidget {
  const SelectRoomType({Key? key}) : super(key: key);

  @override
  State<SelectRoomType> createState() => _SelectRoomTypeState();
}

class _SelectRoomTypeState extends State<SelectRoomType> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Select room type",
            style: TextStyle(fontFamily: "drawerhead", fontSize: 20)),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
            )),
        actions: [
          Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            width: 50,
            height: 50,
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: theme.colorScheme.secondary, width: 1)),
                child: Center(
                  child: Icon(
                    Icons.mic,
                    color: Colors.grey,
                    size: 70,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                "Would you like to create a room",
                style: TextStyle(fontFamily: "drawerbody", fontSize: 40),
                textAlign: TextAlign.center,
              ),
            ),

            //buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //now
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          body: EnterRoomDetails(
                            type: "now",
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 45,
                    decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        "Now",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "drawerbody",
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "OR",
                    style: TextStyle(
                        fontFamily: "drawerbody",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),

                //later
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          body: EnterRoomDetails(
                            type: "later",
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 45,
                    decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        "Later",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "drawerbody",
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
