extension StringExtensions on String {
  String get fileName {
    final parts = split('/');
    return parts.isEmpty ? this : parts.last;
  }

  String get fileExtension {
    final name = fileName;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  String get parentDirectory {
    final parts = split('/');
    if (parts.length <= 1) return '/';
    parts.removeLast();
    final result = parts.join('/');
    return result.isEmpty ? '/' : result;
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
