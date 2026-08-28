import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_colors.dart';

class SetuTypography {
  final SetuColors colors;

  const SetuTypography(this.colors);

  // Brand / Logo
  TextStyle get brand => GoogleFonts.spaceGrotesk(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: colors.foreground,
    letterSpacing: 2.5,
  );

  TextStyle get brandSmall => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: colors.foreground,
    letterSpacing: 1.5,
  );

  // UI Headings
  TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: colors.foreground,
  );

  TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: colors.foreground,
  );

  TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: colors.foreground,
  );

  TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: colors.foreground,
  );

  TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: colors.foreground,
  );

  // UI Body
  TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: colors.foreground,
    height: 1.4,
  );

  TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: colors.foreground,
    height: 1.4,
  );

  TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: colors.foregroundMuted,
    height: 1.3,
  );

  TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: colors.foreground,
  );

  TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: colors.foregroundMuted,
  );

  TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: colors.foregroundMuted,
    letterSpacing: 0.5,
  );

  // Code / Terminal Monospace
  TextStyle get code => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: colors.editorForeground,
    height: 1.5,
  );

  TextStyle get terminal => GoogleFonts.jetBrainsMono(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: colors.terminalForeground,
    height: 1.35,
  );
}
