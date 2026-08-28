import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';

enum TerminalSessionStatus {
  connected,
  disconnected,
  error,
}

class TerminalSessionItem {
  final String id;
  String name;
  final Terminal terminal;
  SSHSession? sshSession;
  final bool isTmux;
  final String? tmuxSessionName;
  final DateTime createdAt;
  String? tagColor;
  TerminalSessionStatus status;
  void Function(TerminalSessionStatus status)? onStatusChange;

  StreamSubscription? _stdoutSub;
  StreamSubscription? _stderrSub;

  TerminalSessionItem({
    required this.id,
    required this.name,
    required this.terminal,
    this.sshSession,
    this.isTmux = false,
    this.tmuxSessionName,
    required this.createdAt,
    this.tagColor,
    TerminalSessionStatus? status,
    this.onStatusChange,
  }) : status = status ?? (sshSession != null ? TerminalSessionStatus.connected : TerminalSessionStatus.disconnected) {
    _initWiring();
  }

  void _initWiring() {
    if (sshSession == null) {
      status = TerminalSessionStatus.disconnected;
      return;
    }

    status = TerminalSessionStatus.connected;

    // Terminal keystrokes -> SSH Session stdin
    terminal.onOutput = (data) {
      sshSession?.write(utf8.encode(data));
    };

    // Terminal resize -> SSH Session PTY resize
    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      sshSession?.resizeTerminal(width, height, pixelWidth, pixelHeight);
    };

    // SSH Session stdout -> Terminal display
    _stdoutSub = sshSession?.stdout.listen(
      (data) {
        terminal.write(utf8.decode(data, allowMalformed: true));
      },
      onError: (err) {
        terminal.write('\r\n\x1b[31m[Session stream error: $err]\x1b[0m\r\n');
        status = TerminalSessionStatus.error;
        onStatusChange?.call(status);
      },
      onDone: () {
        terminal.write('\r\n\x1b[33m[Session ended]\x1b[0m\r\n');
        status = TerminalSessionStatus.disconnected;
        onStatusChange?.call(status);
      },
    );

    // SSH Session stderr -> Terminal display
    _stderrSub = sshSession?.stderr.listen((data) {
      terminal.write(utf8.decode(data, allowMalformed: true));
    });
  }

  void attachShell(SSHSession newShell) {
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    sshSession?.close();
    sshSession = newShell;
    _initWiring();
    onStatusChange?.call(status);
  }

  void resize(int cols, int rows) {
    terminal.resize(cols, rows);
    sshSession?.resizeTerminal(cols, rows);
  }

  void writeInput(String data) {
    terminal.onOutput?.call(data);
  }

  void sendCtrl(String char) {
    if (char.isEmpty) return;
    final code = char.toUpperCase().codeUnitAt(0) - 64;
    if (code > 0 && code <= 26) {
      writeInput(String.fromCharCode(code));
    }
  }

  void dispose() {
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    sshSession?.close();
    status = TerminalSessionStatus.disconnected;
  }
}
