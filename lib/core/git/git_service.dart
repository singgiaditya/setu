import '../ssh/ssh_service.dart';
import '../../shared/models/result.dart';
import 'git_models.dart';

class GitService {
  GitFileStatusType _parseStatusChar(String c) {
    switch (c) {
      case 'M':
        return GitFileStatusType.modified;
      case 'A':
        return GitFileStatusType.added;
      case 'D':
        return GitFileStatusType.deleted;
      case 'R':
        return GitFileStatusType.renamed;
      case 'C':
        return GitFileStatusType.copied;
      case 'T':
        return GitFileStatusType.typeChanged;
      case '?':
        return GitFileStatusType.untracked;
      default:
        return GitFileStatusType.unknown;
    }
  }

  GitStatusResult parseStatusOutput(String output) {
    if (output.toLowerCase().contains('not a git repository') ||
        output.toLowerCase().contains('fatal:')) {
      return GitStatusResult.notRepo();
    }

    final lines = output.split('\n');
    String branch = 'HEAD';
    String? trackingBranch;
    int ahead = 0;
    int behind = 0;

    final stagedFiles = <GitFileItem>[];
    final unstagedFiles = <GitFileItem>[];
    final untrackedFiles = <GitFileItem>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('##')) {
        // Branch header line: ## main...origin/main [ahead 1, behind 2]
        final header = line.substring(2).trim();
        final branchPart = header.split(' ').first;
        if (branchPart.contains('...')) {
          final parts = branchPart.split('...');
          branch = parts.first;
          trackingBranch = parts.length > 1 ? parts[1] : null;
        } else {
          branch = branchPart;
        }

        if (header.contains('[ahead')) {
          final aheadMatch = RegExp(r'ahead (\d+)').firstMatch(header);
          if (aheadMatch != null) {
            ahead = int.tryParse(aheadMatch.group(1) ?? '0') ?? 0;
          }
        }
        if (header.contains('behind')) {
          final behindMatch = RegExp(r'behind (\d+)').firstMatch(header);
          if (behindMatch != null) {
            behind = int.tryParse(behindMatch.group(1) ?? '0') ?? 0;
          }
        }
        continue;
      }

      if (line.length < 3) continue;
      final x = line[0];
      final y = line[1];
      final rawPath = line.substring(3).trim();

      String path = rawPath;
      String? oldPath;
      if (rawPath.contains(' -> ')) {
        final split = rawPath.split(' -> ');
        oldPath = split.first.trim();
        path = split.last.trim();
      }

      if (x == '?' && y == '?') {
        untrackedFiles.add(GitFileItem(
          path: path,
          status: GitFileStatusType.untracked,
          isStaged: false,
        ));
      } else {
        if (x != ' ') {
          stagedFiles.add(GitFileItem(
            path: path,
            oldPath: oldPath,
            status: _parseStatusChar(x),
            isStaged: true,
          ));
        }
        if (y != ' ') {
          unstagedFiles.add(GitFileItem(
            path: path,
            oldPath: oldPath,
            status: _parseStatusChar(y),
            isStaged: false,
          ));
        }
      }
    }

    return GitStatusResult(
      isRepo: true,
      branch: branch,
      trackingBranch: trackingBranch,
      aheadCount: ahead,
      behindCount: behind,
      stagedFiles: stagedFiles,
      unstagedFiles: unstagedFiles,
      untrackedFiles: untrackedFiles,
    );
  }

  List<GitDiffLine> parseDiffOutput(String diffText) {
    final lines = diffText.split('\n');
    final result = <GitDiffLine>[];
    int? oldLine = 0;
    int? newLine = 0;

    for (final line in lines) {
      if (line.startsWith('@@')) {
        // Hunk header: @@ -1,5 +1,6 @@
        final match = RegExp(r'@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@').firstMatch(line);
        if (match != null) {
          oldLine = int.tryParse(match.group(1) ?? '0');
          newLine = int.tryParse(match.group(2) ?? '0');
        }
        result.add(GitDiffLine(type: DiffLineType.header, content: line));
      } else if (line.startsWith('+') && !line.startsWith('+++')) {
        result.add(GitDiffLine(
          type: DiffLineType.addition,
          content: line,
          newLineNo: newLine,
        ));
        if (newLine != null) newLine++;
      } else if (line.startsWith('-') && !line.startsWith('---')) {
        result.add(GitDiffLine(
          type: DiffLineType.deletion,
          content: line,
          oldLineNo: oldLine,
        ));
        if (oldLine != null) oldLine++;
      } else if (line.startsWith('diff --git') ||
          line.startsWith('index ') ||
          line.startsWith('--- ') ||
          line.startsWith('+++ ')) {
        result.add(GitDiffLine(type: DiffLineType.header, content: line));
      } else {
        result.add(GitDiffLine(
          type: DiffLineType.context,
          content: line,
          oldLineNo: oldLine,
          newLineNo: newLine,
        ));
        if (oldLine != null) oldLine++;
        if (newLine != null) newLine++;
      }
    }
    return result;
  }

  Future<Result<GitStatusResult>> getStatus(
    SshService ssh,
    String workingDir,
  ) async {
    final res = await ssh.runCommand('git -C "$workingDir" status --porcelain=v1 -b');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to execute git status');
    }
    return Result.success(parseStatusOutput(res.data ?? ''));
  }

  Future<Result<List<GitDiffLine>>> getDiff(
    SshService ssh,
    String workingDir, {
    String? filePath,
    bool staged = false,
  }) async {
    final fileArg = filePath != null && filePath.isNotEmpty ? ' -- "$filePath"' : '';
    final stagedArg = staged ? ' --staged' : '';
    final res = await ssh.runCommand('git -C "$workingDir" diff$stagedArg$fileArg');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to execute git diff');
    }
    return Result.success(parseDiffOutput(res.data ?? ''));
  }

  Future<Result<bool>> stageFile(
    SshService ssh,
    String workingDir,
    String filePath,
  ) async {
    final res = await ssh.runCommand('git -C "$workingDir" add -- "$filePath"');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to stage file: $filePath');
    }
    return Result.success(true);
  }

  Future<Result<bool>> stageAll(
    SshService ssh,
    String workingDir,
  ) async {
    final res = await ssh.runCommand('git -C "$workingDir" add -A');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to stage all changes');
    }
    return Result.success(true);
  }

  Future<Result<bool>> unstageFile(
    SshService ssh,
    String workingDir,
    String filePath,
  ) async {
    final res = await ssh.runCommand(
      'git -C "$workingDir" restore --staged -- "$filePath" || git -C "$workingDir" reset HEAD -- "$filePath"',
    );
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to unstage file: $filePath');
    }
    return Result.success(true);
  }

  Future<Result<bool>> discardChanges(
    SshService ssh,
    String workingDir,
    String filePath,
  ) async {
    final res = await ssh.runCommand(
      'git -C "$workingDir" restore -- "$filePath" || git -C "$workingDir" checkout -- "$filePath"',
    );
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to discard changes for: $filePath');
    }
    return Result.success(true);
  }

  Future<Result<String>> commit(
    SshService ssh,
    String workingDir,
    String message,
  ) async {
    final escaped = message.replaceAll('"', '\\"');
    final res = await ssh.runCommand('git -C "$workingDir" commit -m "$escaped"');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Commit failed');
    }
    return Result.success(res.data ?? 'Commit successful');
  }

  Future<Result<String>> push(
    SshService ssh,
    String workingDir,
  ) async {
    final res = await ssh.runCommand('git -C "$workingDir" push');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Git push failed');
    }
    return Result.success(res.data ?? 'Pushed successfully');
  }

  Future<Result<String>> pull(
    SshService ssh,
    String workingDir,
  ) async {
    final res = await ssh.runCommand('git -C "$workingDir" pull');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Git pull failed');
    }
    return Result.success(res.data ?? 'Pulled successfully');
  }

  Future<Result<String>> fetch(
    SshService ssh,
    String workingDir,
  ) async {
    final res = await ssh.runCommand('git -C "$workingDir" fetch');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Git fetch failed');
    }
    return Result.success(res.data ?? 'Fetched successfully');
  }

  Future<Result<List<GitBranch>>> getBranches(
    SshService ssh,
    String workingDir,
  ) async {
    final res = await ssh.runCommand('git -C "$workingDir" branch -a --format="%(refname:short)|%(HEAD)"');
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to list branches');
    }

    final branches = <GitBranch>[];
    final lines = (res.data ?? '').split('\n');
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.trim().split('|');
      final name = parts.first.trim();
      final isCurrent = parts.length > 1 && parts[1].trim() == '*';
      final isRemote = name.startsWith('origin/') || name.contains('/origin/');
      branches.add(GitBranch(
        name: name,
        isCurrent: isCurrent,
        isRemote: isRemote,
      ));
    }
    return Result.success(branches);
  }

  Future<Result<bool>> checkoutBranch(
    SshService ssh,
    String workingDir,
    String branchName, {
    bool createNew = false,
  }) async {
    final cmd = createNew
        ? 'git -C "$workingDir" checkout -b "$branchName"'
        : 'git -C "$workingDir" checkout "$branchName"';
    final res = await ssh.runCommand(cmd);
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to checkout branch: $branchName');
    }
    return Result.success(true);
  }

  Future<Result<List<GitCommitLog>>> getCommitHistory(
    SshService ssh,
    String workingDir, {
    int limit = 20,
  }) async {
    final res = await ssh.runCommand(
      'git -C "$workingDir" log -n $limit --pretty=format:"%h|%an|%ad|%s" --date=short',
    );
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to retrieve commit history');
    }

    final list = <GitCommitLog>[];
    final lines = (res.data ?? '').split('\n');
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('|');
      if (parts.length >= 4) {
        list.add(GitCommitLog(
          hash: parts[0],
          author: parts[1],
          date: parts[2],
          subject: parts.sublist(3).join('|'),
        ));
      }
    }
    return Result.success(list);
  }
}
