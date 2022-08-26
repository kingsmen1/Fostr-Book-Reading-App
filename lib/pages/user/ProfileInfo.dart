import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/widgets/RoundedImage.dart';

class ProfileInfo extends StatefulWidget {
  final String userid;
  const ProfileInfo({Key? key, required this.userid}) : super(key: key);

  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  String? image = '';
  String? name = '';
  String? desc = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // final auth = Provider.of<AuthProvider>(context, listen: false);
      getData();
    });
  }

  void getData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userid)
        .get()
        .then((value) {
      setState(() {
        name = value.data()?["name"];
        image = value.data()?['userProfile']['profileImage'];
        desc = value.data()?['userProfile']?['description'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthProvider>(context);
    // final user = auth.user!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 10),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: 20, top: MediaQuery.of(context).size.height * 0.03),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: RoundedImage(
                      width: 80,
                      height: 80,
                      borderRadius: 35,
                      url: image,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          name ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 20.0, top: MediaQuery.of(context).size.height / 20),
              child: Text(
                desc ?? "",
                style: TextStyle(fontFamily: "drawerbody"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
