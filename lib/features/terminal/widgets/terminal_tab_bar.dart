import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/terminal/terminal_session.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_typography.dart';

class TerminalTabBar extends StatelessWidget {
  final List<TerminalSessionItem> sessions;
  final TerminalSessionItem? activeSession;
  final SetuColors colors;
  final SetuTypography typography;
  final Function(String id) onSelectSession;
  final Function(String id) onCloseSession;
  final VoidCallback onNewSession;

  const TerminalTabBar({
    super.key,
    required this.sessions,
    required this.activeSession,
    required this.colors,
    required this.typography,
    required this.onSelectSession,
    required this.onCloseSession,
    required this.onNewSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isActive = activeSession?.id == session.id;

                return InkWell(
                  onTap: () => onSelectSession(session.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive ? colors.background : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? colors.primary : Colors.transparent,
                          width: 2,
                        ),
                        right: BorderSide(color: colors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive ? colors.primary : colors.foregroundMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          session.name,
                          style: typography.bodySmall.copyWith(
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            color: isActive ? colors.foreground : colors.foregroundMuted,
                          ),
                        ),
                        if (sessions.length > 1) ...[
                          const Gap(6),
                          GestureDetector(
                            onTap: () => onCloseSession(session.id),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: colors.foregroundMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, size: 18, color: colors.primary),
            onPressed: onNewSession,
            tooltip: 'New Terminal Session',
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
