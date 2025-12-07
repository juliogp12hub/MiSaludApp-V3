import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/professional.dart';
import '../../providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../professional_detail/professional_detail_data.dart';
import '../professional_detail/professional_detail_page.dart';
import '../../widgets/favorite_toggle.dart';

class FavoritosPage extends ConsumerWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Check Auth
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Favoritos")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
               const SizedBox(height: 16),
               const Text("Inicia sesión para ver tus favoritos"),
               const SizedBox(height: 16),
               ElevatedButton(
                 onPressed: () {
                   // Navigate to login or just show snackbar
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ve al Perfil para iniciar sesión.")));
                 },
                 child: const Text("Iniciar Sesión"),
               )
            ],
          ),
        ),
      );
    }

    // 2. Watch Favorites IDs
    final favoriteIds = ref.watch(favoritesProvider);

    if (favoriteIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Favoritos")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Aún no tienes profesionales favoritos.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                "Agrega doctores a tu lista para encontrarlos rápido.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Fetch Details
    // Ideally we have a provider that fetches by IDs list.
    // For now we assume we fetch all and filter client-side or make individual calls.
    // Making individual calls in build is bad. Use a FutureProvider/StreamProvider.
    // But let's reuse `professionalsProvider` (which fetches all mock data) and filter.
    // Since mock data is small (100 items), this is fine.

    // Note: We use a filter that fetches ALL types.
    final professionalsAsync = ref.watch(professionalsProvider(const ProfessionalFilter()));

    return Scaffold(
      appBar: AppBar(title: const Text("Favoritos")),
      body: professionalsAsync.when(
        data: (allProfessionals) {
          final favorites = allProfessionals.where((p) => favoriteIds.contains(p.id)).toList();

          if (favorites.isEmpty) {
             // Case where IDs exist but professionals not found (e.g. deleted or mock data reset)
             return const Center(child: Text("No se pudo cargar la información de los favoritos."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (_, i) => _cardProfessional(context, favorites[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _cardProfessional(BuildContext context, Professional p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          final data = ProfessionalDetailData(
              id: p.id,
              nombre: p.name,
              tipo: p.type.name.toUpperCase(), // Assuming enum name usage
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: (p.photoUrl != null && p.photoUrl!.isNotEmpty)
                    ? NetworkImage(p.photoUrl!)
                    : null,
                child: (p.photoUrl == null || p.photoUrl!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${p.specialty} • ${p.city}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(p.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),

              // Toggle
              FavoriteToggle(professionalId: p.id, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
