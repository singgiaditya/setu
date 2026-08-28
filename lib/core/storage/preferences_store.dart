import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/constants/app_constants.dart';

class PreferencesStore {
  final SharedPreferences _prefs;

  PreferencesStore(this._prefs);

  static Future<PreferencesStore> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesStore(prefs);
  }

  // Onboarding
  bool get hasCompletedOnboarding =>
      _prefs.getBool(AppConstants.keyHasCompletedOnboarding) ?? false;

  Future<void> setCompletedOnboarding(bool value) async {
    await _prefs.setBool(AppConstants.keyHasCompletedOnboarding, value);
  }

  // Biometric
  bool get isBiometricEnabled =>
      _prefs.getBool(AppConstants.keyBiometricEnabled) ?? false;

  Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool(AppConstants.keyBiometricEnabled, value);
  }

  // Active Profile
  String? get activeProfileId =>
      _prefs.getString(AppConstants.keyActiveProfileId);

  Future<void> setActiveProfileId(String? id) async {
    if (id == null) {
      await _prefs.remove(AppConstants.keyActiveProfileId);
    } else {
      await _prefs.setString(AppConstants.keyActiveProfileId, id);
    }
  }

  // Saved Profiles JSON
  List<Map<String, dynamic>> getSavedProfiles() {
    final raw = _prefs.getString(AppConstants.keySavedProfiles);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProfiles(List<Map<String, dynamic>> profiles) async {
    await _prefs.setString(AppConstants.keySavedProfiles, jsonEncode(profiles));
  }

  // Saved Projects JSON
  List<Map<String, dynamic>> getSavedProjects() {
    final raw = _prefs.getString(AppConstants.keySavedProjects);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProjects(List<Map<String, dynamic>> projects) async {
    await _prefs.setString(AppConstants.keySavedProjects, jsonEncode(projects));
  }

  // Recent Files JSON
  List<Map<String, dynamic>> getRecentFiles() {
    final raw = _prefs.getString(AppConstants.keyRecentFiles);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentFiles(List<Map<String, dynamic>> files) async {
    await _prefs.setString(AppConstants.keyRecentFiles, jsonEncode(files));
  }

  // Editor settings
  double get editorFontSize =>
      _prefs.getDouble(AppConstants.keyEditorFontSize) ?? 13.0;

  Future<void> setEditorFontSize(double size) async {
    await _prefs.setDouble(AppConstants.keyEditorFontSize, size);
  }

  int get editorTabSize =>
      _prefs.getInt(AppConstants.keyEditorTabSize) ?? 2;

  Future<void> setEditorTabSize(int size) async {
    await _prefs.setInt(AppConstants.keyEditorTabSize, size);
  }

  bool get editorWordWrap =>
      _prefs.getBool(AppConstants.keyEditorWordWrap) ?? false;

  Future<void> setEditorWordWrap(bool wrap) async {
    await _prefs.setBool(AppConstants.keyEditorWordWrap, wrap);
  }

  bool get editorLineNumbers =>
      _prefs.getBool(AppConstants.keyEditorLineNumbers) ?? true;

  Future<void> setEditorLineNumbers(bool show) async {
    await _prefs.setBool(AppConstants.keyEditorLineNumbers, show);
  }

  // Terminal settings
  double get terminalFontSize =>
      _prefs.getDouble(AppConstants.keyTerminalFontSize) ?? 12.5;

  Future<void> setTerminalFontSize(double size) async {
    await _prefs.setDouble(AppConstants.keyTerminalFontSize, size);
  }

  String get terminalTheme =>
      _prefs.getString(AppConstants.keyTerminalTheme) ?? 'setu-dark';

  Future<void> setTerminalTheme(String themeId) async {
    await _prefs.setString(AppConstants.keyTerminalTheme, themeId);
  }

  String get terminalFontFamily =>
      _prefs.getString(AppConstants.keyTerminalFontFamily) ?? 'JetBrainsMono';

  Future<void> setTerminalFontFamily(String family) async {
    await _prefs.setString(AppConstants.keyTerminalFontFamily, family);
  }

  String get terminalCursorStyle =>
      _prefs.getString(AppConstants.keyTerminalCursorStyle) ?? 'block';

  Future<void> setTerminalCursorStyle(String style) async {
    await _prefs.setString(AppConstants.keyTerminalCursorStyle, style);
  }

  bool get terminalCursorBlink =>
      _prefs.getBool(AppConstants.keyTerminalCursorBlink) ?? true;

  Future<void> setTerminalCursorBlink(bool blink) async {
    await _prefs.setBool(AppConstants.keyTerminalCursorBlink, blink);
  }

  bool get terminalHapticFeedback =>
      _prefs.getBool(AppConstants.keyTerminalHapticFeedback) ?? true;

  Future<void> setTerminalHapticFeedback(bool enabled) async {
    await _prefs.setBool(AppConstants.keyTerminalHapticFeedback, enabled);
  }

  // Saved Snippets JSON
  List<Map<String, dynamic>> getSavedSnippets() {
    final raw = _prefs.getString(AppConstants.keySavedSnippets);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSnippets(List<Map<String, dynamic>> snippets) async {
    await _prefs.setString(AppConstants.keySavedSnippets, jsonEncode(snippets));
  }
}
