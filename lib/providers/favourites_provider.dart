import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that exposes the set of favourite Pokémon IDs.
/// Persists to SharedPreferences so favourites survive app restarts.
final favouritesProvider =
    NotifierProvider<FavouritesNotifier, Set<int>>(FavouritesNotifier.new);

class FavouritesNotifier extends Notifier<Set<int>> {
  static const _prefsKey = 'favourite_pokemon_ids';

  @override
  Set<int> build() {
    _loadFromPrefs();
    return {};
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefsKey) ?? [];
    state = ids.map(int.parse).toSet();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      state.map((id) => id.toString()).toList(),
    );
  }

  /// Toggles a Pokémon's favourite status.
  Future<void> toggle(int pokemonId) async {
    final updated = Set<int>.from(state);
    if (updated.contains(pokemonId)) {
      updated.remove(pokemonId);
    } else {
      updated.add(pokemonId);
    }
    state = updated;
    await _saveToPrefs();
  }

  bool isFavourite(int pokemonId) => state.contains(pokemonId);
}
