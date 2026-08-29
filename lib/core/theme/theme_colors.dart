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

  SetuColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? foreground,
    Color? foregroundMuted,
    Color? border,
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? selection,
    Color? editorBackground,
    Color? editorForeground,
    Color? editorLineNumber,
    Color? editorCurrentLine,
    Color? editorSelection,
    Color? terminalBackground,
    Color? terminalForeground,
    Color? terminalCursor,
    Color? terminalSelection,
  }) {
    return SetuColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      foreground: foreground ?? this.foreground,
      foregroundMuted: foregroundMuted ?? this.foregroundMuted,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      selection: selection ?? this.selection,
      editorBackground: editorBackground ?? this.editorBackground,
      editorForeground: editorForeground ?? this.editorForeground,
      editorLineNumber: editorLineNumber ?? this.editorLineNumber,
      editorCurrentLine: editorCurrentLine ?? this.editorCurrentLine,
      editorSelection: editorSelection ?? this.editorSelection,
      terminalBackground: terminalBackground ?? this.terminalBackground,
      terminalForeground: terminalForeground ?? this.terminalForeground,
      terminalCursor: terminalCursor ?? this.terminalCursor,
      terminalSelection: terminalSelection ?? this.terminalSelection,
    );
  }

  factory SetuColors.fromJson(Map<String, dynamic> json) {
    return SetuColors(
      background: colorFromHex(json['background']?.toString() ?? '#0D1117'),
      surface: colorFromHex(json['surface']?.toString() ?? '#161B22'),
      surfaceVariant: colorFromHex(json['surfaceVariant']?.toString() ?? '#21262D'),
      foreground: colorFromHex(json['foreground']?.toString() ?? '#E6EDF3'),
      foregroundMuted: colorFromHex(json['foregroundMuted']?.toString() ?? '#8B949E'),
      border: colorFromHex(json['border']?.toString() ?? '#30363D'),
      primary: colorFromHex(json['primary']?.toString() ?? '#58A6FF'),
      secondary: colorFromHex(json['secondary']?.toString() ?? '#8B949E'),
      accent: colorFromHex(json['accent']?.toString() ?? '#A371F7'),
      success: colorFromHex(json['success']?.toString() ?? '#3FB950'),
      warning: colorFromHex(json['warning']?.toString() ?? '#D29922'),
      error: colorFromHex(json['error']?.toString() ?? '#F85149'),
      info: colorFromHex(json['info']?.toString() ?? '#58A6FF'),
      selection: colorFromHex(json['selection']?.toString() ?? '#264F78'),
      editorBackground: colorFromHex(json['editorBackground']?.toString() ?? '#0D1117'),
      editorForeground: colorFromHex(json['editorForeground']?.toString() ?? '#E6EDF3'),
      editorLineNumber: colorFromHex(json['editorLineNumber']?.toString() ?? '#6E7681'),
      editorCurrentLine: colorFromHex(json['editorCurrentLine']?.toString() ?? '#161B22'),
      editorSelection: colorFromHex(json['editorSelection']?.toString() ?? '#264F78'),
      terminalBackground: colorFromHex(json['terminalBackground']?.toString() ?? '#0D1117'),
      terminalForeground: colorFromHex(json['terminalForeground']?.toString() ?? '#E6EDF3'),
      terminalCursor: colorFromHex(json['terminalCursor']?.toString() ?? '#E6EDF3'),
      terminalSelection: colorFromHex(json['terminalSelection']?.toString() ?? '#264F78'),
    );
  }

  Map<String, String> toJson() => {
    'background': colorToHex(background),
    'surface': colorToHex(surface),
    'surfaceVariant': colorToHex(surfaceVariant),
    'foreground': colorToHex(foreground),
    'foregroundMuted': colorToHex(foregroundMuted),
    'border': colorToHex(border),
    'primary': colorToHex(primary),
    'secondary': colorToHex(secondary),
    'accent': colorToHex(accent),
    'success': colorToHex(success),
    'warning': colorToHex(warning),
    'error': colorToHex(error),
    'info': colorToHex(info),
    'selection': colorToHex(selection),
    'editorBackground': colorToHex(editorBackground),
    'editorForeground': colorToHex(editorForeground),
    'editorLineNumber': colorToHex(editorLineNumber),
    'editorCurrentLine': colorToHex(editorCurrentLine),
    'editorSelection': colorToHex(editorSelection),
    'terminalBackground': colorToHex(terminalBackground),
    'terminalForeground': colorToHex(terminalForeground),
    'terminalCursor': colorToHex(terminalCursor),
    'terminalSelection': colorToHex(terminalSelection),
  };

  static Color colorFromHex(String hex) {
    final cleanHex = hex.replaceFirst('#', '').trim();
    if (cleanHex.length == 6) {
      return Color(int.parse('0xFF$cleanHex'));
    } else if (cleanHex.length == 8) {
      return Color(int.parse('0x$cleanHex'));
    }
    return const Color(0xFF0D1117);
  }

  static String colorToHex(Color color, {bool includeHash = true, bool includeAlpha = false}) {
    final a = color.a;
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    final aInt = (a * 255).round();

    final hexRgb = '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

    if (includeAlpha) {
      final hexA = aInt.toRadixString(16).padLeft(2, '0').toUpperCase();
      return includeHash ? '#$hexA$hexRgb' : '$hexA$hexRgb';
    }
    return includeHash ? '#$hexRgb' : hexRgb;
  }
}
