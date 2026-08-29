import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/theme_manager.dart';
import 'widgets/theme_mockup_preview.dart';

class ThemeSelectionScreen extends ConsumerStatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ConsumerState<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends ConsumerState<ThemeSelectionScreen> {
  ThemePreset? _previewPreset;
  CustomThemeModel? _previewCustom;

  SetuColors _getPreviewColors(ThemeState currentTheme) {
    if (_previewPreset != null) return _previewPreset!.colors;
    if (_previewCustom != null) return _previewCustom!.colors;
    return currentTheme.colors;
  }

  bool _getPreviewIsDark(ThemeState currentTheme) {
    if (_previewPreset != null) return _previewPreset!.isDark;
    if (_previewCustom != null) return _previewCustom!.isDark;
    return currentTheme.isDark;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final colors = themeState.colors;
    final typography = themeState.typography;
    final customThemes = ref.watch(customThemesProvider);

    final previewColors = _getPreviewColors(themeState);
    final previewIsDark = _getPreviewIsDark(themeState);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text('On|Bed', style: typography.brandSmall.copyWith(color: colors.primary)),
            const Gap(8),
            Container(width: 4, height: 4, decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle)),
            const Gap(8),
            Text('Themes & Colors', style: typography.titleMedium),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Live Interactive Mockup
          ThemeMockupPreview(
            colors: previewColors,
            isDark: previewIsDark,
          ),
          const Gap(24),

          // 2. Built-in Presets Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BUILT-IN PRESETS',
                style: typography.labelSmall.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: colors.foregroundMuted,
                ),
              ),
              Text(
                '${BuiltInThemes.all.length} Themes',
                style: typography.bodySmall.copyWith(color: colors.foregroundMuted),
              ),
            ],
          ),
          const Gap(12),

          // Presets Grid
          ...BuiltInThemes.all.map((preset) {
            final isActive = !themeState.isCustom && themeState.themeId == preset.id;
            final isPreviewing = _previewPreset?.id == preset.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildPresetCard(
                preset: preset,
                isActive: isActive,
                isPreviewing: isPreviewing,
                colors: colors,
                typography: typography,
              ),
            );
          }),
          const Gap(16),

          // 3. Custom Themes Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CUSTOM THEMES',
                style: typography.labelSmall.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: colors.foregroundMuted,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _showImportDialog,
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Import', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Gap(8),
                  TextButton.icon(
                    onPressed: () => context.push('/themes/edit'),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Create New', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(12),

          // Custom Themes List / Empty State
          if (customThemes.isEmpty)
            _buildCustomEmptyState(colors, typography)
          else
            ...customThemes.map((customTheme) {
              final isActive = themeState.isCustom && themeState.themeId == customTheme.id;
              final isPreviewing = _previewCustom?.id == customTheme.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildCustomThemeCard(
                  customTheme: customTheme,
                  isActive: isActive,
                  isPreviewing: isPreviewing,
                  colors: colors,
                  typography: typography,
                ),
              );
            }),

          const Gap(32),
        ],
      ),
    );
  }

  // Preset Theme Card
  Widget _buildPresetCard({
    required ThemePreset preset,
    required bool isActive,
    required bool isPreviewing,
    required SetuColors colors,
    required SetuTypography typography,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _previewPreset = preset;
          _previewCustom = null;
        });
        ref.read(themeProvider.notifier).applyPreset(preset);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? colors.primary : colors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Swatch Preview circles
            _buildColorSwatchRow(preset.colors),
            const Gap(14),

            // Theme Name & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        preset.name,
                        style: typography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.foreground,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: preset.isDark
                              ? colors.surfaceVariant
                              : const Color(0xFFEFF1F5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          preset.isDark ? 'DARK' : 'LIGHT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: preset.isDark ? colors.foregroundMuted : const Color(0xFF4C4F69),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(2),
                  Text(
                    preset.description,
                    style: typography.bodySmall.copyWith(
                      color: colors.foregroundMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Gap(8),

            // Active Badge or Duplicate Button
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.primary),
                ),
                child: Text(
                  'Active',
                  style: typography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'Duplicate as Custom Theme',
                onPressed: () => _duplicatePreset(preset),
              ),
          ],
        ),
      ),
    );
  }

  // Custom Theme Card
  Widget _buildCustomThemeCard({
    required CustomThemeModel customTheme,
    required bool isActive,
    required bool isPreviewing,
    required SetuColors colors,
    required SetuTypography typography,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _previewCustom = customTheme;
          _previewPreset = null;
        });
        ref.read(themeProvider.notifier).applyCustomTheme(customTheme);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? colors.primary : colors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            _buildColorSwatchRow(customTheme.colors),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        customTheme.name,
                        style: typography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.foreground,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          customTheme.isDark ? 'CUSTOM DARK' : 'CUSTOM LIGHT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(2),
                  Text(
                    'Tap to apply • Customized theme',
                    style: typography.bodySmall.copyWith(
                      color: colors.foregroundMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),

            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.primary),
                ),
                child: Text(
                  'Active',
                  style: typography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Popup Actions Menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 20, color: colors.foregroundMuted),
              onSelected: (val) {
                switch (val) {
                  case 'apply':
                    ref.read(themeProvider.notifier).applyCustomTheme(customTheme);
                    break;
                  case 'edit':
                    context.push('/themes/edit', extra: customTheme);
                    break;
                  case 'duplicate':
                    _duplicateCustomTheme(customTheme);
                    break;
                  case 'export':
                    _exportTheme(customTheme);
                    break;
                  case 'delete':
                    _confirmDelete(customTheme);
                    break;
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'apply',
                  child: Row(children: [Icon(Icons.check_circle_outline, size: 18), Gap(10), Text('Apply Theme')]),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [Icon(Icons.edit_outlined, size: 18), Gap(10), Text('Edit Colors')]),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(children: [Icon(Icons.copy_outlined, size: 18), Gap(10), Text('Duplicate')]),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(children: [Icon(Icons.share_outlined, size: 18), Gap(10), Text('Export JSON')]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), Gap(10), Text('Delete', style: TextStyle(color: Colors.red))]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4 Dots Swatch Row
  Widget _buildColorSwatchRow(SetuColors c) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSwatchCircle(c.surface),
              _buildSwatchCircle(c.primary),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSwatchCircle(c.accent),
              _buildSwatchCircle(c.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwatchCircle(Color col) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: col,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCustomEmptyState(SetuColors colors, SetuTypography typography) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.palette_outlined, size: 36, color: colors.foregroundMuted),
          const Gap(10),
          Text(
            'Belum Ada Tema Custom',
            style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(4),
          Text(
            'Buat tema sendiri dengan mengkustomisasi setiap token warna atau import dari preset.',
            style: typography.bodySmall.copyWith(color: colors.foregroundMuted),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          ElevatedButton.icon(
            onPressed: () => context.push('/themes/edit'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Buat Tema Custom Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.background,
            ),
          ),
        ],
      ),
    );
  }

  void _duplicatePreset(ThemePreset preset) {
    final newTheme = CustomThemeModel(
      id: const Uuid().v4(),
      name: '${preset.name} (Copy)',
      colors: preset.colors,
      isDark: preset.isDark,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ref.read(customThemesProvider.notifier).saveTheme(newTheme);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tema "${newTheme.name}" berhasil dibuat di Custom Themes!')),
    );
  }

  void _duplicateCustomTheme(CustomThemeModel customTheme) {
    final newTheme = customTheme.copyWith(
      id: const Uuid().v4(),
      name: '${customTheme.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ref.read(customThemesProvider.notifier).saveTheme(newTheme);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tema "${newTheme.name}" berhasil diduplikasi!')),
    );
  }

  void _confirmDelete(CustomThemeModel customTheme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus "${customTheme.name}"?'),
        content: const Text('Tema custom ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(customThemesProvider.notifier).deleteTheme(customTheme.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportTheme(CustomThemeModel customTheme) {
    final jsonStr = jsonEncode(customTheme.toJson());
    Clipboard.setData(ClipboardData(text: jsonStr));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Export "${customTheme.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('JSON konfigurasi tema telah disalin ke clipboard! Anda dapat membagikannya kepada pengguna lain.'),
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                jsonStr,
                style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Theme JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tempel kode JSON konfigurasi tema On|Bed di bawah ini:'),
            const Gap(12),
            TextField(
              controller: controller,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11),
              decoration: InputDecoration(
                hintText: '{\n  "name": "My Theme",\n  "colors": { ... }\n}',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste_rounded),
                  tooltip: 'Paste from Clipboard',
                  onPressed: () async {
                    final d = await Clipboard.getData('text/plain');
                    if (d?.text != null) controller.text = d!.text!;
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final map = jsonDecode(controller.text.trim()) as Map<String, dynamic>;
                final theme = CustomThemeModel.fromJson({
                  ...map,
                  'id': map['id'] ?? const Uuid().v4(),
                  'name': map['name'] ?? 'Imported Theme',
                  'colors': map['colors'] ?? map,
                });
                ref.read(customThemesProvider.notifier).saveTheme(theme);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tema "${theme.name}" berhasil diimport!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Format JSON tidak valid: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Import & Simpan'),
          ),
        ],
      ),
    );
  }
}
