import '../models/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<User?> checkSession(); // For token refresh / sync
}
