import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon_detail.dart';
import '../services/pokemon_service.dart';

/// Provider for the PokemonService singleton.
final pokemonServiceProvider = Provider<PokemonService>((ref) {
  return PokemonService();
});

// ---------------------------------------------------------------------------
// List Screen State
// ---------------------------------------------------------------------------

/// State held by [PokemonListNotifier].
class PokemonListState {
  final List<PokemonDetail> pokemon;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentOffset;
  final String searchQuery;

  const PokemonListState({
    required this.pokemon,
    required this.isLoadingMore,
    required this.hasMore,
    required this.currentOffset,
    required this.searchQuery,
  });

  PokemonListState copyWith({
    List<PokemonDetail>? pokemon,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentOffset,
    String? searchQuery,
  }) {
    return PokemonListState(
      pokemon: pokemon ?? this.pokemon,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Returns the list filtered by the current search query.
  List<PokemonDetail> get filteredPokemon {
    if (searchQuery.isEmpty) return pokemon;
    return pokemon
        .where((p) => p.name.contains(searchQuery.toLowerCase()))
        .toList();
  }
}

/// AsyncNotifier that manages the Pokémon list, pagination, and search.
class PokemonListNotifier
    extends AsyncNotifier<PokemonListState> {
  static const int _pageSize = 30;

  @override
  Future<PokemonListState> build() async {
    return _fetchPage(offset: 0, existing: []);
  }

  Future<PokemonListState> _fetchPage({
    required int offset,
    required List<PokemonDetail> existing,
  }) async {
    final service = ref.read(pokemonServiceProvider);
    final listResponse = await service.fetchPokemonList(
      limit: _pageSize,
      offset: offset,
    );

    // Fetch detail for each item to get sprite + types
    final details = await Future.wait(
      listResponse.results.map(
        (item) => service.fetchPokemonDetail(item.id.toString()),
      ),
    );

    final allPokemon = [...existing, ...details];
    final hasMore = listResponse.next != null;

    return PokemonListState(
      pokemon: allPokemon,
      isLoadingMore: false,
      hasMore: hasMore,
      currentOffset: offset + _pageSize,
      searchQuery: state.valueOrNull?.searchQuery ?? '',
    );
  }

  /// Loads the next page of Pokémon (infinite scroll).
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    // Mark as loading more without replacing existing data
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final next = await _fetchPage(
        offset: current.currentOffset,
        existing: current.pokemon,
      );
      state = AsyncData(next);
    } catch (e) {
      // Restore previous state on error, just stop loading
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Updates the search query to filter the displayed list.
  void updateSearch(String query) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  /// Refreshes the list from the beginning.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchPage(offset: 0, existing: []),
    );
  }
}

final pokemonListProvider =
    AsyncNotifierProvider<PokemonListNotifier, PokemonListState>(
  PokemonListNotifier.new,
);

// ---------------------------------------------------------------------------
// Detail Screen State
// ---------------------------------------------------------------------------

/// Family provider that fetches detail for a single Pokémon by name or ID.
final pokemonDetailProvider = FutureProvider.family<PokemonDetail, String>(
  (ref, nameOrId) async {
    final service = ref.read(pokemonServiceProvider);
    return service.fetchPokemonDetail(nameOrId);
  },
);
