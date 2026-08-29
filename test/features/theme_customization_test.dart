import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/core/theme/theme_manager.dart';
import 'package:setu/features/theme/theme_selection_screen.dart';
import 'package:setu/features/theme/custom_theme_editor_screen.dart';
import 'package:setu/shared/widgets/color_picker_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Customization Widget Tests', () {
    late PreferencesStore prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesStore.init();
    });

    testWidgets('ThemeSelectionScreen renders all 5 presets and live preview tabs', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: ThemeSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Header & Live preview
      expect(find.text('Themes & Colors'), findsOneWidget);
      expect(find.text('LIVE PREVIEW'), findsOneWidget);
      expect(find.text('BUILT-IN PRESETS'), findsOneWidget);

      // Check all 5 presets are rendered
      expect(find.text('OnBed Classic'), findsOneWidget);
      expect(find.text('Gruvbox Dark'), findsOneWidget);
      expect(find.text('Tokyo Night'), findsOneWidget);
      expect(find.text('Dracula'), findsOneWidget);
      expect(find.text('Catppuccin Latte'), findsOneWidget);

      // Tap on Gruvbox Dark preset
      await tester.tap(find.text('Gruvbox Dark'));
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('CustomThemeEditorScreen renders name input and category tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: CustomThemeEditorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Custom Theme'), findsOneWidget);
      expect(find.text('General UI (14)'), findsOneWidget);
      expect(find.text('Editor (5)'), findsOneWidget);
      expect(find.text('Terminal (4)'), findsOneWidget);
      expect(find.text('Save & Apply Theme'), findsOneWidget);
    });

    testWidgets('ColorPickerDialog opens and shows HSV and RGB channels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ColorPickerDialog.show(
                          context,
                          title: 'Test Color Picker',
                          initialColor: const Color(0xFF58A6FF),
                          appColors: BuiltInThemes.onBedClassic.colors,
                        );
                      },
                      child: const Text('Open Picker'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Test Color Picker'), findsOneWidget);
      expect(find.text('HSV Spectrum'), findsOneWidget);
      expect(find.text('RGB Channels'), findsOneWidget);
      expect(find.text('Apply Color'), findsOneWidget);
    });
  });
}
