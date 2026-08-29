import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/theme_colors.dart';

class ThemeMockupPreview extends StatefulWidget {
  final SetuColors colors;
  final bool isDark;

  const ThemeMockupPreview({
    super.key,
    required this.colors,
    this.isDark = true,
  });

  @override
  State<ThemeMockupPreview> createState() => _ThemeMockupPreviewState();
}

class _ThemeMockupPreviewState extends State<ThemeMockupPreview> {
  int _selectedTab = 0; // 0: App UI, 1: Terminal, 2: Code Editor

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview Header with Mini Segmented Control
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                    const Gap(6),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                    const Gap(6),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                    const Gap(10),
                    Text(
                      'LIVE PREVIEW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colors.foregroundMuted,
                      ),
                    ),
                  ],
                ),
                // Tabs
                Row(
                  children: [
                    _buildTabButton('UI', 0, colors),
                    const Gap(4),
                    _buildTabButton('Terminal', 1, colors),
                    const Gap(4),
                    _buildTabButton('Editor', 2, colors),
                  ],
                ),
              ],
            ),
          ),

          // Preview Canvas
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              key: ValueKey(_selectedTab),
              height: 180,
              child: _buildTabContent(colors),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, SetuColors colors) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colors.primary : colors.foregroundMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(SetuColors colors) {
    switch (_selectedTab) {
      case 0:
        return _buildUiPreview(colors);
      case 1:
        return _buildTerminalPreview(colors);
      case 2:
        return _buildEditorPreview(colors);
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. App UI Preview
  Widget _buildUiPreview(SetuColors colors) {
    return Container(
      color: colors.background,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'On|Bed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: colors.success.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'ONLINE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: colors.success,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(Icons.more_horiz_rounded, size: 18, color: colors.foregroundMuted),
            ],
          ),
          const Gap(10),

          // Main Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.computer_rounded, size: 18, color: colors.primary),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'arch-omarchy-dev',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.foreground,
                        ),
                      ),
                      Text(
                        '100.84.22.10 • 14ms latency',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.foregroundMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colors.background,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),

          // Action Chips Row
          Row(
            children: [
              _buildChip('Terminal', Icons.terminal, colors.primary, colors),
              const Gap(6),
              _buildChip('Files', Icons.folder, colors.accent, colors),
              const Gap(6),
              _buildChip('Neovim', Icons.code, colors.secondary, colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color accentColor, SetuColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accentColor),
          const Gap(4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colors.foreground),
          ),
        ],
      ),
    );
  }

  // 2. Terminal Preview
  Widget _buildTerminalPreview(SetuColors colors) {
    return Container(
      color: colors.terminalBackground,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'omarchy@workstation',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              Text(
                ':',
                style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: colors.foregroundMuted),
              ),
              Text(
                '~/projects/onbed',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: colors.accent,
                ),
              ),
              Text(
                '\$ git status',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: colors.terminalForeground,
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            'On branch main',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: colors.foregroundMuted,
            ),
          ),
          Text(
            'Your branch is up to date with \'origin/main\'.',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: colors.success,
            ),
          ),
          const Gap(4),
          Row(
            children: [
              Text(
                'omarchy@workstation:\$ nvim app.dart ',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: colors.terminalForeground,
                ),
              ),
              Container(
                width: 7,
                height: 14,
                color: colors.terminalCursor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Code Editor Preview
  Widget _buildEditorPreview(SetuColors colors) {
    return Container(
      color: colors.editorBackground,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditorLine('1', 'void main() async {', colors),
          _buildEditorLine('2', '  final client = OnBedClient();', colors, highlight: true),
          _buildEditorLine('3', '  await client.connect();', colors),
          _buildEditorLine('4', '  print("Connected to Workstation!");', colors),
          _buildEditorLine('5', '}', colors),
        ],
      ),
    );
  }

  Widget _buildEditorLine(String lineNo, String code, SetuColors colors, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: highlight ? colors.editorCurrentLine : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              lineNo,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                color: highlight ? colors.primary : colors.editorLineNumber,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              code,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                color: colors.editorForeground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
