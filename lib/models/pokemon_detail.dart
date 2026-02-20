/// Represents a single base stat (e.g. hp, attack, defense, speed).
class PokemonStat {
  final String name;
  final int baseStat;

  const PokemonStat({required this.name, required this.baseStat});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: (json['stat'] as Map<String, dynamic>)['name'] as String,
      baseStat: json['base_stat'] as int,
    );
  }
}

/// Represents a Pokémon ability.
class PokemonAbility {
  final String name;
  final bool isHidden;

  const PokemonAbility({required this.name, required this.isHidden});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(
      name: (json['ability'] as Map<String, dynamic>)['name'] as String,
      isHidden: json['is_hidden'] as bool,
    );
  }
}

/// Represents the full detail response from the PokéAPI detail endpoint.
class PokemonDetail {
  final int id;
  final String name;
  final String? spriteUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.spriteUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
    required this.abilities,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    // Parse types: [{slot, type: {name, url}}, ...]
    final types = (json['types'] as List<dynamic>)
        .map((t) =>
            (t as Map<String, dynamic>)['type']['name'] as String)
        .toList();

    // Parse stats: [{base_stat, effort, stat: {name, url}}, ...]
    final stats = (json['stats'] as List<dynamic>)
        .map((s) => PokemonStat.fromJson(s as Map<String, dynamic>))
        .toList();

    // Parse abilities: [{ability: {name, url}, is_hidden, slot}, ...]
    final abilities = (json['abilities'] as List<dynamic>)
        .map((a) => PokemonAbility.fromJson(a as Map<String, dynamic>))
        .toList();

    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      spriteUrl: (json['sprites'] as Map<String, dynamic>)['front_default']
          as String?,
      types: types,
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: stats,
      abilities: abilities,
    );
  }

  /// Returns the formatted Pokédex number, e.g. "#001"
  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  /// Height in metres (API returns decimetres)
  String get heightFormatted => '${(height / 10).toStringAsFixed(1)} m';

  /// Weight in kilograms (API returns hectograms)
  String get weightFormatted => '${(weight / 10).toStringAsFixed(1)} kg';
}
