import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/storage_provider.dart';
import 'models/project_model.dart';

class ProjectsNotifier extends Notifier<List<ProjectModel>> {
  @override
  List<ProjectModel> build() {
    final prefs = ref.watch(preferencesStoreProvider);
    final raw = prefs.getSavedProjects();
    if (raw.isEmpty) {
      return [];
    }
    return raw.map((p) => ProjectModel.fromJson(p)).toList();
  }

  Future<void> addProject(ProjectModel project) async {
    state = [...state, project];
    await _persist();
  }

  Future<void> updateProject(ProjectModel project) async {
    state = [
      for (final p in state)
        if (p.id == project.id) project else p
    ];
    await _persist();
  }

  Future<void> deleteProject(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(isFavorite: !p.isFavorite) else p
    ];
    await _persist();
  }

  Future<void> touchProject(String id) async {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(lastOpened: DateTime.now()) else p
    ];
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.saveProjects(state.map((p) => p.toJson()).toList());
  }
}

final projectsProvider =
    NotifierProvider<ProjectsNotifier, List<ProjectModel>>(
  ProjectsNotifier.new,
);

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  static const List<String> _emojiPresets = [
    '📁', '🚀', '💻', '⚡', '📦', '🌐', '🛠️', '🎯', '🔥', '🐍', '🦀', '📱', '🤖', '☕', '🐘'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text('SETU', style: typography.brandSmall.copyWith(color: colors.primary)),
            const Gap(8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle),
            ),
            const Gap(8),
            Text('Workspaces', style: typography.titleMedium),
          ],
        ),
      ),
      body: projects.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: projects.length,
              separatorBuilder: (context, index) => const Gap(10),
              itemBuilder: (context, index) {
                final project = projects[index];
                return _ProjectCard(
                  project: project,
                  onTap: () {
                    ref.read(projectsProvider.notifier).touchProject(project.id);
                    context.push('/workspace/${project.id}');
                  },
                  onLongPress: () => _showContextMenu(context, ref, project),
                  onFavoriteToggle: () {
                    ref.read(projectsProvider.notifier).toggleFavorite(project.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProjectDialog(context, ref),
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add_rounded, color: Color(0xFF0D1117)),
        label: Text(
          'New Workspace',
          style: typography.labelLarge.copyWith(
            color: const Color(0xFF0D1117),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Icon(Icons.folder_special_outlined, size: 40, color: colors.foregroundMuted),
            ),
            const Gap(20),
            Text(
              'No Workspaces Yet',
              style: typography.headlineSmall.copyWith(color: colors.foreground),
            ),
            const Gap(8),
            Text(
              'Save workspace shortcuts for quick access to your remote development hubs.',
              textAlign: TextAlign.center,
              style: typography.bodyMedium.copyWith(color: colors.foregroundMuted),
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: () => _showProjectDialog(context, ref),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: const Color(0xFF0D1117),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDialog(BuildContext context, WidgetRef ref, [ProjectModel? existing]) {
    final colors = ref.read(setuColorsProvider);
    final typography = ref.read(setuTypographyProvider);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final pathController = TextEditingController(text: existing?.remotePath ?? '');
    String selectedEmoji = existing?.emoji ?? '📁';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border),
          ),
          title: Text(
            existing != null ? 'Edit Workspace' : 'Add Workspace',
            style: typography.titleMedium,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Icon Emoji', style: typography.labelSmall),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emojiPresets.map((emoji) {
                    final isSelected = emoji == selectedEmoji;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedEmoji = emoji),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary.withValues(alpha: 0.2) : colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const Gap(16),
                Text('Workspace Name', style: typography.labelSmall),
                const Gap(6),
                TextField(
                  controller: nameController,
                  style: typography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'e.g. backend-api',
                    hintStyle: typography.bodySmall,
                    filled: true,
                    fillColor: colors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const Gap(16),
                Text('Remote Workspace Path', style: typography.labelSmall),
                const Gap(6),
                TextField(
                  controller: pathController,
                  style: typography.code.copyWith(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '/home/user/my-project',
                    hintStyle: typography.bodySmall,
                    filled: true,
                    fillColor: colors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: colors.foregroundMuted)),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final path = pathController.text.trim();
                if (name.isEmpty || path.isEmpty) return;

                if (existing != null) {
                  final updated = existing.copyWith(
                    name: name,
                    remotePath: path,
                    emoji: selectedEmoji,
                  );
                  ref.read(projectsProvider.notifier).updateProject(updated);
                } else {
                  final newProject = ProjectModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    remotePath: path,
                    emoji: selectedEmoji,
                    lastOpened: DateTime.now(),
                  );
                  ref.read(projectsProvider.notifier).addProject(newProject);
                }
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: const Color(0xFF0D1117),
              ),
              child: Text(existing != null ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref, ProjectModel project) {
    final colors = ref.read(setuColorsProvider);
    final typography = ref.read(setuTypographyProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(project.emoji, style: const TextStyle(fontSize: 24)),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: typography.titleMedium),
                      Text(
                        project.remotePath,
                        style: typography.bodySmall.copyWith(color: colors.foregroundMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            Divider(color: colors.border, height: 1),
            const Gap(8),
            ListTile(
              leading: Icon(
                project.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: project.isFavorite ? colors.warning : colors.foregroundMuted,
              ),
              title: Text(project.isFavorite ? 'Remove from Favorites' : 'Add to Favorites', style: typography.bodyMedium),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(projectsProvider.notifier).toggleFavorite(project.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.folder_open_rounded, color: colors.primary),
              title: Text('Open in Explorer', style: typography.bodyMedium),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(projectsProvider.notifier).touchProject(project.id);
                context.go('/files');
              },
            ),
            ListTile(
              leading: Icon(Icons.terminal_rounded, color: colors.accent),
              title: Text('Open in Terminal', style: typography.bodyMedium),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(projectsProvider.notifier).touchProject(project.id);
                context.go('/terminal');
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_rounded, color: colors.foreground),
              title: Text('Edit Project', style: typography.bodyMedium),
              onTap: () {
                Navigator.pop(ctx);
                _showProjectDialog(context, ref, project);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: colors.error),
              title: Text('Delete Project', style: typography.bodyMedium.copyWith(color: colors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref, project);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ProjectModel project) {
    final colors = ref.read(setuColorsProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        title: const Text('Delete Project Shortcut?'),
        content: Text('Are you sure you want to remove "${project.name}"? This only removes the app shortcut, not remote files.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(projectsProvider.notifier).deleteProject(project.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavoriteToggle;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final colors = ref.watch(setuColorsProvider);
        final typography = ref.watch(setuTypographyProvider);

        return Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: project.isFavorite ? colors.primary.withValues(alpha: 0.5) : colors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                    ),
                    alignment: Alignment.center,
                    child: Text(project.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                project.name,
                                style: typography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (project.isFavorite) ...[
                              const Gap(6),
                              Icon(Icons.star_rounded, size: 16, color: colors.warning),
                            ],
                          ],
                        ),
                        const Gap(4),
                        Text(
                          project.remotePath,
                          style: typography.code.copyWith(
                            fontSize: 11,
                            color: colors.foregroundMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      project.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: project.isFavorite ? colors.warning : colors.foregroundMuted,
                      size: 20,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
