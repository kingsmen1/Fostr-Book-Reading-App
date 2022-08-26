import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fostr/services/CacheService.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' show Response, get;

class BitsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allBits = [];
  final CacheService _cacheService = GetIt.I<CacheService>();
  bool initialLoad = true;
  bool initialProfileLoad = true;

  Duration _cacheValidDuration = Duration(minutes: 1);
  DateTime _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);

  List<Map<String, dynamic>> get allFeeds => _allBits;

  Future<void> refreshFeed(bool notifyListeners) async {
    initialLoad = false;
    initialProfileLoad = false;
    _lastFetchTime = DateTime.now();
    await _getBits();
    if (notifyListeners) this.notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getFeed(
      {bool forceRefresh = false, bool notifyListeners = false}) async {
    bool shouldRefresh = _allBits.isEmpty ||
        forceRefresh ||
        _lastFetchTime.difference(DateTime.now()).inMinutes >
            _cacheValidDuration.inMinutes ||
        initialLoad;
    String? bitsJsonString = await _cacheService.getBitsCache();
    if (shouldRefresh && bitsJsonString == null) {
      await refreshFeed(notifyListeners);
    } else {
      if (bitsJsonString != null) {
        _allBits = List<Map<String, dynamic>>.from(
            json.decode(bitsJsonString)["data"]);
        refreshFeed(shouldRefresh);
      }
    }
    return _allBits;
  }

  Future<List<Map<String, dynamic>>> getFeedById(String userid,
      {bool forceRefresh = false, bool notifyListeners = false}) async {
    List<Map<String, dynamic>> _filteredBits = [];
    bool shouldRefresh = _allBits.isEmpty ||
        forceRefresh ||
        _lastFetchTime.difference(DateTime.now()).inMinutes >
            _cacheValidDuration.inMinutes ||
        initialProfileLoad;

    String? bitsJsonString = await _cacheService.getBitsCache();

    if (shouldRefresh && bitsJsonString == null) {
      await refreshFeed(notifyListeners);
    } else {
      if (bitsJsonString != null) {
        final Map<String, dynamic> fetchedBits =
            Map<String, dynamic>.from(json.decode(bitsJsonString));
        _allBits = List<Map<String, dynamic>>.from(fetchedBits['data']);
        refreshFeed(shouldRefresh);
      }
    }

    _allBits.forEach((element) {
      if (element['editorId'] == userid) {
        _filteredBits.add(element);
      }
    });

    return _filteredBits;
  }

  Future<void> _getBits() async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final Uri url = Uri.parse(
        "https://us-central1-fostr2021.cloudfunctions.net/foster/fosterbits/reviews");
    final Response response = await get(url, headers: {
      'Authorization': 'Bearer $token',
    }).timeout(Duration(seconds: 10), onTimeout: () {
      _cacheService.removeBitsCache();
      // ToastMessege(
      //   "Network Request Timeout",
      // );

      return Response(
        '{"error": "Timeout"}',
        404,
      );
    }).then((value) {
      return value;
    });
    try {
      if (response.statusCode == 200) {
        _cacheService.setBitsCache(response.body);
        final Map<String, dynamic> fetchedBits =
            Map<String, dynamic>.from(json.decode(response.body));
        _allBits = List<Map<String, dynamic>>.from(fetchedBits["data"]);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteBit(int index) async {
    if (_allBits.isNotEmpty) {
      _allBits[index]["isActive"] = false;
      notifyListeners();
    }
  }
}
