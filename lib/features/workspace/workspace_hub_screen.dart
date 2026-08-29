import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:xterm/xterm.dart';
import '../../core/git/git_models.dart';
import '../../core/sftp/sftp_file_model.dart';
import '../../core/sftp/sftp_service.dart';
import '../../core/terminal/terminal_session.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/git_provider.dart';
import '../../providers/ssh_provider.dart';
import '../../providers/terminal_provider.dart';
import '../projects/models/project_model.dart';
import '../projects/projects_screen.dart';
import '../terminal/widgets/terminal_keyboard_toolbar.dart';
import 'widgets/git_branch_sheet.dart';
import 'widgets/git_diff_sheet.dart';

final _workspaceSftpProvider = Provider.autoDispose<SftpService>((ref) {
  final service = SftpService();
  ref.onDispose(() => service.close());
  return service;
});

class WorkspaceHubScreen extends ConsumerStatefulWidget {
  final String workspaceId;

  const WorkspaceHubScreen({
    super.key,
    required this.workspaceId,
  });

  @override
  ConsumerState<WorkspaceHubScreen> createState() => _WorkspaceHubScreenState();
}

class _WorkspaceHubScreenState extends ConsumerState<WorkspaceHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commitMessageCtrl = TextEditingController();

  // Explorer State
  String _currentExplorerPath = '';
  List<SftpFileItem> _explorerItems = [];
  bool _isLoadingExplorer = false;
  String? _explorerError;

  // Terminal State
  TerminalSessionItem? _workspaceSession;
  final FocusNode _terminalFocus = FocusNode();
  double _scaleBaseFontSize = 13.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWorkspace();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commitMessageCtrl.dispose();
    _terminalFocus.dispose();
    super.dispose();
  }

  ProjectModel? _getWorkspace() {
    final projects = ref.read(projectsProvider);
    final match = projects.where((p) => p.id == widget.workspaceId);
    return match.isNotEmpty ? match.first : null;
  }

  Future<void> _initWorkspace() async {
    final ws = _getWorkspace();
    if (ws == null) return;
    _currentExplorerPath = ws.remotePath;

    // Load Explorer & Terminal
    _loadExplorerDirectory();
    _initWorkspaceTerminal(ws);
  }

  // --- EXPLORER METHODS ---
  Future<void> _loadExplorerDirectory() async {
    final ssh = ref.read(sshServiceProvider);
    if (!ssh.isConnected || ssh.client == null) {
      setState(() {
        _isLoadingExplorer = false;
        _explorerError = 'Workstation not connected';
      });
      return;
    }

    setState(() {
      _isLoadingExplorer = true;
      _explorerError = null;
    });

    final sftp = ref.read(_workspaceSftpProvider);
    if (!sftp.isReady) {
      await sftp.init(ssh.client!);
    }

    final res = await sftp.listDirectory(_currentExplorerPath);
    if (mounted) {
      res.when(
        onSuccess: (items) => setState(() {
          _explorerItems = items;
          _isLoadingExplorer = false;
        }),
        onFailure: (err) => setState(() {
          _explorerError = err;
          _isLoadingExplorer = false;
        }),
      );
    }
  }

  void _navigateToDir(String path) {
    setState(() => _currentExplorerPath = path);
    _loadExplorerDirectory();
  }

  void _navigateUp() {
    final ws = _getWorkspace();
    final root = ws?.remotePath ?? '/';
    if (_currentExplorerPath == root || _currentExplorerPath == '/') return;

    final lastSlash = _currentExplorerPath.lastIndexOf('/');
    if (lastSlash > 0) {
      _navigateToDir(_currentExplorerPath.substring(0, lastSlash));
    } else {
      _navigateToDir('/');
    }
  }

  void _showNewFileDialog({bool isDirectory = false}) {
    final colors = ref.read(setuColorsProvider);
    final typography = ref.read(setuTypographyProvider);
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        title: Text(
          isDirectory ? 'New Folder' : 'New File',
          style: typography.titleMedium,
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: typography.bodyMedium,
          decoration: InputDecoration(
            hintText: isDirectory ? 'e.g. models' : 'e.g. main.py',
            hintStyle: typography.bodySmall,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              final targetPath = '$_currentExplorerPath/$name';
              final sftp = ref.read(_workspaceSftpProvider);
              if (isDirectory) {
                await sftp.createDirectory(targetPath);
              } else {
                await sftp.writeFile(targetPath, '');
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) _loadExplorerDirectory();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: const Color(0xFF0D1117),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // --- TERMINAL METHODS ---
  Future<void> _initWorkspaceTerminal(ProjectModel ws) async {
    final terminalNotifier = ref.read(terminalSessionsProvider.notifier);
    final session = await terminalNotifier.createSession(
      name: ws.name,
      command: 'cd "${ws.remotePath}" && clear\n',
      tagColor: 'primary',
    );
    if (mounted) {
      setState(() => _workspaceSession = session);
    }
  }

  TerminalCursorType _getCursorType(String style) {
    switch (style) {
      case 'underline':
        return TerminalCursorType.underline;
      case 'bar':
        return TerminalCursorType.verticalBar;
      case 'block':
      default:
        return TerminalCursorType.block;
    }
  }

  // --- GIT METHODS ---
  void _openDiffSheet(String filePath, bool isStaged) async {
    final ws = _getWorkspace();
    if (ws == null) return;
    final gitNotifier = ref.read(workspaceGitProvider(ws.remotePath));
    await gitNotifier.loadDiff(filePath, staged: isStaged);

    if (!mounted) return;
    final gitState = ref.read(workspaceGitProvider(ws.remotePath)).value;
    final colors = ref.read(setuColorsProvider);
    final typography = ref.read(setuTypographyProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GitDiffSheet(
        filePath: filePath,
        isStaged: isStaged,
        lines: gitState.activeDiff ?? [],
        colors: colors,
        typography: typography,
      ),
    );
  }

  void _openBranchSheet(GitStatusResult status, List<GitBranch> branches) {
    final ws = _getWorkspace();
    if (ws == null) return;
    final colors = ref.read(setuColorsProvider);
    final typography = ref.read(setuTypographyProvider);
    final gitNotifier = ref.read(workspaceGitProvider(ws.remotePath));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GitBranchSheet(
        branches: branches,
        currentBranch: status.branch,
        colors: colors,
        typography: typography,
        onCheckout: (branch) => gitNotifier.checkoutBranch(branch),
        onCreateBranch: (newBranch) => gitNotifier.checkoutBranch(newBranch, createNew: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final ws = _getWorkspace();

    if (ws == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(title: const Text('Workspace')),
        body: Center(
          child: Text('Workspace not found', style: typography.bodyMedium),
        ),
      );
    }

    final gitNotifier = ref.watch(workspaceGitProvider(ws.remotePath));

    return ListenableBuilder(
      listenable: gitNotifier,
      builder: (context, _) {
        final gitState = gitNotifier.value;
        final gitStatus = gitState.status ?? GitStatusResult.notRepo();

        return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(ws.emoji, style: const TextStyle(fontSize: 20)),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ws.name, style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    ws.remotePath,
                    style: typography.code.copyWith(fontSize: 10, color: colors.foregroundMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (gitStatus.isRepo)
            ActionChip(
              avatar: Icon(Icons.alt_route_rounded, size: 14, color: colors.primary),
              label: Text(
                gitStatus.branch.isEmpty ? 'HEAD' : gitStatus.branch,
                style: typography.code.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              backgroundColor: colors.surfaceVariant,
              side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
              onPressed: () => _openBranchSheet(gitStatus, gitState.branches),
            ),
          const Gap(8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          unselectedLabelColor: colors.foregroundMuted,
          tabs: [
            const Tab(
              icon: Icon(Icons.folder_outlined, size: 18),
              text: 'Files',
            ),
            const Tab(
              icon: Icon(Icons.terminal_outlined, size: 18),
              text: 'Terminal',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: gitStatus.totalChanges > 0,
                label: Text('${gitStatus.totalChanges}'),
                child: const Icon(Icons.commit_rounded, size: 18),
              ),
              text: 'Git',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Files Tab
          _buildExplorerView(ws, colors, typography),

          // 2. Terminal Tab
          _buildTerminalView(ws, colors, typography),

          // 3. Git Tab
          _buildGitView(ws, gitState, gitStatus, colors, typography),
        ],
      ),
    );
      },
    );
  }

  // ==========================================
  // TAB 1: WORKSPACE FILE EXPLORER VIEW
  // ==========================================
  Widget _buildExplorerView(ProjectModel ws, SetuColors colors, SetuTypography typography) {
    final relativePath = _currentExplorerPath.startsWith(ws.remotePath)
        ? _currentExplorerPath.substring(ws.remotePath.length)
        : _currentExplorerPath;
    final displayPath = relativePath.isEmpty ? '/' : relativePath;

    return Column(
      children: [
        // Explorer Action Bar & Breadcrumb
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Row(
            children: [
              if (_currentExplorerPath != ws.remotePath)
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                  tooltip: 'Go up',
                  onPressed: _navigateUp,
                  visualDensity: VisualDensity.compact,
                ),
              Icon(Icons.folder_open_rounded, size: 18, color: colors.primary),
              const Gap(8),
              Expanded(
                child: Text(
                  displayPath,
                  style: typography.code.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.note_add_outlined, size: 18),
                tooltip: 'New File',
                onPressed: () => _showNewFileDialog(isDirectory: false),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                tooltip: 'New Folder',
                onPressed: () => _showNewFileDialog(isDirectory: true),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                tooltip: 'Refresh',
                onPressed: _loadExplorerDirectory,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        // File List
        Expanded(
          child: _isLoadingExplorer
              ? const Center(child: CircularProgressIndicator())
              : _explorerError != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 40, color: colors.error),
                          const Gap(8),
                          Text(_explorerError!, style: typography.bodySmall),
                          const Gap(12),
                          ElevatedButton(
                            onPressed: _loadExplorerDirectory,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _explorerItems.isEmpty
                      ? Center(
                          child: Text('Folder is empty', style: typography.bodySmall),
                        )
                      : ListView.separated(
                          itemCount: _explorerItems.length,
                          separatorBuilder: (_, _) => Divider(color: colors.border.withValues(alpha: 0.3), height: 1),
                          itemBuilder: (context, index) {
                            final item = _explorerItems[index];
                            return ListTile(
                              leading: Icon(
                                item.isDirectory ? Icons.folder_rounded : Icons.insert_drive_file_outlined,
                                color: item.isDirectory ? colors.primary : colors.foregroundMuted,
                                size: 22,
                              ),
                              title: Text(item.name, style: typography.bodyMedium),
                              subtitle: item.isDirectory
                                  ? null
                                  : Text(
                                      '${item.formattedSize} • ${item.modifyTime != null ? item.modifyTime.toString().split('.').first : ''}',
                                      style: typography.bodySmall.copyWith(fontSize: 10),
                                    ),
                              onTap: () {
                                if (item.isDirectory) {
                                  _navigateToDir(item.path);
                                } else {
                                  // Open in Code Editor
                                  context.push('/editor?path=${Uri.encodeComponent(item.path)}');
                                }
                              },
                            );
                          },
                        ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: WORKSPACE TERMINAL VIEW
  // ==========================================
  Widget _buildTerminalView(ProjectModel ws, SetuColors colors, SetuTypography typography) {
    final terminalSettings = ref.watch(terminalSettingsProvider);
    final terminalTheme = terminalSettings.theme.toTerminalTheme();

    if (_workspaceSession == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const Gap(12),
            Text('Initializing workspace terminal...', style: typography.bodySmall),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Main View
        Expanded(
          child: GestureDetector(
            onScaleStart: (_) {
              _scaleBaseFontSize = terminalSettings.fontSize;
            },
            onScaleUpdate: (details) {
              if (details.scale != 1.0) {
                final newSize = (_scaleBaseFontSize * details.scale).clamp(9.0, 24.0);
                ref.read(terminalSettingsProvider.notifier).setFontSize(
                      double.parse(newSize.toStringAsFixed(1)),
                    );
              }
            },
            child: Container(
              color: terminalSettings.theme.background,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: TerminalView(
                _workspaceSession!.terminal,
                focusNode: _terminalFocus,
                autofocus: true,
                theme: terminalTheme,
                backgroundOpacity: 1.0,
                deleteDetection: true,
                keyboardType: TextInputType.visiblePassword,
                cursorType: _getCursorType(terminalSettings.cursorStyle),
                textStyle: TerminalStyle(
                  fontFamily: terminalSettings.fontFamily,
                  fontSize: terminalSettings.fontSize,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),

        // Accessory Toolbar (Connected with Workspace Snippets)
        TerminalKeyboardToolbar(
          session: _workspaceSession,
          colors: colors,
          typography: typography,
          workspaceId: ws.id,
          workspaceName: ws.name,
          onClear: () => _workspaceSession?.terminal.eraseDisplay(),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: WORKSPACE GIT SOURCE CONTROL VIEW
  // ==========================================
  Widget _buildGitView(
    ProjectModel ws,
    WorkspaceGitState gitState,
    GitStatusResult status,
    SetuColors colors,
    SetuTypography typography,
  ) {
    final gitNotifier = ref.read(workspaceGitProvider(ws.remotePath));

    if (gitState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!status.isRepo) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.commit_rounded, size: 48, color: colors.foregroundMuted),
              const Gap(16),
              Text('Not a Git Repository', style: typography.titleMedium),
              const Gap(8),
              Text(
                'Initialize git in this workspace to track changes and collaborate.',
                textAlign: TextAlign.center,
                style: typography.bodySmall.copyWith(color: colors.foregroundMuted),
              ),
              const Gap(20),
              FilledButton.icon(
                onPressed: () async {
                  final ssh = ref.read(sshServiceProvider);
                  await ssh.runCommand('git -C "${ws.remotePath}" init');
                  gitNotifier.refresh();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: const Color(0xFF0D1117),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Initialize Repository'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => gitNotifier.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync & Action Toolbar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.alt_route_rounded, size: 18, color: colors.primary),
                  const Gap(6),
                  Text(
                    status.branch,
                    style: typography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (status.aheadCount > 0) ...[
                    const Gap(6),
                    Text('↑${status.aheadCount}', style: typography.code.copyWith(color: colors.primary, fontSize: 11)),
                  ],
                  if (status.behindCount > 0) ...[
                    const Gap(6),
                    Text('↓${status.behindCount}', style: typography.code.copyWith(color: colors.warning, fontSize: 11)),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    tooltip: 'Pull',
                    onPressed: gitState.isSyncing ? null : () => gitNotifier.pull(),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    tooltip: 'Push',
                    onPressed: gitState.isSyncing ? null : () => gitNotifier.push(),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cloud_download_outlined, size: 18),
                    tooltip: 'Fetch',
                    onPressed: gitState.isSyncing ? null : () => gitNotifier.fetch(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const Gap(14),

            // Commit Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _commitMessageCtrl,
                    style: typography.bodySmall,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Message (Ctrl+Enter to commit)',
                      hintStyle: typography.bodySmall.copyWith(color: colors.foregroundMuted),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: (status.stagedFiles.isEmpty && status.unstagedFiles.isEmpty) ||
                                  gitState.isSyncing
                              ? null
                              : () async {
                                  // If no staged files, stage all first
                                  if (status.stagedFiles.isEmpty) {
                                    await gitNotifier.stageAll();
                                  }
                                  final ok = await gitNotifier.commit(_commitMessageCtrl.text);
                                  if (ok) _commitMessageCtrl.clear();
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: const Color(0xFF0D1117),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            gitState.isSyncing ? 'Committing...' : 'Commit',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Gap(8),
                      OutlinedButton(
                        onPressed: (status.stagedFiles.isEmpty && status.unstagedFiles.isEmpty) ||
                                gitState.isSyncing
                            ? null
                            : () async {
                                if (status.stagedFiles.isEmpty) {
                                  await gitNotifier.stageAll();
                                }
                                final ok = await gitNotifier.commitAndPush(_commitMessageCtrl.text);
                                if (ok) _commitMessageCtrl.clear();
                              },
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Commit & Push'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(16),

            // Error display
            if (gitState.error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: colors.error, size: 18),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        gitState.error!,
                        style: typography.bodySmall.copyWith(color: colors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(14),
            ],

            // Staged Changes Section
            if (status.stagedFiles.isNotEmpty) ...[
              _buildGitSectionHeader(
                'STAGED CHANGES (${status.stagedFiles.length})',
                colors,
                typography,
                trailing: TextButton(
                  onPressed: () {
                    for (final f in status.stagedFiles) {
                      gitNotifier.unstageFile(f.path);
                    }
                  },
                  child: const Text('Unstage All', style: TextStyle(fontSize: 11)),
                ),
              ),
              ...status.stagedFiles.map((file) => _buildGitFileTile(
                    file,
                    isStaged: true,
                    colors: colors,
                    typography: typography,
                    onAction: () => gitNotifier.unstageFile(file.path),
                    actionIcon: Icons.remove_circle_outline_rounded,
                    actionTooltip: 'Unstage',
                    onTap: () => _openDiffSheet(file.path, true),
                  )),
              const Gap(16),
            ],

            // Changes (Unstaged) Section
            if (status.unstagedFiles.isNotEmpty) ...[
              _buildGitSectionHeader(
                'CHANGES (${status.unstagedFiles.length})',
                colors,
                typography,
                trailing: TextButton(
                  onPressed: () => gitNotifier.stageAll(),
                  child: const Text('Stage All', style: TextStyle(fontSize: 11)),
                ),
              ),
              ...status.unstagedFiles.map((file) => _buildGitFileTile(
                    file,
                    isStaged: false,
                    colors: colors,
                    typography: typography,
                    onAction: () => gitNotifier.stageFile(file.path),
                    actionIcon: Icons.add_circle_outline_rounded,
                    actionTooltip: 'Stage',
                    onDiscard: () => gitNotifier.discardChanges(file.path),
                    onTap: () => _openDiffSheet(file.path, false),
                  )),
              const Gap(16),
            ],

            // Untracked Files Section
            if (status.untrackedFiles.isNotEmpty) ...[
              _buildGitSectionHeader(
                'UNTRACKED FILES (${status.untrackedFiles.length})',
                colors,
                typography,
              ),
              ...status.untrackedFiles.map((file) => _buildGitFileTile(
                    file,
                    isStaged: false,
                    colors: colors,
                    typography: typography,
                    onAction: () => gitNotifier.stageFile(file.path),
                    actionIcon: Icons.add_circle_outline_rounded,
                    actionTooltip: 'Track & Stage',
                    onTap: () => _openDiffSheet(file.path, false),
                  )),
              const Gap(16),
            ],

            // Clean state
            if (status.isClean)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 36, color: colors.primary),
                      const Gap(8),
                      Text('Working tree clean', style: typography.titleSmall),
                      Text('No changes to commit.', style: typography.bodySmall.copyWith(color: colors.foregroundMuted)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGitSectionHeader(
    String title,
    SetuColors colors,
    SetuTypography typography, {
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: typography.labelSmall.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: colors.foregroundMuted,
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildGitFileTile(
    GitFileItem file, {
    required bool isStaged,
    required SetuColors colors,
    required SetuTypography typography,
    required VoidCallback onAction,
    required IconData actionIcon,
    required String actionTooltip,
    VoidCallback? onDiscard,
    required VoidCallback onTap,
  }) {
    Color statusColor = colors.foregroundMuted;
    if (file.status == GitFileStatusType.modified) {
      statusColor = colors.warning;
    } else if (file.status == GitFileStatusType.added || file.status == GitFileStatusType.untracked) {
      statusColor = colors.primary;
    } else if (file.status == GitFileStatusType.deleted) {
      statusColor = colors.error;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                file.statusBadge,
                style: typography.code.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (file.directoryPath.isNotEmpty)
                    Text(
                      file.directoryPath,
                      style: typography.code.copyWith(fontSize: 10, color: colors.foregroundMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (onDiscard != null)
              IconButton(
                icon: Icon(Icons.restore_rounded, size: 16, color: colors.foregroundMuted),
                tooltip: 'Discard Changes',
                onPressed: onDiscard,
                visualDensity: VisualDensity.compact,
              ),
            IconButton(
              icon: Icon(actionIcon, size: 18, color: colors.primary),
              tooltip: actionTooltip,
              onPressed: onAction,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
