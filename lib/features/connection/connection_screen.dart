import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/ssh/ssh_config.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/ssh_provider.dart';
import '../onboarding/widgets/feature_tour_sheet.dart';
import 'widgets/connection_form_dialog.dart';
import 'widgets/connection_profile_card.dart';
import 'widgets/connection_status_indicator.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  String? _connectingProfileId;

  Future<void> _connect(ConnectionProfile profile) async {
    setState(() => _connectingProfileId = profile.id);

    final sshService = ref.read(sshServiceProvider);
    final keyManager = ref.read(sshKeyManagerProvider);

    String? key;
    String? pass;
    if (profile.authMethod == AuthMethod.privateKey) {
      key = await keyManager.getKey(profile.id);
    } else {
      pass = await keyManager.getPassword(profile.id);
    }

    final result = await sshService.connect(
      profile,
      privateKey: key,
      password: pass,
    );

    if (mounted) {
      setState(() => _connectingProfileId = null);
      if (result.isSuccess) {
        ref.read(activeProfileProvider.notifier).setActive(profile);
        // Update lastConnected time
        ref.read(connectionProfilesProvider.notifier).updateProfile(
              profile.copyWith(lastConnected: DateTime.now()),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${profile.name}!'),
            backgroundColor: const Color(0xFF3FB950),
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Connection failed'),
            backgroundColor: const Color(0xFFF85149),
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    final sshService = ref.read(sshServiceProvider);
    await sshService.disconnect();
    if (mounted) setState(() {});
  }

  void _openForm([ConnectionProfile? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectionFormDialog(existingProfile: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final profiles = ref.watch(connectionProfilesProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final sshService = ref.watch(sshServiceProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text('On|Bed', style: typography.brandSmall.copyWith(color: colors.primary)),
            const Gap(8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle),
            ),
            const Gap(8),
            Text('Workstations', style: typography.titleMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded, color: colors.foregroundMuted),
            onPressed: () => context.push('/setup-guide'),
            tooltip: 'Linux Setup Guide',
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, color: colors.primary),
            onPressed: () => _openForm(),
            tooltip: 'Add Workstation',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Current Status Header Card
            ConnectionStatusIndicator(
              status: sshService.status,
              machineName: sshService.isConnected
                  ? (activeProfile?.name ?? 'Workstation')
                  : null,
              host: sshService.isConnected ? activeProfile?.host : null,
              colors: colors,
              typography: typography,
              onActionTap: sshService.isConnected ? _disconnect : null,
            ),
            const Gap(20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Workstations',
                  style: typography.titleMedium.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${profiles.length} available',
                  style: typography.bodySmall,
                ),
              ],
            ),
            const Gap(12),

            // Profiles List or Empty State
            if (profiles.isEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.computer_rounded, size: 44, color: colors.foregroundMuted),
                    const Gap(12),
                    Text(
                      'No Workstations Configured',
                      style: typography.headlineSmall,
                    ),
                    const Gap(6),
                    Text(
                      'Tambahkan laptop/PC Linux Anda atau perangkat Tailscale untuk mulai remote development.',
                      style: typography.bodyMedium.copyWith(color: colors.foregroundMuted),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    ElevatedButton.icon(
                      onPressed: () => _openForm(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Workstation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: const Color(0xFF0D1117),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(14),

              // Linux Setup Guide Action Card
              Material(
                color: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                ),
                child: InkWell(
                  onTap: () => context.push('/setup-guide'),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.menu_book_rounded, color: colors.primary, size: 20),
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panduan Setup Komputer Linux',
                                style: typography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.foreground,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                'Langkah install OpenSSH, service systemd, & Tailscale VPN.',
                                style: typography.bodySmall.copyWith(
                                  color: colors.foregroundMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.primary),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(12),

              // Feature Tour Link
              Center(
                child: TextButton.icon(
                  onPressed: () => FeatureTourSheet.show(context, colors, typography),
                  icon: Icon(Icons.explore_outlined, size: 16, color: colors.accent),
                  label: Text(
                    'Jelajahi Panduan Fitur On|Bed',
                    style: typography.labelMedium.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ]
            else
              ...profiles.map((profile) {
                final isConnected = sshService.isConnected && activeProfile?.id == profile.id;
                final isConnecting = _connectingProfileId == profile.id;

                return ConnectionProfileCard(
                  profile: profile,
                  isSelected: activeProfile?.id == profile.id,
                  isConnected: isConnected,
                  isConnecting: isConnecting,
                  colors: colors,
                  typography: typography,
                  onConnect: () => _connect(profile),
                  onDisconnect: _disconnect,
                  onEdit: () => _openForm(profile),
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Workstation?'),
                        content: Text('Are you sure you want to remove "${profile.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(connectionProfilesProvider.notifier).deleteProfile(profile.id);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Delete', style: TextStyle(color: Color(0xFFF85149))),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: colors.primary,
        foregroundColor: const Color(0xFF0D1117),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Workstation',
          style: typography.labelLarge.copyWith(
            color: const Color(0xFF0D1117),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
