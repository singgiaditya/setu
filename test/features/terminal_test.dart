import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/core/terminal/terminal_service.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/terminal/terminal_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TerminalService Unit Tests', () {
    test('TerminalService manages sessions list correctly', () async {
      final service = TerminalService();
      expect(service.sessions, isEmpty);
      expect(service.activeSession, isNull);
    });
  });

  group('TerminalScreen Widget Tests', () {
    testWidgets('TerminalScreen renders empty state when no sessions exist and spawns session on demand',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesStore.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: TerminalScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SETU'), findsOneWidget);
      expect(find.text('No Terminal Sessions'), findsOneWidget);
      expect(find.text('New Terminal Session'), findsOneWidget);
      expect(find.text('Attach Tmux Session'), findsOneWidget);

      // Tap 'New Terminal Session'
      await tester.tap(find.text('New Terminal Session'));
      await tester.pumpAndSettle();

      expect(find.text('tmux'), findsOneWidget);
      expect(find.text('ESC'), findsOneWidget);
      expect(find.text('TAB'), findsOneWidget);
      expect(find.text('CTRL'), findsOneWidget);
    });
  });
}
