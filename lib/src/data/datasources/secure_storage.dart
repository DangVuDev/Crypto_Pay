import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;
  
  SecureStorage(this._storage);
  
  // Auth Tokens
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  
  Future<void> setAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }
  
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }
  
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  // User Credentials
  static const _userEmailKey = 'user_email';
  
  Future<void> setUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }
  
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }
  
  // Generic Storage
  Future<void> setSecureValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  Future<String?> getSecureValue(String key) async {
    return await _storage.read(key: key);
  }
  
  // Clear Storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  Future<void> clearAuthData() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}