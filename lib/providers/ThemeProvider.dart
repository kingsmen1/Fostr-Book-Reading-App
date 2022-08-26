import 'package:flutter/material.dart';
import 'package:fostr/services/DeviceSettings.dart';
import 'package:get_it/get_it.dart';

class ThemeProvider with ChangeNotifier {
  DeviceSettings _deviceSettings = GetIt.I<DeviceSettings>();

  late ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeProvider({ThemeMode themeMode = ThemeMode.light}) {
    _mode = _deviceSettings.isDarkModeOn ? ThemeMode.dark : themeMode;
  }

  void toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _deviceSettings.setDarkMode(_mode == ThemeMode.dark);
    notifyListeners();
  }
}
