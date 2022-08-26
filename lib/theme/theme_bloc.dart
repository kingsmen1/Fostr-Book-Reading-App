import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fostr/theme/theme_event.dart';
import 'package:fostr/theme/theme_state.dart';
import './themes.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {

  ThemeBloc() : super(ThemeState(themeData: appThemeData[AppTheme.Light]));

  @override
  Stream<ThemeState> mapEventToState(
      ThemeEvent event,
      ) async* {

    if (event is ThemeChanged) {
      yield ThemeState(themeData: appThemeData[event.theme]);
    }
  }
}