import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';

part 'token_storage.g.dart';

@riverpod
TokenStorage tokenStorage(TokenStorageRef ref) => TokenStorage();

/// Wraps [FlutterSecureStorage] for JWT token management.
class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyAccessToken, value: accessToken),
      _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<void> saveUserMeta({
    required String userId,
    required String role,
    required String name,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyUserId, value: userId),
      _storage.write(key: AppConstants.keyUserRole, value: role),
      _storage.write(key: AppConstants.keyUserName, value: name),
    ]);
  }

  Future<String?> getUserRole() =>
      _storage.read(key: AppConstants.keyUserRole);

  Future<String?> getUserId() =>
      _storage.read(key: AppConstants.keyUserId);

  Future<String?> getUserName() =>
      _storage.read(key: AppConstants.keyUserName);

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
