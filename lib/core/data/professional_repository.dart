import '../models/professional.dart';
import '../../providers.dart'; // For ProfessionalFilter

class PaginatedResult {
  final List<Professional> items;
  final bool hasMore;
  final int totalCount;

  PaginatedResult({
    required this.items,
    required this.hasMore,
    this.totalCount = 0
  });
}

/// Interface for Professional data operations
abstract class ProfessionalRepository {
  /// Fetches a list of professionals, optionally filtered by type.
  Future<PaginatedResult> getProfessionals({
    required ProfessionalFilter filter,
    int page = 1,
    int limit = 20,
  });

  /// Fetches a single professional by ID.
  Future<Professional> getProfessionalById(String id);
}
