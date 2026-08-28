import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/theme/theme_typography.dart';
import '../../core/theme/themes/dark_theme.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  SetuColors get colors => darkThemeColors;
  SetuTypography get typography => SetuTypography(darkThemeColors);

  void showSnackBar(String message, {bool isError = false, Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: isError ? const Color(0xFFF85149) : const Color(0xFF161B22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isError ? const Color(0xFFF85149).withValues(alpha: 0.5) : const Color(0xFF30363D),
          ),
        ),
        duration: duration,
      ),
    );
  }
}
