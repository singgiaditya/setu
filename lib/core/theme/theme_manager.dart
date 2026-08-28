import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'theme_colors.dart';
import 'theme_typography.dart';
import 'themes/dark_theme.dart';

class ThemeState {
  final String themeName;
  final SetuColors colors;
  final ThemeData themeData;
  final SetuTypography typography;

  ThemeState({
    required this.themeName,
    required this.colors,
  })  : themeData = SetuTheme.buildTheme(colors),
        typography = SetuTypography(colors);
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return ThemeState(
      themeName: 'Dark',
      colors: darkThemeColors,
    );
  }

  void setTheme(String name, SetuColors colors) {
    state = ThemeState(themeName: name, colors: colors);
  }

  void resetToDark() {
    state = ThemeState(themeName: 'Dark', colors: darkThemeColors);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

final setuColorsProvider = Provider<SetuColors>((ref) {
  return ref.watch(themeProvider).colors;
});

final setuTypographyProvider = Provider<SetuTypography>((ref) {
  return ref.watch(themeProvider).typography;
});
