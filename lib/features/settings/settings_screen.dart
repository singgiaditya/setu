import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../core/terminal/terminal_theme_data.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/storage_provider.dart';
import '../../providers/terminal_provider.dart';
import '../../shared/constants/app_constants.dart';
import '../onboarding/widgets/feature_tour_sheet.dart';
import '../terminal/widgets/terminal_snippets_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late double _editorFontSize;
  late int _editorTabSize;
  late bool _editorLineNumbers;
  late bool _editorWordWrap;
  late bool _biometricEnabled;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesStoreProvider);
    _editorFontSize = prefs.editorFontSize;
    _editorTabSize = prefs.editorTabSize;
    _editorLineNumbers = prefs.editorLineNumbers;
    _editorWordWrap = prefs.editorWordWrap;
    _biometricEnabled = prefs.isBiometricEnabled;
  }

  void _showTerminalThemePicker(BuildContext context, WidgetRef ref) {
    final colors = ref.read(setuColorsProvider);
    final typography = ref.read(setuTypographyProvider);
    final currentThemeId = ref.read(terminalSettingsProvider).themeId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.65,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: colors.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.foregroundMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_outlined, color: colors.primary, size: 22),
                    const Gap(8),
                    Text('Terminal Theme', style: typography.titleMedium),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.foregroundMuted),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const Gap(12),
            Expanded(
              child: ListView.separated(
                itemCount: SetuTerminalTheme.allThemes.length,
                separatorBuilder: (_, _) => const Gap(8),
                itemBuilder: (context, index) {
                  final theme = SetuTerminalTheme.allThemes[index];
                  final isSelected = theme.id == currentThemeId;

                  return Material(
                    color: colors.surfaceVariant.withValues(alpha: isSelected ? 0.8 : 0.4),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        ref.read(terminalSettingsProvider.notifier).setTheme(theme.id);
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Theme Color Palette Swatch
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: theme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.border),
                              ),
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: theme.cursor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    theme.name,
                                    style: typography.titleSmall.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const Gap(4),
                                  Row(
                                    children: [
                                      _buildColorDot(theme.red),
                                      _buildColorDot(theme.green),
                                      _buildColorDot(theme.yellow),
                                      _buildColorDot(theme.blue),
                                      _buildColorDot(theme.magenta),
                                      _buildColorDot(theme.cyan),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: colors.primary, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final prefs = ref.read(preferencesStoreProvider);
    final terminalSettings = ref.watch(terminalSettingsProvider);

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
            Text('Settings', style: typography.titleMedium),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Section: Connection
          _buildSectionHeader('CONNECTION', colors, typography),
          _buildSettingsCard(
            colors: colors,
            children: [
              ListTile(
                leading: Icon(Icons.lan_outlined, color: colors.primary, size: 22),
                title: Text('Default Port', style: typography.bodyMedium),
                subtitle: Text('Default SSH port for new hosts', style: typography.bodySmall),
                trailing: Text('22', style: typography.code.copyWith(color: colors.foregroundMuted)),
              ),
              _buildDivider(colors),
              ListTile(
                leading: Icon(Icons.timer_outlined, color: colors.accent, size: 22),
                title: Text('Connection Timeout', style: typography.bodyMedium),
                subtitle: Text('Socket connection timeout limit', style: typography.bodySmall),
                trailing: Text('12s', style: typography.code.copyWith(color: colors.foregroundMuted)),
              ),
              _buildDivider(colors),
              ListTile(
                leading: Icon(Icons.sync_outlined, color: colors.success, size: 22),
                title: Text('Keep-Alive Interval', style: typography.bodyMedium),
                subtitle: Text('SSH heartbeat ping interval', style: typography.bodySmall),
                trailing: Text('25s', style: typography.code.copyWith(color: colors.foregroundMuted)),
              ),
            ],
          ),
          const Gap(24),

          // Section: Appearance
          _buildSectionHeader('APPEARANCE', colors, typography),
          _buildSettingsCard(
            colors: colors,
            children: [
              ListTile(
                leading: Icon(Icons.dark_mode_outlined, color: colors.primary, size: 22),
                title: Text('Theme', style: typography.bodyMedium),
                subtitle: Text('On|Bed Dark Mode (Dark only for now)', style: typography.bodySmall),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    'Dark',
                    style: typography.labelSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildDivider(colors),
              ListTile(
                leading: Icon(Icons.font_download_outlined, color: colors.secondary, size: 22),
                title: Text('Typography', style: typography.bodyMedium),
                subtitle: Text('Inter (UI) & JetBrains Mono (Code)', style: typography.bodySmall),
              ),
            ],
          ),
          const Gap(24),

          // Section: Editor
          _buildSectionHeader('EDITOR', colors, typography),
          _buildSettingsCard(
            colors: colors,
            children: [
              // Font Size Slider
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Font Size', style: typography.bodyMedium),
                        Text(
                          '${_editorFontSize.toStringAsFixed(1)} pt',
                          style: typography.code.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colors.primary,
                        inactiveTrackColor: colors.surfaceVariant,
                        thumbColor: colors.primary,
                        overlayColor: colors.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _editorFontSize,
                        min: 10.0,
                        max: 20.0,
                        divisions: 20,
                        onChanged: (val) {
                          setState(() => _editorFontSize = val);
                          prefs.setEditorFontSize(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildDivider(colors),

              // Tab Size Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tab Size', style: typography.bodyMedium),
                    const Gap(2),
                    Text('Indentation spaces count', style: typography.bodySmall),
                    const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 2, label: Text('2 spaces')),
                          ButtonSegment(value: 4, label: Text('4 spaces')),
                        ],
                        selected: {_editorTabSize},
                        onSelectionChanged: (newSelection) {
                          final val = newSelection.first;
                          setState(() => _editorTabSize = val);
                          prefs.setEditorTabSize(val);
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colors.primary.withValues(alpha: 0.2);
                            }
                            return colors.surfaceVariant;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colors.primary;
                            }
                            return colors.foregroundMuted;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildDivider(colors),

              // Line Numbers Switch
              SwitchListTile(
                secondary: Icon(Icons.format_list_numbered_rounded, color: colors.foregroundMuted, size: 22),
                title: Text('Line Numbers', style: typography.bodyMedium),
                subtitle: Text('Show gutter line numbers in editor', style: typography.bodySmall),
                value: _editorLineNumbers,
                activeTrackColor: colors.primary,
                onChanged: (val) {
                  setState(() => _editorLineNumbers = val);
                  prefs.setEditorLineNumbers(val);
                },
              ),
              _buildDivider(colors),

              // Word Wrap Switch
              SwitchListTile(
                secondary: Icon(Icons.wrap_text_rounded, color: colors.foregroundMuted, size: 22),
                title: Text('Word Wrap', style: typography.bodyMedium),
                subtitle: Text('Wrap long code lines to fit screen', style: typography.bodySmall),
                value: _editorWordWrap,
                activeTrackColor: colors.primary,
                onChanged: (val) {
                  setState(() => _editorWordWrap = val);
                  prefs.setEditorWordWrap(val);
                },
              ),
            ],
          ),
          const Gap(24),

          // Section: Terminal
          _buildSectionHeader('TERMINAL', colors, typography),
          _buildSettingsCard(
            colors: colors,
            children: [
              // Terminal Theme
              ListTile(
                leading: Icon(Icons.palette_outlined, color: colors.primary, size: 22),
                title: Text('Terminal Color Theme', style: typography.bodyMedium),
                subtitle: Text(terminalSettings.theme.name, style: typography.bodySmall),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showTerminalThemePicker(context, ref),
              ),
              _buildDivider(colors),

              // Terminal Font Size Slider
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Font Size', style: typography.bodyMedium),
                        Text(
                          '${terminalSettings.fontSize.toStringAsFixed(1)} pt',
                          style: typography.code.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colors.primary,
                        inactiveTrackColor: colors.surfaceVariant,
                        thumbColor: colors.primary,
                        overlayColor: colors.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: terminalSettings.fontSize,
                        min: 9.0,
                        max: 24.0,
                        divisions: 30,
                        onChanged: (val) {
                          ref.read(terminalSettingsProvider.notifier).setFontSize(
                                double.parse(val.toStringAsFixed(1)),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildDivider(colors),

              // Haptic Feedback Switch
              SwitchListTile(
                secondary: Icon(Icons.vibration_rounded, color: colors.accent, size: 22),
                title: Text('Haptic Feedback', style: typography.bodyMedium),
                subtitle: Text('Vibrate on keyboard toolbar key taps', style: typography.bodySmall),
                value: terminalSettings.hapticFeedback,
                activeTrackColor: colors.primary,
                onChanged: (val) {
                  ref.read(terminalSettingsProvider.notifier).setHapticFeedback(val);
                },
              ),
              _buildDivider(colors),

              // Cursor Style Segmented Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cursor Style', style: typography.bodyMedium),
                    const Gap(2),
                    Text('Terminal cursor shape', style: typography.bodySmall),
                    const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'block', label: Text('Block')),
                          ButtonSegment(value: 'underline', label: Text('Line')),
                          ButtonSegment(value: 'bar', label: Text('Bar')),
                        ],
                        selected: {terminalSettings.cursorStyle},
                        onSelectionChanged: (newSelection) {
                          ref.read(terminalSettingsProvider.notifier).setCursorStyle(newSelection.first);
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colors.primary.withValues(alpha: 0.2);
                            }
                            return colors.surfaceVariant;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return colors.primary;
                            }
                            return colors.foregroundMuted;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildDivider(colors),

              // Snippets Manager Tile
              ListTile(
                leading: Icon(Icons.bolt_rounded, color: colors.warning, size: 22),
                title: Text('Snippets & Quick Actions', style: typography.bodyMedium),
                subtitle: Text('Manage CLI command presets & macros', style: typography.bodySmall),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const TerminalSnippetsSheet(session: null),
                  );
                },
              ),
            ],
          ),
          const Gap(24),

          // Section: Security
          _buildSectionHeader('SECURITY', colors, typography),
          _buildSettingsCard(
            colors: colors,
            children: [
              SwitchListTile(
                secondary: Icon(Icons.fingerprint_rounded, color: colors.accent, size: 24),
                title: Text('Biometric Unlock', style: typography.bodyMedium),
                subtitle: Text('Require fingerprint or Face ID to open app', style: typography.bodySmall),
                value: _biometricEnabled,
                activeTrackColor: colors.primary,
                onChanged: (val) {
                  setState(() => _biometricEnabled = val);
                  prefs.setBiometricEnabled(val);
                },
              ),
            ],
          ),
          const Gap(24),

          // Section: Help & Guides
          _buildSectionHeader('HELP & GUIDES', colors, typography),
          _buildSettingsCard(
            colors: colors,
            children: [
              ListTile(
                leading: Icon(Icons.menu_book_rounded, color: colors.primary, size: 22),
                title: Text('Linux Workstation Setup Guide', style: typography.bodyMedium),
                subtitle: Text('Panduan setup OpenSSH, Tailscale, & firewall', style: typography.bodySmall),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/setup-guide'),
              ),
              _buildDivider(colors),
              ListTile(
                leading: Icon(Icons.explore_outlined, color: colors.accent, size: 22),
                title: Text('App Feature Tour', style: typography.bodyMedium),
                subtitle: Text('Putar ulang panduan fitur utama On|Bed', style: typography.bodySmall),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => FeatureTourSheet.show(context, colors, typography),
              ),
            ],
          ),
          const Gap(24),

          // Section: About
          _buildSectionHeader('ABOUT', colors, typography),
          _buildSettingsCard(
            colors: colors,
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text('On|Bed', style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('Your Machine, Even in Bed.', style: typography.bodySmall),
                trailing: Text('v${AppConstants.appVersion}', style: typography.code.copyWith(color: colors.foregroundMuted)),
              ),
              _buildDivider(colors),
              ListTile(
                title: Text('Platform', style: typography.bodySmall),
                subtitle: Text('Mobile Remote Development Client', style: typography.bodyMedium),
                trailing: Icon(Icons.terminal_rounded, color: colors.foregroundMuted, size: 20),
              ),
            ],
          ),
          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, SetuColors colors, SetuTypography typography) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: typography.labelSmall.copyWith(
          color: colors.foregroundMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required SetuColors colors,
    required List<Widget> children,
  }) {
    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDivider(SetuColors colors) {
    return Divider(
      height: 1,
      thickness: 1,
      color: colors.border.withValues(alpha: 0.6),
    );
  }
}
