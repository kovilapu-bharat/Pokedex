import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favourites_provider.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_badge.dart';

/// Shows full detail for a single Pokémon: sprite, ID, types, height,
/// weight, base stats (with animated bars), and abilities.
class PokemonDetailScreen extends ConsumerWidget {
  final String pokemonName;

  const PokemonDetailScreen({super.key, required this.pokemonName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(pokemonDetailProvider(pokemonName));

    return Scaffold(
      body: asyncDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DetailError(
          message: error.toString(),
          onRetry: () => ref.invalidate(pokemonDetailProvider(pokemonName)),
        ),
        data: (pokemon) {
          final isFav = ref.watch(favouritesProvider).contains(pokemon.id);
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return CustomScrollView(
            slivers: [
              // Collapsible app bar with sprite
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                actions: [
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFav),
                        color: isFav ? Colors.red : null,
                      ),
                    ),
                    onPressed: () => ref
                        .read(favouritesProvider.notifier)
                        .toggle(pokemon.id),
                    tooltip: isFav
                        ? 'Remove from favourites'
                        : 'Add to favourites',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    color: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    child: Center(
                      child: pokemon.spriteUrl != null
                          ? Hero(
                              tag: 'pokemon-${pokemon.id}',
                              child: CachedNetworkImage(
                                imageUrl: pokemon.spriteUrl!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.contain,
                                placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.catching_pokemon,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.catching_pokemon,
                              size: 80,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID + Types row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pokemon.formattedId,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Wrap(
                            spacing: 6,
                            children: pokemon.types
                                .map((t) => TypeBadge(type: t))
                                .toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Height & Weight
                      const _SectionTitle('Measurements'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.height,
                              label: 'Height',
                              value: pokemon.heightFormatted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.monitor_weight_outlined,
                              label: 'Weight',
                              value: pokemon.weightFormatted,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Base Stats
                      const _SectionTitle('Base Stats'),
                      const SizedBox(height: 8),
                      ...pokemon.stats.map(
                        (stat) => StatBar(
                          statName: stat.name,
                          value: stat.baseStat,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Abilities
                      const _SectionTitle('Abilities'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: pokemon.abilities.map((ability) {
                          final name = ability.name
                              .split('-')
                              .map((w) =>
                                  w[0].toUpperCase() + w.substring(1))
                              .join(' ');
                          final chip = Chip(
                            label: Text(name),
                            avatar: ability.isHidden
                                ? const Icon(Icons.visibility_off,
                                    size: 16)
                                : const Icon(Icons.star, size: 16),
                          );
                          return ability.isHidden
                              ? Tooltip(
                                  message: 'Hidden ability',
                                  child: chip,
                                )
                              : chip;
                        }).toList(),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Error state for the detail screen.
class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Failed to load Pokémon details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
