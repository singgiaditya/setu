import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/security/biometric_service.dart';
import '../core/security/secure_storage.dart';
import '../core/storage/preferences_store.dart';

final preferencesStoreProvider = Provider<PreferencesStore>((ref) {
  throw UnimplementedError('preferencesStoreProvider must be overridden in ProviderScope');
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});
