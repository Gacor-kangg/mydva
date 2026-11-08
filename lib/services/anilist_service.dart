import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/media_model.dart';
import 'api_exception.dart';

class AnilistService {
  final http.Client _client;

  AnilistService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MediaModel>> getTrendingAnime({
    int page = 1,
    int perPage = 20,
  }) async {
    const query = r'''
      query ($page: Int, $perPage: Int) {
        Page(page: $page, perPage: $perPage) {
          media(
            type: ANIME,
            sort: [TRENDING_DESC, POPULARITY_DESC],
            isAdult: false
          ) {
            id
            title {
              english
              romaji
              native
            }
            coverImage {
              large
            }
            description(asHtml: false)
            startDate {
              year
            }
            averageScore
            genres
          }
        }
      }
    ''';

    final uri = Uri.parse(ApiConfig.anilistUrl);

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'query': query,
              'variables': {'page': page, 'perPage': perPage},
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal mengambil data anime dari AniList.',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons AniList tidak valid.');
      }

      if (decoded['errors'] != null) {
        throw ApiException('AniList mengembalikan error: ${decoded['errors']}');
      }

      final data = decoded['data'];

      if (data is! Map<String, dynamic>) {
        throw const ApiException('Data AniList tidak ditemukan.');
      }

      final pageData = data['Page'];

      if (pageData is! Map<String, dynamic>) {
        throw const ApiException('Respons halaman AniList tidak valid.');
      }

      final results = pageData['media'];

      if (results is! List) {
        throw const ApiException('Daftar anime tidak ditemukan.');
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(MediaModel.fromAniList)
          .toList();
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Tidak dapat terhubung ke AniList: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
