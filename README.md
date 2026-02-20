# Pokédex App

A Flutter app that lets you browse Pokémon using the free [PokéAPI](https://pokeapi.co). Built as part of a technical assignment — two screens, live API data, and a few extra features I added along the way.

---

## What it does

When you open the app you get a scrollable grid of Pokémon with their sprites and type badges. You can search by name, scroll down to load more, and tap any card to see the full detail page — stats, abilities, height, weight, everything. There's also a heart button to save your favourites, and it remembers them even after you close the app.

It works in light and dark mode, follows your phone's system setting automatically.

---

## How to run it

You'll need Flutter installed. If you don't have it yet: https://flutter.dev/docs/get-started/install

```bash
# Clone the repo
git clone https://github.com/kovilapu-bharat/Pokedex.git
cd Pokedex

# Get dependencies
flutter pub get

# Run on your connected device or emulator
flutter run
```

---

## Flutter version

```
Flutter 3.24.2  •  channel stable  •  Dart 3.5.2  •  DevTools 2.37.2
```

---

## Packages used

| Package | What it's for |
|---|---|
| `flutter_riverpod` | State management — handles loading, success, and error states |
| `http` | Making GET requests to PokéAPI |
| `cached_network_image` | Loading and caching Pokémon sprite images efficiently |
| `shared_preferences` | Saving favourite Pokémon so they persist between sessions |

---

## Project structure

```
lib/
├── main.dart                      # Entry point, theme setup
├── models/
│   ├── pokemon_list_item.dart     # Model for the list API response
│   └── pokemon_detail.dart        # Model for the detail API response
├── services/
│   └── pokemon_service.dart       # All API calls live here
├── providers/
│   ├── pokemon_providers.dart     # Riverpod providers for list + detail
│   └── favourites_provider.dart   # Favourites state + SharedPreferences
├── screens/
│   ├── pokemon_list_screen.dart   # Screen 1: the grid
│   └── pokemon_detail_screen.dart # Screen 2: full detail
└── widgets/
    ├── pokemon_card.dart           # The card shown in the grid
    ├── stat_bar.dart               # Animated progress bar for stats
    └── type_badge.dart             # Coloured type pill (Fire, Water, etc.)
```

---

## A few decisions I made

**Why Riverpod?** It models the three UI states (loading / success / error) cleanly without a lot of boilerplate. `AsyncNotifierProvider` was a natural fit for the list screen since it handles async state out of the box.

**Detail calls on the list screen:** The list endpoint only gives you a name and a URL — no sprite, no types. So for each Pokémon shown in the grid, I make a separate detail call to get the image and type data. This is by design (and mentioned in the assignment spec).

**Pagination:** Loads 30 at a time. When you scroll near the bottom it quietly fetches the next batch and appends it — no jarring reloads.

**Stat bar colours:** Red for low, orange for medium, green for high — based on the value relative to 255 (the max possible). Makes it easy to see at a glance how strong a Pokémon is.

---

## Note on AI tools

I used **Google Gemini (Antigravity)** as a coding assistant during development. It helped with initial structure and some boilerplate. I reviewed, understood, and tested all the code myself.

---

## Screenshots

| List Screen | Search | Detail Screen | Dark Mode |
|---|---|---|---|
| ![List Screen](screenshots/List.jpg) | ![Search](screenshots/Search.jpg) | ![Detail Screen](screenshots/Detail.jpg) | ![Dark Mode](screenshots/Darkmode.png) |
