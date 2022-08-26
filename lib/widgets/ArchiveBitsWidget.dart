import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/ToastMessege.dart';

class Archive extends StatefulWidget {
  final String bitsID;
  final String userID;
  const Archive({Key? key, required this.bitsID, required this.userID})
      : super(key: key);

  @override
  _ArchiveState createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  bool added = false;

  @override
  void initState() {
    isAdded(widget.userID, widget.bitsID);
    super.initState();
  }

  void isAdded(String authID, String bitID) async {
    await FirebaseFirestore.instance
        .collection("Archive Bits")
        .doc(authID)
        .collection("bits")
        .doc(bitID)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          added = value.exists ? true : false;
        });
      }
    });
  }

  void addToArchive(String authID, String bitID) async {
    await FirebaseFirestore.instance
        .collection("Archive Bits")
        .doc(authID)
        .collection("bits")
        .doc(bitID)
        .set({"bitID": bitID, "userID": authID},SetOptions(merge: true)).then((value) {
      setState(() {
        added = true;
      });
      ToastMessege("Bit added to archive collection", context: context);
    });
  }

  void removeFromArchive(String authID, String bitID) async {
    await FirebaseFirestore.instance
        .collection("Archive Bits")
        .doc(authID)
        .collection(bitID)
        .where("bitID", isEqualTo: bitID)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
      setState(() {
        added = false;
      });
      ToastMessege("Bit removed from archive collection", context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () async {
          added
              ? removeFromArchive(widget.userID, widget.bitsID)
              : addToArchive(widget.userID, widget.bitsID);
        },
        child: Center(
            child: Icon(
          CupertinoIcons.archivebox,
          color: added ? GlobalColors.signUpSignInButton : Colors.grey,
          size: 20,
        )),
      ),
    );
  }
}
