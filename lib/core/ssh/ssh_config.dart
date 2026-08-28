import 'package:equatable/equatable.dart';

enum AuthMethod {
  password,
  privateKey,
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  connectionLost,
  reconnecting,
  authFailed,
  hostUnavailable,
}

class ConnectionProfile extends Equatable {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final AuthMethod authMethod;
  final String? privateKey; // PEM string or null
  final String? password;
  final DateTime? lastConnected;
  final DateTime createdAt;

  const ConnectionProfile({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.authMethod = AuthMethod.privateKey,
    this.privateKey,
    this.password,
    this.lastConnected,
    required this.createdAt,
  });

  ConnectionProfile copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    AuthMethod? authMethod,
    String? privateKey,
    String? password,
    DateTime? lastConnected,
    DateTime? createdAt,
  }) {
    return ConnectionProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authMethod: authMethod ?? this.authMethod,
      privateKey: privateKey ?? this.privateKey,
      password: password ?? this.password,
      lastConnected: lastConnected ?? this.lastConnected,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'username': username,
        'authMethod': authMethod.name,
        'lastConnected': lastConnected?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
    return ConnectionProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      host: json['host'] as String,
      port: json['port'] as int? ?? 22,
      username: json['username'] as String,
      authMethod: json['authMethod'] == 'password'
          ? AuthMethod.password
          : AuthMethod.privateKey,
      lastConnected: json['lastConnected'] != null
          ? DateTime.parse(json['lastConnected'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        host,
        port,
        username,
        authMethod,
        lastConnected,
        createdAt,
      ];
}
