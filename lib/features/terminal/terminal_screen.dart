import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:xterm/xterm.dart';
import '../../core/terminal/terminal_session.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/ssh_provider.dart';
import '../../providers/terminal_provider.dart';
import 'widgets/setu_terminal_view.dart';
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
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  int _searchMatchCount = 0;
  int _currentMatchIndex = 0;
  double _scaleBaseFontSize = 13.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _terminalFocus.dispose();
    _searchController.dispose();
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

  void _switchTab(int delta) {
    final sessions = ref.read(terminalSessionsProvider);
    final active = ref.read(activeTerminalSessionProvider);
    if (sessions.length <= 1 || active == null) return;

    final currentIndex = sessions.indexWhere((s) => s.id == active.id);
    if (currentIndex == -1) return;

    final newIndex = (currentIndex + delta) % sessions.length;
    final targetIndex = newIndex < 0 ? sessions.length - 1 : newIndex;
    ref.read(terminalSessionsProvider.notifier).setActive(sessions[targetIndex].id);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchMatchCount = 0;
        _currentMatchIndex = 0;
      });
      return;
    }
    // Search query match count approximation in visible buffer
    final active = ref.read(activeTerminalSessionProvider);
    if (active == null) return;

    int matches = 0;
    final buffer = active.terminal.buffer;
    for (int i = 0; i < buffer.lines.length; i++) {
      final lineText = buffer.lines[i].toString();
      if (lineText.toLowerCase().contains(query.toLowerCase())) {
        matches++;
      }
    }
    setState(() {
      _searchMatchCount = matches;
      _currentMatchIndex = matches > 0 ? 1 : 0;
    });
  }

  TerminalCursorType _getCursorType(String style) {
    switch (style) {
      case 'underline':
        return TerminalCursorType.underline;
      case 'bar':
        return TerminalCursorType.verticalBar;
      case 'block':
      default:
        return TerminalCursorType.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final sessions = ref.watch(terminalSessionsProvider);
    final activeSession = ref.watch(activeTerminalSessionProvider);
    final sshService = ref.watch(sshServiceProvider);
    final terminalSettings = ref.watch(terminalSettingsProvider);

    final terminalTheme = terminalSettings.theme.toTerminalTheme();
    final isDisconnected = activeSession != null &&
        activeSession.status != TerminalSessionStatus.connected;

    return Scaffold(
      backgroundColor: terminalSettings.theme.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
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
            Text(
              activeSession?.name ?? 'Terminal',
              style: typography.titleMedium,
            ),
          ],
        ),
        actions: [
          // Search in terminal button
          IconButton(
            icon: Icon(
              _isSearching ? Icons.search_off_rounded : Icons.search_rounded,
              size: 20,
              color: _isSearching ? colors.primary : colors.foregroundMuted,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchMatchCount = 0;
                }
              });
            },
            tooltip: 'Search Buffer',
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
            // Status bar if SSH disconnected
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
                onRenameSession: (id, newName) {
                  ref.read(terminalSessionsProvider.notifier).renameSession(id, newName);
                },
                onNewSession: () {
                  ref.read(terminalSessionsProvider.notifier).createSession();
                },
              ),

            // Search Bar Overlay
            if (_isSearching)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 18, color: colors.primary),
                    const Gap(8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: typography.bodySmall,
                        decoration: InputDecoration(
                          hintText: 'Find in terminal buffer...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: InputBorder.none,
                        ),
                        onChanged: _performSearch,
                      ),
                    ),
                    if (_searchMatchCount > 0)
                      Text(
                        '$_currentMatchIndex/$_searchMatchCount',
                        style: typography.code.copyWith(fontSize: 11, color: colors.foregroundMuted),
                      ),
                    const Gap(4),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
                      onPressed: _searchMatchCount > 0
                          ? () {
                              setState(() {
                                if (_currentMatchIndex > 1) _currentMatchIndex--;
                              });
                            }
                          : null,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      onPressed: _searchMatchCount > 0
                          ? () {
                              setState(() {
                                if (_currentMatchIndex < _searchMatchCount) _currentMatchIndex++;
                              });
                            }
                          : null,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                          _searchMatchCount = 0;
                        });
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

            // Reconnection Banner (if session ended or disconnected)
            if (isDisconnected && sshService.isConnected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: colors.warning.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    Icon(Icons.link_off_rounded, size: 16, color: colors.warning),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Session disconnected.',
                        style: typography.bodySmall.copyWith(color: colors.warning),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(terminalSessionsProvider.notifier).reconnect(activeSession.id);
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('Reconnect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.warning,
                        foregroundColor: const Color(0xFF0D1117),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                        textStyle: typography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: colors.surfaceVariant,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.border),
                              ),
                              child: Icon(Icons.terminal_rounded, size: 36, color: colors.foregroundMuted),
                            ),
                            const Gap(18),
                            Text('No Terminal Sessions', style: typography.titleMedium),
                            const Gap(8),
                            Text(
                              'Start a new shell session or attach to Tmux.',
                              textAlign: TextAlign.center,
                              style: typography.bodySmall.copyWith(color: colors.foregroundMuted),
                            ),
                            const Gap(24),
                            FilledButton.icon(
                              onPressed: () {
                                ref.read(terminalSessionsProvider.notifier).createSession();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: const Color(0xFF0D1117),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('New Terminal Session', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const Gap(10),
                            OutlinedButton.icon(
                              onPressed: _openTmuxSheet,
                              icon: const Icon(Icons.view_carousel_outlined, size: 16),
                              label: const Text('Attach Tmux Session'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : activeSession != null
                      ? GestureDetector(
                          onScaleStart: (_) {
                            _scaleBaseFontSize = terminalSettings.fontSize;
                          },
                          onScaleUpdate: (details) {
                            if (details.scale != 1.0) {
                              final newSize = (_scaleBaseFontSize * details.scale).clamp(9.0, 24.0);
                              ref.read(terminalSettingsProvider.notifier).setFontSize(
                                    double.parse(newSize.toStringAsFixed(1)),
                                  );
                            }
                          },
                          onHorizontalDragEnd: (details) {
                            // Swipe left / right to switch tabs
                            final vx = details.primaryVelocity ?? 0;
                            if (vx < -300) {
                              // Swipe left -> next tab
                              _switchTab(1);
                            } else if (vx > 300) {
                              // Swipe right -> previous tab
                              _switchTab(-1);
                            }
                          },
                          child: Container(
                            color: terminalSettings.theme.background,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: SetuTerminalView(
                              activeSession.terminal,
                              focusNode: _terminalFocus,
                              autofocus: true,
                              theme: terminalTheme,
                              backgroundOpacity: 1.0,
                              deleteDetection: true,
                              keyboardType: TextInputType.text,
                              cursorType: _getCursorType(terminalSettings.cursorStyle),
                              textStyle: TerminalStyle(
                                fontFamily: terminalSettings.fontFamily,
                                fontSize: terminalSettings.fontSize,
                                height: 1.3,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
            ),

            // Mobile Accessory Keyboard Toolbar
            if (activeSession != null)
              TerminalKeyboardToolbar(
                session: activeSession,
                colors: colors,
                typography: typography,
                onClear: () {
                  activeSession.terminal.eraseDisplay();
                },
              ),
          ],
        ),
      ),
    );
  }
}
