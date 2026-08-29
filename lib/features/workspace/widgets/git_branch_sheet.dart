import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/git/git_models.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_typography.dart';

class GitBranchSheet extends StatefulWidget {
  final List<GitBranch> branches;
  final String currentBranch;
  final SetuColors colors;
  final SetuTypography typography;
  final Function(String branchName) onCheckout;
  final Function(String newBranchName) onCreateBranch;

  const GitBranchSheet({
    super.key,
    required this.branches,
    required this.currentBranch,
    required this.colors,
    required this.typography,
    required this.onCheckout,
    required this.onCreateBranch,
  });

  @override
  State<GitBranchSheet> createState() => _GitBranchSheetState();
}

class _GitBranchSheetState extends State<GitBranchSheet> {
  String _searchQuery = '';

  void _showNewBranchDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: widget.colors.border),
        ),
        title: Row(
          children: [
            Icon(Icons.alt_route_rounded, color: widget.colors.primary, size: 22),
            const Gap(8),
            Text('Create Branch', style: widget.typography.titleMedium),
          ],
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: widget.typography.bodyMedium,
          decoration: InputDecoration(
            labelText: 'Branch Name',
            hintText: 'e.g. feature/new-login',
            hintStyle: widget.typography.bodySmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: widget.colors.foregroundMuted)),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                widget.onCreateBranch(name);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: widget.colors.primary,
              foregroundColor: const Color(0xFF0D1117),
            ),
            child: const Text('Create & Checkout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.branches.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: widget.colors.border)),
      ),
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: widget.colors.foregroundMuted.withValues(alpha: 0.4),
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
                Row(
                  children: [
                    Icon(Icons.alt_route_rounded, color: widget.colors.primary, size: 22),
                    const Gap(8),
                    Text('Switch Branch', style: widget.typography.titleMedium),
                  ],
                ),
                FilledButton.icon(
                  onPressed: _showNewBranchDialog,
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.colors.primary,
                    foregroundColor: const Color(0xFF0D1117),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('New Branch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const Gap(8),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: widget.typography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Filter branches...',
                prefixIcon: Icon(Icons.search_rounded, size: 18, color: widget.colors.foregroundMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const Gap(8),
          Divider(color: widget.colors.border, height: 1),

          // Branch list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No branches found', style: widget.typography.bodySmall),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => Divider(color: widget.colors.border.withValues(alpha: 0.5), height: 1),
                    itemBuilder: (context, index) {
                      final branch = filtered[index];
                      final isCurrent = branch.name == widget.currentBranch || branch.isCurrent;

                      return ListTile(
                        leading: Icon(
                          branch.isRemote ? Icons.cloud_outlined : Icons.alt_route_rounded,
                          color: isCurrent
                              ? widget.colors.primary
                              : (branch.isRemote ? widget.colors.foregroundMuted : widget.colors.foreground),
                          size: 20,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                branch.name,
                                style: widget.typography.bodyMedium.copyWith(
                                  color: isCurrent ? widget.colors.primary : widget.colors.foreground,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.colors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Current',
                                  style: widget.typography.code.copyWith(
                                    fontSize: 10,
                                    color: widget.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: isCurrent
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                widget.onCheckout(branch.name);
                              },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
