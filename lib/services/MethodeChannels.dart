import 'dart:developer';

import 'package:flutter/services.dart';

class FosterMethodChannel {
  final _platform = MethodChannel("com.clubfostr.fostr/foster");

  Future<void> setAgoraUserId(
      String creatorId, String roomId, String userId, String role) async {
    try {
      final int result = await _platform.invokeMethod("setID", {
        "creatorId": creatorId,
        "roomId": roomId,
        "userId": userId,
        "role": role,
      });
      log(result.toString());
    } catch (e) {
      print(e);
    }
  }

  Future<void> setRecording(bool recording) async {
    try {
      final int result = await _platform.invokeMethod("setRecording", {
        "recording": recording,
      });
      log(result.toString());
    } catch (e) {
      print(e);
    }
  }

  Future<void> setRecordingIDs(String userId, String roomId, String resourceId,
      String sid, String uid, String cname, String token) async {
    try {
      final int result = await _platform.invokeMethod("setRecordingIDs", {
        "userId": userId,
        "roomId": roomId,
        "resourceId": resourceId,
        "sid": sid,
        "uid": uid,
        "cname": cname,
        "token": token,
      });
      log(result.toString());
    } catch (e) {
      print(e);
    }
  }
}

