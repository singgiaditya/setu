import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/theme_manager.dart';
import '../models/setup_guide_step.dart';

class SetupStepCard extends StatefulWidget {
  final SetupGuideStep step;
  final SetuColors colors;
  final SetuTypography typography;

  const SetupStepCard({
    super.key,
    required this.step,
    required this.colors,
    required this.typography,
  });

  @override
  State<SetupStepCard> createState() => _SetupStepCardState();
}

class _SetupStepCardState extends State<SetupStepCard> {
  String? _selectedDistro;

  @override
  void initState() {
    super.initState();
    if (widget.step.distroSnippets != null && widget.step.distroSnippets!.isNotEmpty) {
      _selectedDistro = widget.step.distroSnippets!.keys.first;
    }
  }

  void _copyToClipboard(BuildContext context, String code) {
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
        backgroundColor: widget.colors.surface,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final typography = widget.typography;
    final step = widget.step;

    final String? activeCode = step.distroSnippets != null && _selectedDistro != null
        ? step.distroSnippets![_selectedDistro]
        : step.codeSnippet;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Step Number & Category
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${step.stepNumber}',
                    style: typography.titleSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              step.category.label.toUpperCase(),
                              style: typography.code.copyWith(
                                fontSize: 9,
                                color: colors.foregroundMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        step.title,
                        style: typography.titleMedium.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(step.icon, color: colors.foregroundMuted, size: 22),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              step.description,
              style: typography.bodyMedium.copyWith(
                color: colors.foregroundMuted,
                height: 1.45,
              ),
            ),
          ),
          const Gap(12),

          // Distro Selector Chips (if applicable)
          if (step.distroSnippets != null && step.distroSnippets!.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: step.distroSnippets!.keys.map((distro) {
                    final isSelected = distro == _selectedDistro;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(distro),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedDistro = distro);
                        },
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        backgroundColor: colors.surfaceVariant,
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
                  }).toList(),
                ),
              ),
            ),

          // Code Snippet Terminal Box
          if (activeCode != null && activeCode.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF090D13),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Terminal Header Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
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
                            Text('bash', style: typography.code.copyWith(fontSize: 10, color: colors.foregroundMuted)),
                          ],
                        ),
                        InkWell(
                          onTap: () => _copyToClipboard(context, activeCode),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.copy_rounded, size: 13, color: colors.primary),
                                const Gap(4),
                                Text(
                                  'Salin',
                                  style: typography.labelSmall.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Code Text
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      activeCode,
                      style: typography.code.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF58A6FF),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Pro-Tip Box (if present)
          if (step.tip != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 16, color: colors.warning),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      step.tip!,
                      style: typography.bodySmall.copyWith(
                        color: colors.foregroundMuted,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
