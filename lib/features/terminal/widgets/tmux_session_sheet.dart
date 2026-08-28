import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../providers/terminal_provider.dart';

class TmuxSessionSheet extends ConsumerStatefulWidget {
  const TmuxSessionSheet({super.key});

  @override
  ConsumerState<TmuxSessionSheet> createState() => _TmuxSessionSheetState();
}

class _TmuxSessionSheetState extends ConsumerState<TmuxSessionSheet> {
  final _newSessionController = TextEditingController();

  @override
  void dispose() {
    _newSessionController.dispose();
    super.dispose();
  }

  void _createNewSession() {
    final name = _newSessionController.text.trim();
    if (name.isEmpty) return;

    ref.read(terminalSessionsProvider.notifier).createOrAttachTmux(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final tmuxAsync = ref.watch(tmuxSessionsProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.dashboard_customize_rounded, color: colors.primary, size: 22),
                  const Gap(8),
                  Text('tmux Sessions', style: typography.headlineSmall),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.foregroundMuted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Persistent sessions stay running on your workstation even if your phone disconnects.',
            style: typography.bodySmall,
          ),
          const Gap(16),

          // New Session Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSessionController,
                  style: typography.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'New session name (e.g. dev, api)',
                    prefixIcon: Icon(Icons.add_rounded, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const Gap(10),
              ElevatedButton(
                onPressed: _createNewSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: Text(
                  'Attach / New',
                  style: typography.labelMedium.copyWith(
                    color: const Color(0xFF0D1117),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),

          // List of Active tmux Sessions on Machine
          Text('Existing Workstation Sessions', style: typography.labelMedium),
          const Gap(8),
          tmuxAsync.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'No active tmux sessions found on workstation.',
                    style: typography.bodySmall,
                  ),
                );
              }
              return Column(
                children: sessions.map((s) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: s.isAttached ? colors.success : colors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              s.name,
                              style: typography.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              '(${s.windowsCount} window${s.windowsCount > 1 ? 's' : ''})',
                              style: typography.bodySmall,
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(terminalSessionsProvider.notifier).createOrAttachTmux(s.name);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.surface,
                            foregroundColor: colors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                            ),
                          ),
                          child: const Text('Attach'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, _) => Text(
              'Failed to check tmux: $err',
              style: typography.bodySmall.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
