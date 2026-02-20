import 'package:flutter/material.dart';

/// An animated stat bar that shows a Pokémon's base stat value
/// as a coloured progress indicator.
class StatBar extends StatelessWidget {
  final String statName;
  final int value;
  /// Maximum stat value used to calculate the fill ratio (default 255).
  final int maxValue;

  const StatBar({
    super.key,
    required this.statName,
    required this.value,
    this.maxValue = 255,
  });

  /// Returns a colour based on the stat value (red → yellow → green).
  Color _barColor() {
    final ratio = value / maxValue;
    if (ratio < 0.33) return Colors.red.shade400;
    if (ratio < 0.66) return Colors.orange.shade400;
    return Colors.green.shade500;
  }

  /// Formats the raw stat name from the API (e.g. "special-attack" → "Sp. Atk").
  String _formatName(String name) {
    const aliases = {
      'hp': 'HP',
      'attack': 'Attack',
      'defense': 'Defense',
      'special-attack': 'Sp. Atk',
      'special-defense': 'Sp. Def',
      'speed': 'Speed',
    };
    return aliases[name] ?? name;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              _formatName(statName),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              value.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_barColor()),
                    minHeight: 8,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
