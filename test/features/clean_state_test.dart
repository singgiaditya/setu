import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/ssh_provider.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/projects/projects_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Clean State Tests (Zero Mock Data on Fresh Install)', () {
    test('ConnectionProfilesNotifier returns empty list on fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesStore.init();

      final container = ProviderContainer(
        overrides: [
          preferencesStoreProvider.overrideWithValue(prefs),
        ],
      );

      final profiles = container.read(connectionProfilesProvider);
      expect(profiles, isEmpty);

      final active = container.read(activeProfileProvider);
      expect(active, isNull);
    });

    test('Projects/Workspaces Notifier returns empty list on fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesStore.init();

      final container = ProviderContainer(
        overrides: [
          preferencesStoreProvider.overrideWithValue(prefs),
        ],
      );

      final projects = container.read(projectsProvider);
      expect(projects, isEmpty);
    });
  });
}
