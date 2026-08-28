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

    test('copyWith updates properties properly', () {
      final snippet = TerminalSnippet(
        id: 'orig',
        title: 'Original',
        command: 'ls',
        createdAt: DateTime.now(),
      );

      final updated = snippet.copyWith(
        title: 'New Title',
        autoExecute: false,
      );

      expect(updated.id, 'orig');
      expect(updated.title, 'New Title');
      expect(updated.autoExecute, isFalse);
      expect(updated.command, 'ls');
    });
  });
}
