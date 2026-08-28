import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen Widget Tests', () {
    testWidgets('Renders all settings categories', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = PreferencesStore(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(store),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('CONNECTION'), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('EDITOR'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('TERMINAL'), 100);
      expect(find.text('TERMINAL'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('SECURITY'), 100);
      expect(find.text('SECURITY'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('ABOUT'), 100);
      expect(find.text('ABOUT'), findsOneWidget);
    });
  });
}
