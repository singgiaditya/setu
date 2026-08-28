import 'package:flutter_test/flutter_test.dart';
import 'package:setu/core/terminal/terminal_theme_data.dart';

void main() {
  group('SetuTerminalTheme Tests', () {
    test('Contains 8 curated themes', () {
      expect(SetuTerminalTheme.allThemes.length, equals(8));
      final ids = SetuTerminalTheme.allThemes.map((t) => t.id).toSet();
      expect(ids.contains('setu-dark'), isTrue);
      expect(ids.contains('dracula'), isTrue);
      expect(ids.contains('tokyo-night'), isTrue);
      expect(ids.contains('nord'), isTrue);
      expect(ids.contains('one-dark'), isTrue);
      expect(ids.contains('monokai-pro'), isTrue);
      expect(ids.contains('solarized-dark'), isTrue);
      expect(ids.contains('oled-black'), isTrue);
    });

    test('fromId returns matched theme or default fallback', () {
      expect(SetuTerminalTheme.fromId('dracula').id, equals('dracula'));
      expect(SetuTerminalTheme.fromId('tokyo-night').name, equals('Tokyo Night'));
      expect(SetuTerminalTheme.fromId('non-existent-theme').id, equals('setu-dark'));
      expect(SetuTerminalTheme.fromId(null).id, equals('setu-dark'));
    });

    test('toTerminalTheme produces valid xterm TerminalTheme', () {
      for (final theme in SetuTerminalTheme.allThemes) {
        final xtermTheme = theme.toTerminalTheme();
        expect(xtermTheme.background, equals(theme.background));
        expect(xtermTheme.foreground, equals(theme.foreground));
        expect(xtermTheme.cursor, equals(theme.cursor));
        expect(xtermTheme.red, equals(theme.red));
        expect(xtermTheme.green, equals(theme.green));
        expect(xtermTheme.blue, equals(theme.blue));
      }
    });
  });
}
