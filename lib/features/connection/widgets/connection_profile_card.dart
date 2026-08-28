import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/ssh/ssh_config.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_typography.dart';

class ConnectionProfileCard extends StatelessWidget {
  final ConnectionProfile profile;
  final bool isSelected;
  final bool isConnected;
  final bool isConnecting;
  final SetuColors colors;
  final SetuTypography typography;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ConnectionProfileCard({
    super.key,
    required this.profile,
    required this.isSelected,
    required this.isConnected,
    required this.isConnecting,
    required this.colors,
    required this.typography,
    required this.onConnect,
    required this.onDisconnect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConnected
              ? colors.success.withValues(alpha: 0.6)
              : (isSelected ? colors.primary.withValues(alpha: 0.5) : colors.border),
          width: isConnected || isSelected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Machine name, online badge, menu
            Row(
              children: [
                // Machine Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? colors.success.withValues(alpha: 0.12)
                        : colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.laptop_mac_rounded,
                    size: 22,
                    color: isConnected ? colors.success : colors.primary,
                  ),
                ),
                const Gap(12),

                // Name & Host
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              style: typography.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isConnected) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ONLINE',
                                style: typography.labelSmall.copyWith(
                                  color: colors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Gap(2),
                      Text(
                        '${profile.username}@${profile.host}:${profile.port}',
                        style: typography.bodySmall.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                // More Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: colors.foregroundMuted, size: 20),
                  color: colors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          Gap(8),
                          Text('Edit Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFF85149)),
                          const Gap(8),
                          Text('Delete', style: TextStyle(color: Color(0xFFF85149))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(14),

            // Bottom action row: Auth type + Connect Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Auth Type Badge
                Row(
                  children: [
                    Icon(
                      profile.authMethod == AuthMethod.privateKey
                          ? Icons.key_rounded
                          : Icons.password_rounded,
                      size: 14,
                      color: colors.foregroundMuted,
                    ),
                    const Gap(6),
                    Text(
                      profile.authMethod == AuthMethod.privateKey ? 'SSH Key' : 'Password',
                      style: typography.bodySmall,
                    ),
                  ],
                ),

                // Connect / Disconnect Action Button
                if (isConnected)
                  OutlinedButton.icon(
                    onPressed: onDisconnect,
                    icon: Icon(Icons.link_off_rounded, size: 16, color: colors.error),
                    label: Text(
                      'Disconnect',
                      style: typography.labelMedium.copyWith(color: colors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: isConnecting ? null : onConnect,
                    icon: isConnecting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cable_rounded, size: 16),
                    label: Text(
                      isConnecting ? 'Connecting...' : 'Connect',
                      style: typography.labelMedium.copyWith(
                        color: const Color(0xFF0D1117),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
