import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/data/professional_repository.dart';
import 'core/data/mock_professional_repository.dart';
import 'core/models/professional.dart';

// Repository Provider
final professionalRepositoryProvider = Provider<ProfessionalRepository>((ref) {
  return MockProfessionalRepository();
});

// Helper class for filtering parameters
class ProfessionalFilter {
  final ProfessionalType? type;
  final String? query;

  // Advanced Filters
  final double? minPrice;
  final double? maxPrice;
  final List<String>? cities;
  final List<String>? insurances;
  final int? minExperience;
  final double? minRating;
  final bool? isTelemedicine;

  // Sorting
  final String sortBy; // 'relevance', 'price_asc', 'price_desc', 'rating_desc', 'experience_desc'

  const ProfessionalFilter({
    this.type,
    this.query,
    this.minPrice,
    this.maxPrice,
    this.cities,
    this.insurances,
    this.minExperience,
    this.minRating,
    this.isTelemedicine,
    this.sortBy = 'relevance',
  });

  ProfessionalFilter copyWith({
    ProfessionalType? type,
    String? query,
    double? minPrice,
    double? maxPrice,
    List<String>? cities,
    List<String>? insurances,
    int? minExperience,
    double? minRating,
    bool? isTelemedicine,
    String? sortBy,
  }) {
    return ProfessionalFilter(
      type: type ?? this.type,
      query: query ?? this.query,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      cities: cities ?? this.cities,
      insurances: insurances ?? this.insurances,
      minExperience: minExperience ?? this.minExperience,
      minRating: minRating ?? this.minRating,
      isTelemedicine: isTelemedicine ?? this.isTelemedicine,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfessionalFilter &&
        other.type == type &&
        other.query == query &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.minExperience == minExperience &&
        other.minRating == minRating &&
        other.isTelemedicine == isTelemedicine &&
        other.sortBy == sortBy &&
        _listEquals(other.cities, cities) &&
        _listEquals(other.insurances, insurances);
  }

  @override
  int get hashCode => Object.hash(
      type, query, minPrice, maxPrice, minExperience, minRating, isTelemedicine, sortBy);

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// --- STATE MANAGEMENT ---

class ProfessionalSearchState {
  final List<Professional> items;
  final bool isLoading;
  final bool isLoadingMore; // For pagination
  final String? error;
  final bool hasMore;
  final int page;
  final ProfessionalFilter filter;

  const ProfessionalSearchState({
    required this.items,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    required this.filter,
  });

  ProfessionalSearchState copyWith({
    List<Professional>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? page,
    ProfessionalFilter? filter,
  }) {
    return ProfessionalSearchState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error, // Nullable override
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      filter: filter ?? this.filter,
    );
  }
}

class ProfessionalSearchNotifier extends StateNotifier<ProfessionalSearchState> {
  final ProfessionalRepository _repository;

  ProfessionalSearchNotifier(this._repository, {ProfessionalFilter? initialFilter})
      : super(ProfessionalSearchState(
          items: [],
          isLoading: true,
          filter: initialFilter ?? const ProfessionalFilter(),
        )) {
    _fetchPage(1);
  }

  Future<void> _fetchPage(int page) async {
    try {
      final result = await _repository.getProfessionals(
        filter: state.filter,
        page: page,
        limit: 10,
      );

      if (mounted) {
        state = state.copyWith(
          items: page == 1 ? result.items : [...state.items, ...result.items],
          isLoading: false,
          isLoadingMore: false,
          hasMore: result.hasMore,
          page: page,
          error: null,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: e.toString(),
        );
      }
    }
  }

  // Called when user applies new filters or search query
  void updateFilter(ProfessionalFilter newFilter) {
    if (newFilter == state.filter) return;

    state = state.copyWith(
      filter: newFilter,
      isLoading: true,
      items: [],
      page: 1,
      hasMore: true,
    );
    _fetchPage(1);
  }

  // Called by UI when scrolling to bottom
  void loadMore() {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    _fetchPage(state.page + 1);
  }

  // Convenience for Quick Filters
  void toggleTelemedicine() {
     final current = state.filter.isTelemedicine ?? false;
     updateFilter(state.filter.copyWith(isTelemedicine: !current));
  }
}

// Provider
final professionalSearchProvider = StateNotifierProvider.family<ProfessionalSearchNotifier, ProfessionalSearchState, ProfessionalFilter?>(
  (ref, initialFilter) {
    final repo = ref.watch(professionalRepositoryProvider);
    return ProfessionalSearchNotifier(repo, initialFilter: initialFilter);
  },
);

// Single Professional Provider
final professionalProvider = FutureProvider.family<Professional, String>((ref, id) async {
  final repository = ref.watch(professionalRepositoryProvider);
  return repository.getProfessionalById(id);
});
