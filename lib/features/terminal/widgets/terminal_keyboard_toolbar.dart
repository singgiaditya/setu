import 'package:flutter/material.dart';
import '../../../core/terminal/terminal_session.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_typography.dart';

class TerminalKeyboardToolbar extends StatefulWidget {
  final TerminalSessionItem? session;
  final SetuColors colors;
  final SetuTypography typography;
  final VoidCallback? onClear;

  const TerminalKeyboardToolbar({
    super.key,
    required this.session,
    required this.colors,
    required this.typography,
    this.onClear,
  });

  @override
  State<TerminalKeyboardToolbar> createState() => _TerminalKeyboardToolbarState();
}

class _TerminalKeyboardToolbarState extends State<TerminalKeyboardToolbar> {
  bool _ctrlActive = false;
  bool _altActive = false;

  void _handleKey(String key) {
    if (widget.session == null) return;
    final s = widget.session!;

    if (_ctrlActive) {
      s.sendCtrl(key);
      setState(() => _ctrlActive = false);
      return;
    }

    switch (key) {
      case 'ESC':
        s.writeInput('\x1b');
        break;
      case 'TAB':
        s.writeInput('\t');
        break;
      case 'CTRL':
        setState(() => _ctrlActive = !_ctrlActive);
        break;
      case 'ALT':
        setState(() => _altActive = !_altActive);
        break;
      case '↑':
        s.writeInput('\x1b[A');
        break;
      case '↓':
        s.writeInput('\x1b[B');
        break;
      case '→':
        s.writeInput('\x1b[C');
        break;
      case '←':
        s.writeInput('\x1b[D');
        break;
      case 'C-c':
        s.sendCtrl('C');
        break;
      case 'C-d':
        s.sendCtrl('D');
        break;
      case 'C-z':
        s.sendCtrl('Z');
        break;
      case 'CLR':
        widget.onClear?.call();
        break;
      default:
        s.writeInput(key);
        break;
    }
  }

  static const _buttons = [
    'ESC', 'TAB', 'CTRL', 'ALT',
    'C-c', 'C-d', 'C-z',
    '↑', '↓', '←', '→',
    '|', '~', '`', '/', '\\', '-', '_', '=', '+',
    '{', '}', '[', ']', '(', ')', '<', '>',
    '\$', '&', ';', ':', '"', "'", 'CLR',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: widget.colors.surface,
        border: Border(
          top: BorderSide(color: widget.colors.border, width: 1),
          bottom: BorderSide(color: widget.colors.border, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: _buttons.length,
        itemBuilder: (context, index) {
          final label = _buttons[index];
          final isCtrl = label == 'CTRL' && _ctrlActive;
          final isAlt = label == 'ALT' && _altActive;
          final isSpecial = label.startsWith('C-') || label == 'ESC' || label == 'TAB';

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Material(
              color: isCtrl || isAlt
                  ? widget.colors.primary
                  : (isSpecial ? widget.colors.surfaceVariant : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: () => _handleKey(label),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isCtrl || isAlt
                          ? widget.colors.primary
                          : widget.colors.border.withValues(alpha: 0.7),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: widget.typography.code.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCtrl || isAlt
                          ? const Color(0xFF0D1117)
                          : widget.colors.foreground,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
