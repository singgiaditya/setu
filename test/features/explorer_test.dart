import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/sftp/sftp_file_model.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/explorer/explorer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SftpFileItem Tests', () {
    test('Calculates formatted sizes and extensions correctly', () {
      const file = SftpFileItem(
        name: 'test.dart',
        path: '/home/user/test.dart',
        isDirectory: false,
        size: 2048,
      );
      expect(file.fileExtension, equals('dart'));
      expect(file.formattedSize, equals('2.0 KB'));
      expect(file.isHidden, isFalse);
      expect(file.iconData, equals(Icons.flutter_dash_rounded));

      const dir = SftpFileItem(
        name: '.git',
        path: '/home/user/.git',
        isDirectory: true,
        size: 4096,
      );
      expect(dir.isHidden, isTrue);
      expect(dir.formattedSize, equals(''));
      expect(dir.iconData, equals(Icons.folder_rounded));
    });
  });

  group('ExplorerScreen Widget Tests', () {
    testWidgets('Renders ExplorerScreen with disconnected state message', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = PreferencesStore(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStoreProvider.overrideWithValue(store),
          ],
          child: const MaterialApp(
            home: ExplorerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Files'), findsOneWidget);
      expect(find.textContaining('Not connected'), findsOneWidget);
    });
  });
}
