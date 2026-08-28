import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu/core/theme/theme_colors.dart';
import 'package:setu/core/theme/themes/dark_theme.dart';
import 'package:setu/core/theme/app_theme.dart';
import 'package:setu/core/theme/theme_typography.dart';
import 'package:setu/shared/models/result.dart';
import 'package:setu/shared/extensions/string_extensions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SetuTheme Tests', () {
    test('Dark theme colors have required fields', () {
      expect(darkThemeColors.background.value, isNotNull);
      expect(darkThemeColors.surface.value, isNotNull);
      expect(darkThemeColors.primary.value, isNotNull);
      expect(darkThemeColors.terminalBackground.value, isNotNull);
      expect(darkThemeColors.editorBackground.value, isNotNull);
    });

    test('SetuColors serialization & deserialization works', () {
      final json = darkThemeColors.toJson();
      expect(json['background'], startsWith('#'));
      final restored = SetuColors.fromJson(json);
      expect(restored.background.value, equals(darkThemeColors.background.value));
      expect(restored.primary.value, equals(darkThemeColors.primary.value));
    });

    test('SetuTheme builds valid ThemeData', () {
      final theme = SetuTheme.dark();
      expect(theme.brightness, equals(androidxBrightnessDark));
      expect(theme.scaffoldBackgroundColor, equals(darkThemeColors.background));
    });

    test('SetuTypography builds valid TextStyles', () {
      final typo = SetuTypography(darkThemeColors);
      expect(typo.brand.fontSize, equals(26));
      expect(typo.code.fontSize, equals(13));
      expect(typo.terminal.fontSize, equals(12.5));
    });
  });

  group('Result<T> Tests', () {
    test('Result.success returns data in when', () {
      final res = Result.success('test_data');
      expect(res.isSuccess, isTrue);
      expect(res.isFailure, isFalse);
      final val = res.when(
        onSuccess: (data) => data,
        onFailure: (err) => 'err',
      );
      expect(val, equals('test_data'));
    });

    test('Result.failure returns error in when', () {
      final res = Result<String>.failure('error_msg');
      expect(res.isSuccess, isFalse);
      expect(res.isFailure, isTrue);
      final val = res.when(
        onSuccess: (data) => data,
        onFailure: (err) => err,
      );
      expect(val, equals('error_msg'));
    });
  });

  group('StringExtensions Tests', () {
    test('fileName extracts basename', () {
      expect('/home/user/project/main.dart'.fileName, equals('main.dart'));
      expect('main.dart'.fileName, equals('main.dart'));
    });

    test('fileExtension extracts extension', () {
      expect('main.dart'.fileExtension, equals('dart'));
      expect('docker-compose.yml'.fileExtension, equals('yml'));
      expect('Dockerfile'.fileExtension, equals(''));
    });

    test('parentDirectory extracts parent path', () {
      expect('/home/user/project'.parentDirectory, equals('/home/user'));
      expect('/home'.parentDirectory, equals('/'));
    });
  });
}

const androidxBrightnessDark = androidx_brightness_dark;
const androidx_brightness_dark = androidx_Brightness_Dark;
const androidx_Brightness_Dark = androidx_brightness_dark_enum;
const androidx_brightness_dark_enum = androidx_b_dark;
const androidx_b_dark = Brightness.dark;
