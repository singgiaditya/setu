import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/git/git_models.dart';
import '../core/git/git_service.dart';
import 'ssh_provider.dart';

final gitServiceProvider = Provider<GitService>((ref) {
  return GitService();
});

class WorkspaceGitState {
  final bool isLoading;
  final bool isSyncing;
  final GitStatusResult? status;
  final List<GitBranch> branches;
  final List<GitCommitLog> history;
  final String? error;
  final List<GitDiffLine>? activeDiff;
  final String? activeDiffFile;
  final bool activeDiffIsStaged;

  const WorkspaceGitState({
    this.isLoading = false,
    this.isSyncing = false,
    this.status,
    this.branches = const [],
    this.history = const [],
    this.error,
    this.activeDiff,
    this.activeDiffFile,
    this.activeDiffIsStaged = false,
  });

  WorkspaceGitState copyWith({
    bool? isLoading,
    bool? isSyncing,
    GitStatusResult? status,
    List<GitBranch>? branches,
    List<GitCommitLog>? history,
    String? error,
    bool clearError = false,
    List<GitDiffLine>? activeDiff,
    String? activeDiffFile,
    bool? activeDiffIsStaged,
    bool clearDiff = false,
  }) {
    return WorkspaceGitState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      status: status ?? this.status,
      branches: branches ?? this.branches,
      history: history ?? this.history,
      error: clearError ? null : (error ?? this.error),
      activeDiff: clearDiff ? null : (activeDiff ?? this.activeDiff),
      activeDiffFile: clearDiff ? null : (activeDiffFile ?? this.activeDiffFile),
      activeDiffIsStaged: activeDiffIsStaged ?? this.activeDiffIsStaged,
    );
  }
}

class WorkspaceGitNotifier extends ValueNotifier<WorkspaceGitState> {
  final Ref ref;
  final String workingDir;

  WorkspaceGitNotifier(this.ref, this.workingDir)
      : super(const WorkspaceGitState(isLoading: true)) {
    refresh();
  }

  void _setState(WorkspaceGitState newState) {
    value = newState;
  }

  Future<void> refresh() async {
    _setState(value.copyWith(isLoading: true, clearError: true));
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);

    if (!ssh.isConnected) {
      _setState(value.copyWith(
        isLoading: false,
        error: 'Workstation not connected.',
      ));
      return;
    }

    final statusRes = await git.getStatus(ssh, workingDir);
    final branchesRes = await git.getBranches(ssh, workingDir);

    _setState(value.copyWith(
      isLoading: false,
      status: statusRes.data ?? GitStatusResult.notRepo(),
      branches: branchesRes.data ?? [],
      error: statusRes.isFailure ? statusRes.error : null,
    ));
  }

  Future<bool> stageFile(String filePath) async {
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);
    final res = await git.stageFile(ssh, workingDir, filePath);
    if (res.isSuccess) {
      await refresh();
      return true;
    }
    _setState(value.copyWith(error: res.error));
    return false;
  }

  Future<bool> stageAll() async {
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);
    final res = await git.stageAll(ssh, workingDir);
    if (res.isSuccess) {
      await refresh();
      return true;
    }
    _setState(value.copyWith(error: res.error));
    return false;
  }

  Future<bool> unstageFile(String filePath) async {
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);
    final res = await git.unstageFile(ssh, workingDir, filePath);
    if (res.isSuccess) {
      await refresh();
      return true;
    }
    _setState(value.copyWith(error: res.error));
    return false;
  }

  Future<bool> discardChanges(String filePath) async {
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);
    final res = await git.discardChanges(ssh, workingDir, filePath);
    if (res.isSuccess) {
      await refresh();
      return true;
    }
    _setState(value.copyWith(error: res.error));
    return false;
  }

  Future<bool> commit(String message) async {
    if (message.trim().isEmpty) return false;
    _setState(value.copyWith(isSyncing: true, clearError: true));
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);

    final res = await git.commit(ssh, workingDir, message.trim());
    _setState(value.copyWith(isSyncing: false));

    if (res.isSuccess) {
      await refresh();
      return true;
    } else {
      _setState(value.copyWith(error: res.error));
      return false;
    }
  }

  Future<bool> commitAndPush(String message) async {
    final success = await commit(message);
    if (success) {
      return await push();
    }
    return false;
  }

  Future<bool> push() async {
    _setState(value.copyWith(isSyncing: true, clearError: true));
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);

    final res = await git.push(ssh, workingDir);
    _setState(value.copyWith(isSyncing: false));

    if (res.isSuccess) {
      await refresh();
      return true;
    } else {
      _setState(value.copyWith(error: res.error));
      return false;
    }
  }

  Future<bool> pull() async {
    _setState(value.copyWith(isSyncing: true, clearError: true));
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);

    final res = await git.pull(ssh, workingDir);
    _setState(value.copyWith(isSyncing: false));

    if (res.isSuccess) {
      await refresh();
      return true;
    } else {
      _setState(value.copyWith(error: res.error));
      return false;
    }
  }

  Future<bool> fetch() async {
    _setState(value.copyWith(isSyncing: true, clearError: true));
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);

    final res = await git.fetch(ssh, workingDir);
    _setState(value.copyWith(isSyncing: false));

    if (res.isSuccess) {
      await refresh();
      return true;
    } else {
      _setState(value.copyWith(error: res.error));
      return false;
    }
  }

  Future<bool> checkoutBranch(String branchName, {bool createNew = false}) async {
    _setState(value.copyWith(isLoading: true, clearError: true));
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);

    final res = await git.checkoutBranch(ssh, workingDir, branchName, createNew: createNew);
    if (res.isSuccess) {
      await refresh();
      return true;
    } else {
      _setState(value.copyWith(isLoading: false, error: res.error));
      return false;
    }
  }

  Future<void> loadDiff(String filePath, {bool staged = false}) async {
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);

    final res = await git.getDiff(ssh, workingDir, filePath: filePath, staged: staged);
    if (res.isSuccess) {
      _setState(value.copyWith(
        activeDiff: res.data ?? [],
        activeDiffFile: filePath,
        activeDiffIsStaged: staged,
      ));
    }
  }

  void clearDiff() {
    _setState(value.copyWith(clearDiff: true));
  }

  Future<void> loadHistory() async {
    final ssh = ref.read(sshServiceProvider);
    final git = ref.read(gitServiceProvider);

    final res = await git.getCommitHistory(ssh, workingDir);
    if (res.isSuccess) {
      _setState(value.copyWith(history: res.data ?? []));
    }
  }
}

final workspaceGitProvider = Provider.family<
    WorkspaceGitNotifier, String>((ref, workingDir) {
  final notifier = WorkspaceGitNotifier(ref, workingDir);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
