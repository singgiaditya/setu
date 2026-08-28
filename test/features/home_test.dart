import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen Widget Tests', () {
    testWidgets('Renders HomeScreen with greeting, quick actions, and status', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = PreferencesStore(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(store),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('SETU'), findsOneWidget);
      expect(find.text('QUICK ACTIONS'), findsOneWidget);
      expect(find.text('SYSTEM SUMMARY'), findsOneWidget);
    });
  });
}
