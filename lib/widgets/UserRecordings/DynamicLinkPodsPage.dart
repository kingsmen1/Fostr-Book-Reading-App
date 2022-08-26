import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/pages/user/userActivity/UserRecordings.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:provider/provider.dart';

import '../../pages/user/SelectBookCLubGenre.dart';
import '../../providers/AuthProvider.dart';

class DynamicLinkPodsPage extends StatefulWidget {
  final String? id;
  const DynamicLinkPodsPage({Key? key, required this.id}) : super(key: key);

  @override
  State<DynamicLinkPodsPage> createState() => _DynamicLinkPodsPageState();
}

class _DynamicLinkPodsPageState extends State<DynamicLinkPodsPage> {
  bool isLoading = true;
  final recordingCollection =
      FirebaseFirestore.instance.collection('recordings');
  void _loadData() async {
    if (widget.id != null) {
      final doc = await recordingCollection.doc(widget.id).get();
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (doc.exists && auth.logedIn) {
        final Map<String, dynamic>? data = doc.data();
        data?["id"] = doc.id;

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => Material(
              color: Theme.of(context).colorScheme.primary,
              child: SafeArea(
                  child: RoomTile(
                    authId: auth.user!.id,
                roomData: [data!],
                showShare: false,
              )),
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
