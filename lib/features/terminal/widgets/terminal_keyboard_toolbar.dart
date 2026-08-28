import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/terminal/terminal_session.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_typography.dart';
import '../../../providers/terminal_provider.dart';
import 'terminal_dpad_sheet.dart';
import 'terminal_snippets_sheet.dart';

enum ModifierState {
  inactive,
  latched, // 1 tap: active for next key, then resets
  locked,  // 2 taps: locked until tapped again
}

class TerminalKeyboardToolbar extends ConsumerStatefulWidget {
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
  ConsumerState<TerminalKeyboardToolbar> createState() => _TerminalKeyboardToolbarState();
}

class _TerminalKeyboardToolbarState extends ConsumerState<TerminalKeyboardToolbar> {
  ModifierState _ctrlState = ModifierState.inactive;
  ModifierState _altState = ModifierState.inactive;
  bool _showFnRow = false;

  void _triggerHaptic() {
    final settings = ref.read(terminalSettingsProvider);
    if (settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _toggleCtrl() {
    _triggerHaptic();
    setState(() {
      if (_ctrlState == ModifierState.inactive) {
        _ctrlState = ModifierState.latched;
      } else if (_ctrlState == ModifierState.latched) {
        _ctrlState = ModifierState.locked;
      } else {
        _ctrlState = ModifierState.inactive;
      }
    });
  }

  void _toggleAlt() {
    _triggerHaptic();
    setState(() {
      if (_altState == ModifierState.inactive) {
        _altState = ModifierState.latched;
      } else if (_altState == ModifierState.latched) {
        _altState = ModifierState.locked;
      } else {
        _altState = ModifierState.inactive;
      }
    });
  }

  Future<void> _handlePaste() async {
    _triggerHaptic();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      widget.session?.writeInput(data.text!);
    }
  }

  void _handleKey(String key) {
    _triggerHaptic();
    if (widget.session == null) return;
    final s = widget.session!;

    // If CTRL active
    if (_ctrlState != ModifierState.inactive) {
      s.sendCtrl(key);
      if (_ctrlState == ModifierState.latched) {
        setState(() => _ctrlState = ModifierState.inactive);
      }
      return;
    }

    // If ALT active
    if (_altState != ModifierState.inactive) {
      s.writeInput('\x1b$key');
      if (_altState == ModifierState.latched) {
        setState(() => _altState = ModifierState.inactive);
      }
      return;
    }

    switch (key) {
      case 'ESC':
        s.writeInput('\x1b');
        break;
      case 'TAB':
        s.writeInput('\t');
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
      case 'C-l':
        s.sendCtrl('L');
        break;
      case 'C-r':
        s.sendCtrl('R');
        break;
      case 'CLR':
        widget.onClear?.call();
        break;
      // F-Keys
      case 'F1':
        s.writeInput('\x1bOP');
        break;
      case 'F2':
        s.writeInput('\x1bOQ');
        break;
      case 'F3':
        s.writeInput('\x1bOR');
        break;
      case 'F4':
        s.writeInput('\x1bOS');
        break;
      case 'F5':
        s.writeInput('\x1b[15~');
        break;
      case 'F6':
        s.writeInput('\x1b[17~');
        break;
      case 'F7':
        s.writeInput('\x1b[18~');
        break;
      case 'F8':
        s.writeInput('\x1b[19~');
        break;
      case 'F9':
        s.writeInput('\x1b[20~');
        break;
      case 'F10':
        s.writeInput('\x1b[21~');
        break;
      case 'F11':
        s.writeInput('\x1b[23~');
        break;
      case 'F12':
        s.writeInput('\x1b[24~');
        break;
      default:
        s.writeInput(key);
        break;
    }
  }

  void _openDpad() {
    _triggerHaptic();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TerminalDpadSheet(session: widget.session),
    );
  }

  void _openSnippets() {
    _triggerHaptic();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TerminalSnippetsSheet(session: widget.session),
    );
  }

  static const _symbols = [
    '|', '~', '`', '/', '\\', '-', '_', '=', '+',
    '{', '}', '[', ']', '(', ')', '<', '>',
    '\$', '&', ';', ':', '"', "'",
  ];

  static const _fnKeys = [
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6',
    'F7', 'F8', 'F9', 'F10', 'F11', 'F12',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.colors.surface,
        border: Border(
          top: BorderSide(color: widget.colors.border, width: 1),
          bottom: BorderSide(color: widget.colors.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Optional Fn Keys Row
          if (_showFnRow)
            Container(
              height: 36,
              color: widget.colors.surfaceVariant.withValues(alpha: 0.5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                itemCount: _fnKeys.length,
                itemBuilder: (context, index) {
                  final fn = _fnKeys[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: widget.colors.surface,
                      borderRadius: BorderRadius.circular(5),
                      child: InkWell(
                        onTap: () => _handleKey(fn),
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: widget.colors.border),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            fn,
                            style: widget.typography.code.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Primary Accessory Toolbar
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              children: [
                // 1. D-Pad Mode Button
                _buildActionChip(
                  icon: Icons.gamepad_rounded,
                  label: 'D-Pad',
                  onTap: _openDpad,
                  isAccent: true,
                ),

                // 2. Snippets Drawer Button
                _buildActionChip(
                  icon: Icons.bolt_rounded,
                  label: 'Snippets',
                  onTap: _openSnippets,
                  isAccent: true,
                ),

                // 3. Paste from clipboard
                _buildActionChip(
                  icon: Icons.content_paste_rounded,
                  label: 'Paste',
                  onTap: _handlePaste,
                ),

                // 4. Fn Toggle
                _buildActionChip(
                  label: 'Fn',
                  isActive: _showFnRow,
                  onTap: () {
                    _triggerHaptic();
                    setState(() => _showFnRow = !_showFnRow);
                  },
                ),

                _buildDivider(),

                // 5. Sticky Modifiers: CTRL & ALT
                _buildModifierChip(
                  label: 'CTRL',
                  state: _ctrlState,
                  onTap: _toggleCtrl,
                ),
                _buildModifierChip(
                  label: 'ALT',
                  state: _altState,
                  onTap: _toggleAlt,
                ),

                _buildDivider(),

                // 6. Navigation & Control Keys
                _buildKeyButton('ESC', isSpecial: true),
                _buildKeyButton('TAB', isSpecial: true),
                _buildKeyButton('C-c', isSpecial: true),
                _buildKeyButton('C-d', isSpecial: true),
                _buildKeyButton('C-z', isSpecial: true),
                _buildKeyButton('C-l', isSpecial: true),
                _buildKeyButton('C-r', isSpecial: true),

                _buildDivider(),

                // 7. Arrow keys
                _buildKeyButton('↑'),
                _buildKeyButton('↓'),
                _buildKeyButton('←'),
                _buildKeyButton('→'),

                _buildDivider(),

                // 8. Symbols
                ..._symbols.map((sym) => _buildKeyButton(sym)),

                _buildDivider(),

                // 9. Clear
                _buildKeyButton('CLR', isSpecial: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      color: widget.colors.border.withValues(alpha: 0.6),
    );
  }

  Widget _buildModifierChip({
    required String label,
    required ModifierState state,
    required VoidCallback onTap,
  }) {
    final isLocked = state == ModifierState.locked;
    final isLatched = state == ModifierState.latched;
    final isActive = isLocked || isLatched;

    final bgColor = isLocked
        ? widget.colors.primary
        : (isLatched ? widget.colors.primary.withValues(alpha: 0.2) : widget.colors.surfaceVariant);
    final textColor = isLocked
        ? const Color(0xFF0D1117)
        : (isLatched ? widget.colors.primary : widget.colors.foreground);
    final borderColor = isActive ? widget.colors.primary : widget.colors.border;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: widget.typography.code.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (isLocked) ...[
                  const Gap(4),
                  Icon(Icons.lock_rounded, size: 12, color: textColor),
                ] else if (isLatched) ...[
                  const Gap(4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: textColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    IconData? icon,
    required String label,
    required VoidCallback onTap,
    bool isAccent = false,
    bool isActive = false,
  }) {
    final bgColor = isActive
        ? widget.colors.primary
        : (isAccent ? widget.colors.primary.withValues(alpha: 0.15) : widget.colors.surfaceVariant);
    final textColor = isActive
        ? const Color(0xFF0D1117)
        : (isAccent ? widget.colors.primary : widget.colors.foreground);
    final borderColor = isAccent || isActive ? widget.colors.primary : widget.colors.border;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor.withValues(alpha: 0.8)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: textColor),
                  const Gap(4),
                ],
                Text(
                  label,
                  style: widget.typography.code.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label, {bool isSpecial = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSpecial ? widget.colors.surfaceVariant : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => _handleKey(label),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: widget.colors.border.withValues(alpha: 0.7)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: widget.typography.code.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.colors.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
