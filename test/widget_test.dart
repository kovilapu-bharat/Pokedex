import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/main.dart';

void main() {
  testWidgets('App renders PokemonListScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PokedexApp()),
    );
    // The app bar title should be visible
    expect(find.text('Pokédex'), findsOneWidget);
  });
}
