import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';

class TerminalSessionItem {
  final String id;
  final String name;
  final Terminal terminal;
  final SSHSession? sshSession;
  final bool isTmux;
  final String? tmuxSessionName;
  final DateTime createdAt;
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
  }) {
    _initWiring();
  }

  void _initWiring() {
    if (sshSession == null) return;

    // Terminal keystrokes -> SSH Session stdin
    terminal.onOutput = (data) {
      sshSession?.write(utf8.encode(data));
    };

    // SSH Session stdout -> Terminal display
    _stdoutSub = sshSession?.stdout.listen(
      (data) {
        terminal.write(utf8.decode(data, allowMalformed: true));
      },
      onError: (err) {
        terminal.write('\r\n[Session stream error: $err]\r\n');
      },
      onDone: () {
        terminal.write('\r\n[Session ended]\r\n');
      },
    );

    // SSH Session stderr -> Terminal display
    _stderrSub = sshSession?.stderr.listen((data) {
      terminal.write(utf8.decode(data, allowMalformed: true));
    });
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
  }
}
