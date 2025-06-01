import 'package:crysta_pay/src/data/datasources/app_preferences.dart';
import 'package:crysta_pay/src/data/datasources/secure_storage.dart';

import '../../core/utils/logger.dart';
import '../models/user_model.dart';

class UserRepository {
  final AppPreferences preferences;
  final SecureStorage secureStorage;
  static const String _userKey = 'current_user';
  
  UserRepository({
    required this.preferences,
    required this.secureStorage,
  });
  
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = preferences.getObject(_userKey);
      if (userData == null) return null;
      
      return UserModel.fromJson(userData);
    } catch (e) {
      AppLogger.error('Error getting current user: $e');
      return null;
    }
  }
  
  Future<bool> updateUserProfile({
    required String name,
    String? email,
    String? avatar,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
        avatar: avatar,
        updatedAt: DateTime.now(),
      );
      
      await preferences.setObject(_userKey, updatedUser.toJson());
      
      if (email != null && email != currentUser.email) {
        await secureStorage.setUserEmail(email);
      }
      
      return true;
    } catch (e) {
      AppLogger.error('Error updating user profile: $e');
      return false;
    }
  }
  
  Future<bool> updateAvatar(String avatarPath) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      final updatedUser = currentUser.copyWith(
        avatar: avatarPath,
        updatedAt: DateTime.now(),
      );
      
      await preferences.setObject(_userKey, updatedUser.toJson());
      return true;
    } catch (e) {
      AppLogger.error('Error updating avatar: $e');
      return false;
    }
  }
}