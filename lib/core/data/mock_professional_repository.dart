import 'dart:math';
import 'professional_repository.dart';
import '../models/professional.dart';
import '../error/app_error.dart';

class MockProfessionalRepository implements ProfessionalRepository {
  final List<Professional> _mockData = [
    Professional(
      id: '1',
      name: 'Dr. Juan Pérez',
      specialty: 'Cardiología',
      city: 'Ciudad de Guatemala',
      rating: 4.8,
      price: 350.0,
      photoUrl: 'https://i.pravatar.cc/300?img=11',
      yearsExperience: 10,
      insurance: ['Seguros G&T', 'Roble'],
      type: ProfessionalType.doctor,
      bio: 'Especialista en corazón con más de 10 años de experiencia.',
      languages: ['Español', 'Inglés'],
    ),
    Professional(
      id: '2',
      name: 'Dra. María López',
      specialty: 'Ortodoncia',
      city: 'Antigua Guatemala',
      rating: 4.9,
      price: 400.0,
      photoUrl: 'https://i.pravatar.cc/300?img=5',
      yearsExperience: 8,
      insurance: ['Universales'],
      type: ProfessionalType.dentist,
      address: 'Calle del Arco #4',
    ),
    Professional(
      id: '3',
      name: 'Lic. Carlos Ruiz',
      specialty: 'Cognitivo Conductual',
      city: 'Ciudad de Guatemala',
      rating: 4.7,
      price: 250.0,
      photoUrl: 'https://i.pravatar.cc/300?img=3',
      yearsExperience: 5,
      type: ProfessionalType.psychologist,
      isTelemedicine: true,
    ),
     Professional(
      id: '4',
      name: 'Dr. Alejandro Gomez',
      specialty: 'Pediatría',
      city: 'Xela',
      rating: 4.5,
      price: 300.0,
      photoUrl: 'https://i.pravatar.cc/300?img=12',
      yearsExperience: 15,
      insurance: ['Seguros G&T'],
      type: ProfessionalType.doctor,
    ),
  ];

  @override
  Future<List<Professional>> getProfessionals({ProfessionalType? type, String? query}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate random error (10% chance)
    if (Random().nextDouble() < 0.1) {
      throw NetworkError(message: 'Simulated connection failure');
    }

    return _mockData.where((p) {
      if (type != null && p.type != type) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        return p.name.toLowerCase().contains(q) ||
               p.specialty.toLowerCase().contains(q) ||
               p.city.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Future<Professional> getProfessionalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockData.firstWhere((p) => p.id == id);
    } catch (e) {
      throw NotFoundError(message: 'Profesional no encontrado');
    }
  }
}
