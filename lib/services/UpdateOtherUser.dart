import 'package:cloud_functions/cloud_functions.dart';

class UpdateOtherUser {
  static Future<Map<String, dynamic>> update(
      Map<String, dynamic> userData) async {
    try {
      final HttpsCallable updateFunction =
          FirebaseFunctions.instance.httpsCallable('updateUser');
      final data = {'userData': userData};
      final res = await updateFunction(data);
      return res.data;
    } catch (e) {
      return {'error': e.toString(), 'result': -1};
    }
  }
}
