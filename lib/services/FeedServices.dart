import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class FeedServices {
  Future getFeed() async {
    await FirebaseAuth.instance.currentUser!.getIdToken().then((token) async {
      await http.get(
        Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/feeds"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      ).then((http.Response value) {});
    });
  }
}
