import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/models/result.dart';
import 'ssh_config.dart';

class SshService {
  SSHClient? _client;
  ConnectionProfile? _activeProfile;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _lastError;
  Timer? _keepAliveTimer;

  final _statusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  ConnectionStatus get status => _status;
  ConnectionProfile? get activeProfile => _activeProfile;
  String? get lastError => _lastError;
  bool get isConnected => _status == ConnectionStatus.connected && _client != null && !_client!.isClosed;
  SSHClient? get client => _client;

  void _setStatus(ConnectionStatus newStatus, {String? error}) {
    _status = newStatus;
    _lastError = error;
    _statusController.add(newStatus);
  }

  Future<Result<SSHClient>> connect(
    ConnectionProfile profile, {
    String? privateKey,
    String? password,
    Duration timeout = AppConstants.defaultConnectionTimeout,
  }) async {
    _setStatus(ConnectionStatus.connecting);
    _activeProfile = profile;

    try {
      final socket = await SSHSocket.connect(
        profile.host,
        profile.port,
        timeout: timeout,
      );

      List<SSHKeyPair> identities = [];
      if (profile.authMethod == AuthMethod.privateKey && privateKey != null && privateKey.isNotEmpty) {
        try {
          identities = SSHKeyPair.fromPem(privateKey);
        } catch (e) {
          _setStatus(ConnectionStatus.authFailed, error: 'Invalid private key format.');
          return Result.failure('Invalid private key format: $e');
        }
      }

      final client = SSHClient(
        socket,
        username: profile.username,
        onPasswordRequest: () => password ?? profile.password ?? '',
        identities: identities.isNotEmpty ? identities : null,
        onAuthenticated: () {
          // authentication success
        },
      );

      await client.authenticated;
      _client = client;
      _setStatus(ConnectionStatus.connected);

      _startKeepAlive();
      return Result.success(client);
    } on SocketException catch (e) {
      final message = 'Cannot reach ${profile.host}:${profile.port}. Is your workstation on Tailscale? (${e.message})';
      _setStatus(ConnectionStatus.hostUnavailable, error: message);
      return Result.failure(message);
    } on TimeoutException {
      final message = 'Connection timed out connecting to ${profile.host}:${profile.port}. Check your network and Tailscale status.';
      _setStatus(ConnectionStatus.hostUnavailable, error: message);
      return Result.failure(message);
    } catch (e) {
      final message = e.toString().toLowerCase().contains('auth')
          ? 'Authentication failed for user ${profile.username}. Check your key or password.'
          : 'Failed to connect: $e';
      _setStatus(ConnectionStatus.authFailed, error: message);
      return Result.failure(message);
    }
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(AppConstants.keepAliveInterval, (timer) async {
      if (_client == null || _client!.isClosed) {
        timer.cancel();
        if (_status == ConnectionStatus.connected) {
          _setStatus(ConnectionStatus.connectionLost, error: 'Connection lost unexpectedly.');
        }
        return;
      }
      try {
        await _client!.ping();
      } catch (_) {
        timer.cancel();
        _setStatus(ConnectionStatus.connectionLost, error: 'Workstation connection lost.');
      }
    });
  }

  Future<Result<String>> runCommand(String command) async {
    if (!isConnected || _client == null) {
      return Result.failure('Not connected to workstation.');
    }
    try {
      final result = await _client!.run(command);
      return Result.success(utf8.decode(result));
    } catch (e) {
      return Result.failure('Command execution failed: $e');
    }
  }

  Future<SSHSession?> createShell({
    int width = 80,
    int height = 25,
    int pixelWidth = 0,
    int pixelHeight = 0,
  }) async {
    if (!isConnected || _client == null) return null;
    try {
      return await _client!.shell(
        pty: SSHPtyConfig(
          width: width,
          height: height,
          pixelWidth: pixelWidth,
          pixelHeight: pixelHeight,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  Future<SftpClient?> getSftp() async {
    if (!isConnected || _client == null) return null;
    try {
      return await _client!.sftp();
    } catch (e) {
      return null;
    }
  }

  Future<void> disconnect() async {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    if (_client != null && !_client!.isClosed) {
      _client!.close();
    }
    _client = null;
    _setStatus(ConnectionStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}
