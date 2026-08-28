import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/projects/models/project_model.dart';
import 'package:setu/features/projects/projects_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProjectModel Tests', () {
    test('Serialization and deserialization', () {
      final project = ProjectModel(
        id: 'p1',
        name: 'Backend API',
        emoji: '🚀',
        remotePath: '/var/www/api',
        isFavorite: true,
      );
      final json = project.toJson();
      expect(json['name'], equals('Backend API'));
      final restored = ProjectModel.fromJson(json);
      expect(restored.id, equals('p1'));
      expect(restored.emoji, equals('🚀'));
      expect(restored.isFavorite, isTrue);
    });
  });

  group('ProjectsScreen Widget Tests', () {
    testWidgets('Renders empty projects screen with default state', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = PreferencesStore(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(store),
          ],
          child: const MaterialApp(
            home: ProjectsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Projects'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
