import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_manager.dart';
import 'data/setup_guide_data.dart';
import 'models/setup_guide_step.dart';
import 'widgets/setup_step_card.dart';

class SetupGuideScreen extends ConsumerStatefulWidget {
  final SetupCategory? initialCategory;

  const SetupGuideScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<SetupGuideScreen> createState() => _SetupGuideScreenState();
}

class _SetupGuideScreenState extends ConsumerState<SetupGuideScreen> {
  SetupCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String code, SetuColors colors) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF3FB950), size: 18),
            Gap(8),
            Text('Perintah berhasil disalin ke clipboard!'),
          ],
        ),
        backgroundColor: colors.surface,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);

    final filteredSteps = SetupGuideData.steps.where((step) {
      if (_selectedCategory != null &&
          _selectedCategory != SetupCategory.troubleshooting &&
          step.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = step.title.toLowerCase().contains(q);
        final matchDesc = step.description.toLowerCase().contains(q);
        final matchCode = (step.codeSnippet ?? '').toLowerCase().contains(q);
        return matchTitle || matchDesc || matchCode;
      }
      return true;
    }).toList();

    final showFaq = _selectedCategory == null ||
        _selectedCategory == SetupCategory.troubleshooting ||
        _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text('SETU', style: typography.brandSmall.copyWith(color: colors.primary)),
            const Gap(8),
            Container(width: 4, height: 4, decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle)),
            const Gap(8),
            Text('Setup Guide', style: typography.titleMedium),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: typography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Cari panduan (misal: openssh, tailscale, ufw)...',
                  hintStyle: typography.bodySmall,
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.foregroundMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),

            // Category Filter Chips
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Semua'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = null);
                      },
                      selectedColor: colors.primary.withValues(alpha: 0.2),
                      backgroundColor: colors.surface,
                      labelStyle: typography.labelSmall.copyWith(
                        color: _selectedCategory == null ? colors.primary : colors.foregroundMuted,
                        fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: _selectedCategory == null ? colors.primary : colors.border,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  ...SetupCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: Icon(cat.icon, size: 14, color: isSelected ? colors.primary : colors.foregroundMuted),
                        label: Text(cat.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = selected ? cat : null);
                        },
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        backgroundColor: colors.surface,
                        labelStyle: typography.labelSmall.copyWith(
                          color: isSelected ? colors.primary : colors.foregroundMuted,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? colors.primary : colors.border,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Gap(6),

            // Main Guide Content List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Banner Header if All
                  if (_selectedCategory == null && _searchQuery.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primary.withValues(alpha: 0.15),
                            colors.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.laptop_chromebook_rounded, color: colors.primary, size: 28),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Siapkan Workstation Linux Anda',
                                  style: typography.titleSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.foreground,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  'Ikuti 3 langkah cepat di bawah ini untuk menghubungkan PC/laptop Anda ke SETU.',
                                  style: typography.bodySmall.copyWith(
                                    color: colors.foregroundMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Steps List
                  if (_selectedCategory != SetupCategory.troubleshooting)
                    ...filteredSteps.map((step) => SetupStepCard(
                          step: step,
                          colors: colors,
                          typography: typography,
                        )),

                  // FAQ / Troubleshooting Section
                  if (showFaq) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.help_outline_rounded, color: colors.warning, size: 20),
                          const Gap(8),
                          Text(
                            'TROUBLESHOOTING & FAQ',
                            style: typography.labelSmall.copyWith(
                              letterSpacing: 1.2,
                              color: colors.foregroundMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...SetupGuideData.faqs.map((faq) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.border),
                          ),
                          child: ExpansionTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            leading: const Icon(Icons.error_outline_rounded, color: Color(0xFFF85149), size: 20),
                            title: Text(
                              faq.question,
                              style: typography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.foreground,
                              ),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kemungkinan Penyebab:',
                                      style: typography.labelSmall.copyWith(color: colors.foregroundMuted, fontWeight: FontWeight.bold),
                                    ),
                                    const Gap(2),
                                    Text(faq.cause, style: typography.bodySmall),
                                    const Gap(8),
                                    Text(
                                      'Solusi:',
                                      style: typography.labelSmall.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
                                    ),
                                    const Gap(2),
                                    Text(faq.solutionExplanation, style: typography.bodySmall),
                                    if (faq.solutionSnippet != null) ...[
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF090D13),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: colors.border),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                faq.solutionSnippet!,
                                                style: typography.code.copyWith(fontSize: 11, color: const Color(0xFF58A6FF)),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.copy_rounded, size: 14),
                                              color: colors.primary,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () => _copyToClipboard(context, faq.solutionSnippet!, colors),
                                              tooltip: 'Salin Solusi',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  const Gap(32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.foreground,
                    side: BorderSide(color: colors.border),
                  ),
                  child: const Text('Tutup Panduan'),
                ),
              ),
              const Gap(12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.pop();
                    context.go('/connect');
                  },
                  icon: const Icon(Icons.add_link_rounded, size: 18),
                  label: const Text('Buka Koneksi'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: const Color(0xFF0D1117),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
