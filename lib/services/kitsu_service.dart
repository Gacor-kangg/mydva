import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/media_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

class KitsuService {
  final Dio _dio;

  KitsuService({Dio? dio})
    : _dio =
          dio ??
          ApiClient.create(
            baseUrl: ApiConfig.kitsuBaseUrl,
            // Content-Type tidak perlu untuk GET dan memicu preflight CORS.
            headers: {'Accept': 'application/vnd.api+json'},
          );

  static const int maxPerPage = 20;

  /// Mengambil daftar anime populer dari Kitsu.
  ///
  /// Kitsu menggunakan pagination berbasis offset.
  /// Page dimulai dari 1.
  Future<List<MediaModel>> getPopularAnime({
    int page = 1,
    int perPage = 20,
  }) async {
    if (page < 1) {
      throw const ApiException('Nomor halaman harus minimal 1.');
    }

    final limit = perPage.clamp(1, maxPerPage);
    final offset = (page - 1) * limit;

    return _fetchAnime({
      'page[limit]': limit.toString(),
      'page[offset]': offset.toString(),
      'sort': '-user_count',
      'include': 'genres',
    });
  }

  /// Mencari anime berdasarkan judul.
  Future<List<MediaModel>> searchAnime(
    String keyword, {
    int page = 1,
    int perPage = 20,
  }) async {
    final query = keyword.trim();

    if (query.isEmpty) {
      return [];
    }

    if (page < 1) {
      throw const ApiException('Nomor halaman harus minimal 1.');
    }

    final limit = perPage.clamp(1, maxPerPage);
    final offset = (page - 1) * limit;

    return _fetchAnime({
      'filter[text]': query,
      'page[limit]': limit.toString(),
      'page[offset]': offset.toString(),
      'include': 'genres',
    });
  }

  /// Mengambil dan memetakan data anime dari Kitsu.
  Future<List<MediaModel>> _fetchAnime(Map<String, String> parameters) async {
    try {
      final response = await _dio.get<dynamic>(
        '/anime',
        queryParameters: parameters,
      );

      final decoded = ApiClient.asJsonMap(response.data, source: 'Kitsu');

      final results = decoded['data'];

      if (results is! List) {
        throw const ApiException('Daftar anime dari Kitsu tidak ditemukan.');
      }

      // Membaca data genre dari bagian included.
      final included = decoded['included'];

      final genreMap = <String, String>{};

      if (included is List) {
        for (final item in included) {
          if (item is! Map<String, dynamic>) continue;

          if (item['type'] != 'genres') continue;

          final id = item['id']?.toString();
          final attributes = item['attributes'] as Map<String, dynamic>?;

          final name = attributes?['name']?.toString();

          if (id != null && name != null) {
            genreMap[id] = name;
          }
        }
      }

      final animeList = <MediaModel>[];

      for (final item in results) {
        if (item is! Map<String, dynamic>) continue;

        final attributes = item['attributes'] as Map<String, dynamic>? ?? {};

        // Menghubungkan ID genre dengan nama genre.
        final relationships =
            item['relationships'] as Map<String, dynamic>? ?? {};

        final genresRelationship =
            relationships['genres'] as Map<String, dynamic>? ?? {};

        final genreData = genresRelationship['data'];

        final genres = <String>[];

        if (genreData is List) {
          for (final genre in genreData) {
            if (genre is! Map<String, dynamic>) continue;

            final genreId = genre['id']?.toString();

            if (genreId != null && genreMap.containsKey(genreId)) {
              genres.add(genreMap[genreId]!);
            }
          }
        }

        // Menyesuaikan atribut dengan MediaModel.
        final mappedJson = <String, dynamic>{
          ...item,
          'attributes': {
            ...attributes,
            'genres': genres.map((name) => {'name': name}).toList(),
          },
        };

        animeList.add(MediaModel.fromKitsu(mappedJson));
      }

      return animeList;
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw ApiException.fromDio(error, source: 'Kitsu');
    } catch (error) {
      throw ApiException('Gagal memproses data Kitsu: $error');
    }
  }

  void dispose() {
    _dio.close();
  }
}
