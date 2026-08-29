import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/ssh/ssh_config.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/connection/connection_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectionProfile Model Tests', () {
    test('ConnectionProfile serialization & deserialization', () {
      final profile = ConnectionProfile(
        id: 'test-1',
        name: 'Workstation Alpha',
        host: '100.64.0.5',
        port: 2222,
        username: 'archlinux',
        authMethod: AuthMethod.privateKey,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = profile.toJson();
      expect(json['id'], equals('test-1'));
      expect(json['name'], equals('Workstation Alpha'));
      expect(json['host'], equals('100.64.0.5'));
      expect(json['port'], equals(2222));
      expect(json['username'], equals('archlinux'));
      expect(json['authMethod'], equals('privateKey'));

      final restored = ConnectionProfile.fromJson(json);
      expect(restored.id, equals(profile.id));
      expect(restored.name, equals(profile.name));
      expect(restored.host, equals(profile.host));
      expect(restored.port, equals(profile.port));
      expect(restored.authMethod, equals(AuthMethod.privateKey));
    });
  });

  group('ConnectionScreen Widget Tests', () {
    testWidgets('Renders ConnectionScreen with empty state and setup guide banner',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesStore.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: ConnectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('On|Bed'), findsOneWidget);
      expect(find.text('Workstations'), findsOneWidget);
      expect(find.text('Saved Workstations'), findsOneWidget);
      expect(find.text('No Workstations Configured'), findsOneWidget);
      expect(find.text('Panduan Setup Komputer Linux'), findsOneWidget);
      expect(find.text('Jelajahi Panduan Fitur On|Bed'), findsOneWidget);
    });
  });
}
