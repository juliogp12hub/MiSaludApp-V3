import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/data/professional_repository.dart';
import 'core/data/mock_professional_repository.dart';
import 'core/models/professional.dart';

// Repository Provider
final professionalRepositoryProvider = Provider<ProfessionalRepository>((ref) {
  return MockProfessionalRepository();
});

// Professionals List Provider (Family to handle filtering)
final professionalsProvider = FutureProvider.family<List<Professional>, ProfessionalFilter>((ref, filter) async {
  final repository = ref.watch(professionalRepositoryProvider);
  return repository.getProfessionals(type: filter.type, query: filter.query);
});

// Helper class for filtering parameters
class ProfessionalFilter {
  final ProfessionalType? type;
  final String? query;

  const ProfessionalFilter({this.type, this.query});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfessionalFilter && other.type == type && other.query == query;
  }

  @override
  int get hashCode => Object.hash(type, query);
}

// Single Professional Provider
final professionalProvider = FutureProvider.family<Professional, String>((ref, id) async {
  final repository = ref.watch(professionalRepositoryProvider);
  return repository.getProfessionalById(id);
});
