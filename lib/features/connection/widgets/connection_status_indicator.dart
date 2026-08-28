import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/ssh/ssh_config.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_typography.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  final ConnectionStatus status;
  final String? machineName;
  final String? host;
  final SetuColors colors;
  final SetuTypography typography;
  final VoidCallback? onActionTap;

  const ConnectionStatusIndicator({
    super.key,
    required this.status,
    this.machineName,
    this.host,
    required this.colors,
    required this.typography,
    this.onActionTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case ConnectionStatus.connected:
        return colors.success;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return colors.warning;
      case ConnectionStatus.connectionLost:
      case ConnectionStatus.authFailed:
      case ConnectionStatus.hostUnavailable:
        return colors.error;
      case ConnectionStatus.disconnected:
        return colors.foregroundMuted;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Workstation Online';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case ConnectionStatus.connectionLost:
        return 'Connection Lost';
      case ConnectionStatus.authFailed:
        return 'Auth Failed';
      case ConnectionStatus.hostUnavailable:
        return 'Host Unavailable';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          // Glowing Pulse Dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const Gap(12),

          // Status & Host Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  machineName ?? statusLabel,
                  style: typography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                ),
                if (host != null && host!.isNotEmpty)
                  Text(
                    host!,
                    style: typography.bodySmall.copyWith(
                      color: colors.foregroundMuted,
                    ),
                  )
                else
                  Text(
                    statusLabel,
                    style: typography.bodySmall.copyWith(
                      color: statusColor,
                    ),
                  ),
              ],
            ),
          ),

          // Action button if callback provided
          if (onActionTap != null)
            IconButton(
              icon: Icon(
                status == ConnectionStatus.connected
                    ? Icons.link_off_rounded
                    : Icons.link_rounded,
                color: statusColor,
                size: 20,
              ),
              onPressed: onActionTap,
            ),
        ],
      ),
    );
  }
}
