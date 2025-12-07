import 'dart:math';
import 'professional_repository.dart';
import '../models/professional.dart';
import '../error/app_error.dart';
import '../../providers.dart'; // For ProfessionalFilter

class MockProfessionalRepository implements ProfessionalRepository {
  late List<Professional> _mockData;

  MockProfessionalRepository() {
    _generateMockData();
  }

  void _generateMockData() {
    // Generate ~100 items for infinite scroll testing
    _mockData = [];
    final random = Random();
    final specialties = ['Cardiología', 'Pediatría', 'Dermatología', 'Ginecología', 'Ortodoncia', 'Psicología Clínica', 'Nutrición'];
    final cities = ['Ciudad de Guatemala', 'Antigua Guatemala', 'Xela', 'Escuintla', 'Cobán'];
    final insurances = ['Seguros G&T', 'Roble', 'Universales', 'Mapfre', 'Seguros El Roble'];

    // Core data
     _mockData.addAll([
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
          isTelemedicine: true,
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
          specialty: 'Psicología Clínica',
          city: 'Ciudad de Guatemala',
          rating: 4.7,
          price: 250.0,
          photoUrl: 'https://i.pravatar.cc/300?img=3',
          yearsExperience: 5,
          type: ProfessionalType.psychologist,
          isTelemedicine: true,
        ),
    ]);

    // Generate remaining
    for (int i = 4; i <= 100; i++) {
       final typeIndex = random.nextInt(3);
       final type = ProfessionalType.values[typeIndex];
       final specialty = specialties[random.nextInt(specialties.length)];

       _mockData.add(Professional(
          id: i.toString(),
          name: 'Doctor Mock $i',
          specialty: specialty,
          city: cities[random.nextInt(cities.length)],
          rating: 3.0 + random.nextDouble() * 2.0, // 3.0 - 5.0
          price: 150.0 + random.nextInt(500), // 150 - 650
          photoUrl: 'https://i.pravatar.cc/300?img=${(i % 70)}',
          yearsExperience: 1 + random.nextInt(30),
          insurance: [insurances[random.nextInt(insurances.length)]],
          type: type,
          isTelemedicine: random.nextBool(),
       ));
    }
  }

  @override
  Future<PaginatedResult> getProfessionals({
    required ProfessionalFilter filter,
    int page = 1,
    int limit = 20,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate random error (5% chance)
    if (Random().nextDouble() < 0.05) {
      throw NetworkError(message: 'Simulated connection failure');
    }

    var filtered = _mockData.where((p) {
      // 1. Filter by Type
      if (filter.type != null && p.type != filter.type) return false;

      // 2. Filter by Query (Name, Specialty, Bio)
      if (filter.query != null && filter.query!.isNotEmpty) {
        final q = filter.query!.toLowerCase();
        final match = p.name.toLowerCase().contains(q) ||
                      p.specialty.toLowerCase().contains(q) ||
                      p.city.toLowerCase().contains(q);
        if (!match) return false;
      }

      // 3. Advanced Filters
      if (filter.minPrice != null && p.price < filter.minPrice!) return false;
      if (filter.maxPrice != null && p.price > filter.maxPrice!) return false;

      if (filter.cities != null && filter.cities!.isNotEmpty) {
         if (!filter.cities!.contains(p.city)) return false;
      }

      if (filter.insurances != null && filter.insurances!.isNotEmpty) {
         // Check if professional accepts ANY of the selected insurances
         // or logic: must accept AT LEAST ONE of user's insurances?
         // Usually: "I have insurance X, show doctors who take X"
         // If filter is [A, B], we show doctors who take A OR B.
         final hasMatch = p.insurance.any((ins) => filter.insurances!.contains(ins));
         if (!hasMatch) return false;
      }

      if (filter.minExperience != null && p.yearsExperience < filter.minExperience!) return false;
      if (filter.minRating != null && p.rating < filter.minRating!) return false;
      if (filter.isTelemedicine != null && filter.isTelemedicine == true) {
         if (!p.isTelemedicine) return false;
      }

      return true;
    }).toList();

    // 4. Sorting
    switch (filter.sortBy) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating_desc':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'experience_desc':
        filtered.sort((a, b) => b.yearsExperience.compareTo(a.yearsExperience));
        break;
      case 'relevance':
      default:
        // Already "random" or query relevant
        break;
    }

    // 5. Pagination
    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) {
      return PaginatedResult(items: [], hasMore: false, totalCount: filtered.length);
    }

    final endIndex = startIndex + limit;
    final items = filtered.sublist(startIndex, min(endIndex, filtered.length));
    final hasMore = endIndex < filtered.length;

    return PaginatedResult(items: items, hasMore: hasMore, totalCount: filtered.length);
  }

  @override
  Future<Professional> getProfessionalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockData.firstWhere((p) => p.id == id);
    } catch (e) {
      throw NotFoundError(message: 'Profesional no encontrado');
    }
  }
}
