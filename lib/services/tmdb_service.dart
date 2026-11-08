import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/media_model.dart';
import 'api_exception.dart';

class TmdbService {
  final http.Client _client;

  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  // Pilihan pengurutan untuk drama (endpoint /discover/tv).
  static const String sortPopular = 'popularity.desc';
  static const String sortNewest = 'first_air_date.desc';

  static const String japanCode = 'JP';
  static const String koreaCode = 'KR';

  // ID genre TMDB.
  static const String _genreDrama = '18';
  static const String _genreAnimation = '16';

  // =========================
  // FILM & SERIES
  // =========================

  Future<List<MediaModel>> getPopularMovies({int page = 1}) {
    return _getList(
      endpoint: '/movie/popular',
      mediaType: 'Film',
      parameters: {'page': page.toString()},
    );
  }

  Future<List<MediaModel>> getPopularSeries({int page = 1}) {
    return _getList(
      endpoint: '/tv/popular',
      mediaType: 'Series',
      parameters: {'page': page.toString()},
    );
  }

  // =========================
  // J-DRAMA & K-DRAMA
  // =========================

  Future<List<MediaModel>> getJDrama({
    int page = 1,
    String sortBy = sortPopular,
  }) {
    return _discoverDrama(
      countryCode: japanCode,
      language: 'ja',
      mediaType: 'J-Drama',
      page: page,
      sortBy: sortBy,
      excludeAnimation: true, // anime sudah punya kategori sendiri
    );
  }

  Future<List<MediaModel>> getKDrama({
    int page = 1,
    String sortBy = sortPopular,
  }) {
    return _discoverDrama(
      countryCode: koreaCode,
      language: 'ko',
      mediaType: 'K-Drama',
      page: page,
      sortBy: sortBy,
      excludeAnimation: true,
    );
  }

  Future<List<MediaModel>> searchDrama({
    required String keyword,
    required String countryCode,
    required String mediaType,
  }) async {
    final query = keyword.trim();
    if (query.isEmpty) return [];

    final results = await _getList(
      endpoint: '/search/tv',
      mediaType: mediaType,
      parameters: {'query': query, 'page': '1'},
      onlyWithPoster: true,
      rawFilter: (item) {
        final origin = item['origin_country'];
        final genreIds = item['genre_ids'];

        final matchesCountry = origin is List &&
            origin.map((e) => e.toString().toUpperCase()).contains(countryCode);

        final isAnimation =
            genreIds is List && genreIds.contains(int.parse(_genreAnimation));

        return matchesCountry && !isAnimation;
      },
    );

    return results;
  }

  Future<List<MediaModel>> _discoverDrama({
    required String countryCode,
    required String language,
    required String mediaType,
    required int page,
    required String sortBy,
    required bool excludeAnimation,
  }) {
    final isNewest = sortBy == sortNewest;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return _getList(
      endpoint: '/discover/tv',
      mediaType: mediaType,
      onlyWithPoster: true,
      parameters: {
        'page': page.toString(),
        'sort_by': sortBy,
        'with_origin_country': countryCode,
        'with_original_language': language,
        'with_genres': _genreDrama,
        if (excludeAnimation) 'without_genres': _genreAnimation,
        'include_null_first_air_dates': 'false',
        // Untuk "terbaru": hanya yang sudah tayang dan punya sedikit suara,
        // supaya bukan judul kosong/tidak dikenal.
        if (isNewest) 'first_air_date.lte': today,
        if (isNewest) 'vote_count.gte': '3',
      },
    );
  }

  // =========================
  // HTTP
  // =========================

  Future<List<MediaModel>> _getList({
    required String endpoint,
    required String mediaType,
    required Map<String, String> parameters,
    bool onlyWithPoster = false,
    bool Function(Map<String, dynamic> item)? rawFilter,
  }) async {
    if (ApiConfig.tmdbAccessToken.isEmpty) {
      throw const ApiException('TMDB Access Token belum dikonfigurasi.');
    }

    final uri = Uri.parse('${ApiConfig.tmdbBaseUrl}$endpoint').replace(
      queryParameters: {'language': ApiConfig.language, ...parameters},
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer ${ApiConfig.tmdbAccessToken}',
              'accept': 'application/json',
            },
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal mengambil data $mediaType dari TMDB.',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons TMDB tidak valid.');
      }

      final results = decoded['results'];

      if (results is! List) {
        throw const ApiException(
          'Data media tidak ditemukan pada respons TMDB.',
        );
      }

      return results
          .whereType<Map<String, dynamic>>()
          .where((item) => rawFilter == null || rawFilter(item))
          .map((item) => MediaModel.fromTmdb(item, mediaType: mediaType))
          .where((media) => !onlyWithPoster || media.imageUrl.isNotEmpty)
          .toList();
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Tidak dapat terhubung ke TMDB: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
