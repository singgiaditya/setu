import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/terminal/terminal_session.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../providers/terminal_provider.dart';

class TerminalDpadSheet extends ConsumerWidget {
  final TerminalSessionItem? session;

  const TerminalDpadSheet({
    super.key,
    required this.session,
  });

  void _send(WidgetRef ref, String seq) {
    if (session == null) return;
    final settings = ref.read(terminalSettingsProvider);
    if (settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    session!.writeInput(seq);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.foregroundMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(12),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.gamepad_rounded, color: colors.primary, size: 20),
                  const Gap(8),
                  Text('D-Pad & Navigation', style: typography.titleMedium),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.foregroundMuted, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const Gap(12),

          // Main D-Pad and Navigation Cluster
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left Cluster: Home, End, PgUp, PgDn
              Column(
                children: [
                  _NavButton(
                    label: 'PgUp',
                    colors: colors,
                    typography: typography,
                    onTap: () => _send(ref, '\x1b[5~'),
                  ),
                  const Gap(8),
                  _NavButton(
                    label: 'Home',
                    colors: colors,
                    typography: typography,
                    onTap: () => _send(ref, '\x1b[H'),
                  ),
                  const Gap(8),
                  _NavButton(
                    label: 'End',
                    colors: colors,
                    typography: typography,
                    onTap: () => _send(ref, '\x1b[F'),
                  ),
                  const Gap(8),
                  _NavButton(
                    label: 'PgDn',
                    colors: colors,
                    typography: typography,
                    onTap: () => _send(ref, '\x1b[6~'),
                  ),
                ],
              ),

              // Center Cluster: Virtual D-Pad Cross
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // UP
                    Positioned(
                      top: 6,
                      child: _DpadArrowButton(
                        icon: Icons.keyboard_arrow_up_rounded,
                        colors: colors,
                        onTap: () => _send(ref, '\x1b[A'),
                      ),
                    ),
                    // DOWN
                    Positioned(
                      bottom: 6,
                      child: _DpadArrowButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        colors: colors,
                        onTap: () => _send(ref, '\x1b[B'),
                      ),
                    ),
                    // LEFT
                    Positioned(
                      left: 6,
                      child: _DpadArrowButton(
                        icon: Icons.keyboard_arrow_left_rounded,
                        colors: colors,
                        onTap: () => _send(ref, '\x1b[D'),
                      ),
                    ),
                    // RIGHT
                    Positioned(
                      right: 6,
                      child: _DpadArrowButton(
                        icon: Icons.keyboard_arrow_right_rounded,
                        colors: colors,
                        onTap: () => _send(ref, '\x1b[C'),
                      ),
                    ),
                    // CENTER: Enter
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
                      ),
                      child: InkWell(
                        onTap: () => _send(ref, '\r'),
                        customBorder: const CircleBorder(),
                        child: Center(
                          child: Text(
                            '↵',
                            style: typography.titleMedium.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Cluster: ESC, TAB, Ctrl-C, CLR
              Column(
                children: [
                  _NavButton(
                    label: 'ESC',
                    colors: colors,
                    typography: typography,
                    isAccent: true,
                    onTap: () => _send(ref, '\x1b'),
                  ),
                  const Gap(8),
                  _NavButton(
                    label: 'TAB',
                    colors: colors,
                    typography: typography,
                    onTap: () => _send(ref, '\t'),
                  ),
                  const Gap(8),
                  _NavButton(
                    label: 'Ctrl+C',
                    colors: colors,
                    typography: typography,
                    isWarning: true,
                    onTap: () {
                      if (session == null) return;
                      final settings = ref.read(terminalSettingsProvider);
                      if (settings.hapticFeedback) HapticFeedback.mediumImpact();
                      session!.sendCtrl('C');
                    },
                  ),
                  const Gap(8),
                  _NavButton(
                    label: 'Ctrl+Z',
                    colors: colors,
                    typography: typography,
                    onTap: () {
                      if (session == null) return;
                      final settings = ref.read(terminalSettingsProvider);
                      if (settings.hapticFeedback) HapticFeedback.mediumImpact();
                      session!.sendCtrl('Z');
                    },
                  ),
                ],
              ),
            ],
          ),
          const Gap(14),
        ],
      ),
    );
  }
}

class _DpadArrowButton extends StatelessWidget {
  final IconData icon;
  final SetuColors colors;
  final VoidCallback onTap;

  const _DpadArrowButton({
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.border),
          ),
          child: Icon(icon, color: colors.foreground, size: 26),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final SetuColors colors;
  final SetuTypography typography;
  final VoidCallback onTap;
  final bool isAccent;
  final bool isWarning;

  const _NavButton({
    required this.label,
    required this.colors,
    required this.typography,
    required this.onTap,
    this.isAccent = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isAccent
        ? colors.primary.withValues(alpha: 0.15)
        : (isWarning ? colors.error.withValues(alpha: 0.15) : colors.surfaceVariant);
    final borderColor = isAccent
        ? colors.primary.withValues(alpha: 0.4)
        : (isWarning ? colors.error.withValues(alpha: 0.4) : colors.border);
    final textColor = isAccent
        ? colors.primary
        : (isWarning ? colors.error : colors.foreground);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 58,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: typography.code.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
