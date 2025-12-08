import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';

class FavoriteToggle extends ConsumerWidget {
  final String professionalId;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;

  const FavoriteToggle({
    super.key,
    required this.professionalId,
    this.activeColor = Colors.red,
    this.inactiveColor,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.contains(professionalId);

    return IconButton(
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? activeColor : (inactiveColor ?? Colors.grey),
        size: size,
      ),
      onPressed: () {
        final user = ref.read(authProvider).user;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Debes iniciar sesión para guardar favoritos.")),
          );
          return;
        }
        ref.read(favoritesProvider.notifier).toggle(user.id, professionalId);
      },
    );
  }
}
