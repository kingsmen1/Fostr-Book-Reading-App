import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fostr/services/CacheService.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' show Response, get;

import '../widgets/ToastMessege.dart';

class PostsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allPosts = [];
  final CacheService _cacheService = GetIt.I<CacheService>();
  bool initialLoad = true;

  Duration _cacheValidDuration = Duration(minutes: 1);
  DateTime _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);

  List<Map<String, dynamic>> get allPosts => _allPosts;

  Future<void> refreshPosts(bool notifyListeners) async {
    _lastFetchTime = DateTime.now();
    initialLoad = false;
    await _getPosts();
    if (notifyListeners) this.notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getPosts(
      {bool forceRefresh = false, bool notifyListeners = false}) async {
    bool shouldRefresh = _allPosts.isEmpty ||
        forceRefresh ||
        _lastFetchTime.difference(DateTime.now()).inMinutes >
            _cacheValidDuration.inMinutes ||
        initialLoad;
    String? postsJsonString = await _cacheService.getPostsCache();

    if (shouldRefresh && postsJsonString == null) {
      await refreshPosts(notifyListeners);
    } else {
      if (postsJsonString != null) {
        _allPosts = List<Map<String, dynamic>>.from(
            json.decode(postsJsonString)["data"]);
        refreshPosts(shouldRefresh);
      }
    }
    return _allPosts;
  }

  Future<void> _getPosts() async {
    var token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final Uri url = Uri.parse(
        "https://us-central1-fostr2021.cloudfunctions.net/foster/posts/all");
    final Response response = await get(url, headers: {
      'Authorization': 'Bearer $token',
    }).timeout(Duration(seconds: 10), onTimeout: () {
      _cacheService.removePostsCache();
      // ToastMessege(
      //   "Network Request Timeout",
      // );
      return Response(
        '{"error": "Timeout"}',
        404,
      );
    });
    try {
      if (response.statusCode == 200) {
        _cacheService.setPostsCache(response.body);
        _allPosts =
            List<Map<String, dynamic>>.from(json.decode(response.body)["data"]);
      } else {
        // _cacheService.removePostsCache();
        // _allPosts = [];
      }
    } catch (e) {
      print(e);
    }
  }
}
