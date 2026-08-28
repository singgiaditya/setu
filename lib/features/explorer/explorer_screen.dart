import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/sftp/sftp_file_model.dart';
import '../../core/sftp/sftp_service.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/ssh_provider.dart';

final _sftpServiceProvider = Provider<SftpService>((ref) {
  final service = SftpService();
  ref.onDispose(() => service.close());
  return service;
});

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  String _currentPath = '/home';
  List<SftpFileItem> _items = [];
  bool _isLoading = true;
  String? _error;
  bool _showHidden = false;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final sshService = ref.read(sshServiceProvider);
    if (!sshService.isConnected || sshService.client == null) {
      setState(() {
        _isLoading = false;
        _error = 'Not connected. Connect to your workstation first.';
      });
      return;
    }
    final sftp = ref.read(_sftpServiceProvider);
    if (!sftp.isReady) {
      await sftp.init(sshService.client!);
    }

    // Try to detect home dir
    final homeResult = await sshService.runCommand('echo \$HOME');
    if (homeResult.isSuccess && homeResult.data != null) {
      _currentPath = homeResult.data!.trim();
      if (_currentPath.isEmpty) _currentPath = '/home';
    }
    await _loadDirectory();
  }

  Future<void> _loadDirectory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final sftp = ref.read(_sftpServiceProvider);
    final result = await sftp.listDirectory(_currentPath);
    if (mounted) {
      result.when(
        onSuccess: (items) => setState(() {
          _items = items;
          _isLoading = false;
        }),
        onFailure: (err) => setState(() {
          _error = err;
          _isLoading = false;
        }),
      );
    }
  }

  void _navigateTo(String path) {
    _currentPath = path;
    _loadDirectory();
  }

  void _goUp() {
    if (_currentPath == '/') return;
    final parts = _currentPath.split('/');
    parts.removeLast();
    final parent = parts.join('/');
    _navigateTo(parent.isEmpty ? '/' : parent);
  }

  List<String> get _breadcrumbs {
    if (_currentPath == '/') return ['/'];
    final parts = _currentPath.split('/').where((p) => p.isNotEmpty).toList();
    return ['/', ...parts];
  }

  List<SftpFileItem> get _filteredItems {
    var result = _items.toList();
    if (!_showHidden) {
      result = result.where((f) => !f.isHidden).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final sftp = ref.read(_sftpServiceProvider);
      final newPath = '$_currentPath/$name';
      await sftp.createDirectory(newPath);
      await _loadDirectory();
    }
  }

  Future<void> _createFile() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create File'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'filename.ext'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final sftp = ref.read(_sftpServiceProvider);
      final newPath = '$_currentPath/$name';
      await sftp.writeFile(newPath, '');
      await _loadDirectory();
    }
  }

  Future<void> _renameItem(SftpFileItem item) async {
    final controller = TextEditingController(text: item.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && newName != item.name) {
      final sftp = ref.read(_sftpServiceProvider);
      final newPath = '$_currentPath/$newName';
      await sftp.rename(item.path, newPath);
      await _loadDirectory();
    }
  }

  Future<void> _deleteItem(SftpFileItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${item.isDirectory ? "folder" : "file"}?'),
        content: Text('Are you sure you want to delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFF85149))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final sftp = ref.read(_sftpServiceProvider);
      await sftp.delete(item.path, isDirectory: item.isDirectory);
      await _loadDirectory();
    }
  }

  void _openFile(SftpFileItem item) {
    context.push('/editor?path=${Uri.encodeComponent(item.path)}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: typography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search files...',
                  border: InputBorder.none,
                  hintStyle: typography.bodyMedium.copyWith(color: colors.foregroundMuted),
                ),
                onChanged: (q) => setState(() => _searchQuery = q),
              )
            : Row(
                children: [
                  Text('SETU', style: typography.brandSmall.copyWith(color: colors.primary)),
                  const Gap(8),
                  Container(width: 4, height: 4, decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle)),
                  const Gap(8),
                  Text('Files', style: typography.titleMedium),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, size: 20),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchQuery = '';
            }),
          ),
          IconButton(
            icon: Icon(
              _showHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              size: 20,
              color: _showHidden ? colors.primary : colors.foregroundMuted,
            ),
            onPressed: () => setState(() => _showHidden = !_showHidden),
            tooltip: 'Toggle hidden files',
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_currentPath != '/')
                    InkWell(
                      onTap: _goUp,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Icon(Icons.arrow_upward_rounded, size: 16, color: colors.primary),
                      ),
                    ),
                  ..._breadcrumbs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final segment = entry.value;
                    final path = idx == 0
                        ? '/'
                        : '/${_breadcrumbs.skip(1).take(idx).join('/')}';
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (idx > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(Icons.chevron_right_rounded, size: 14, color: colors.foregroundMuted),
                          ),
                        InkWell(
                          onTap: () => _navigateTo(path),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text(
                              segment,
                              style: typography.bodySmall.copyWith(
                                color: idx == _breadcrumbs.length - 1
                                    ? colors.foreground
                                    : colors.primary,
                                fontWeight: idx == _breadcrumbs.length - 1
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                        ),
                        const Gap(12),
                        Text('Loading files...', style: typography.bodySmall),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline_rounded, size: 40, color: colors.error),
                              const Gap(12),
                              Text(_error!, style: typography.bodyMedium.copyWith(color: colors.foregroundMuted), textAlign: TextAlign.center),
                              const Gap(16),
                              OutlinedButton.icon(
                                onPressed: _loadDirectory,
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder_open_rounded, size: 48, color: colors.foregroundMuted),
                                const Gap(12),
                                Text(
                                  _searchQuery.isNotEmpty ? 'No matching files' : 'This folder is empty.',
                                  style: typography.bodyMedium.copyWith(color: colors.foregroundMuted),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDirectory,
                            color: colors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => Divider(height: 1, color: colors.border.withValues(alpha: 0.4)),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return _FileListTile(
                                  item: item,
                                  colors: colors,
                                  typography: typography,
                                  onTap: () {
                                    if (item.isDirectory) {
                                      _navigateTo(item.path);
                                    } else {
                                      _openFile(item);
                                    }
                                  },
                                  onLongPress: () => _showContextMenu(item),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateMenu(),
        backgroundColor: colors.primary,
        child: const Icon(Icons.add_rounded, color: Color(0xFF0D1117)),
      ),
    );
  }

  void _showCreateMenu() {
    final colors = ref.read(setuColorsProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.create_new_folder_rounded, color: colors.primary),
              title: const Text('New Folder'),
              onTap: () {
                Navigator.pop(ctx);
                _createFolder();
              },
            ),
            ListTile(
              leading: Icon(Icons.note_add_rounded, color: colors.primary),
              title: const Text('New File'),
              onTap: () {
                Navigator.pop(ctx);
                _createFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(SftpFileItem item) {
    final colors = ref.read(setuColorsProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(12),
            if (!item.isDirectory)
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Open in Editor'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openFile(item);
                },
              ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _renameItem(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF85149)),
              title: const Text('Delete', style: TextStyle(color: Color(0xFFF85149))),
              onTap: () {
                Navigator.pop(ctx);
                _deleteItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FileListTile extends StatelessWidget {
  final SftpFileItem item;
  final SetuColors colors;
  final SetuTypography typography;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FileListTile({
    required this.item,
    required this.colors,
    required this.typography,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(item.iconData, size: 22, color: item.iconColor),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.formattedSize.isNotEmpty || item.formattedDate.isNotEmpty)
                    Text(
                      [item.formattedSize, item.formattedDate].where((s) => s.isNotEmpty).join(' · '),
                      style: typography.bodySmall,
                    ),
                ],
              ),
            ),
            if (item.isDirectory)
              Icon(Icons.chevron_right_rounded, size: 18, color: colors.foregroundMuted),
          ],
        ),
      ),
    );
  }
}
