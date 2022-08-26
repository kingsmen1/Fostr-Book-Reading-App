import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fostr/services/CacheService.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' show Response, get;

class FeedProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allFeed = [];

  final CacheService _cacheService = GetIt.I<CacheService>();

  final FeedResponse initialData = FeedResponse(0, []);

  int _totalLength = 0;
  bool initialFetch = true;

  Duration _cacheValidDuration = Duration(minutes: 2);
  DateTime _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);

  List<Map<String, dynamic>> get allFeeds => _allFeed;
  int get totalFeeds => _totalLength;

  Future<void> refreshFeed(bool notifyListeners) async {
    initialFetch = false;
    _lastFetchTime = DateTime.now();
    await _getFeed();
    if (notifyListeners) this.notifyListeners();
  }

  Future<FeedResponse> getFeed(
      {bool forceRefresh = false, bool notifyListeners = false}) async {
    bool shouldRefresh = _allFeed.isEmpty ||
        forceRefresh ||
        _lastFetchTime.difference(DateTime.now()).inMinutes >
            _cacheValidDuration.inMinutes ||
        initialFetch;

    String? feedJsonString = await _cacheService.getFeedsCache();
    if (shouldRefresh && feedJsonString == null) {
      await refreshFeed(notifyListeners);
    } else {
      if (feedJsonString != null) {
        dynamic feedJson = {};
        try {
          feedJson = json.decode(feedJsonString);
        } catch (e) {
          _cacheService.removeFeedsCache();
          feedJson = [];
        }
        _allFeed = List<Map<String, dynamic>>.from(feedJson);
        _totalLength = _allFeed.length;
        refreshFeed(shouldRefresh);
      }
    }
    return FeedResponse(
      _totalLength,
      _allFeed,
    );
  }

  Future _getFeed() async {
    final Uri url =
        Uri.parse("https://us-central1-fostr2021.cloudfunctions.net/feeds");
    final Response response =
        await get(url).timeout(Duration(seconds: 10), onTimeout: () {
      _cacheService.removeFeedsCache();
      // ToastMessege("Network Request Timeout",);
      return Response(
        "Timeout",
        404,
      );
    });
    if (response.statusCode == 200) {
      _cacheService.setFeedsCache(response.body);
      _allFeed = List<Map<String, dynamic>>.from(json.decode(response.body));
      _totalLength = _allFeed.length;
    }
  }
}

class FeedResponse {
  final int length;
  final List<Map<String, dynamic>> feeds;
  FeedResponse(this.length, this.feeds);
}
