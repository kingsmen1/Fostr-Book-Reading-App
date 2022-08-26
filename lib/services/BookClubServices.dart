import 'dart:convert';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:http/http.dart' as http;

class BookClubServices {
  Future<BookClubModel> createBookClub(
      BookClubModel bookClubModel, String token) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/bookclubs/v1/create";

    var body = jsonEncode({
      "bookclubLowerName": bookClubModel.bookClubName.toLowerCase(),
      ...bookClubModel.toJson(),
    });

    await http
        .post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: body)
        .then((http.Response response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print(response.headers);
      print(response.request);
    });

    return bookClubModel;
  }

  Future<void> editBookClub(Map<String, dynamic> data, String token) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/bookclubs/v1/update/${data["id"]}";
    var body = jsonEncode(data);

    await http.put(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: body);
  }

  Future<void> deleteBookClub(String id, String token) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/bookclubs/v1/update/$id";

    var body = jsonEncode({
      "isActive": false,
    });

    await http.put(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: body);
  }

  Future<void> unsubscribeBookClub(
      String clubID, String userID, String token) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/bookclubs/v1/unfollow/$clubID/$userID";

    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
  }

  Future<void> subscribeBookClub(
      String clubID, String userID, String token) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/bookclubs/v1/follow/$clubID/$userID";

    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
  }

  Future<void> createBookCLubRoomNow(
    String summary,
    String clubID,
    String userID,
    String genre,
    bool humanLibrary,
    String roomTitle,
    String roomImage,
    String roomCreator,
    String bearerToken,
    bool membersOnly,
  ) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/roomsapiv2/v1/create/$clubID/$userID";

    var body = jsonEncode({
      "summary": summary,
      "authorName": roomCreator,
      "agenda": "",
      "genre": genre,
      "id": userID,
      "bookClubId": clubID,
      "image": roomImage,
      "imageUrl": "",
      "imageUrl2": "",
      "button toggle": humanLibrary,
      "isActive": true,
      "isBookClub": true,
      "isUpcoming": false,
      "roomCreator": roomCreator,
      "title": roomTitle,
      "participantsCount": 0,
      "speakersCount": 0,
      "adTitle": "",
      "adDescription": "",
      "redirectLink": "",
      "membersOnly": membersOnly,
    });
    print("----------------------------------------------------");
    await http
        .post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json'
            },
            body: body)
        .catchError((e) {
      print(e);
    });
    print("----------------------------------------------------");
  }

  Future<void> createBookCLubRoomLater(
      String clubID,
      String userID,
      String genre,
      bool humanLibrary,
      String roomTitle,
      String roomImage,
      String roomCreator,
      String bearerToken,
      String summary,
      bool membersOnly) async {
    String url =
        "https://us-central1-fostr2021.cloudfunctions.net/roomsapiv2/v1/create/$clubID/$userID";

    var body = jsonEncode({
      "summary": summary,
      "authorName": roomCreator,
      "agenda": "",
      "genre": genre,
      "id": userID,
      "image": roomImage,
      "imageUrl": "",
      "imageUrl2": "",
      "bookClubId": clubID,
      "button toggle": humanLibrary,
      "isActive": true,
      "isBookClub": true,
      "isUpcoming": true,
      "roomCreator": roomCreator,
      "title": roomTitle,
      "participantsCount": 0,
      "speakersCount": 0,
      "adTitle": "",
      "adDescription": "",
      "redirectLink": "",
      "membersOnly": membersOnly,
    });

    await http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json'
        },
        body: body);
  }
}
