class AppConstants {
  static const String appName = 'SETU';
  static const String appTagline = 'Your Machine, Anywhere.';
  static const String appVersion = '0.2.0';

  // Defaults
  static const int defaultSshPort = 22;
  static const Duration defaultConnectionTimeout = Duration(seconds: 12);
  static const Duration keepAliveInterval = Duration(seconds: 25);
  static const int maxRecentFiles = 20;
  static const int maxRecentProjects = 10;

  // Preferences Keys
  static const String keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keySavedProfiles = 'saved_connection_profiles';
  static const String keyActiveProfileId = 'active_profile_id';
  static const String keySavedProjects = 'saved_projects';
  static const String keyRecentFiles = 'recent_files';
  static const String keyEditorFontSize = 'editor_font_size';
  static const String keyEditorTabSize = 'editor_tab_size';
  static const String keyEditorWordWrap = 'editor_word_wrap';
  static const String keyEditorLineNumbers = 'editor_line_numbers';
  static const String keyTerminalFontSize = 'terminal_font_size';
  static const String keyTerminalScrollback = 'terminal_scrollback';
  static const String keyTerminalCursorStyle = 'terminal_cursor_style';
  static const String keyTerminalTheme = 'terminal_theme';
  static const String keyTerminalFontFamily = 'terminal_font_family';
  static const String keyTerminalCursorBlink = 'terminal_cursor_blink';
  static const String keyTerminalHapticFeedback = 'terminal_haptic_feedback';
  static const String keySavedSnippets = 'saved_terminal_snippets';

  // Secure Storage Keys prefix
  static const String secureKeyPrefix = 'setu_ssh_key_';
  static const String securePassPrefix = 'setu_ssh_pass_';
}
