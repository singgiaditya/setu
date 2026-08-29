import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ssh/ssh_config.dart';
import '../core/ssh/ssh_key_manager.dart';
import '../core/ssh/ssh_service.dart';
import 'storage_provider.dart';

final sshServiceProvider = Provider<SshService>((ref) {
  final service = SshService();
  ref.onDispose(() => service.dispose());
  return service;
});

final sshKeyManagerProvider = Provider<SshKeyManager>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SshKeyManager(secureStorage);
});

class ConnectionProfilesNotifier extends Notifier<List<ConnectionProfile>> {
  @override
  List<ConnectionProfile> build() {
    final prefs = ref.watch(preferencesStoreProvider);
    final rawProfiles = prefs.getSavedProfiles();
    if (rawProfiles.isEmpty) {
      return [];
    }
    return rawProfiles.map((p) => ConnectionProfile.fromJson(p)).toList();
  }

  Future<void> addProfile(ConnectionProfile profile) async {
    final updated = [...state, profile];
    state = updated;
    await _persist();
  }

  Future<void> updateProfile(ConnectionProfile profile) async {
    state = [
      for (final p in state)
        if (p.id == profile.id) profile else p
    ];
    await _persist();
  }

  Future<void> deleteProfile(String id) async {
    state = state.where((p) => p.id != id).toList();
    final keyManager = ref.read(sshKeyManagerProvider);
    await keyManager.deleteKey(id);
    await keyManager.deletePassword(id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.saveProfiles(state.map((p) => p.toJson()).toList());
  }
}

final connectionProfilesProvider =
    NotifierProvider<ConnectionProfilesNotifier, List<ConnectionProfile>>(
  ConnectionProfilesNotifier.new,
);

class ActiveProfileNotifier extends Notifier<ConnectionProfile?> {
  @override
  ConnectionProfile? build() {
    final profiles = ref.watch(connectionProfilesProvider);
    final prefs = ref.watch(preferencesStoreProvider);
    final activeId = prefs.activeProfileId;
    if (activeId != null) {
      final match = profiles.where((p) => p.id == activeId);
      if (match.isNotEmpty) return match.first;
    }
    return profiles.isNotEmpty ? profiles.first : null;
  }

  Future<void> setActive(ConnectionProfile profile) async {
    state = profile;
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.setActiveProfileId(profile.id);
  }
}

final activeProfileProvider =
    NotifierProvider<ActiveProfileNotifier, ConnectionProfile?>(
  ActiveProfileNotifier.new,
);

final connectionStatusStreamProvider = StreamProvider<ConnectionStatus>((ref) {
  final sshService = ref.watch(sshServiceProvider);
  return sshService.statusStream;
});
