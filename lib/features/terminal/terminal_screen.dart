import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:xterm/xterm.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/ssh_provider.dart';
import '../../providers/terminal_provider.dart';
import 'widgets/terminal_keyboard_toolbar.dart';
import 'widgets/terminal_tab_bar.dart';
import 'widgets/tmux_session_sheet.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  final FocusNode _terminalFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSessionExists();
    });
  }

  void _ensureSessionExists() {
    final sessions = ref.read(terminalSessionsProvider);
    if (sessions.isEmpty) {
      ref.read(terminalSessionsProvider.notifier).createSession(name: 'main');
    }
  }

  @override
  void dispose() {
    _terminalFocus.dispose();
    super.dispose();
  }

  void _openTmuxSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TmuxSessionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final sessions = ref.watch(terminalSessionsProvider);
    final activeSession = ref.watch(activeTerminalSessionProvider);
    final sshService = ref.watch(sshServiceProvider);

    return Scaffold(
      backgroundColor: colors.terminalBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Text('SETU', style: typography.brandSmall.copyWith(color: colors.primary)),
            const Gap(8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle),
            ),
            const Gap(8),
            Text(
              activeSession?.name ?? 'Terminal',
              style: typography.titleMedium,
            ),
          ],
        ),
        actions: [
          // tmux session manager button
          TextButton.icon(
            onPressed: _openTmuxSheet,
            icon: Icon(Icons.dashboard_customize_rounded, size: 16, color: colors.accent),
            label: Text(
              'tmux',
              style: typography.labelSmall.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          IconButton(
            icon: Icon(Icons.cleaning_services_rounded, size: 18, color: colors.foregroundMuted),
            onPressed: () {
              activeSession?.terminal.eraseDisplay();
            },
            tooltip: 'Clear Terminal',
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, size: 20, color: colors.primary),
            onPressed: () {
              ref.read(terminalSessionsProvider.notifier).createSession();
            },
            tooltip: 'New Session',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar if disconnected
            if (!sshService.isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                color: colors.warning.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: colors.warning),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Workstation offline. Connect in Workstations tab.',
                        style: typography.bodySmall.copyWith(color: colors.warning),
                      ),
                    ),
                  ],
                ),
              ),

            // Tab bar for sessions
            if (sessions.isNotEmpty)
              TerminalTabBar(
                sessions: sessions,
                activeSession: activeSession,
                colors: colors,
                typography: typography,
                onSelectSession: (id) {
                  ref.read(terminalSessionsProvider.notifier).setActive(id);
                },
                onCloseSession: (id) {
                  ref.read(terminalSessionsProvider.notifier).closeSession(id);
                },
                onNewSession: () {
                  ref.read(terminalSessionsProvider.notifier).createSession();
                },
              ),

            // Main Terminal View
            Expanded(
              child: activeSession != null
                  ? Container(
                      color: colors.terminalBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: TerminalView(
                        activeSession.terminal,
                        focusNode: _terminalFocus,
                        autofocus: true,
                        backgroundOpacity: 1.0,
                        textStyle: TerminalStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.terminal_rounded, size: 48, color: colors.foregroundMuted),
                          const Gap(12),
                          Text('No active terminal sessions', style: typography.headlineSmall),
                          const Gap(16),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(terminalSessionsProvider.notifier).createSession();
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Open Terminal'),
                          ),
                        ],
                      ),
                    ),
            ),

            // Mobile Accessory Keyboard Toolbar
            TerminalKeyboardToolbar(
              session: activeSession,
              colors: colors,
              typography: typography,
              onClear: () {
                activeSession?.terminal.eraseDisplay();
              },
            ),
          ],
        ),
      ),
    );
  }
}
