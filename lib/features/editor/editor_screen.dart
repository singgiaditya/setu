import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/styles/github-dark.dart';
import '../../core/sftp/sftp_service.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/ssh_provider.dart';
import '../../providers/storage_provider.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String? initialFilePath;

  const EditorScreen({
    super.key,
    this.initialFilePath,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final CodeLineEditingController _controller;
  final SftpService _sftpService = SftpService();

  String? _filePath;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isModified = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _filePath = widget.initialFilePath;
    _controller = CodeLineEditingController();
    _controller.addListener(_onCodeChanged);

    if (_filePath != null && _filePath!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFileContent());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onCodeChanged);
    _controller.dispose();
    _sftpService.close();
    super.dispose();
  }

  void _onCodeChanged() {
    if (!_isModified && !_isLoading) {
      setState(() {
        _isModified = true;
      });
    }
  }

  Future<void> _loadFileContent() async {
    if (_filePath == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final sshService = ref.read(sshServiceProvider);
    if (!sshService.isConnected || sshService.client == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Workstation not connected. Please connect before editing files.';
      });
      return;
    }

    try {
      if (!_sftpService.isReady) {
        await _sftpService.init(sshService.client!);
      }

      final result = await _sftpService.readFile(_filePath!);
      if (mounted) {
        result.when(
          onSuccess: (content) {
            setState(() {
              _controller.text = content;
              _isLoading = false;
              _isModified = false;
            });
          },
          onFailure: (err) {
            setState(() {
              _errorMessage = err;
              _isLoading = false;
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to open file: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveFile() async {
    if (_filePath == null || _isSaving) return;

    final colors = ref.read(setuColorsProvider);
    setState(() => _isSaving = true);

    final sshService = ref.read(sshServiceProvider);
    if (!sshService.isConnected || sshService.client == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not connected to workstation.'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    try {
      if (!_sftpService.isReady) {
        await _sftpService.init(sshService.client!);
      }

      final content = _controller.text;
      final result = await _sftpService.writeFile(_filePath!, content);

      if (mounted) {
        setState(() => _isSaving = false);
        result.when(
          onSuccess: (_) {
            setState(() => _isModified = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saved ${p.basename(_filePath!)} successfully'),
                backgroundColor: colors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          onFailure: (err) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Save failed: $err'),
                backgroundColor: colors.error,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  void _handleToolbarKey(String key) {
    switch (key) {
      case 'TAB':
        _controller.replaceSelection('  ');
        break;
      case 'ESC':
        _controller.cancelSelection();
        break;
      case 'UND':
        if (_controller.canUndo) _controller.undo();
        break;
      case 'RED':
        if (_controller.canRedo) _controller.redo();
        break;
      case 'CLR':
        _controller.deleteBackward();
        break;
      case '{}':
        _controller.replaceSelection('{}');
        break;
      case '[]':
        _controller.replaceSelection('[]');
        break;
      case '()':
        _controller.replaceSelection('()');
        break;
      case '""':
        _controller.replaceSelection('""');
        break;
      case "''":
        _controller.replaceSelection("''");
        break;
      default:
        _controller.replaceSelection(key);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final prefs = ref.watch(preferencesStoreProvider);

    final fileName = _filePath != null ? p.basename(_filePath!) : 'No file open';
    final fontSize = prefs.editorFontSize;
    final showLineNumbers = prefs.editorLineNumbers;
    final wordWrap = prefs.editorWordWrap;

    return Scaffold(
      backgroundColor: colors.editorBackground,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    fileName,
                    style: typography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isModified) ...[
                  const Gap(6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            if (_filePath != null)
              Text(
                _filePath!,
                style: typography.code.copyWith(
                  fontSize: 10,
                  color: colors.foregroundMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          if (_filePath != null) ...[
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  Icons.save_rounded,
                  color: _isModified ? colors.primary : colors.foregroundMuted,
                  size: 22,
                ),
                onPressed: _saveFile,
                tooltip: 'Save (SFTP)',
              ),
          ],
        ],
      ),
      body: _filePath == null
          ? _buildNoFileState(colors, typography)
          : _isLoading
              ? _buildLoadingState(colors, typography)
              : _errorMessage != null
                  ? _buildErrorState(colors, typography)
                  : Column(
                      children: [
                        // Editor View
                        Expanded(
                          child: CodeEditor(
                            controller: _controller,
                            wordWrap: wordWrap,
                            style: CodeEditorStyle(
                              fontSize: fontSize,
                              textColor: colors.editorForeground,
                              backgroundColor: colors.editorBackground,
                              selectionColor: colors.editorSelection,
                              cursorColor: colors.primary,
                              cursorLineColor: colors.editorCurrentLine,
                              codeTheme: CodeHighlightTheme(
                                languages: {
                                  for (final entry in builtinAllLanguages.entries)
                                    entry.key: CodeHighlightThemeMode(mode: entry.value),
                                },
                                theme: githubDarkTheme,
                              ),
                            ),
                            indicatorBuilder: showLineNumbers
                                ? (context, editingController, chunkController, notifier) {
                                    return DefaultCodeLineNumber(
                                      controller: editingController,
                                      notifier: notifier,
                                      textStyle: TextStyle(
                                        color: colors.editorLineNumber,
                                        fontSize: fontSize - 1,
                                      ),
                                      focusedTextStyle: TextStyle(
                                        color: colors.primary,
                                        fontSize: fontSize - 1,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ),

                        // Developer Keyboard Toolbar
                        _EditorKeyboardToolbar(
                          colors: colors,
                          typography: typography,
                          onKeyTap: _handleToolbarKey,
                        ),
                      ],
                    ),
    );
  }

  Widget _buildNoFileState(dynamic colors, dynamic typography) {
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
              child: Icon(
                Icons.code_off_rounded,
                size: 40,
                color: colors.foregroundMuted,
              ),
            ),
            const Gap(20),
            Text(
              'No File Open',
              style: typography.headlineSmall.copyWith(color: colors.foreground),
            ),
            const Gap(8),
            Text(
              'Select a file from Explorer to view and edit code directly on your remote workstation.',
              textAlign: TextAlign.center,
              style: typography.bodyMedium.copyWith(color: colors.foregroundMuted),
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: () => context.go('/files'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: const Color(0xFF0D1117),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: const Text('Browse Files', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(dynamic colors, dynamic typography) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.primary,
            ),
          ),
          const Gap(14),
          Text(
            'Loading remote file content...',
            style: typography.bodySmall.copyWith(color: colors.foregroundMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic colors, dynamic typography) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44, color: colors.error),
            const Gap(14),
            Text(
              _errorMessage ?? 'Failed to open file',
              textAlign: TextAlign.center,
              style: typography.bodyMedium.copyWith(color: colors.foregroundMuted),
            ),
            const Gap(20),
            OutlinedButton.icon(
              onPressed: _loadFileContent,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorKeyboardToolbar extends StatelessWidget {
  final dynamic colors;
  final dynamic typography;
  final void Function(String key) onKeyTap;

  const _EditorKeyboardToolbar({
    required this.colors,
    required this.typography,
    required this.onKeyTap,
  });

  static const _buttons = [
    'TAB', 'ESC', 'UND', 'RED', 'CLR',
    '{', '}', '[', ']', '(', ')', '<', '>',
    '|', '~', '`', '/', '\\', '-', '_', '=', '+',
    ';', ':', '\$', '&', '"', "'", '!', '?', '#', '@',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: _buttons.length,
        itemBuilder: (context, index) {
          final label = _buttons[index];
          final isSpecial = label == 'TAB' || label == 'ESC' || label == 'UND' || label == 'RED' || label == 'CLR';

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Material(
              color: isSpecial ? colors.surfaceVariant : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: () => onKeyTap(label),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSpecial
                          ? colors.border
                          : colors.border.withValues(alpha: 0.6),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: typography.code.copyWith(
                      fontSize: 12,
                      fontWeight: isSpecial ? FontWeight.bold : FontWeight.w500,
                      color: isSpecial ? colors.primary : colors.foreground,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
