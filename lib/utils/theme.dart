import 'package:flutter/material.dart';

const gradientTop = Color(0xffe9ffee);
const gradientBottom = Color(0xffa3c4bc);
const btnGradientLeft = Color(0xff92c8a2);
const btnGradientRight = Color(0xff639c8f);
const cardGradientLeft = Color(0xff4a956f);
const cardGradientRight = Color(0xff8edaa9);
const toastColor = Color(0xffa75a20);

Map<int, Color> getSwatch(Color color) {
  final hslColor = HSLColor.fromColor(color);
  final lightness = hslColor.lightness;

  final lowDivisor = 6;

  final highDivisor = 5;

  final lowStep = (1.0 - lightness) / lowDivisor;
  final highStep = lightness / highDivisor;

  return {
    50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
    100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
    200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
    300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
    400: (hslColor.withLightness(lightness + lowStep)).toColor(),
    500: (hslColor.withLightness(lightness)).toColor(),
    600: (hslColor.withLightness(lightness - highStep)).toColor(),
    700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
    800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
    900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
  };
}

mixin FostrTheme {
  final paddingH = const EdgeInsets.symmetric(horizontal: 24);

  final primaryColor = Color(0xff66A399);

  final background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      gradientTop,
      gradientBottom,
    ],
  );

  final secondaryBackground = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xffD8F7E2),
        Color(0xff8CB7AB),
      ]);

  final primaryButton = const LinearGradient(colors: [
    btnGradientLeft,
    btnGradientRight,
  ]);

  final buttonBorderRadius = BorderRadius.circular(20);

  final h1 = const TextStyle(
    fontSize: 24,
    color: Color(0xff000000),
    fontFamily: "drawerhead",
  );
  final h2 = const TextStyle(
    fontSize: 16,
    color: Color(0xffffffff),
    fontFamily: "drawerbody",
  );

  final textFieldStyle = const TextStyle(
    fontSize: 16,
    color: Color(0xffEEEEEE),
    fontFamily: "Lato",
  );

  final actionTextStyle = const TextStyle(
    fontSize: 16,
    color: Color(0xffffffff),
    fontFamily: "Lato",
  );

  final boxShadow = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Colors.black.withOpacity(0.25),
    ),
  ];
}

class FosterThemeData {
  static final _primaryColor = Color(0xFFF7F5F2);
  static final _accentColor = Colors.teal; //Color(0xFF575FCC);

  static final _accentColorDark = Color(0xffFF613A);
  static final _primaryColorDark = Colors.black;
  static final _errorColorDark = Colors.red;

  static final ThemeData lightTheme = ThemeData(
    hintColor: Color(0xff5C5C5C),
    backgroundColor: _primaryColor,
    indicatorColor: Color(0xffF1EEE9),
    colorScheme: ColorScheme(
      inversePrimary: Colors.black,
      primary: _primaryColor,
      secondary: _accentColor,
      surface: _primaryColor,
      background: _primaryColor,
      error: _errorColorDark,
      onPrimary: _primaryColorDark,
      onSecondary: _primaryColor,
      onSurface: _primaryColor,
      onBackground: _primaryColor,
      onError: _primaryColor,
      brightness: Brightness.light,
      tertiary: Color(0x808A8A8A),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _accentColor,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Color(0xffF1EEE9),
    ),
    // fontFamily: "drawerhead",
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 24,
      ),
      headline2: TextStyle(
        fontSize: 20,
      ),
      headline3: TextStyle(
        fontSize: 16,
      ),
      headline4: TextStyle(
        fontSize: 14,
      ),
      headline5: TextStyle(
        fontSize: 12,
      ),
      headline6: TextStyle(
        fontSize: 10,
      ),
      subtitle1: TextStyle(
        fontSize: 12,
      ),
      subtitle2: TextStyle(
        fontSize: 10,
      ),
      bodyText1: TextStyle(
        fontSize: 18,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
      ),
      button: TextStyle(
        fontSize: 17,
      ),
      caption: TextStyle(
        fontSize: 12,
      ),
      overline: TextStyle(
        fontSize: 10,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _accentColorDark,
    ),
    backgroundColor: _primaryColorDark,
    colorScheme: ColorScheme(
      inversePrimary: Colors.white,
      secondary: _accentColorDark,
      background: _primaryColorDark,
      brightness: Brightness.dark,
      error: _errorColorDark,
      onBackground: _primaryColorDark,
      onError: _errorColorDark,
      onPrimary: _primaryColor,
      onSecondary: _accentColor,
      onSurface: _primaryColor,
      primary: _primaryColorDark,
      surface: Color(0xff1F1F1F),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xffffffff),
    ),
    inputDecorationTheme: InputDecorationTheme(fillColor: Color(0xff1F1F1F)),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 24,
      ),
      headline2: TextStyle(
        fontSize: 20,
      ),
      headline3: TextStyle(
        fontSize: 16,
      ),
      headline4: TextStyle(
        fontSize: 14,
      ),
      headline5: TextStyle(
        fontSize: 12,
      ),
      headline6: TextStyle(
        fontSize: 10,
      ),
      subtitle1: TextStyle(
        fontSize: 12,
      ),
      subtitle2: TextStyle(
        fontSize: 10,
      ),
      bodyText1: TextStyle(
        fontSize: 16,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
      ),
      button: TextStyle(
        fontSize: 17,
      ),
      caption: TextStyle(
        fontSize: 12,
      ),
      overline: TextStyle(
        fontSize: 10,
      ),
    ),
  );
}
