import '../models/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<User?> checkSession(); // For token refresh / sync

  // Profile Management
  Future<User> updateProfilePhoto(String userId, String path);
  Future<void> changePassword(String userId, String oldPassword, String newPassword);
  Future<void> updateNotificationPreferences(String userId, Map<String, bool> prefs);
}
