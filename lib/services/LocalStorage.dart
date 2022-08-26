import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String FIRST_OPEN = 'fostr-firstOpen';
  static const String LOGGED_IN = 'fostr-loggedin';
  static const String USER_TYPE = "fostr-userType";
  static const String FEEDS_CACHE = "fostr-feedsCache";
  static const String BITS_CACHE = "fostr-bitsCache";
  static const String POSTS_CACHE = "fostr-postsCache";

  SharedPreferences? _prefs;
  bool firstOpen = true;
  bool loggedIn = false;
  bool isClub = false;

  initPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  readPrefs() async {
    await initPrefs();
    firstOpen = _prefs!.getBool(FIRST_OPEN) ?? true;
    loggedIn = _prefs!.getBool(LOGGED_IN) ?? false;
    isClub = _prefs!.getBool(USER_TYPE) ?? false;
  }

  Future<String?> readCache(String key) async {
    await initPrefs();
    return _prefs!.getString(key);
  }

  Future<bool> writeCache(String key, String value) async {
    await initPrefs();
    return _prefs!.setString(key, value);
  }

  Future<bool> removeCache(String key) async {
    await initPrefs();
    return _prefs!.remove(key);
  }

  Future<bool?> readBool(String key) async {
    await initPrefs();
    return _prefs!.getBool(key);
  }

  Future<bool> writeBool(String key, bool value) async {
    await initPrefs();
    return _prefs!.setBool(key, value);
  }

  setLoggedIn() {
    firstOpen = false;
    loggedIn = true;
    _prefs!.setBool(FIRST_OPEN, firstOpen);
    _prefs!.setBool(LOGGED_IN, loggedIn);
  }

  setUser() {
    isClub = false;
    _prefs!.setBool(USER_TYPE, false);
  }

  setClub() {
    isClub = true;
    _prefs!.setBool(USER_TYPE, true);
  }

  setLoggedOut() {
    firstOpen = false;
    loggedIn = false;
    _prefs!.setBool(FIRST_OPEN, firstOpen);
    _prefs!.setBool(LOGGED_IN, loggedIn);
  }
}
