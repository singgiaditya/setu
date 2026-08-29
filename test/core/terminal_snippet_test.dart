import 'package:flutter_test/flutter_test.dart';
import 'package:setu/core/terminal/terminal_snippet.dart';

void main() {
  group('TerminalSnippet Model Tests', () {
    test('Serializes to and from JSON correctly', () {
      final snippet = TerminalSnippet(
        id: 'test-snippet-1',
        title: 'Git Fetch & Rebase',
        command: 'git fetch && git rebase origin/main',
        category: 'Git',
        autoExecute: true,
        createdAt: DateTime(2026, 8, 28, 12, 0, 0),
      );

      final json = snippet.toJson();
      expect(json['id'], 'test-snippet-1');
      expect(json['title'], 'Git Fetch & Rebase');
      expect(json['command'], 'git fetch && git rebase origin/main');
      expect(json['category'], 'Git');
      expect(json['autoExecute'], isTrue);

      final fromJson = TerminalSnippet.fromJson(json);
      expect(fromJson, equals(snippet));
    });

    test('defaultSnippets contains key presets', () {
      final defaults = TerminalSnippet.defaultSnippets;
      expect(defaults, isNotEmpty);
      expect(defaults.any((s) => s.category == 'Git'), isTrue);
      expect(defaults.any((s) => s.category == 'Docker'), isTrue);
      expect(defaults.any((s) => s.category == 'System'), isTrue);
      expect(defaults.any((s) => s.category == 'Tmux'), isTrue);
    });

    test('Supports workspaceId scoping and isGlobal property', () {
      final globalSnippet = TerminalSnippet(
        id: 'global-1',
        title: 'Global Cmd',
        command: 'uptime',
        createdAt: DateTime.now(),
      );
      expect(globalSnippet.isGlobal, isTrue);
      expect(globalSnippet.workspaceId, isNull);

      final wsSnippet = TerminalSnippet(
        id: 'ws-1',
        title: 'Build Setu',
        command: 'flutter build apk',
        workspaceId: 'ws-setu-123',
        createdAt: DateTime.now(),
      );
      expect(wsSnippet.isGlobal, isFalse);
      expect(wsSnippet.workspaceId, equals('ws-setu-123'));

      final json = wsSnippet.toJson();
      expect(json['workspaceId'], equals('ws-setu-123'));

      final fromJson = TerminalSnippet.fromJson(json);
      expect(fromJson.workspaceId, equals('ws-setu-123'));
      expect(fromJson.isGlobal, isFalse);
    });
  });
}
