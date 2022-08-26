import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/pages/onboarding/SignupPage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/PageSingleReview.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../pages/user/SelectBookCLubGenre.dart';

class DynamicLinkBitsPage extends StatefulWidget {
  final String? id;
  const DynamicLinkBitsPage({Key? key, required this.id}) : super(key: key);

  @override
  State<DynamicLinkBitsPage> createState() => _DynamicLinkBitsPageState();
}

class _DynamicLinkBitsPageState extends State<DynamicLinkBitsPage> {
  bool isLoading = true;
  final reviewsCollection = FirebaseFirestore.instance.collection('reviews');
  final userCollection = FirebaseFirestore.instance.collection('users');
  void _loadData() async {
    if (widget.id != null) {
      final doc = await reviewsCollection.doc(widget.id).get();
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (doc.exists && auth.logedIn) {
        final Map<String, dynamic>? data = doc.data();

        final userDoc = await userCollection.doc(data!['editorId']).get();
        final Map<String, dynamic>? userData = userDoc.data();

        String finalDateTime = "";
        var dateDiff = DateTime.now().difference(data["dateTime"].toDate());

        if (dateDiff.inDays >= 1) {
          finalDateTime = DateFormat.yMMMd()
              .addPattern(" | ")
              .add_jm()
              .format(data["dateTime"].toDate())
              .toString();
        } else {
          finalDateTime = timeago.format(data["dateTime"].toDate());
        }

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => PageSingleReview(
              url: data["url"] as String,
              profile: userData?["userProfile"]?["profileImage"] ?? "",
              username: userData?["userName"] as String,
              bookName: data["bookName"] as String,
              bookAuthor: data["bookAuthor"] as String,
              bookBio: data["bookNote"] as String,
              dateTime: finalDateTime,
              id: data["id"] as String,
              uid: auth.user!.id,
              imageUrl: data["imageUrl"],
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
        child: (widget.id != null && auth.logedIn)
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
                        style: buildButtonStyle(theme.colorScheme.secondary),
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
