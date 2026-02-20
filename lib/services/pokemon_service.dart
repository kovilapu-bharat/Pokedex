import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_list_item.dart';
import '../models/pokemon_detail.dart';

/// Custom exception for API errors.
class PokemonApiException implements Exception {
  final String message;
  final int? statusCode;

  const PokemonApiException(this.message, {this.statusCode});

  @override
  String toString() => 'PokemonApiException: $message (status: $statusCode)';
}

/// Service class responsible for all HTTP communication with PokéAPI.
/// All methods throw [PokemonApiException] on failure.
class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  final http.Client _client;

  PokemonService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a paginated list of Pokémon.
  /// [limit] — number of results per page (default 30)
  /// [offset] — starting index for pagination (default 0)
  Future<PokemonListResponse> fetchPokemonList({
    int limit = 30,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$_baseUrl/pokemon?limit=$limit&offset=$offset');
    try {
      final response = await _client.get(uri);
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PokemonListResponse.fromJson(json);
    } on PokemonApiException {
      rethrow;
    } catch (e) {
      throw PokemonApiException('Network error: $e');
    }
  }

  /// Fetches full detail for a single Pokémon by name or numeric ID.
  Future<PokemonDetail> fetchPokemonDetail(String nameOrId) async {
    final uri = Uri.parse('$_baseUrl/pokemon/$nameOrId');
    try {
      final response = await _client.get(uri);
      _checkStatus(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PokemonDetail.fromJson(json);
    } on PokemonApiException {
      rethrow;
    } catch (e) {
      throw PokemonApiException('Network error: $e');
    }
  }

  /// Throws [PokemonApiException] for non-2xx HTTP responses.
  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PokemonApiException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    }
  }
}
