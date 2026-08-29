import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/git/git_models.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_typography.dart';

class GitDiffSheet extends StatelessWidget {
  final String filePath;
  final bool isStaged;
  final List<GitDiffLine> lines;
  final SetuColors colors;
  final SetuTypography typography;

  const GitDiffSheet({
    super.key,
    required this.filePath,
    required this.isStaged,
    required this.lines,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.foregroundMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.difference_rounded,
                        color: isStaged ? colors.primary : colors.warning,
                        size: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filePath.split('/').last,
                              style: typography.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${isStaged ? "Staged" : "Working tree"} diff: $filePath',
                              style: typography.bodySmall.copyWith(
                                color: colors.foregroundMuted,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.foregroundMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Gap(8),
          Divider(color: colors.border, height: 1),

          // Diff content
          Expanded(
            child: lines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 40, color: colors.primary),
                        const Gap(8),
                        Text('No differences found', style: typography.bodySmall),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final line = lines[index];
                      Color bgColor = Colors.transparent;
                      Color textColor = colors.foreground;
                      FontWeight fontWeight = FontWeight.normal;

                      if (line.type == DiffLineType.addition) {
                        bgColor = const Color(0xFF238636).withValues(alpha: 0.18);
                        textColor = const Color(0xFF3FB950);
                      } else if (line.type == DiffLineType.deletion) {
                        bgColor = const Color(0xFFDA3633).withValues(alpha: 0.18);
                        textColor = const Color(0xFFF85149);
                      } else if (line.type == DiffLineType.header) {
                        bgColor = colors.surfaceVariant.withValues(alpha: 0.5);
                        textColor = colors.primary;
                        fontWeight = FontWeight.w600;
                      }

                      return Container(
                        color: bgColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Line numbers
                            if (line.type != DiffLineType.header) ...[
                              SizedBox(
                                width: 32,
                                child: Text(
                                  line.oldLineNo != null ? '${line.oldLineNo}' : '',
                                  style: typography.code.copyWith(
                                    fontSize: 10,
                                    color: colors.foregroundMuted.withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const Gap(6),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  line.newLineNo != null ? '${line.newLineNo}' : '',
                                  style: typography.code.copyWith(
                                    fontSize: 10,
                                    color: colors.foregroundMuted.withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const Gap(8),
                            ],
                            // Code text
                            Expanded(
                              child: Text(
                                line.content,
                                style: typography.code.copyWith(
                                  fontSize: 11,
                                  color: textColor,
                                  fontWeight: fontWeight,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
