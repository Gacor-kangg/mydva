import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/media_model.dart';
import 'api_exception.dart';

class TmdbService {
  final http.Client _client;

  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MediaModel>> getPopularMovies({int page = 1}) {
    return _getPopularMedia(
      endpoint: '/movie/popular',
      mediaType: 'Film',
      page: page,
    );
  }

  Future<List<MediaModel>> getPopularSeries({int page = 1}) {
    return _getPopularMedia(
      endpoint: '/tv/popular',
      mediaType: 'Series',
      page: page,
    );
  }

  Future<List<MediaModel>> _getPopularMedia({
    required String endpoint,
    required String mediaType,
    required int page,
  }) async {
    if (ApiConfig.tmdbAccessToken.isEmpty) {
      throw const ApiException('TMDB Access Token belum dikonfigurasi.');
    }

    final uri = Uri.parse('${ApiConfig.tmdbBaseUrl}$endpoint').replace(
      queryParameters: {
        'language': ApiConfig.language,
        'page': page.toString(),
      },
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
          .timeout(const Duration(seconds: 20));

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
          .map((item) => MediaModel.fromTmdb(item, mediaType: mediaType))
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
