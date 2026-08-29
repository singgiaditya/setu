import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/theme_manager.dart';

class FeatureTourItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<String> highlights;

  const FeatureTourItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.highlights,
  });
}

class FeatureTourSheet extends StatefulWidget {
  final SetuColors colors;
  final SetuTypography typography;
  final VoidCallback? onFinish;

  const FeatureTourSheet({
    super.key,
    required this.colors,
    required this.typography,
    this.onFinish,
  });

  static void show(BuildContext context, SetuColors colors, SetuTypography typography, {VoidCallback? onFinish}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FeatureTourSheet(
        colors: colors,
        typography: typography,
        onFinish: onFinish,
      ),
    );
  }

  @override
  State<FeatureTourSheet> createState() => _FeatureTourSheetState();
}

class _FeatureTourSheetState extends State<FeatureTourSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<FeatureTourItem> _tourItems = [
    FeatureTourItem(
      title: 'Workstation Remote SSH',
      subtitle: 'Koneksi Langsung & Tailscale VPN',
      description:
          'Hubungkan HP Anda langsung ke laptop atau server Linux via Direct IP atau Tailscale MagicDNS. Kredensial dan private key tersimpan aman di Android Keystore.',
      icon: Icons.hub_rounded,
      accentColor: Color(0xFF58A6FF),
      highlights: ['Tailscale MagicDNS', 'Biometric Keystore', 'Zero Cloud Dependency'],
    ),
    FeatureTourItem(
      title: 'Workspace-Centric Hub',
      subtitle: 'Lingkungan Kerja Terisolasi',
      description:
          'Kelola project Anda dalam Workspace mandiri. File Explorer dan Terminal otomatis masuk ke folder root project Anda tanpa perlu mengetik cd manual.',
      icon: Icons.folder_special_rounded,
      accentColor: Color(0xFF3FB950),
      highlights: ['Auto cd Remote Path', 'Scoped File Explorer', 'Workspace Snippets'],
    ),
    FeatureTourItem(
      title: 'Termius-Grade Terminal',
      subtitle: 'Ergonomi Keyboard Mobile Lengkap',
      description:
          'Dilengkapi Sticky Modifier (CTRL/ALT), Virtual D-Pad navigasi untuk Vim/Nano/Neovim, baris tombol fungsi F1–F12, pinch-to-zoom ukuran font, dan pencarian buffer.',
      icon: Icons.terminal_rounded,
      accentColor: Color(0xFFD29922),
      highlights: ['Sticky CTRL & ALT', 'Virtual D-Pad Modal', 'Vim / Neovim Ready'],
    ),
    FeatureTourItem(
      title: 'VS Code Git Suite',
      subtitle: 'Kontrol Versi Visual Lengkap',
      description:
          'Lihat perubahan kode baris-demi-baris dengan visual unified diff viewer, stage & unstage file, commit & push, serta switch dan checkout branch langsung dari HP.',
      icon: Icons.alt_route_rounded,
      accentColor: Color(0xFFBC8CFF),
      highlights: ['Visual Unified Diff', 'Branch Switcher', 'Commit & Push 1-Tap'],
    ),
    FeatureTourItem(
      title: 'Real-Time System Metrics',
      subtitle: 'Monitoring Beban Mesin Linux',
      description:
          'Pantau utilisasi CPU, RAM terpakai, kapasitas partisi Disk, dan Uptime sistem operasi workstation Anda secara real-time via SSH tanpa perlu install daemon tambahan.',
      icon: Icons.insights_rounded,
      accentColor: Color(0xFF388BFD),
      highlights: ['Live CPU & Load', 'Real Memory & Disk', 'Zero Daemon Overhead'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _closeTour() {
    Navigator.of(context).pop();
    widget.onFinish?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final typography = widget.typography;
    final isLastPage = _currentPage == _tourItems.length - 1;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        children: [
          // Drag Handle & Top Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.foregroundMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SETU TOUR',
                          style: typography.code.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: colors.primary,
                          ),
                        ),
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_currentPage + 1}/${_tourItems.length}',
                            style: typography.code.copyWith(fontSize: 10, color: colors.foregroundMuted),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _closeTour,
                      child: Text(
                        'Lewati (Skip)',
                        style: typography.labelMedium.copyWith(
                          color: colors.foregroundMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Slide Pages View
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _tourItems.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final item = _tourItems[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustrated Icon Circle
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: item.accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: item.accentColor.withValues(alpha: 0.35), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: item.accentColor.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(item.icon, size: 36, color: item.accentColor),
                      ),
                      const Gap(16),

                      // Title & Subtitle
                      Text(
                        item.title,
                        style: typography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.foreground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(4),
                      Text(
                        item.subtitle,
                        style: typography.bodyMedium.copyWith(
                          color: item.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(10),

                      // Description
                      Text(
                        item.description,
                        style: typography.bodySmall.copyWith(
                          color: colors.foregroundMuted,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),

                      // Feature Highlight Badges
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: item.highlights.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 13, color: item.accentColor),
                                const Gap(6),
                                Text(
                                  tag,
                                  style: typography.code.copyWith(
                                    fontSize: 11,
                                    color: colors.foreground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Bar with Indicator & Navigation Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.border.withValues(alpha: 0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _tourItems.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: _tourItems[_currentPage].accentColor,
                    dotColor: colors.surfaceVariant,
                    dotHeight: 6,
                    dotWidth: 6,
                    expansionFactor: 3.5,
                    spacing: 6,
                  ),
                ),

                // Action Buttons
                Row(
                  children: [
                    if (_currentPage > 0) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        tooltip: 'Sebelumnya',
                      ),
                      const Gap(8),
                    ],
                    FilledButton(
                      onPressed: () {
                        if (isLastPage) {
                          _closeTour();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _tourItems[_currentPage].accentColor,
                        foregroundColor: const Color(0xFF0D1117),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                        style: typography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D1117),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
