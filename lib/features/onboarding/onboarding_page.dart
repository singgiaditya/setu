import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/theme/theme_typography.dart';
import 'onboarding_data.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingItem item;
  final SetuColors colors;
  final SetuTypography typography;

  const OnboardingPageWidget({
    super.key,
    required this.item,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Graphic / Icon Container
          Center(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.12),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 58,
                color: colors.primary,
              ),
            ),
          ),
          const Gap(40),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              item.badge,
              style: typography.labelSmall.copyWith(
                color: colors.primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(14),

          // Title
          Text(
            item.title,
            style: typography.brand.copyWith(
              fontSize: 30,
              letterSpacing: 1.2,
            ),
          ),
          const Gap(6),

          // Subtitle
          Text(
            item.subtitle,
            style: typography.headlineMedium.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(14),

          // Description
          Text(
            item.description,
            style: typography.bodyLarge.copyWith(
              color: colors.foregroundMuted,
              height: 1.5,
            ),
          ),
          const Gap(24),

          // Feature Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.highlightTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  tag,
                  style: typography.bodySmall.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
}

