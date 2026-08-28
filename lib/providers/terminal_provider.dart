import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/terminal/terminal_service.dart';
import '../core/terminal/terminal_session.dart';
import '../core/terminal/terminal_theme_data.dart';
import 'ssh_provider.dart';
import 'storage_provider.dart';

final terminalServiceProvider = Provider<TerminalService>((ref) {
  final service = TerminalService();
  ref.onDispose(() => service.dispose());
  return service;
});

class TerminalSessionsNotifier extends Notifier<List<TerminalSessionItem>> {
  @override
  List<TerminalSessionItem> build() {
    final service = ref.watch(terminalServiceProvider);
    return service.sessions;
  }

  Future<TerminalSessionItem> createSession({
    String? name,
    String? command,
    String? tagColor,
  }) async {
    final service = ref.read(terminalServiceProvider);
    final sshService = ref.read(sshServiceProvider);
    final session = await service.createSession(
      sshService,
      name: name,
      initialCommand: command,
      tagColor: tagColor,
    );
    session.onStatusChange = (_) {
      state = [...service.sessions];
    };
    state = service.sessions;
    return session;
  }

  Future<TerminalSessionItem> createOrAttachTmux(String tmuxName) async {
    final service = ref.read(terminalServiceProvider);
    final sshService = ref.read(sshServiceProvider);
    final session = await service.createOrAttachTmux(sshService, tmuxName);
    session.onStatusChange = (_) {
      state = [...service.sessions];
    };
    state = service.sessions;
    return session;
  }

  Future<bool> reconnect(String id) async {
    final service = ref.read(terminalServiceProvider);
    final sshService = ref.read(sshServiceProvider);
    final success = await service.reconnectSession(id, sshService);
    state = [...service.sessions];
    return success;
  }

  void renameSession(String id, String newName) {
    final service = ref.read(terminalServiceProvider);
    service.renameSession(id, newName);
    state = [...service.sessions];
  }

  void setTagColor(String id, String? color) {
    final service = ref.read(terminalServiceProvider);
    service.setSessionTagColor(id, color);
    state = [...service.sessions];
  }

  void setActive(String id) {
    final service = ref.read(terminalServiceProvider);
    service.setActiveSession(id);
    state = [...service.sessions];
  }

  void closeSession(String id) {
    final service = ref.read(terminalServiceProvider);
    service.closeSession(id);
    state = service.sessions;
  }
}

final terminalSessionsProvider =
    NotifierProvider<TerminalSessionsNotifier, List<TerminalSessionItem>>(
  TerminalSessionsNotifier.new,
);

final activeTerminalSessionProvider = Provider<TerminalSessionItem?>((ref) {
  final service = ref.watch(terminalServiceProvider);
  ref.watch(terminalSessionsProvider);
  return service.activeSession;
});

final tmuxSessionsProvider = FutureProvider<List<TmuxSessionInfo>>((ref) async {
  final service = ref.watch(terminalServiceProvider);
  final sshService = ref.watch(sshServiceProvider);
  return await service.listTmuxSessions(sshService);
});

// Terminal Settings State
class TerminalSettingsState {
  final double fontSize;
  final String themeId;
  final SetuTerminalTheme theme;
  final String fontFamily;
  final String cursorStyle;
  final bool cursorBlink;
  final bool hapticFeedback;

  const TerminalSettingsState({
    required this.fontSize,
    required this.themeId,
    required this.theme,
    required this.fontFamily,
    required this.cursorStyle,
    required this.cursorBlink,
    required this.hapticFeedback,
  });

  TerminalSettingsState copyWith({
    double? fontSize,
    String? themeId,
    SetuTerminalTheme? theme,
    String? fontFamily,
    String? cursorStyle,
    bool? cursorBlink,
    bool? hapticFeedback,
  }) {
    return TerminalSettingsState(
      fontSize: fontSize ?? this.fontSize,
      themeId: themeId ?? this.themeId,
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
      cursorStyle: cursorStyle ?? this.cursorStyle,
      cursorBlink: cursorBlink ?? this.cursorBlink,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}

class TerminalSettingsNotifier extends Notifier<TerminalSettingsState> {
  @override
  TerminalSettingsState build() {
    final prefs = ref.watch(preferencesStoreProvider);
    final themeId = prefs.terminalTheme;
    return TerminalSettingsState(
      fontSize: prefs.terminalFontSize,
      themeId: themeId,
      theme: SetuTerminalTheme.fromId(themeId),
      fontFamily: prefs.terminalFontFamily,
      cursorStyle: prefs.terminalCursorStyle,
      cursorBlink: prefs.terminalCursorBlink,
      hapticFeedback: prefs.terminalHapticFeedback,
    );
  }

  Future<void> setFontSize(double size) async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.setTerminalFontSize(size);
    state = state.copyWith(fontSize: size);
  }

  Future<void> setTheme(String themeId) async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.setTerminalTheme(themeId);
    state = state.copyWith(
      themeId: themeId,
      theme: SetuTerminalTheme.fromId(themeId),
    );
  }

  Future<void> setFontFamily(String family) async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.setTerminalFontFamily(family);
    state = state.copyWith(fontFamily: family);
  }

  Future<void> setCursorStyle(String style) async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.setTerminalCursorStyle(style);
    state = state.copyWith(cursorStyle: style);
  }

  Future<void> setCursorBlink(bool blink) async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.setTerminalCursorBlink(blink);
    state = state.copyWith(cursorBlink: blink);
  }

  Future<void> setHapticFeedback(bool enabled) async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.setTerminalHapticFeedback(enabled);
    state = state.copyWith(hapticFeedback: enabled);
  }
}

final terminalSettingsProvider =
    NotifierProvider<TerminalSettingsNotifier, TerminalSettingsState>(
  TerminalSettingsNotifier.new,
);
