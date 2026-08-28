import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/core/theme/theme_manager.dart';
import 'package:setu/core/theme/themes/dark_theme.dart';
import 'package:setu/features/terminal/widgets/terminal_keyboard_toolbar.dart';
import 'package:setu/providers/storage_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TerminalKeyboardToolbar Widget Tests', () {
    testWidgets('Renders all primary action chips and sticky modifiers', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesStore.init();
      final colors = darkThemeColors;
      final typography = SetuTypography(colors);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TerminalKeyboardToolbar(
                session: null,
                colors: colors,
                typography: typography,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('D-Pad'), findsOneWidget);
      expect(find.text('Snippets'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('Fn'), findsOneWidget);
      expect(find.text('CTRL'), findsOneWidget);
      expect(find.text('ALT'), findsOneWidget);
      expect(find.text('ESC'), findsOneWidget);
      expect(find.text('TAB'), findsOneWidget);
    });

    testWidgets('Tapping Fn toggles the F1-F12 keys row', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesStore.init();
      final colors = darkThemeColors;
      final typography = SetuTypography(colors);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TerminalKeyboardToolbar(
                session: null,
                colors: colors,
                typography: typography,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('F1'), findsNothing);

      // Tap Fn
      await tester.tap(find.text('Fn'));
      await tester.pumpAndSettle();

      expect(find.text('F1'), findsOneWidget);
      expect(find.text('F2'), findsOneWidget);

      // Tap Fn again to hide
      await tester.tap(find.text('Fn'));
      await tester.pumpAndSettle();

      expect(find.text('F1'), findsNothing);
    });

    testWidgets('Tapping CTRL toggles modifier state from latched to locked to inactive', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesStore.init();
      final colors = darkThemeColors;
      final typography = SetuTypography(colors);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TerminalKeyboardToolbar(
                session: null,
                colors: colors,
                typography: typography,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap once -> Latched
      await tester.tap(find.text('CTRL'));
      await tester.pumpAndSettle();

      // Tap twice -> Locked (shows lock icon)
      await tester.tap(find.text('CTRL'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      // Tap thrice -> Inactive
      await tester.tap(find.text('CTRL'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });
  });
}
