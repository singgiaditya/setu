import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/theme_manager.dart';
import '../../shared/widgets/color_picker_dialog.dart';
import 'widgets/theme_mockup_preview.dart';

class CustomThemeEditorScreen extends ConsumerStatefulWidget {
  final CustomThemeModel? initialTheme;

  const CustomThemeEditorScreen({
    super.key,
    this.initialTheme,
  });

  @override
  ConsumerState<CustomThemeEditorScreen> createState() => _CustomThemeEditorScreenState();
}

class _CustomThemeEditorScreenState extends ConsumerState<CustomThemeEditorScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late SetuColors _editingColors;
  late bool _isDark;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final theme = widget.initialTheme;
    if (theme != null) {
      _nameController = TextEditingController(text: theme.name);
      _editingColors = theme.colors;
      _isDark = theme.isDark;
    } else {
      final currentColors = ref.read(setuColorsProvider);
      _nameController = TextEditingController(text: 'My Custom Theme');
      _editingColors = currentColors;
      _isDark = true;
    }
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _pickTokenColor(String tokenName, Color currentColor, Function(Color) onColorPicked) async {
    final colors = ref.read(setuColorsProvider);
    final picked = await ColorPickerDialog.show(
      context,
      title: 'Pilih Warna: $tokenName',
      initialColor: currentColor,
      appColors: colors,
    );
    if (picked != null && mounted) {
      setState(() {
        onColorPicked(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.initialTheme == null ? 'Create Custom Theme' : 'Edit Custom Theme',
          style: typography.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Save & Apply',
            onPressed: _saveTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Live Preview Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ThemeMockupPreview(
              colors: _editingColors,
              isDark: _isDark,
            ),
          ),

          // 2. Name & Mode Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'THEME NAME',
                      labelStyle: TextStyle(fontSize: 11, color: appColors.foregroundMuted),
                      prefixIcon: const Icon(Icons.title_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: appColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        size: 16,
                        color: appColors.primary,
                      ),
                      const Gap(6),
                      Text(
                        _isDark ? 'Dark' : 'Light',
                        style: TextStyle(fontSize: 12, color: appColors.foreground),
                      ),
                      Switch(
                        value: _isDark,
                        activeThumbColor: appColors.primary,
                        onChanged: (v) => setState(() => _isDark = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),

          // 3. Category Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: appColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: appColors.border),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: appColors.primary,
              unselectedLabelColor: appColors.foregroundMuted,
              indicatorColor: appColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'General UI (14)'),
                Tab(text: 'Editor (5)'),
                Tab(text: 'Terminal (4)'),
              ],
            ),
          ),
          const Gap(8),

          // 4. Color Tokens List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: General UI Tokens
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildColorTile('Background', 'Main background of screens and scafolds', _editingColors.background,
                        (c) => _editingColors = _editingColors.copyWith(background: c), appColors, typography),
                    _buildColorTile('Surface', 'Cards, dialogs, bottom sheets, and app bars', _editingColors.surface,
                        (c) => _editingColors = _editingColors.copyWith(surface: c), appColors, typography),
                    _buildColorTile('Surface Variant', 'Input fields, active chips, and subtle containers', _editingColors.surfaceVariant,
                        (c) => _editingColors = _editingColors.copyWith(surfaceVariant: c), appColors, typography),
                    _buildColorTile('Text / Foreground', 'Primary titles, headings, and body labels', _editingColors.foreground,
                        (c) => _editingColors = _editingColors.copyWith(foreground: c), appColors, typography),
                    _buildColorTile('Muted Text', 'Subtitles, hints, timestamps, and secondary info', _editingColors.foregroundMuted,
                        (c) => _editingColors = _editingColors.copyWith(foregroundMuted: c), appColors, typography),
                    _buildColorTile('Border Color', 'Card outlines, dividers, and container borders', _editingColors.border,
                        (c) => _editingColors = _editingColors.copyWith(border: c), appColors, typography),
                    _buildColorTile('Primary Accent', 'Brand highlight, primary buttons, active icons', _editingColors.primary,
                        (c) => _editingColors = _editingColors.copyWith(primary: c), appColors, typography),
                    _buildColorTile('Secondary Accent', 'Secondary buttons, badges, subtle highlights', _editingColors.secondary,
                        (c) => _editingColors = _editingColors.copyWith(secondary: c), appColors, typography),
                    _buildColorTile('Accent Color', 'Interactive links, highlights, special badges', _editingColors.accent,
                        (c) => _editingColors = _editingColors.copyWith(accent: c), appColors, typography),
                    _buildColorTile('Success Color', 'Online status, connected indicators, git adds', _editingColors.success,
                        (c) => _editingColors = _editingColors.copyWith(success: c), appColors, typography),
                    _buildColorTile('Warning Color', 'Warning alerts, unsaved changes, caution badges', _editingColors.warning,
                        (c) => _editingColors = _editingColors.copyWith(warning: c), appColors, typography),
                    _buildColorTile('Error / Danger', 'Errors, failed connections, delete actions', _editingColors.error,
                        (c) => _editingColors = _editingColors.copyWith(error: c), appColors, typography),
                    _buildColorTile('Info Color', 'Information banners, tips, and helper tooltips', _editingColors.info,
                        (c) => _editingColors = _editingColors.copyWith(info: c), appColors, typography),
                    _buildColorTile('Selection Color', 'Text highlight and list item selected state', _editingColors.selection,
                        (c) => _editingColors = _editingColors.copyWith(selection: c), appColors, typography),
                  ],
                ),

                // Tab 2: Code Editor Tokens
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildColorTile('Editor Background', 'Background canvas of the code editor', _editingColors.editorBackground,
                        (c) => _editingColors = _editingColors.copyWith(editorBackground: c), appColors, typography),
                    _buildColorTile('Editor Foreground', 'Default code text color', _editingColors.editorForeground,
                        (c) => _editingColors = _editingColors.copyWith(editorForeground: c), appColors, typography),
                    _buildColorTile('Line Numbers', 'Gutter and line numbers font color', _editingColors.editorLineNumber,
                        (c) => _editingColors = _editingColors.copyWith(editorLineNumber: c), appColors, typography),
                    _buildColorTile('Current Line Highlight', 'Background bar of the currently active line', _editingColors.editorCurrentLine,
                        (c) => _editingColors = _editingColors.copyWith(editorCurrentLine: c), appColors, typography),
                    _buildColorTile('Editor Selection', 'Highlighted selected code text block', _editingColors.editorSelection,
                        (c) => _editingColors = _editingColors.copyWith(editorSelection: c), appColors, typography),
                  ],
                ),

                // Tab 3: Terminal Tokens
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildColorTile('Terminal Background', 'PTY terminal window background', _editingColors.terminalBackground,
                        (c) => _editingColors = _editingColors.copyWith(terminalBackground: c), appColors, typography),
                    _buildColorTile('Terminal Text', 'Standard terminal font color', _editingColors.terminalForeground,
                        (c) => _editingColors = _editingColors.copyWith(terminalForeground: c), appColors, typography),
                    _buildColorTile('Terminal Cursor', 'Cursor block, bar, or underline color', _editingColors.terminalCursor,
                        (c) => _editingColors = _editingColors.copyWith(terminalCursor: c), appColors, typography),
                    _buildColorTile('Terminal Selection', 'Selected text in terminal buffer', _editingColors.terminalSelection,
                        (c) => _editingColors = _editingColors.copyWith(terminalSelection: c), appColors, typography),
                  ],
                ),
              ],
            ),
          ),

          // 5. Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: appColors.surface,
              border: Border(top: BorderSide(color: appColors.border)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveTheme,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.primary,
                  foregroundColor: appColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  widget.initialTheme == null ? 'Save & Apply Theme' : 'Update & Apply Theme',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTile(
    String label,
    String description,
    Color currentColor,
    Function(Color) onColorPicked,
    SetuColors appColors,
    SetuTypography typography,
  ) {
    final hexString = SetuColors.colorToHex(currentColor, includeHash: true);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Text(
          label,
          style: typography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: appColors.foreground,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          description,
          style: typography.bodySmall.copyWith(
            color: appColors.foregroundMuted,
            fontSize: 11,
          ),
        ),
        trailing: InkWell(
          onTap: () => _pickTokenColor(label, currentColor, onColorPicked),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: appColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: appColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: appColors.border, width: 1.5),
                  ),
                ),
                const Gap(8),
                Text(
                  hexString,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveTheme() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tema tidak boleh kosong!'), backgroundColor: Colors.red),
      );
      return;
    }

    final themeId = widget.initialTheme?.id ?? const Uuid().v4();
    final theme = CustomThemeModel(
      id: themeId,
      name: name,
      colors: _editingColors,
      isDark: _isDark,
      createdAt: widget.initialTheme?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(customThemesProvider.notifier).saveTheme(theme);
    ref.read(themeProvider.notifier).applyCustomTheme(theme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tema "$name" berhasil disimpan dan diterapkan!')),
    );
    context.pop();
  }
}
