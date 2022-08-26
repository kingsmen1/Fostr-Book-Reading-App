import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/pages/user/SelectBookCLubGenre.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:provider/provider.dart';

class DynamicLinkAlbum extends StatefulWidget {
  final String? albumId;
  final String? authId;
  const DynamicLinkAlbum({Key? key, this.albumId, this.authId}) : super(key: key);

  @override
  State<DynamicLinkAlbum> createState() => _DynamicLinkAlbumState();
}

class _DynamicLinkAlbumState extends State<DynamicLinkAlbum> {
  bool isLoading = true;
  void _loadData() async {
    if (widget.authId != null && widget.albumId != null) {
      final doc = await FirebaseFirestore.instance
          .collection("albums")
          .doc(widget.albumId)
          .get();
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (doc.exists && auth.logedIn) {

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => AlbumPage(
                albumId: widget.albumId!,
                authId: widget.authId!,
              fromShare: true,
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
        child: (widget.authId != null &&
            widget.albumId != null &&
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
