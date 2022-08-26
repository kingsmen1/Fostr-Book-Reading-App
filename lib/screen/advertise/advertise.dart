import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/advertise/advertiseService.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'datachart.dart';

class Advertise extends StatefulWidget {
  const Advertise({Key? key}) : super(key: key);

  @override
  _AdvertiseState createState() => _AdvertiseState();
}

class _AdvertiseState extends State<Advertise> {
  static const headStyle = TextStyle(fontWeight: FontWeight.w400, fontSize: 14);
  static const countStyle =
      TextStyle(fontWeight: FontWeight.w800, fontSize: 20);

  static const header = TextStyle(fontWeight: FontWeight.w800, fontSize: 25);

  final _userCollection = FirebaseFirestore.instance.collection("users");

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: Icon(Icons.arrow_back_ios),
        title: Text('Advertise with us'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: 48,
              child: ElevatedButton(
                style: ButtonStyle(),
                onPressed: () => {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Post a New Advertisement",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Container(
              height: 80,
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Active Ads', style: headStyle),
                        Text('10', style: countStyle)
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Impressions', style: headStyle),
                        Text('10', style: countStyle)
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Clicks', style: headStyle),
                        Text('10', style: countStyle)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            DataChart(
              title: '',
            ),
            Text(
              'Active Advertisements',
              style: header,
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: _userCollection.doc(auth.user?.id).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }
                  if (snapshot.hasData && !snapshot.data!.exists) {
                    return Text("User does not exist");
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: data["ads"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: FosterImage(
                              imageUrl: "${data["ads"][index]["imageLink"]}"),
                          title: Text("${data["ads"][index]["title"]}"),
                          subtitle:
                              Text("${data["ads"][index]["description"]}"),
                          onTap: () async {
                            _launchURL("${data["ads"][index]["redirectLink"]}");
                          },
                        );
                      },
                    );
                  }
                  return Text("loading");
                }),
            Container(
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 6),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Card(
                margin: EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FosterImage(
                      imageUrl:
                          'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Users 1000'),
                          Text('View Statistics')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
