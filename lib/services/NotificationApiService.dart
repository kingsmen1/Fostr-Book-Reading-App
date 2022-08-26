import 'package:cloud_functions/cloud_functions.dart';

/*
notificationId: 0 - 6 // int as string;

0 - "follow notification"
1 - "invite notification"
2 - "like notification"
3 - "comment notification"
....
*/

class NotificationApiService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future sendNotification(Map<String, dynamic> data) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('notifications');
      final result = await callable.call(data);
      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
