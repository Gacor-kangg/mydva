import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/media_model.dart';
import 'api_exception.dart';

class TvmazeService {
  final http.Client _client;

  TvmazeService({http.Client? client}) : _client = client ?? http.Client();

  static const String japanCode = 'JP';
  static const String koreaCode = 'KR';

  // Satu permintaan katalog memeriksa 10 halaman.
  // Setiap halaman TVmaze berisi maksimal 250 acara.
  static const int pagesPerRequest = 10;

  Future<List<MediaModel>> getJDrama({int page = 0}) {
    return getDramaByCountry(
      countryCode: japanCode,
      mediaType: 'J-Drama',
      page: page,
    );
  }

  Future<List<MediaModel>> getKDrama({int page = 0}) {
    return getDramaByCountry(
      countryCode: koreaCode,
      mediaType: 'K-Drama',
      page: page,
    );
  }

  Future<List<MediaModel>> getDramaByCountry({
    required String countryCode,
    required String mediaType,
    int page = 0,
  }) async {
    if (page < 0) {
      throw const ApiException('Nomor halaman TVmaze tidak valid.');
    }

    final startPage = page * pagesPerRequest;
    final result = <MediaModel>[];
    final existingIds = <String>{};

    for (
      var currentPage = startPage;
      currentPage < startPage + pagesPerRequest;
      currentPage++
    ) {
      final uri = Uri.parse('${ApiConfig.tvmazeBaseUrl}/shows')
          .replace(queryParameters: {'page': currentPage.toString()});

      final response = await _get(uri);

      // HTTP 404 berarti sudah mencapai halaman terakhir.
      if (response.statusCode == 404) {
        break;
      }

      _checkResponse(response);

      final shows = _decodeList(response.body);

      if (shows.isEmpty) {
        break;
      }

      final filtered = _filterShows(
        shows,
        countryCode: countryCode,
        mediaType: mediaType,
      );

      for (final media in filtered) {
        final id = media.externalId;

        if (id != null && existingIds.add(id)) {
          result.add(media);
        }
      }
    }

    return result;
  }

  Future<List<MediaModel>> searchDrama({
    required String keyword,
    required String countryCode,
    required String mediaType,
  }) async {
    final query = keyword.trim();

    if (query.isEmpty) {
      return [];
    }

    final uri = Uri.parse('${ApiConfig.tvmazeBaseUrl}/search/shows')
        .replace(queryParameters: {'q': query});

    final response = await _get(uri);

    _checkResponse(response);

    final decoded = _decodeList(response.body);
    final shows = <Map<String, dynamic>>[];

    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;

      final show = item['show'];

      if (show is Map<String, dynamic>) {
        shows.add(show);
      }
    }

    return _filterShows(shows, countryCode: countryCode, mediaType: mediaType);
  }

  List<MediaModel> _filterShows(
    List<dynamic> shows, {
    required String countryCode,
    required String mediaType,
  }) {
    final result = <MediaModel>[];

    final expectedLanguage = countryCode == japanCode
        ? 'japanese'
        : countryCode == koreaCode
        ? 'korean'
        : '';

    for (final item in shows) {
      if (item is! Map<String, dynamic>) continue;

      final network = item['network'] as Map<String, dynamic>?;
      final webChannel = item['webChannel'] as Map<String, dynamic>?;

      final networkCountry = network?['country'] as Map<String, dynamic>?;

      final webChannelCountry = webChannel?['country'] as Map<String, dynamic>?;

      final networkCode = networkCountry?['code']?.toString().toUpperCase();

      final webChannelCode = webChannelCountry?['code']
          ?.toString()
          .toUpperCase();

      final language = item['language']?.toString().toLowerCase();

      final matchesCountry =
          networkCode == countryCode || webChannelCode == countryCode;

      final matchesLanguage = language == expectedLanguage;

      if (!matchesCountry && !matchesLanguage) {
        continue;
      }

      result.add(MediaModel.fromTvmaze(item, mediaType: mediaType));
    }

    return result;
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(ApiConfig.requestTimeout);
    } on TimeoutException {
      throw const ApiException(
        'Koneksi ke TVmaze terlalu lama. Silakan coba lagi.',
      );
    } catch (error) {
      if (error is ApiException) rethrow;

      throw ApiException('Tidak dapat terhubung ke TVmaze: $error');
    }
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'Gagal mengambil data dari TVmaze.',
        statusCode: response.statusCode,
      );
    }
  }

  List<dynamic> _decodeList(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is List) {
        return decoded;
      }

      throw const ApiException('Format respons TVmaze tidak valid.');
    } on FormatException {
      throw const ApiException('Respons TVmaze tidak dapat dibaca.');
    }
  }

  void dispose() {
    _client.close();
  }
}
