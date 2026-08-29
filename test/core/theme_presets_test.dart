import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu/core/theme/theme_colors.dart';
import 'package:setu/core/theme/themes/built_in_themes.dart';
import 'package:setu/core/theme/models/custom_theme_model.dart';

void main() {
  group('Theme Presets & Models Unit Tests', () {
    test('BuiltInThemes contains 5 curated themes', () {
      expect(BuiltInThemes.all.length, equals(5));
      final ids = BuiltInThemes.all.map((p) => p.id).toList();
      expect(ids, contains('onbed-classic'));
      expect(ids, contains('gruvbox-dark'));
      expect(ids, contains('tokyo-night'));
      expect(ids, contains('dracula'));
      expect(ids, contains('catppuccin-latte'));
    });

    test('ThemePreset findById returns correct preset or null', () {
      final gruvbox = BuiltInThemes.findById('gruvbox-dark');
      expect(gruvbox, isNotNull);
      expect(gruvbox!.name, equals('Gruvbox Dark'));
      expect(gruvbox.isDark, isTrue);

      final latte = BuiltInThemes.findById('catppuccin-latte');
      expect(latte, isNotNull);
      expect(latte!.isDark, isFalse);

      final invalid = BuiltInThemes.findById('non-existent');
      expect(invalid, isNull);
    });

    test('SetuColors serialization to/from JSON preserves all colors', () {
      final original = BuiltInThemes.gruvboxDark.colors;
      final json = original.toJson();
      final restored = SetuColors.fromJson(json);

      expect(restored.background.toARGB32(), equals(original.background.toARGB32()));
      expect(restored.primary.toARGB32(), equals(original.primary.toARGB32()));
      expect(restored.terminalCursor.toARGB32(), equals(original.terminalCursor.toARGB32()));
      expect(restored.editorLineNumber.toARGB32(), equals(original.editorLineNumber.toARGB32()));
    });

    test('SetuColors hex helpers parse and format accurately', () {
      const hex = '#58A6FF';
      final color = SetuColors.colorFromHex(hex);
      expect(color, equals(const Color(0xFF58A6FF)));
      expect(SetuColors.colorToHex(color), equals(hex));
    });

    test('CustomThemeModel serializes and deserializes correctly', () {
      final custom = CustomThemeModel(
        id: 'test-custom-1',
        name: 'My Neon Theme',
        colors: BuiltInThemes.tokyoNight.colors,
        isDark: true,
        createdAt: DateTime(2026, 8, 29),
        updatedAt: DateTime(2026, 8, 29),
      );

      final json = custom.toJson();
      final restored = CustomThemeModel.fromJson(json);

      expect(restored.id, equals('test-custom-1'));
      expect(restored.name, equals('My Neon Theme'));
      expect(restored.isDark, isTrue);
      expect(restored.colors.primary.toARGB32(), equals(BuiltInThemes.tokyoNight.colors.primary.toARGB32()));
    });
  });
}
