import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/terminal/terminal_service.dart';
import '../core/terminal/terminal_session.dart';
import 'ssh_provider.dart';

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

  Future<TerminalSessionItem> createSession({String? name, String? command}) async {
    final service = ref.read(terminalServiceProvider);
    final sshService = ref.read(sshServiceProvider);
    final session = await service.createSession(
      sshService,
      name: name,
      initialCommand: command,
    );
    state = service.sessions;
    return session;
  }

  Future<TerminalSessionItem> createOrAttachTmux(String tmuxName) async {
    final service = ref.read(terminalServiceProvider);
    final sshService = ref.read(sshServiceProvider);
    final session = await service.createOrAttachTmux(sshService, tmuxName);
    state = service.sessions;
    return session;
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
