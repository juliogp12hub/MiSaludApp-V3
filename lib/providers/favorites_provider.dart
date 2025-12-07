import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';

// State Notifier to manage the list of favorite IDs
class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]);

  // Load favorites for a specific user
  Future<void> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_${userId}_favorites';
    final ids = prefs.getStringList(key) ?? [];
    state = ids;
  }

  // Toggle favorite status
  Future<void> toggle(String userId, String professionalId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_${userId}_favorites';

    // Create a new list to ensure state immutability triggers updates
    final currentList = List<String>.from(state);

    if (currentList.contains(professionalId)) {
      currentList.remove(professionalId);
    } else {
      currentList.add(professionalId);
    }

    // Save to local storage
    await prefs.setStringList(key, currentList);

    // Update state
    state = currentList;

    // Mock Sync
    _syncToCloud(userId, currentList);
  }

  // Simulated Sync
  Future<void> _syncToCloud(String userId, List<String> favorites) async {
    // In a real app, this would call an API
    await Future.delayed(const Duration(milliseconds: 500));
    // print("☁️ [Mock Sync] Favorites synced for user $userId: $favorites");
  }

  bool isFavorite(String professionalId) {
    return state.contains(professionalId);
  }
}

// The Provider
// We use a StateNotifierProvider.
// We observe auth state changes to reload favorites automatically.
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final notifier = FavoritesNotifier();

  // Watch auth changes
  ref.listen(authProvider, (previous, next) {
    if (next.user != null) {
      notifier.load(next.user!.id);
    } else {
      // Clear favorites on logout
      notifier.state = [];
    }
  });

  // Initial load if already logged in
  final authState = ref.read(authProvider);
  if (authState.user != null) {
    notifier.load(authState.user!.id);
  }

  return notifier;
});
