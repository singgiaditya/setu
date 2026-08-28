import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import '../security/secure_storage.dart';
import '../../shared/models/result.dart';

class SshKeyManager {
  final SecureStorageService _secureStorage;

  SshKeyManager(this._secureStorage);

  Future<Result<bool>> validatePrivateKey(String pem) async {
    try {
      final keyPairs = SSHKeyPair.fromPem(pem);
      if (keyPairs.isEmpty) {
        return Result.failure('Invalid private key: No valid keypair found in PEM data.');
      }
      return Result.success(true);
    } catch (e) {
      return Result.failure('Invalid PEM key format: $e');
    }
  }

  Future<void> saveKey(String profileId, String pem) async {
    await _secureStorage.savePrivateKey(profileId, pem);
  }

  Future<String?> getKey(String profileId) async {
    return await _secureStorage.getPrivateKey(profileId);
  }

  Future<void> deleteKey(String profileId) async {
    await _secureStorage.deletePrivateKey(profileId);
  }

  Future<void> savePassword(String profileId, String password) async {
    await _secureStorage.savePassword(profileId, password);
  }

  Future<String?> getPassword(String profileId) async {
    return await _secureStorage.getPassword(profileId);
  }

  Future<void> deletePassword(String profileId) async {
    await _secureStorage.deletePassword(profileId);
  }
}
