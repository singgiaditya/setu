import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/storage_provider.dart';
import 'app_theme.dart';
import 'models/custom_theme_model.dart';
import 'theme_colors.dart';
import 'theme_typography.dart';
import 'themes/built_in_themes.dart';
import 'themes/dark_theme.dart';

export 'app_theme.dart';
export 'models/custom_theme_model.dart';
export 'theme_colors.dart';
export 'theme_typography.dart';
export 'themes/built_in_themes.dart';

class ThemeState {
  final String themeId;
  final String themeName;
  final bool isCustom;
  final bool isDark;
  final SetuColors colors;
  final ThemeData themeData;
  final SetuTypography typography;

  ThemeState({
    required this.themeId,
    required this.themeName,
    this.isCustom = false,
    this.isDark = true,
    required this.colors,
  })  : themeData = SetuTheme.buildTheme(colors, isDark: isDark),
        typography = SetuTypography(colors);
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    try {
      final prefs = ref.watch(preferencesStoreProvider);
      final activeId = prefs.activeThemeId;

      if (activeId != null) {
        // Check built-in presets
        final preset = BuiltInThemes.findById(activeId);
        if (preset != null) {
          return ThemeState(
            themeId: preset.id,
            themeName: preset.name,
            isCustom: false,
            isDark: preset.isDark,
            colors: preset.colors,
          );
        }

        // Check saved custom themes
        final rawCustoms = prefs.getSavedCustomThemes();
        for (final raw in rawCustoms) {
          if (raw['id'] == activeId) {
            final custom = CustomThemeModel.fromJson(raw);
            return ThemeState(
              themeId: custom.id,
              themeName: custom.name,
              isCustom: true,
              isDark: custom.isDark,
              colors: custom.colors,
            );
          }
        }
      }
    } catch (_) {}

    // Default to OnBed Classic
    return ThemeState(
      themeId: BuiltInThemes.onBedClassic.id,
      themeName: BuiltInThemes.onBedClassic.name,
      isCustom: false,
      isDark: true,
      colors: darkThemeColors,
    );
  }

  void applyPreset(ThemePreset preset) {
    state = ThemeState(
      themeId: preset.id,
      themeName: preset.name,
      isCustom: false,
      isDark: preset.isDark,
      colors: preset.colors,
    );
    try {
      ref.read(preferencesStoreProvider).setActiveThemeId(preset.id);
    } catch (_) {}
  }

  void applyCustomTheme(CustomThemeModel customTheme) {
    state = ThemeState(
      themeId: customTheme.id,
      themeName: customTheme.name,
      isCustom: true,
      isDark: customTheme.isDark,
      colors: customTheme.colors,
    );
    try {
      ref.read(preferencesStoreProvider).setActiveThemeId(customTheme.id);
    } catch (_) {}
  }

  void setTheme(String name, SetuColors colors, {String? themeId, bool isDark = true, bool isCustom = false}) {
    state = ThemeState(
      themeId: themeId ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      themeName: name,
      isCustom: isCustom,
      isDark: isDark,
      colors: colors,
    );
  }

  void resetToDark() {
    applyPreset(BuiltInThemes.onBedClassic);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

final setuColorsProvider = Provider<SetuColors>((ref) {
  return ref.watch(themeProvider).colors;
});

final setuTypographyProvider = Provider<SetuTypography>((ref) {
  return ref.watch(themeProvider).typography;
});

class CustomThemesNotifier extends Notifier<List<CustomThemeModel>> {
  @override
  List<CustomThemeModel> build() {
    try {
      final prefs = ref.watch(preferencesStoreProvider);
      final rawList = prefs.getSavedCustomThemes();
      return rawList.map((e) => CustomThemeModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTheme(CustomThemeModel theme) async {
    final prefs = ref.read(preferencesStoreProvider);
    final current = [...state];
    final index = current.indexWhere((t) => t.id == theme.id);

    if (index >= 0) {
      current[index] = theme;
    } else {
      current.add(theme);
    }

    state = current;
    await prefs.saveCustomThemes(current.map((t) => t.toJson()).toList());
  }

  Future<void> deleteTheme(String themeId) async {
    final prefs = ref.read(preferencesStoreProvider);
    final current = state.where((t) => t.id != themeId).toList();
    state = current;
    await prefs.saveCustomThemes(current.map((t) => t.toJson()).toList());

    final activeId = prefs.activeThemeId;
    if (activeId == themeId) {
      ref.read(themeProvider.notifier).applyPreset(BuiltInThemes.onBedClassic);
    }
  }
}

final customThemesProvider =
    NotifierProvider<CustomThemesNotifier, List<CustomThemeModel>>(CustomThemesNotifier.new);

