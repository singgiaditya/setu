import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/editor/editor_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EditorScreen Widget Tests', () {
    testWidgets('Renders empty editor state when no path is provided', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = PreferencesStore(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(store),
          ],
          child: const MaterialApp(
            home: EditorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('No File Open'), findsOneWidget);
      expect(find.text('Browse Files'), findsOneWidget);
    });
  });
}
