import 'package:equatable/equatable.dart';
import '../theme_colors.dart';
import 'dark_theme.dart';
import 'gruvbox_theme.dart';
import 'tokyo_night_theme.dart';
import 'dracula_theme.dart';
import 'catppuccin_latte_theme.dart';

class ThemePreset extends Equatable {
  final String id;
  final String name;
  final String description;
  final SetuColors colors;
  final bool isDark;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    this.isDark = true,
  });

  @override
  List<Object?> get props => [id, name, description, colors, isDark];
}

class BuiltInThemes {
  static const onBedClassic = ThemePreset(
    id: 'onbed-classic',
    name: 'OnBed Classic',
    description: 'Default GitHub-inspired dark slate with blue and purple accents.',
    colors: darkThemeColors,
    isDark: true,
  );

  static const gruvboxDark = ThemePreset(
    id: 'gruvbox-dark',
    name: 'Gruvbox Dark',
    description: 'Warm retro dark palette with olive green and vibrant yellow.',
    colors: gruvboxDarkThemeColors,
    isDark: true,
  );

  static const tokyoNight = ThemePreset(
    id: 'tokyo-night',
    name: 'Tokyo Night',
    description: 'Deep indigo night theme with electric cyan and magenta highlights.',
    colors: tokyoNightThemeColors,
    isDark: true,
  );

  static const dracula = ThemePreset(
    id: 'dracula',
    name: 'Dracula',
    description: 'Famous gothic dark theme featuring vibrant purple and neon pink.',
    colors: draculaThemeColors,
    isDark: true,
  );

  static const catppuccinLatte = ThemePreset(
    id: 'catppuccin-latte',
    name: 'Catppuccin Latte',
    description: 'Soothing warm light theme with clean sapphire and mauve accents.',
    colors: catppuccinLatteThemeColors,
    isDark: false,
  );

  static const List<ThemePreset> all = [
    onBedClassic,
    gruvboxDark,
    tokyoNight,
    dracula,
    catppuccinLatte,
  ];

  static ThemePreset? findById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
