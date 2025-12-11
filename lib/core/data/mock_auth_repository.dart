import 'dart:async';
import 'auth_repository.dart';
import '../models/user.dart';
import '../error/app_error.dart';

class MockAuthRepository implements AuthRepository {
  // Simulated database
  final List<User> _users = [
    User(
      id: 'p1',
      email: 'paciente@test.com',
      name: 'Juan Paciente',
      role: UserRole.patient,
      photoUrl: 'https://i.pravatar.cc/150?u=p1',
    ),
    User(
      id: 'd1',
      email: 'doctor@test.com',
      name: 'Dr. Roberto Médico',
      role: UserRole.doctor,
      photoUrl: 'https://i.pravatar.cc/150?u=d1',
      isOnline: true,
      isPremium: true,
    ),
    User(
      id: 'd2',
      email: 'doctor_basic@test.com',
      name: 'Dr. Basic Médico',
      role: UserRole.doctor,
      photoUrl: 'https://i.pravatar.cc/150?u=d2',
      isOnline: true,
      isPremium: false,
    ),
    User(
      id: 'a1',
      email: 'admin@test.com',
      name: 'Super Admin',
      role: UserRole.admin,
      photoUrl: 'https://i.pravatar.cc/150?u=a1',
    ),
  ];

  User? _currentUser;

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Sim delay

    // Simple mock validation
    if (password == '123456') {
      try {
        final user = _users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
        _currentUser = user;
        return user;
      } catch (e) {
        throw NotFoundError(message: 'Usuario no encontrado');
      }
    } else {
      throw AppError('Contraseña incorrecta');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
       throw NotFoundError(message: 'Correo no registrado');
    }
  }

  @override
  Future<User?> checkSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<User> updateProfilePhoto(String userId, String path) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updated = _users[index].copyWith(photoUrl: path);
      _users[index] = updated;
      if (_currentUser?.id == userId) {
        _currentUser = updated;
      }
      return updated;
    }
    throw NotFoundError(message: 'User not found');
  }

  @override
  Future<void> changePassword(String userId, String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock logic
    if (oldPassword != '123456') {
      throw AppError('Contraseña actual incorrecta');
    }
  }

  @override
  Future<void> updateNotificationPreferences(String userId, Map<String, bool> prefs) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Log prefs
    // print("Prefs updated for $userId: $prefs");
  }
}
