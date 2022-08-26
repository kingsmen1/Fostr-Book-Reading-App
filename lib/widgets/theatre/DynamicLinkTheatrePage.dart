import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/theatre/TheatrePeekInPage.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:provider/provider.dart';

import '../../pages/user/SelectBookCLubGenre.dart';

class DynamicLinkTheatrePage extends StatefulWidget {
  final String? theatreId;
  final String? creatorId;
  const DynamicLinkTheatrePage({Key? key, this.theatreId, this.creatorId})
      : super(key: key);

  @override
  State<DynamicLinkTheatrePage> createState() => _DynamicLinkTheatrePageState();
}

class _DynamicLinkTheatrePageState extends State<DynamicLinkTheatrePage> {
  bool isLoading = true;
  void _loadData() async {
    final theatreCollection = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.creatorId)
        .collection("amphitheatre");
    final userCollection = FirebaseFirestore.instance.collection('users');
    if (widget.theatreId != null && widget.creatorId != null) {
      final doc = await theatreCollection.doc(widget.theatreId).get();
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (doc.exists && auth.logedIn) {
        final Map<String, dynamic>? data = doc.data();

        final userDoc = await userCollection.doc(widget.creatorId).get();

        String name;
        String profileImage = "";
        if (userDoc.data()!["userProfile"] != null) {
          if (userDoc.data()!["userProfile"]["profileImage"] != null) {
            profileImage = userDoc.data()?["userProfile"]["profileImage"];
          }
        }
        name = userDoc.data()!["name"];
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => TheatrePeekInPage(
              theatre: Theatre.fromJson(doc.data(), ""),
              imageUrl: profileImage,
              name: name,
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      child: Center(
        child: (widget.theatreId != null &&
                widget.creatorId != null &&
                auth.logedIn)
            ? AppLoading()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'Opps something went wrong',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'There might be a problem with link or you might have been logged out.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  AppLoading(),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 50,
                    child: ElevatedButton(
                        style:
                            buildButtonStyle(theme.colorScheme.secondary),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                FontAwesomeIcons.arrowRightToBracket,
                                color: Colors.white,
                              ),
                            ),
                            Text("Go to Signup Page"),
                          ],
                        )),
                  ),
                ],
              ),
      ),
    );
  }
}
