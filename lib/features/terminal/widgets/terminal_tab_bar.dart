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
  final Function(String id, String newName)? onRenameSession;
  final VoidCallback onNewSession;

  const TerminalTabBar({
    super.key,
    required this.sessions,
    required this.activeSession,
    required this.colors,
    required this.typography,
    required this.onSelectSession,
    required this.onCloseSession,
    this.onRenameSession,
    required this.onNewSession,
  });

  void _showRenameDialog(BuildContext context, TerminalSessionItem session) {
    final controller = TextEditingController(text: session.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        title: Row(
          children: [
            Icon(Icons.edit_note_rounded, color: colors.primary, size: 22),
            const Gap(8),
            Text('Rename Session', style: typography.titleMedium),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: typography.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Session Name',
            hintText: 'e.g. backend-logs, runner, dev',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.foregroundMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                onRenameSession?.call(session.id, newName);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: const Color(0xFF0D1117),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TerminalSessionStatus status) {
    switch (status) {
      case TerminalSessionStatus.connected:
        return colors.success;
      case TerminalSessionStatus.disconnected:
        return colors.warning;
      case TerminalSessionStatus.error:
        return colors.error;
    }
  }

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
                final statusColor = _getStatusColor(session.status);

                return InkWell(
                  onTap: () => onSelectSession(session.id),
                  onLongPress: () => _showRenameDialog(context, session),
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
                        // Status dot
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
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
