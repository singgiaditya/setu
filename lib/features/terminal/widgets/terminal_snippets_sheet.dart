import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../../core/terminal/terminal_session.dart';
import '../../../core/terminal/terminal_snippet.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../providers/terminal_provider.dart';
import '../../../providers/terminal_snippet_provider.dart';

class TerminalSnippetsSheet extends ConsumerStatefulWidget {
  final TerminalSessionItem? session;
  final String? workspaceId;
  final String? workspaceName;

  const TerminalSnippetsSheet({
    super.key,
    required this.session,
    this.workspaceId,
    this.workspaceName,
  });

  @override
  ConsumerState<TerminalSnippetsSheet> createState() => _TerminalSnippetsSheetState();
}

class _TerminalSnippetsSheetState extends ConsumerState<TerminalSnippetsSheet> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _scopeFilter = 'all'; // 'all', 'workspace', 'global'

  void _runSnippet(TerminalSnippet snippet) {
    if (widget.session == null) return;
    final settings = ref.read(terminalSettingsProvider);
    if (settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    if (snippet.autoExecute) {
      widget.session!.writeInput('${snippet.command}\n');
    } else {
      widget.session!.writeInput(snippet.command);
    }
    Navigator.of(context).pop();
  }

  void _showAddSnippetDialog() {
    final titleCtrl = TextEditingController();
    final cmdCtrl = TextEditingController();
    String category = 'Custom';
    bool autoExec = true;
    bool isWorkspaceScoped = widget.workspaceId != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final colors = ref.watch(setuColorsProvider);
          final typography = ref.watch(setuTypographyProvider);

          return AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.border),
            ),
            title: Row(
              children: [
                Icon(Icons.bolt_rounded, color: colors.primary, size: 22),
                const Gap(8),
                Text('New Snippet', style: typography.titleMedium),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    style: typography.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. Run Tests',
                    ),
                  ),
                  const Gap(12),
                  TextField(
                    controller: cmdCtrl,
                    style: typography.code.copyWith(fontSize: 13),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Command',
                      hintText: 'e.g. npm test or cargo check',
                    ),
                  ),
                  const Gap(12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    dropdownColor: colors.surface,
                    style: typography.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: ['Custom', 'Build', 'Test', 'Git', 'Docker', 'System', 'Tmux', 'General']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  if (widget.workspaceId != null) ...[
                    const Gap(12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Save to ${widget.workspaceName ?? "this workspace"} only',
                        style: typography.bodySmall,
                      ),
                      value: isWorkspaceScoped,
                      activeTrackColor: colors.primary,
                      onChanged: (val) => setDialogState(() => isWorkspaceScoped = val),
                    ),
                  ],
                  const Gap(12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Auto-Execute (append Enter)', style: typography.bodySmall),
                    value: autoExec,
                    activeTrackColor: colors.primary,
                    onChanged: (val) => setDialogState(() => autoExec = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text('Cancel', style: TextStyle(color: colors.foregroundMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final cmd = cmdCtrl.text.trim();
                  if (title.isEmpty || cmd.isEmpty) return;

                  final snippet = TerminalSnippet(
                    id: const Uuid().v4(),
                    title: title,
                    command: cmd,
                    category: category,
                    autoExecute: autoExec,
                    createdAt: DateTime.now(),
                    workspaceId: (widget.workspaceId != null && isWorkspaceScoped)
                        ? widget.workspaceId
                        : null,
                  );
                  ref.read(terminalSnippetsProvider.notifier).addSnippet(snippet);
                  Navigator.of(dialogCtx).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: const Color(0xFF0D1117),
                ),
                child: const Text('Save Snippet'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final snippets = ref.watch(scopedSnippetsProvider(widget.workspaceId));
    final categories = ref.watch(snippetCategoriesProvider(widget.workspaceId));

    final filtered = snippets.where((s) {
      final matchesCat = _selectedCategory == 'All' || s.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.command.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesScope = _scopeFilter == 'all' ||
          (_scopeFilter == 'workspace' && s.workspaceId == widget.workspaceId) ||
          (_scopeFilter == 'global' && s.isGlobal);
      return matchesCat && matchesSearch && matchesScope;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.foregroundMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(12),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: colors.primary, size: 22),
                  const Gap(8),
                  Text(
                    widget.workspaceName != null
                        ? '${widget.workspaceName} Snippets'
                        : 'Snippets & Quick Actions',
                    style: typography.titleMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add_circle_outline_rounded, color: colors.primary, size: 22),
                    tooltip: 'Add Snippet',
                    onPressed: _showAddSnippetDialog,
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.foregroundMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
          const Gap(8),

          // Search bar
          TextField(
            style: typography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search snippets or commands...',
              prefixIcon: Icon(Icons.search_rounded, size: 18, color: colors.foregroundMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const Gap(8),

          // Scope Filters (if inside workspace)
          if (widget.workspaceId != null) ...[
            SizedBox(
              height: 28,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ChoiceChip(
                    label: const Text('All Scopes'),
                    selected: _scopeFilter == 'all',
                    onSelected: (_) => setState(() => _scopeFilter = 'all'),
                    labelStyle: typography.labelSmall.copyWith(
                      color: _scopeFilter == 'all' ? const Color(0xFF0D1117) : colors.foreground,
                    ),
                    selectedColor: colors.accent,
                    backgroundColor: colors.surfaceVariant,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Gap(6),
                  ChoiceChip(
                    label: Text(widget.workspaceName ?? 'Workspace'),
                    selected: _scopeFilter == 'workspace',
                    onSelected: (_) => setState(() => _scopeFilter = 'workspace'),
                    labelStyle: typography.labelSmall.copyWith(
                      color: _scopeFilter == 'workspace' ? const Color(0xFF0D1117) : colors.foreground,
                    ),
                    selectedColor: colors.primary,
                    backgroundColor: colors.surfaceVariant,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Gap(6),
                  ChoiceChip(
                    label: const Text('Global'),
                    selected: _scopeFilter == 'global',
                    onSelected: (_) => setState(() => _scopeFilter = 'global'),
                    labelStyle: typography.labelSmall.copyWith(
                      color: _scopeFilter == 'global' ? const Color(0xFF0D1117) : colors.foreground,
                    ),
                    selectedColor: colors.primary,
                    backgroundColor: colors.surfaceVariant,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const Gap(8),
          ],

          // Category Chips
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const Gap(6),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  labelStyle: typography.labelSmall.copyWith(
                    color: isSelected ? const Color(0xFF0D1117) : colors.foreground,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selectedColor: colors.primary,
                  backgroundColor: colors.surfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const Gap(10),

          // Snippet List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 40, color: colors.foregroundMuted),
                        const Gap(8),
                        Text('No snippets found', style: typography.bodySmall),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Gap(8),
                    itemBuilder: (context, index) {
                      final snippet = filtered[index];
                      final isWs = snippet.workspaceId != null && snippet.workspaceId!.isNotEmpty;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isWs
                                ? colors.primary.withValues(alpha: 0.4)
                                : colors.border.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        snippet.title,
                                        style: typography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isWs
                                              ? colors.primary.withValues(alpha: 0.2)
                                              : colors.surface,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isWs ? colors.primary : colors.border,
                                          ),
                                        ),
                                        child: Text(
                                          isWs ? 'Workspace' : snippet.category,
                                          style: typography.code.copyWith(
                                            fontSize: 9,
                                            color: isWs ? colors.primary : colors.foregroundMuted,
                                            fontWeight: isWs ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(4),
                                  Text(
                                    snippet.command,
                                    style: typography.code.copyWith(
                                      fontSize: 11,
                                      color: colors.primary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(8),
                            if (widget.session != null) ...[
                              IconButton(
                                icon: Icon(Icons.input_rounded, size: 18, color: colors.foregroundMuted),
                                tooltip: 'Insert to terminal',
                                onPressed: () {
                                  widget.session!.writeInput(snippet.command);
                                  Navigator.of(context).pop();
                                },
                              ),
                              FilledButton(
                                onPressed: () => _runSnippet(snippet),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: const Color(0xFF0D1117),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Run', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
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
