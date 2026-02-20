/// Represents a single item from the PokéAPI list endpoint.
/// The list endpoint only returns name and url — the sprite and types
/// are fetched separately via the detail endpoint.
class PokemonListItem {
  final String name;
  final String url;

  const PokemonListItem({required this.name, required this.url});

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  /// Extracts the numeric Pokémon ID from the detail URL.
  /// e.g. "https://pokeapi.co/api/v2/pokemon/1/" → 1
  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return int.tryParse(segments.last) ?? 0;
  }
}

/// Represents the full response from the PokéAPI list endpoint.
class PokemonListResponse {
  final int count;
  final String? next;
  final List<PokemonListItem> results;

  const PokemonListResponse({
    required this.count,
    required this.next,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
