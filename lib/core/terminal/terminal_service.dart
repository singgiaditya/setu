import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:xterm/xterm.dart';
import '../ssh/ssh_service.dart';
import 'terminal_session.dart';

class TmuxSessionInfo {
  final String name;
  final bool isAttached;
  final int windowsCount;

  const TmuxSessionInfo({
    required this.name,
    required this.isAttached,
    required this.windowsCount,
  });
}

class TerminalService {
  final Map<String, TerminalSessionItem> _sessions = {};
  String? _activeSessionId;

  List<TerminalSessionItem> get sessions => _sessions.values.toList();
  TerminalSessionItem? get activeSession =>
      _activeSessionId != null ? _sessions[_activeSessionId] : null;
  String? get activeSessionId => _activeSessionId;

  void setActiveSession(String id) {
    if (_sessions.containsKey(id)) {
      _activeSessionId = id;
    }
  }

  Future<TerminalSessionItem> createSession(
    SshService sshService, {
    String? name,
    String? initialCommand,
    int width = 80,
    int height = 25,
  }) async {
    final terminal = Terminal(maxLines: 5000);
    final id = const Uuid().v4();
    final sessionName = name ?? 'Session ${_sessions.length + 1}';

    if (!sshService.isConnected) {
      terminal.write('\x1b[33m[SETU] Not connected to workstation.\x1b[0m\r\n');
      terminal.write('\x1b[90mConnect to your workstation first from the Workstations tab.\x1b[0m\r\n\r\n');
      final offlineSession = TerminalSessionItem(
        id: id,
        name: sessionName,
        terminal: terminal,
        createdAt: DateTime.now(),
      );
      _sessions[id] = offlineSession;
      _activeSessionId = id;
      return offlineSession;
    }

    try {
      final shell = await sshService.createShell(width: width, height: height);
      if (initialCommand != null && shell != null) {
        shell.write(utf8.encode('$initialCommand\n'));
      }

      final item = TerminalSessionItem(
        id: id,
        name: sessionName,
        terminal: terminal,
        sshSession: shell,
        createdAt: DateTime.now(),
      );

      _sessions[id] = item;
      _activeSessionId = id;
      return item;
    } catch (e) {
      terminal.write('\x1b[31m[Failed to spawn shell: $e]\x1b[0m\r\n');
      final errItem = TerminalSessionItem(
        id: id,
        name: sessionName,
        terminal: terminal,
        createdAt: DateTime.now(),
      );
      _sessions[id] = errItem;
      _activeSessionId = id;
      return errItem;
    }
  }

  Future<TerminalSessionItem> createOrAttachTmux(
    SshService sshService,
    String tmuxSessionName, {
    int width = 80,
    int height = 25,
  }) async {
    final cmd = 'tmux new-session -A -s "$tmuxSessionName"';
    final session = await createSession(
      sshService,
      name: 'tmux:$tmuxSessionName',
      initialCommand: cmd,
      width: width,
      height: height,
    );
    return session;
  }

  Future<List<TmuxSessionInfo>> listTmuxSessions(SshService sshService) async {
    if (!sshService.isConnected) return [];

    final result = await sshService.runCommand('tmux list-sessions -F "#{session_name}:#{session_attached}:#{session_windows}" 2>/dev/null || true');
    if (result.isFailure || result.data == null || result.data!.trim().isEmpty) {
      return [];
    }

    final lines = result.data!.trim().split('\n');
    final list = <TmuxSessionInfo>[];
    for (final line in lines) {
      final parts = line.trim().split(':');
      if (parts.length >= 3) {
        list.add(TmuxSessionInfo(
          name: parts[0],
          isAttached: parts[1] == '1',
          windowsCount: int.tryParse(parts[2]) ?? 1,
        ));
      }
    }
    return list;
  }

  void closeSession(String id) {
    final item = _sessions.remove(id);
    item?.dispose();
    if (_activeSessionId == id) {
      _activeSessionId = _sessions.keys.isNotEmpty ? _sessions.keys.first : null;
    }
  }

  void dispose() {
    for (final session in _sessions.values) {
      session.dispose();
    }
    _sessions.clear();
    _activeSessionId = null;
  }
}
