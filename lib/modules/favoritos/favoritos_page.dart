import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/professional.dart';
import '../../providers.dart';
import '../professional_detail/professional_detail_data.dart';
import '../professional_detail/professional_detail_page.dart';
import 'favorites_service.dart';
import '../../widgets/animated_fav_button.dart';

class FavoritosPage extends ConsumerStatefulWidget {
  const FavoritosPage({super.key});

  @override
  ConsumerState<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends ConsumerState<FavoritosPage> {
  bool _isLoading = true;
  List<Professional> _favorites = [];

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    setState(() => _isLoading = true);

    final fav = FavoritesService();
    await fav.cargar();

    final idsDocs = fav.obtenerDoctoresFavoritos();

    // Fetch all professionals (or by IDs if repo supported it)
    // For now we fetch all lists and filter. Ideally repo has getByIds or getById.
    final repo = ref.read(professionalRepositoryProvider);

    // This is inefficient but works for mock. Ideally we iterate IDs and fetch individually or batch.
    List<Professional> allFavorites = [];

    // We assume the mock repo has a method to get all or we can just fetch all types.
    // Since our provider filters, let's just fetch all types manually or assume doctor for now as favorites logic implies doctors.
    // But favorites service should be generic.

    // Let's try to fetch individually for the IDs.
    for (String id in idsDocs) {
      try {
        final p = await repo.getProfessionalById(id);
        allFavorites.add(p);
      } catch (e) {
        // Ignore if not found
      }
    }

    if (mounted) {
      setState(() {
        _favorites = allFavorites;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favoritos")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarFavoritos,
              child: _favorites.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(
                          child: Text(
                            "Aún no tienes profesionales favoritos.",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _favorites.length,
                      itemBuilder: (_, i) => _cardProfessional(_favorites[i]),
                    ),
            ),
    );
  }

  Widget _cardProfessional(Professional p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: (p.photoUrl != null && p.photoUrl!.isNotEmpty)
              ? NetworkImage(p.photoUrl!)
              : null,
          child: (p.photoUrl == null || p.photoUrl!.isEmpty)
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(p.name),
        subtitle: Text("${p.specialty} • ${p.city}"),
        trailing: AnimatedFavButton(
          isFav: true,
          size: 26,
          onTap: () async {
            await FavoritesService().toggleDoctorFavorito(p.id);
            _cargarFavoritos();
          },
        ),
        onTap: () {
          final data = ProfessionalDetailData(
              id: p.id,
              nombre: p.name,
              tipo: 'Doctor', // Simplified
              avatarUrl: p.photoUrl ?? '',
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
        },
      ),
    );
  }
}
