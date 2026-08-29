import 'package:flutter_test/flutter_test.dart';
import 'package:setu/core/git/git_models.dart';
import 'package:setu/core/git/git_service.dart';

void main() {
  group('GitService Parsing Unit Tests', () {
    late GitService gitService;

    setUp(() {
      gitService = GitService();
    });

    test('parseStatusOutput handles clean repository', () {
      const output = '## main...origin/main\n';
      final result = gitService.parseStatusOutput(output);

      expect(result.isRepo, isTrue);
      expect(result.branch, equals('main'));
      expect(result.trackingBranch, equals('origin/main'));
      expect(result.aheadCount, equals(0));
      expect(result.behindCount, equals(0));
      expect(result.isClean, isTrue);
      expect(result.totalChanges, equals(0));
    });

    test('parseStatusOutput handles ahead and behind commits with changes', () {
      const output = '''
## feature/login...origin/feature/login [ahead 2, behind 1]
M  lib/main.dart
 M lib/core/auth.dart
?? lib/new_file.dart
D  old_file.txt
''';
      final result = gitService.parseStatusOutput(output);

      expect(result.isRepo, isTrue);
      expect(result.branch, equals('feature/login'));
      expect(result.aheadCount, equals(2));
      expect(result.behindCount, equals(1));
      expect(result.isClean, isFalse);

      // Staged files: lib/main.dart (M ), old_file.txt (D )
      expect(result.stagedFiles.length, equals(2));
      expect(result.stagedFiles[0].path, equals('lib/main.dart'));
      expect(result.stagedFiles[0].status, equals(GitFileStatusType.modified));
      expect(result.stagedFiles[1].path, equals('old_file.txt'));
      expect(result.stagedFiles[1].status, equals(GitFileStatusType.deleted));

      // Unstaged files: lib/core/auth.dart ( M)
      expect(result.unstagedFiles.length, equals(1));
      expect(result.unstagedFiles[0].path, equals('lib/core/auth.dart'));
      expect(result.unstagedFiles[0].status, equals(GitFileStatusType.modified));

      // Untracked files: lib/new_file.dart (??)
      expect(result.untrackedFiles.length, equals(1));
      expect(result.untrackedFiles[0].path, equals('lib/new_file.dart'));
      expect(result.untrackedFiles[0].status, equals(GitFileStatusType.untracked));
    });

    test('parseStatusOutput handles non-git directory', () {
      const output = 'fatal: not a git repository (or any of the parent directories): .git\n';
      final result = gitService.parseStatusOutput(output);

      expect(result.isRepo, isFalse);
      expect(result.isClean, isTrue);
    });

    test('parseDiffOutput parses additions, deletions, and headers', () {
      const diffText = '''
diff --git a/README.md b/README.md
index 1234..5678 100644
--- a/README.md
+++ b/README.md
@@ -1,3 +1,4 @@
 # My Project
-Old description
+New enhanced description
+Added line
 Context line
''';
      final diffLines = gitService.parseDiffOutput(diffText);

      expect(diffLines.isNotEmpty, isTrue);
      expect(diffLines.any((l) => l.type == DiffLineType.addition && l.content.contains('New enhanced description')), isTrue);
      expect(diffLines.any((l) => l.type == DiffLineType.deletion && l.content.contains('Old description')), isTrue);
      expect(diffLines.any((l) => l.type == DiffLineType.context && l.content.contains('Context line')), isTrue);
    });
  });
}
