import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SftpFileItem {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime? modifyTime;
  final int? permissions;
  final bool isSymlink;

  const SftpFileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    this.modifyTime,
    this.permissions,
    this.isSymlink = false,
  });

  bool get isHidden => name.startsWith('.');

  String get fileExtension {
    if (isDirectory) return '';
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDate {
    if (modifyTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(modifyTime!);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(modifyTime!);
    if (diff.inDays < 7) return DateFormat('E, HH:mm').format(modifyTime!);
    return DateFormat('MMM d, yyyy').format(modifyTime!);
  }

  IconData get iconData {
    if (isDirectory) return Icons.folder_rounded;
    if (isSymlink) return Icons.link_rounded;
    switch (fileExtension) {
      case 'dart':
        return Icons.flutter_dash_rounded;
      case 'py':
        return Icons.code_rounded;
      case 'js':
      case 'ts':
      case 'json':
        return Icons.javascript_rounded;
      case 'html':
      case 'css':
        return Icons.language_rounded;
      case 'sh':
      case 'bash':
        return Icons.terminal_rounded;
      case 'yaml':
      case 'yml':
      case 'toml':
        return Icons.settings_rounded;
      case 'md':
      case 'txt':
        return Icons.description_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'svg':
        return Icons.image_rounded;
      case 'zip':
      case 'tar':
      case 'gz':
        return Icons.folder_zip_rounded;
      case 'lock':
        return Icons.lock_outline_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get iconColor {
    if (isDirectory) return const Color(0xFF58A6FF);
    if (isSymlink) return const Color(0xFFA371F7);
    switch (fileExtension) {
      case 'dart':
        return const Color(0xFF58A6FF);
      case 'py':
        return const Color(0xFFD29922);
      case 'js':
      case 'ts':
      case 'json':
        return const Color(0xFFD29922);
      case 'sh':
        return const Color(0xFF3FB950);
      case 'yaml':
      case 'yml':
        return const Color(0xFFA371F7);
      case 'md':
      case 'txt':
        return const Color(0xFF8B949E);
      default:
        return const Color(0xFF8B949E);
    }
  }
}
