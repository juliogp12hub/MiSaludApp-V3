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
        // Here we would store token in secure storage
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
    // Clear token
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Check if email exists
    if (!_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
       throw NotFoundError(message: 'Correo no registrado');
    }
    // Simulate sending email
  }

  @override
  Future<User?> checkSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate token check.
    // In a real app, read token from storage, validate with backend.
    // For now, assume session persistence if we assigned it (which resets on hot restart unless we persist to shared prefs).
    // I won't implement SharedPrefs persistence here to keep mock simple,
    // but the requirement "Multi-device session sync" implies checks.

    return _currentUser;
  }
}
