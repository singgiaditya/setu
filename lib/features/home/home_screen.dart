import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../core/ssh/ssh_config.dart';
import '../../core/theme/theme_manager.dart';
import '../../features/connection/widgets/connection_status_indicator.dart';
import '../../features/projects/projects_screen.dart';
import '../../providers/ssh_provider.dart';
import '../../providers/system_metrics_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final sshService = ref.watch(sshServiceProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final projects = ref.watch(projectsProvider);
    final ConnectionStatus status = sshService.status;
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (sshService.isConnected) {
              await ref.read(systemMetricsProvider.notifier).fetchMetrics();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand & Greeting Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SETU',
                        style: typography.brand.copyWith(
                          color: colors.primary,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        greeting,
                        style: typography.bodyMedium.copyWith(
                          color: colors.foregroundMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    onPressed: () => context.push('/connect'),
                    icon: const Icon(Icons.tune_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceVariant,
                      foregroundColor: colors.foreground,
                    ),
                    tooltip: 'Connection Profiles',
                  ),
                ],
              ),
              const Gap(20),

              // Connection Status Card
              ConnectionStatusIndicator(
                status: status,
                machineName: activeProfile?.name,
                host: activeProfile != null
                    ? '${activeProfile.username}@${activeProfile.host}:${activeProfile.port}'
                    : null,
                colors: colors,
                typography: typography,
                onActionTap: () => context.push('/connect'),
              ),
              const Gap(24),

              // Quick Actions Row
              Text(
                'QUICK ACTIONS',
                style: typography.labelSmall.copyWith(
                  letterSpacing: 1.2,
                  color: colors.foregroundMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.terminal_rounded,
                      label: 'Terminal',
                      color: colors.primary,
                      onTap: () => context.go('/terminal'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.folder_rounded,
                      label: 'Files',
                      color: colors.accent,
                      onTap: () => context.go('/files'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.folder_special_rounded,
                      label: 'Projects',
                      color: colors.success,
                      onTap: () => context.go('/projects'),
                    ),
                  ),
                ],
              ),
              const Gap(24),

              // System Summary Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SYSTEM SUMMARY',
                    style: typography.labelSmall.copyWith(
                      letterSpacing: 1.2,
                      color: colors.foregroundMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (sshService.isConnected)
                    Consumer(
                      builder: (context, ref, _) {
                        final metricsState = ref.watch(systemMetricsProvider);
                        final uptime = metricsState.metrics?.uptime;
                        return Row(
                          children: [
                            if (uptime != null && uptime.isNotEmpty) ...[
                              Icon(Icons.schedule_rounded, size: 13, color: colors.foregroundMuted),
                              const Gap(4),
                              Text(
                                'Up $uptime',
                                style: typography.code.copyWith(fontSize: 10, color: colors.foregroundMuted),
                              ),
                              const Gap(8),
                            ],
                            InkWell(
                              onTap: () => ref.read(systemMetricsProvider.notifier).fetchMetrics(),
                              borderRadius: BorderRadius.circular(4),
                              child: metricsState.isLoading
                                  ? SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 1.5, color: colors.primary),
                                    )
                                  : Icon(Icons.refresh_rounded, size: 14, color: colors.foregroundMuted),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
              const Gap(10),
              _SystemSummaryBar(
                isConnected: sshService.isConnected,
              ),
              const Gap(24),

              // Recent Projects Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT PROJECTS',
                    style: typography.labelSmall.copyWith(
                      letterSpacing: 1.2,
                      color: colors.foregroundMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go('/projects'),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'View All',
                        style: typography.bodySmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),

              // Recent Workspaces Horizontal Scroll
              if (projects.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.workspaces_outlined, size: 32, color: colors.foregroundMuted),
                      const Gap(8),
                      Text('No saved workspaces', style: typography.bodySmall),
                      const Gap(10),
                      TextButton.icon(
                        onPressed: () => context.go('/projects'),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Workspace'),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: projects.length,
                    separatorBuilder: (context, index) => const Gap(12),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return _RecentProjectCard(
                        projectEmoji: project.emoji,
                        projectName: project.name,
                        projectPath: project.remotePath,
                        onTap: () {
                          ref.read(projectsProvider.notifier).touchProject(project.id);
                          context.push('/workspace/${project.id}');
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final colors = ref.watch(setuColorsProvider);
        final typography = ref.watch(setuTypographyProvider);

        return Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const Gap(8),
                  Text(
                    label,
                    style: typography.labelMedium.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SystemSummaryBar extends StatelessWidget {
  final bool isConnected;

  const _SystemSummaryBar({
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final colors = ref.watch(setuColorsProvider);
        final typography = ref.watch(setuTypographyProvider);
        final metricsState = ref.watch(systemMetricsProvider);
        final metrics = metricsState.metrics;

        final cpuValue = (isConnected && metrics != null) ? metrics.cpuPercentage : 0.0;
        final memValue = (isConnected && metrics != null) ? metrics.memoryPercentage : 0.0;
        final diskValue = (isConnected && metrics != null) ? metrics.diskPercentage : 0.0;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SystemMetricItem(
                  label: 'CPU',
                  valueText: (isConnected && metrics != null)
                      ? '${(cpuValue * 100).toInt()}%'
                      : (isConnected && metricsState.isLoading ? '...' : '--'),
                  subtitle: (isConnected && metrics != null && metrics.loadAvg1m > 0)
                      ? '${metrics.loadAvg1m.toStringAsFixed(2)} load'
                      : null,
                  progress: cpuValue,
                  color: colors.primary,
                  typography: typography,
                  colors: colors,
                ),
              ),
              Container(width: 1, height: 36, color: colors.border),
              Expanded(
                child: _SystemMetricItem(
                  label: 'MEM',
                  valueText: (isConnected && metrics != null)
                      ? '${(memValue * 100).toInt()}%'
                      : (isConnected && metricsState.isLoading ? '...' : '--'),
                  subtitle: (isConnected && metrics != null && metrics.formattedMemUsage.isNotEmpty)
                      ? metrics.formattedMemUsage
                      : null,
                  progress: memValue,
                  color: colors.accent,
                  typography: typography,
                  colors: colors,
                ),
              ),
              Container(width: 1, height: 36, color: colors.border),
              Expanded(
                child: _SystemMetricItem(
                  label: 'DISK',
                  valueText: (isConnected && metrics != null)
                      ? '${(diskValue * 100).toInt()}%'
                      : (isConnected && metricsState.isLoading ? '...' : '--'),
                  subtitle: (isConnected && metrics != null && metrics.formattedDiskUsage.isNotEmpty)
                      ? metrics.formattedDiskUsage
                      : null,
                  progress: diskValue,
                  color: colors.warning,
                  typography: typography,
                  colors: colors,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SystemMetricItem extends StatelessWidget {
  final String label;
  final String valueText;
  final String? subtitle;
  final double progress;
  final Color color;
  final SetuTypography typography;
  final SetuColors colors;

  const _SystemMetricItem({
    required this.label,
    required this.valueText,
    this.subtitle,
    required this.progress,
    required this.color,
    required this.typography,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: typography.labelSmall.copyWith(
                  color: colors.foregroundMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                valueText,
                style: typography.bodySmall.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (subtitle != null) ...[
            const Gap(4),
            Text(
              subtitle!,
              style: typography.code.copyWith(
                fontSize: 9,
                color: colors.foregroundMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentProjectCard extends StatelessWidget {
  final String projectEmoji;
  final String projectName;
  final String projectPath;
  final VoidCallback onTap;

  const _RecentProjectCard({
    required this.projectEmoji,
    required this.projectName,
    required this.projectPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final colors = ref.watch(setuColorsProvider);
        final typography = ref.watch(setuTypographyProvider);

        return Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 170,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(projectEmoji, style: const TextStyle(fontSize: 18)),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: colors.foregroundMuted),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectName,
                        style: typography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      Text(
                        projectPath,
                        style: typography.code.copyWith(
                          fontSize: 10,
                          color: colors.foregroundMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
