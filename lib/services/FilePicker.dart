import 'dart:io';

import 'package:file_picker/file_picker.dart';

class Files {
  Files._();
  static Future<Map<String, dynamic>> getFile() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        File file = File(result.files.single.path!);
        final fileContainer = {
          "file": file,
          "ext": result.files.single.extension,
          "size": result.files.single.size,
        };
        return fileContainer;
      }
      throw "returned null from filePicker";
    } catch (e) {
      throw "User canceled the picker";
    }
  }
}
