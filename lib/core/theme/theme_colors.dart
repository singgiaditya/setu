import 'package:flutter/material.dart';

class SetuColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color foreground;
  final Color foregroundMuted;
  final Color border;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color selection;

  // Editor specific
  final Color editorBackground;
  final Color editorForeground;
  final Color editorLineNumber;
  final Color editorCurrentLine;
  final Color editorSelection;

  // Terminal specific
  final Color terminalBackground;
  final Color terminalForeground;
  final Color terminalCursor;
  final Color terminalSelection;

  const SetuColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.foreground,
    required this.foregroundMuted,
    required this.border,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.selection,
    required this.editorBackground,
    required this.editorForeground,
    required this.editorLineNumber,
    required this.editorCurrentLine,
    required this.editorSelection,
    required this.terminalBackground,
    required this.terminalForeground,
    required this.terminalCursor,
    required this.terminalSelection,
  });

  factory SetuColors.fromJson(Map<String, dynamic> json) {
    return SetuColors(
      background: _colorFromHex(json['background'] ?? '#0D1117'),
      surface: _colorFromHex(json['surface'] ?? '#161B22'),
      surfaceVariant: _colorFromHex(json['surfaceVariant'] ?? '#21262D'),
      foreground: _colorFromHex(json['foreground'] ?? '#E6EDF3'),
      foregroundMuted: _colorFromHex(json['foregroundMuted'] ?? '#8B949E'),
      border: _colorFromHex(json['border'] ?? '#30363D'),
      primary: _colorFromHex(json['primary'] ?? '#58A6FF'),
      secondary: _colorFromHex(json['secondary'] ?? '#8B949E'),
      accent: _colorFromHex(json['accent'] ?? '#A371F7'),
      success: _colorFromHex(json['success'] ?? '#3FB950'),
      warning: _colorFromHex(json['warning'] ?? '#D29922'),
      error: _colorFromHex(json['error'] ?? '#F85149'),
      info: _colorFromHex(json['info'] ?? '#58A6FF'),
      selection: _colorFromHex(json['selection'] ?? '#264F78'),
      editorBackground: _colorFromHex(json['editorBackground'] ?? '#0D1117'),
      editorForeground: _colorFromHex(json['editorForeground'] ?? '#E6EDF3'),
      editorLineNumber: _colorFromHex(json['editorLineNumber'] ?? '#6E7681'),
      editorCurrentLine: _colorFromHex(json['editorCurrentLine'] ?? '#161B22'),
      editorSelection: _colorFromHex(json['editorSelection'] ?? '#264F78'),
      terminalBackground: _colorFromHex(json['terminalBackground'] ?? '#0D1117'),
      terminalForeground: _colorFromHex(json['terminalForeground'] ?? '#E6EDF3'),
      terminalCursor: _colorFromHex(json['terminalCursor'] ?? '#E6EDF3'),
      terminalSelection: _colorFromHex(json['terminalSelection'] ?? '#264F78'),
    );
  }

  Map<String, String> toJson() => {
    'background': _colorToHex(background),
    'surface': _colorToHex(surface),
    'surfaceVariant': _colorToHex(surfaceVariant),
    'foreground': _colorToHex(foreground),
    'foregroundMuted': _colorToHex(foregroundMuted),
    'border': _colorToHex(border),
    'primary': _colorToHex(primary),
    'secondary': _colorToHex(secondary),
    'accent': _colorToHex(accent),
    'success': _colorToHex(success),
    'warning': _colorToHex(warning),
    'error': _colorToHex(error),
    'info': _colorToHex(info),
    'selection': _colorToHex(selection),
    'editorBackground': _colorToHex(editorBackground),
    'editorForeground': _colorToHex(editorForeground),
    'editorLineNumber': _colorToHex(editorLineNumber),
    'editorCurrentLine': _colorToHex(editorCurrentLine),
    'editorSelection': _colorToHex(editorSelection),
    'terminalBackground': _colorToHex(terminalBackground),
    'terminalForeground': _colorToHex(terminalForeground),
    'terminalCursor': _colorToHex(terminalCursor),
    'terminalSelection': _colorToHex(terminalSelection),
  };

  static Color _colorFromHex(String hex) {
    final cleanHex = hex.replaceFirst('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('0xFF$cleanHex'));
    } else if (cleanHex.length == 8) {
      return Color(int.parse('0x$cleanHex'));
    }
    return const Color(0xFF0D1117);
  }

  static String _colorToHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
