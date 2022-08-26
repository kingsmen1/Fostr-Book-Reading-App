import 'package:fostr/services/LocalStorage.dart';

class DeviceSettings {
  final LocalStorage _localStorage = LocalStorage();
  static const String THEME = 'theme';
  bool isDarkMode = false;

  DeviceSettings() {
    _localStorage.readBool(THEME).then((value) {
      isDarkMode = value ?? false;
    });
  }

  void setDarkMode(bool value) {
    isDarkMode = value;
    _localStorage.writeBool(THEME, value);
  }

  bool get isDarkModeOn => isDarkMode;
}
