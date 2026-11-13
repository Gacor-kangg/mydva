import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/media_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

class AnilistService {
  final Dio _dio;

  AnilistService({Dio? dio})
    : _dio =
          dio ??
          ApiClient.create(
            baseUrl: ApiConfig.anilistUrl,
            headers: {'Accept': 'application/json'},
          );

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
            stats {
              scoreDistribution {
                score
                amount
              }
            }
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
      // Dio otomatis mengirim Map sebagai JSON (Content-Type: application/json).
      final response = await _dio.post<dynamic>(
        '',
        data: {'query': query, 'variables': variables},
      );

      final decoded = ApiClient.asJsonMap(response.data, source: 'AniList');

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
    } on DioException catch (error) {
      throw ApiException.fromDio(error, source: 'AniList');
    } catch (error) {
      throw ApiException('Gagal memproses data AniList: $error');
    }
  }

  void dispose() {
    _dio.close();
  }
}
