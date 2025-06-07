import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class SecureStorage {
  final FlutterSecureStorage secureStorage;
  final Logger _logger = Logger();

  SecureStorage({required this.secureStorage});

  // Auth Tokens
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> setAuthToken(String token) async {
    try {
      await secureStorage.write(key: _authTokenKey, value: token);
      _logger.i('Stored auth token');
    } catch (e, stackTrace) {
      _logger.e('Failed to store auth token', error: e, stackTrace: stackTrace);
      throw Exception('Failed to store auth token: $e');
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final token = await secureStorage.read(key: _authTokenKey);
      _logger.i('Retrieved auth token');
      return token;
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve auth token', error: e, stackTrace: stackTrace);
      throw Exception('Failed to retrieve auth token: $e');
    }
  }

  Future<void> setRefreshToken(String token) async {
    try {
      await secureStorage.write(key: _refreshTokenKey, value: token);
      _logger.i('Stored refresh token');
    } catch (e, stackTrace) {
      _logger.e('Failed to store refresh token', error: e, stackTrace: stackTrace);
      throw Exception('Failed to store refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await secureStorage.read(key: _refreshTokenKey);
      _logger.i('Retrieved refresh token');
      return token;
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve refresh token', error: e, stackTrace: stackTrace);
      throw Exception('Failed to retrieve refresh token: $e');
    }
  }

  // User Credentials
  static const _userEmailKey = 'user_email';

  Future<void> setUserEmail(String email) async {
    try {
      await secureStorage.write(key: _userEmailKey, value: email);
      _logger.i('Stored user email');
    } catch (e, stackTrace) {
      _logger.e('Failed to store user email', error: e, stackTrace: stackTrace);
      throw Exception('Failed to store user email: $e');
    }
  }

  Future<String?> getUserEmail() async {
    try {
      final email = await secureStorage.read(key: _userEmailKey);
      _logger.i('Retrieved user email');
      return email;
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve user email', error: e, stackTrace: stackTrace);
      throw Exception('Failed to retrieve user email: $e');
    }
  }

  // Wallet Session Storage
  static const _walletSessionPrefix = 'wc_session_';

  /// Stores a wallet session for a specific wallet type.
  Future<void> setWalletSession(String walletType, String sessionData) async {
    final key = '$_walletSessionPrefix${walletType.toLowerCase()}';
    try {
      await secureStorage.write(key: key, value: sessionData);
      _logger.i('Stored wallet session for $walletType');
    } catch (e, stackTrace) {
      _logger.e('Failed to store wallet session for $walletType', error: e, stackTrace: stackTrace);
      throw Exception('Failed to store wallet session for $walletType: $e');
    }
  }

  /// Retrieves a wallet session for a specific wallet type.
  Future<String?> getWalletSession(String walletType) async {
    final key = '$_walletSessionPrefix${walletType.toLowerCase()}';
    try {
      final sessionData = await secureStorage.read(key: key);
      _logger.i('Retrieved wallet session for $walletType');
      return sessionData;
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve wallet session for $walletType', error: e, stackTrace: stackTrace);
      throw Exception('Failed to retrieve wallet session for $walletType: $e');
    }
  }

  /// Deletes a wallet session for a specific wallet type.
  Future<void> deleteWalletSession(String walletType) async {
    final key = '$_walletSessionPrefix${walletType.toLowerCase()}';
    try {
      await secureStorage.delete(key: key);
      _logger.i('Deleted wallet session for $walletType');
    } catch (e, stackTrace) {
      _logger.e('Failed to delete wallet session for $walletType', error: e, stackTrace: stackTrace);
      throw Exception('Failed to delete wallet session for $walletType: $e');
    }
  }

  /// Deletes all wallet sessions.
  Future<void> clearWalletSessions() async {
    try {
      // Since secureStorage doesn't provide a way to list keys, we explicitly delete known wallet session keys
      const walletTypes = ['metamask_mobile', 'walletconnect', 'trustwallet', 'ledger'];
      for (final walletType in walletTypes) {
        final key = '$_walletSessionPrefix$walletType';
        await secureStorage.delete(key: key);
      }
      _logger.i('Cleared all wallet sessions');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear wallet sessions', error: e, stackTrace: stackTrace);
      throw Exception('Failed to clear wallet sessions: $e');
    }
  }

  // Generic Storage
  Future<void> setSecureValue(String key, String value) async {
    try {
      await secureStorage.write(key: key, value: value);
      _logger.i('Stored secure value for key $key');
    } catch (e, stackTrace) {
      _logger.e('Failed to store secure value for key $key', error: e, stackTrace: stackTrace);
      throw new Exception('Failed to store secure value for key $key: $e');
    }
  }

  Future<String?> getSecureValue(String key) async {
    try {
      final value = await secureStorage.read(key: key);
      _logger.i('Retrieved secure value for key $key');
      return value;
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve secure value for key $key', error: e, stackTrace: stackTrace);
      throw new Exception('Failed to retrieve secure value for key $key: $e');
    }
  }

  // Clear Storage
  Future<void> clearAll() async {
    try {
      await secureStorage.deleteAll();
      _logger.i('Cleared all secure storage');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear secure storage', error: e, stackTrace: stackTrace);
      throw Exception('Failed to clear secure storage: $e');
    }
  }

  Future<void> clearAuthData() async {
    try {
      await secureStorage.delete(key: _authTokenKey);
      await secureStorage.delete(key: _refreshTokenKey);
      _logger.i('Cleared auth data');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear auth data', error: e, stackTrace: stackTrace);
      throw Exception('Failed to clear auth data: $e');
    }
  }

}