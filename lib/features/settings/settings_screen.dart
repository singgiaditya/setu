import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/storage_provider.dart';

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
  late double _terminalFontSize;
  late bool _biometricEnabled;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesStoreProvider);
    _editorFontSize = prefs.editorFontSize;
    _editorTabSize = prefs.editorTabSize;
    _editorLineNumbers = prefs.editorLineNumbers;
    _editorWordWrap = prefs.editorWordWrap;
    _terminalFontSize = prefs.terminalFontSize;
    _biometricEnabled = prefs.isBiometricEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final prefs = ref.read(preferencesStoreProvider);

    return Scaffold(
      backgroundColor: colors.background,
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
                subtitle: Text('SETU Dark Mode (Dark only for now)', style: typography.bodySmall),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tab Size', style: typography.bodyMedium),
                        Text('Indentation spaces count', style: typography.bodySmall),
                      ],
                    ),
                    SegmentedButton<int>(
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
                          '${_terminalFontSize.toStringAsFixed(1)} pt',
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
                        value: _terminalFontSize,
                        min: 10.0,
                        max: 20.0,
                        divisions: 20,
                        onChanged: (val) {
                          setState(() => _terminalFontSize = val);
                          prefs.setTerminalFontSize(val);
                        },
                      ),
                    ),
                  ],
                ),
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

          // Section: About
          _buildSectionHeader('ABOUT', colors, typography),
          _buildSettingsCard(
            colors: colors,
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'S',
                    style: typography.brandSmall.copyWith(color: colors.primary),
                  ),
                ),
                title: Text('SETU', style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('Your Machine, Anywhere.', style: typography.bodySmall),
                trailing: Text('v0.1.0', style: typography.code.copyWith(color: colors.foregroundMuted)),
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
