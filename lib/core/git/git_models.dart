import 'package:equatable/equatable.dart';

enum GitFileStatusType {
  modified,
  added,
  deleted,
  renamed,
  copied,
  untracked,
  typeChanged,
  unknown,
}

class GitFileItem extends Equatable {
  final String path;
  final String? oldPath;
  final GitFileStatusType status;
  final bool isStaged;

  const GitFileItem({
    required this.path,
    this.oldPath,
    required this.status,
    required this.isStaged,
  });

  String get displayName {
    if (status == GitFileStatusType.renamed && oldPath != null) {
      return '$oldPath → $path';
    }
    return path;
  }

  String get fileName {
    final segments = path.split('/');
    return segments.isNotEmpty ? segments.last : path;
  }

  String get directoryPath {
    final lastSlash = path.lastIndexOf('/');
    return lastSlash != -1 ? path.substring(0, lastSlash) : '';
  }

  String get statusBadge {
    switch (status) {
      case GitFileStatusType.modified:
        return 'M';
      case GitFileStatusType.added:
        return 'A';
      case GitFileStatusType.deleted:
        return 'D';
      case GitFileStatusType.renamed:
        return 'R';
      case GitFileStatusType.copied:
        return 'C';
      case GitFileStatusType.untracked:
        return 'U';
      case GitFileStatusType.typeChanged:
        return 'T';
      case GitFileStatusType.unknown:
        return '?';
    }
  }

  @override
  List<Object?> get props => [path, oldPath, status, isStaged];
}

class GitStatusResult extends Equatable {
  final bool isRepo;
  final String branch;
  final String? trackingBranch;
  final int aheadCount;
  final int behindCount;
  final List<GitFileItem> stagedFiles;
  final List<GitFileItem> unstagedFiles;
  final List<GitFileItem> untrackedFiles;

  const GitStatusResult({
    required this.isRepo,
    required this.branch,
    this.trackingBranch,
    this.aheadCount = 0,
    this.behindCount = 0,
    required this.stagedFiles,
    required this.unstagedFiles,
    required this.untrackedFiles,
  });

  factory GitStatusResult.notRepo() => const GitStatusResult(
        isRepo: false,
        branch: '',
        stagedFiles: [],
        unstagedFiles: [],
        untrackedFiles: [],
      );

  factory GitStatusResult.empty(String branch) => GitStatusResult(
        isRepo: true,
        branch: branch,
        stagedFiles: const [],
        unstagedFiles: const [],
        untrackedFiles: const [],
      );

  bool get isClean =>
      stagedFiles.isEmpty && unstagedFiles.isEmpty && untrackedFiles.isEmpty;

  int get totalChanges =>
      stagedFiles.length + unstagedFiles.length + untrackedFiles.length;

  @override
  List<Object?> get props => [
        isRepo,
        branch,
        trackingBranch,
        aheadCount,
        behindCount,
        stagedFiles,
        unstagedFiles,
        untrackedFiles,
      ];
}

class GitBranch extends Equatable {
  final String name;
  final bool isCurrent;
  final bool isRemote;

  const GitBranch({
    required this.name,
    required this.isCurrent,
    this.isRemote = false,
  });

  String get shortName {
    if (isRemote && name.startsWith('origin/')) {
      return name.substring(7);
    }
    return name;
  }

  @override
  List<Object?> get props => [name, isCurrent, isRemote];
}

class GitCommitLog extends Equatable {
  final String hash;
  final String author;
  final String date;
  final String subject;

  const GitCommitLog({
    required this.hash,
    required this.author,
    required this.date,
    required this.subject,
  });

  @override
  List<Object?> get props => [hash, author, date, subject];
}

enum DiffLineType {
  addition,
  deletion,
  context,
  header,
}

class GitDiffLine extends Equatable {
  final DiffLineType type;
  final String content;
  final int? oldLineNo;
  final int? newLineNo;

  const GitDiffLine({
    required this.type,
    required this.content,
    this.oldLineNo,
    this.newLineNo,
  });

  @override
  List<Object?> get props => [type, content, oldLineNo, newLineNo];
}
