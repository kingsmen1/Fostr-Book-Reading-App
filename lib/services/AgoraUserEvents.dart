
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fostr/core/settings.dart';
import 'package:http/http.dart' as http;

class AgoraUserEvents{
  String? cname;
  int? uid;

  AgoraUserEvents({
    required this.cname,
    required this.uid
});

  kickOutParticipant() async{
      String url ='https://api.agora.io/dev/v1/kicking-rule';
      var body = jsonEncode({
        "appid": APP_ID,
        "cname": cname,
        "uid": uid,
        "ip": "",
        "time": 60,
        "privileges": ["join_channel","publish_audio","publish_video"]
       });


      await http.post(
          Uri.parse(url),
          headers: {
            "Authorization" : "Basic YWQzODM1YTQ4ZmRmNDJlOTlmZDczM2Q0NGY4Mzk5Mjk6YWQ0OWI5YjdmYjRlNGUzODhlYjljNGVmYzVjYmJkZTA="
          },
          body: body
      ).then((http.Response response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.contentLength}");
        print(response.headers);
        print(response.request);

      });
  }

  unMuteParticipant(int rtcId) async{
    String url ='https://api.agora.io/dev/v1/kicking-rule';
    var body = jsonEncode({
      "appid": APP_ID,
      "cname": cname,
      "uid": rtcId,
      "ip": "",
      "time": 60,
      "privileges": []
    });




    await http.post(
        Uri.parse(url),
        headers: {
          "Authorization" : "Basic YWQzODM1YTQ4ZmRmNDJlOTlmZDczM2Q0NGY4Mzk5Mjk6YWQ0OWI5YjdmYjRlNGUzODhlYjljNGVmYzVjYmJkZTA="
        },
        body: body
    ).then((http.Response response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print(response.headers);
      print(response.request);

    });
  }

  muteParticipant(int rtcId) async{
    print(rtcId);
    String url ='https://api.agora.io/dev/v1/kicking-rule';
    var body = jsonEncode({
      "appid": APP_ID,
      "cname": cname,
      "uid": rtcId,
      "ip": "",
      "time": 60,
      "privileges": ["","publish_audio","publish_video"]
    });


    await http.post(
        Uri.parse(url),
        headers: {
          "Authorization" : "Basic YWQzODM1YTQ4ZmRmNDJlOTlmZDczM2Q0NGY4Mzk5Mjk6YWQ0OWI5YjdmYjRlNGUzODhlYjljNGVmYzVjYmJkZTA="
        },
        body: body
    ).then((http.Response response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print("Muting participant");
      print(response.headers);
      print(response.request);

    });
  }

  unMuteAllParticipants(List rtcIDs) async{
    String url ='https://api.agora.io/dev/v1/kicking-rule';

    for(int i = 0; i < rtcIDs.length ; i++){
      var body = jsonEncode({
        "appid": APP_ID,
        "cname": cname,
        "uid": rtcIDs[i],
        "ip": "",
        "time": 60,
        "privileges": []
      });


      await http.post(
          Uri.parse(url),
          headers: {
            "Authorization" : "Basic YWQzODM1YTQ4ZmRmNDJlOTlmZDczM2Q0NGY4Mzk5Mjk6YWQ0OWI5YjdmYjRlNGUzODhlYjljNGVmYzVjYmJkZTA="
          },
          body: body
      ).then((http.Response response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.contentLength}");
        print(response.headers);
        print(response.request);

      });
    }
  }

  muteAllParticipants(List rtcIDs) async{
    String url ='https://api.agora.io/dev/v1/kicking-rule';

    for(int i = 0; i < rtcIDs.length ; i++){
      var body = jsonEncode({
        "appid": APP_ID,
        "cname": cname,
        "uid": rtcIDs[i],
        "ip": "",
        "time": 60,
        "privileges": ["publish_audio"]
      });


      await http.post(
          Uri.parse(url),
          headers: {
            "Authorization" : "Basic YWQzODM1YTQ4ZmRmNDJlOTlmZDczM2Q0NGY4Mzk5Mjk6YWQ0OWI5YjdmYjRlNGUzODhlYjljNGVmYzVjYmJkZTA="
          },
          body: body
      ).then((http.Response response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.contentLength}");
        print(response.headers);
        print(response.request);

      });
    }
  }
}