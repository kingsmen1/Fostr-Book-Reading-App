import 'package:firebase_storage/firebase_storage.dart' as fbStorage;

class Storage {
  Storage._();
  static fbStorage.FirebaseStorage _storage =
      fbStorage.FirebaseStorage.instance;

  static Future<String> saveFile(
      Map<String, dynamic> fileContainer, String uid) async {
    try {
      final file = fileContainer['file'];
      final ext = fileContainer['ext'];
      final path = "profile/$uid/profile.$ext";
      fbStorage.Reference ref = _storage.ref(path);
      await ref.putFile(file).catchError((e) {});
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw e;
    }
  }

  static Future<String> saveRoomImage(
      Map<String, dynamic> fileContainer, String roomTitle) async {
    try {
      final file = fileContainer['file'];
      final ext = fileContainer['ext'];
      final path = "roomImage/$roomTitle.$ext";
      fbStorage.Reference ref = _storage.ref(path);
      await ref.putFile(file).catchError((e) {});
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw e;
    }
  }

  static Future<String> saveRoomAdImage(
      Map<String, dynamic> fileContainer, String roomTitle) async {
    try {
      final file = fileContainer['file'];
      final ext = fileContainer['ext'];
      final path = "roomImage/$roomTitle-ad.$ext";
      fbStorage.Reference ref = _storage.ref(path);
      await ref.putFile(file).catchError((e) {});
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw e;
    }
  }

  static Future<String> saveBookClubImage(
      Map<String, dynamic> fileContainer, String bookClubTitle) async {
    try {
      final file = fileContainer['file'];
      final ext = fileContainer['ext'];
      final path = "bookClubImage/$bookClubTitle.$ext";
      fbStorage.Reference ref = _storage.ref(path);
      await ref.putFile(file).catchError((e) {});
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw e;
    }
  }
}
