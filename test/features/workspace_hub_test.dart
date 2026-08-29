import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/projects/models/project_model.dart';
import 'package:setu/features/projects/projects_screen.dart';
import 'package:setu/features/workspace/workspace_hub_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkspaceHubScreen Widget Tests', () {
    testWidgets('Renders WorkspaceHub with Files, Terminal, and Git tabs',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesStore.init();

      final ws = ProjectModel(
        id: 'ws-test-1',
        name: 'setu-workspace',
        emoji: '🚀',
        remotePath: '/home/singgi/Projects/setu',
        lastOpened: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          preferencesStoreProvider.overrideWithValue(prefs),
        ],
      );
      container.read(projectsProvider.notifier).addProject(ws);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WorkspaceHubScreen(workspaceId: 'ws-test-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('setu-workspace'), findsOneWidget);
      expect(find.text('/home/singgi/Projects/setu'), findsOneWidget);
      expect(find.text('Files'), findsOneWidget);
      expect(find.text('Terminal'), findsOneWidget);
      expect(find.text('Git'), findsOneWidget);

      // Switch to Terminal tab
      await tester.tap(find.text('Terminal'));
      await tester.pumpAndSettle();

      // Switch to Git tab
      await tester.tap(find.text('Git'));
      await tester.pumpAndSettle();
    });
  });
}
