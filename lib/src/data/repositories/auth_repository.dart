import 'package:crysta_pay/src/data/datasources/app_preferences.dart';
import 'package:crysta_pay/src/data/datasources/secure_storage.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SecureStorage secureStorage;
  final AppPreferences preferences;
  
  AuthRepository({
    required this.secureStorage,
    required this.preferences,
  });
  
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getAuthToken();
    return token != null;
  }
  
  Future<bool> isOnboarded() async {
    return preferences.isOnboardingCompleted();
  }
  
  Future<void> setOnboarded(bool value) async {
    await preferences.setOnboardingCompleted(value);
  }
  
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = preferences.getObject('current_user');
      if (userData == null) return null;
      
      return UserModel.fromJson(userData);
    } catch (e) {
      AppLogger.error('Error getting current user: $e');
      return null;
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      // In a real app, this would call an API
      // For demo purposes, we'll simulate a successful login
      await Future.delayed(const Duration(seconds: 1));
      
      const token = 'demo_auth_token';
      const refreshToken = 'demo_refresh_token';
      
      await secureStorage.setAuthToken(token);
      await secureStorage.setRefreshToken(refreshToken);
      await secureStorage.setUserEmail(email);
      
      // Save mock user data
      final user = UserModel(
        id: '1',
        name: 'Nguyễn Văn A',
        email: email,
        isVerified: true,
        createdAt: DateTime.now(),
      );
      
      await preferences.setObject('current_user', user.toJson());
      
      return true;
    } catch (e) {
      AppLogger.error('Login error: $e');
      return false;
    }
  }
  
  Future<bool> register(String name, String email, String password) async {
    try {
      // In a real app, this would call an API
      // For demo purposes, we'll simulate a successful registration
      await Future.delayed(const Duration(seconds: 1));
      
      // Save mock user data
      final user = UserModel(
        id: '1',
        name: name,
        email: email,
        isVerified: false,
        createdAt: DateTime.now(),
      );
      
      await preferences.setObject('current_user', user.toJson());
      
      // Automatically login after registration
      return login(email, password);
    } catch (e) {
      AppLogger.error('Registration error: $e');
      return false;
    }
  }
  
  Future<void> logout() async {
    await secureStorage.clearAuthData();
    // Don't clear onboarding status on logout
  }
}