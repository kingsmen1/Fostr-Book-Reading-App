import 'package:flutter/material.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';

class Background extends StatelessWidget with FostrTheme {
  final bool withImage;
  final Gradient? gradient;
  Background({Key? key, this.withImage = false, this.gradient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(color: theme.colorScheme.primary),
    );
  }
}
