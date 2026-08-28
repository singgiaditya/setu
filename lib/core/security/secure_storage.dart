import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
            );

  Future<void> savePrivateKey(String id, String pemKey) async {
    await _storage.write(key: '${AppConstants.secureKeyPrefix}$id', value: pemKey);
  }

  Future<String?> getPrivateKey(String id) async {
    return await _storage.read(key: '${AppConstants.secureKeyPrefix}$id');
  }

  Future<void> deletePrivateKey(String id) async {
    await _storage.delete(key: '${AppConstants.secureKeyPrefix}$id');
  }

  Future<void> savePassword(String id, String password) async {
    await _storage.write(key: '${AppConstants.securePassPrefix}$id', value: password);
  }

  Future<String?> getPassword(String id) async {
    return await _storage.read(key: '${AppConstants.securePassPrefix}$id');
  }

  Future<void> deletePassword(String id) async {
    await _storage.delete(key: '${AppConstants.securePassPrefix}$id');
  }
}
