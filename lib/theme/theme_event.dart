import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import './themes.dart';

@immutable
abstract class ThemeEvent extends Equatable {
  ThemeEvent([List props = const []]) : super();
}

class ThemeChanged extends ThemeEvent {
  final AppTheme theme;

  ThemeChanged({
    required this.theme,
  }) : super([theme]);

  @override
  List<Object?> get props => throw UnimplementedError();
}