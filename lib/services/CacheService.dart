import 'package:fostr/services/LocalStorage.dart';

class CacheService {
  final LocalStorage _localStorage = LocalStorage();

  Future removeFeedsCache() async {
    await _localStorage.removeCache(LocalStorage.FEEDS_CACHE);
  }

  Future<String?> getFeedsCache() async {
    return await _localStorage.readCache(LocalStorage.FEEDS_CACHE);
  }

  Future<bool> setFeedsCache(String value) async {
    return await _localStorage.writeCache(LocalStorage.FEEDS_CACHE, value);
  }

  Future removeBitsCache() async {
    return await _localStorage.removeCache(LocalStorage.BITS_CACHE);
  }

  Future<String?> getBitsCache() async {
    return await _localStorage.readCache(LocalStorage.BITS_CACHE);
  }

  Future<bool> setBitsCache(String value) async {
    return await _localStorage.writeCache(LocalStorage.BITS_CACHE, value);
  }

  Future removePostsCache() async {
    return await _localStorage.removeCache(LocalStorage.POSTS_CACHE);
  }

  Future<String?> getPostsCache() async {
    return await _localStorage.readCache(LocalStorage.POSTS_CACHE);
  }

  Future<bool> setPostsCache(String value) async {
    return await _localStorage.writeCache(LocalStorage.POSTS_CACHE, value);
  }
}
