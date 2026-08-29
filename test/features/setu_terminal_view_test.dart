import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/xterm.dart';
import 'package:setu/features/terminal/widgets/setu_terminal_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SetuTerminalView Mobile Keyboard Enter & Action Detection Tests', () {
    testWidgets('SetuTerminalView renders and mounts properly', (tester) async {
      final terminal = Terminal();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetuTerminalView(
              terminal,
              keyboardType: TextInputType.text,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SetuTerminalView), findsOneWidget);
    });

    testWidgets('Hardware and virtual Enter key sends Enter to terminal', (tester) async {
      final terminal = Terminal();
      var enterSent = false;

      terminal.onOutput = (data) {
        if (data.contains('\r') || data.contains('\n')) {
          enterSent = true;
        }
      };

      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetuTerminalView(
              terminal,
              focusNode: focusNode,
              autofocus: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      focusNode.requestFocus();
      await tester.pump();

      // Simulate pressing Enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(enterSent, isTrue);
    });
  });
}
