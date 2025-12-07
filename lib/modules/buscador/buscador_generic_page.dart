import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/professional.dart';
import '../../providers.dart';
import 'widgets/professional_card.dart';
import 'widgets/filter_modal.dart';
import '../professional_detail/professional_detail_page.dart';
import '../professional_detail/professional_detail_data.dart';

class BuscadorGenericPage extends ConsumerStatefulWidget {
  final ProfessionalType type;
  final String title;

  const BuscadorGenericPage({super.key, required this.type, required this.title});

  @override
  ConsumerState<BuscadorGenericPage> createState() => _BuscadorGenericPageState();
}

class _BuscadorGenericPageState extends ConsumerState<BuscadorGenericPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(professionalSearchProvider(ProfessionalFilter(type: widget.type)).notifier);
      notifier.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state for this specific professional type
    final searchState = ref.watch(professionalSearchProvider(ProfessionalFilter(type: widget.type)));
    final notifier = ref.read(professionalSearchProvider(ProfessionalFilter(type: widget.type)).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          _buildSearchBar(notifier, searchState),
          _buildQuickFilters(notifier, searchState),
          const SizedBox(height: 8),
          Expanded(
            child: _buildList(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ProfessionalSearchState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(child: Text("Error: ${state.error}"));
    }

    if (state.items.isEmpty) {
      return const Center(child: Text("No se encontraron resultados."));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final p = state.items[index];
        return ProfessionalCard(
          professional: p,
          onTap: () => _navigateToDetail(context, p),
        );
      },
    );
  }

  Widget _buildSearchBar(ProfessionalSearchNotifier notifier, ProfessionalSearchState state) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o especialidad',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (value) {
                // Debounce could be added here
                notifier.updateFilter(state.filter.copyWith(query: value));
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilters(context, notifier, state),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(ProfessionalSearchNotifier notifier, ProfessionalSearchState state) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          FilterChip(
            label: const Text("Telemedicina"),
            selected: state.filter.isTelemedicine == true,
            onSelected: (_) => notifier.toggleTelemedicine(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text("4.5+ ⭐"),
            selected: state.filter.minRating == 4.5,
            onSelected: (val) {
               notifier.updateFilter(state.filter.copyWith(
                 minRating: val ? 4.5 : null
               ));
            },
          ),
          const SizedBox(width: 8),
          // Add more quick chips if needed
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, ProfessionalSearchNotifier notifier, ProfessionalSearchState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FilterModal(
        currentFilter: state.filter,
        onApply: (newFilter) {
          notifier.updateFilter(newFilter);
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Professional p) {
    final data = ProfessionalDetailData(
      id: p.id,
      nombre: p.name,
      tipo: widget.type.name.toUpperCase(),
      avatarUrl: p.photoUrl ?? 'https://via.placeholder.com/150',
      ciudad: p.city,
      subespecialidad: p.specialty,
      direccion: p.address,
      acercaDe: p.bio,
      calificacion: p.rating,
      precioPresencial: p.price,
      experiencia: '${p.yearsExperience} años',
      idiomas: p.languages,
      hospitales: p.hospitals,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfessionalDetailPage(data: data),
      ),
    );
  }
}
