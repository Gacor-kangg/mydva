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
            type: ANIME
            sort: TRENDING_DESC
            isAdult: false
          ) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              extraLarge
              large
            }
            description(asHtml: false)
            genres
            averageScore
            episodes
            format
            startDate {
              year
            }
          }
        }
      }
    ''';

    return _fetchAnime(
      query: query,
      variables: {'page': page, 'perPage': perPage},
    );
  }

  Future<List<MediaModel>> searchAnime(
    String keyword, {
    int page = 1,
    int perPage = 20,
  }) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    const query = r'''
      query ($search: String, $page: Int, $perPage: Int) {
        Page(page: $page, perPage: $perPage) {
          media(
            search: $search
            type: ANIME
            sort: SEARCH_MATCH
            isAdult: false
          ) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              extraLarge
              large
            }
            description(asHtml: false)
            genres
            averageScore
            episodes
            format
            startDate {
              year
            }
          }
        }
      }
    ''';

    return _fetchAnime(
      query: query,
      variables: {'search': keyword.trim(), 'page': page, 'perPage': perPage},
    );
  }

  Future<List<MediaModel>> _fetchAnime({
    required String query,
    required Map<String, dynamic> variables,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConfig.anilistUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'query': query, 'variables': variables}),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'AniList gagal merespons. HTTP ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decoded['errors'] != null) {
        throw ApiException(
          'AniList mengembalikan kesalahan saat mengambil anime.',
        );
      }

      final pageData = decoded['data']?['Page'];

      if (pageData == null || pageData['media'] == null) {
        throw const ApiException('Data anime dari AniList tidak ditemukan.');
      }

      final List<dynamic> mediaItems = pageData['media'] as List<dynamic>;

      return mediaItems
          .whereType<Map<String, dynamic>>()
          .map(MediaModel.fromAniList)
          .toList();
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke AniList. Periksa koneksi internet.',
      );
    } catch (error) {
      throw ApiException('Gagal memproses data AniList: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
