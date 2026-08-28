import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import '../../shared/models/result.dart';
import 'sftp_file_model.dart';

class SftpService {
  SftpClient? _sftp;

  bool get isReady => _sftp != null;

  Future<void> init(SSHClient client) async {
    _sftp = await client.sftp();
  }

  void close() {
    _sftp?.close();
    _sftp = null;
  }

  Future<Result<List<SftpFileItem>>> listDirectory(String path) async {
    if (_sftp == null) return Result.failure('SFTP not initialised.');
    try {
      final entries = await _sftp!.listdir(path);
      final items = <SftpFileItem>[];
      for (final entry in entries) {
        final name = entry.filename;
        if (name == '.' || name == '..') continue;
        final attrs = entry.attr;
        final isDir = attrs.isDirectory;
        items.add(SftpFileItem(
          name: name,
          path: path.endsWith('/') ? '$path$name' : '$path/$name',
          isDirectory: isDir,
          size: attrs.size ?? 0,
          modifyTime: attrs.modifyTime != null
              ? DateTime.fromMillisecondsSinceEpoch(attrs.modifyTime! * 1000)
              : null,
          permissions: attrs.mode?.value,
          isSymlink: attrs.isSymbolicLink,
        ));
      }
      // Sort: folders first, then alphabetical
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return Result.success(items);
    } catch (e) {
      return Result.failure('Failed to list directory: $e');
    }
  }

  Future<Result<String>> readFile(String path) async {
    if (_sftp == null) return Result.failure('SFTP not initialised.');
    try {
      final file = await _sftp!.open(path);
      final chunks = <int>[];
      await for (final chunk in file.read()) {
        chunks.addAll(chunk);
      }
      await file.close();
      return Result.success(utf8.decode(Uint8List.fromList(chunks), allowMalformed: true));
    } catch (e) {
      return Result.failure('Failed to read file: $e');
    }
  }

  Future<Result<bool>> writeFile(String path, String content) async {
    if (_sftp == null) return Result.failure('SFTP not initialised.');
    try {
      final file = await _sftp!.open(
        path,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );
      final bytes = utf8.encode(content);
      await file.write(Stream.value(Uint8List.fromList(bytes))).done;
      await file.close();
      return Result.success(true);
    } catch (e) {
      return Result.failure('Failed to write file: $e');
    }
  }

  Future<Result<bool>> createDirectory(String path) async {
    if (_sftp == null) return Result.failure('SFTP not initialised.');
    try {
      await _sftp!.mkdir(path);
      return Result.success(true);
    } catch (e) {
      return Result.failure('Failed to create directory: $e');
    }
  }

  Future<Result<bool>> delete(String path, {bool isDirectory = false}) async {
    if (_sftp == null) return Result.failure('SFTP not initialised.');
    try {
      if (isDirectory) {
        await _sftp!.rmdir(path);
      } else {
        await _sftp!.remove(path);
      }
      return Result.success(true);
    } catch (e) {
      return Result.failure('Failed to delete: $e');
    }
  }

  Future<Result<bool>> rename(String oldPath, String newPath) async {
    if (_sftp == null) return Result.failure('SFTP not initialised.');
    try {
      await _sftp!.rename(oldPath, newPath);
      return Result.success(true);
    } catch (e) {
      return Result.failure('Failed to rename: $e');
    }
  }
}
