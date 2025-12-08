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
      isPremium: true, // Mark this doctor as premium for testing
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
    // Default to the premium doctor for testing if not set
    if (_currentUser == null) {
       _currentUser = _users.firstWhere((u) => u.email == 'doctor@test.com');
    }
    return _currentUser;
  }
}
