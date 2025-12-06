import '../models/professional.dart';

/// Interface for Professional data operations
abstract class ProfessionalRepository {
  /// Fetches a list of professionals, optionally filtered by type.
  Future<List<Professional>> getProfessionals({ProfessionalType? type, String? query});

  /// Fetches a single professional by ID.
  Future<Professional> getProfessionalById(String id);
}
