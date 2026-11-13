import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/media_detail_model.dart';
import '../models/media_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Detail API terpisah dari model katalog. TMDB menangani seluruh kategori
/// non-anime; AniList menangani detail dan karakter anime.
class MediaDetailService {
  final Dio _tmdb;
  final Dio _anilist;
  final Dio _kitsu;

  MediaDetailService({Dio? tmdb, Dio? anilist})
      : _tmdb = tmdb ?? ApiClient.create(
          baseUrl: ApiConfig.tmdbBaseUrl,
          headers: {
            'Authorization': 'Bearer ${ApiConfig.tmdbAccessToken}',
            'accept': 'application/json',
          },
          queryParameters: {'language': ApiConfig.language},
        ),
        _anilist = anilist ?? ApiClient.create(
          baseUrl: ApiConfig.anilistUrl,
          headers: {'Accept': 'application/json'},
        ),
        _kitsu = ApiClient.create(
          baseUrl: ApiConfig.kitsuBaseUrl,
          headers: {'Accept': 'application/vnd.api+json'},
        );

  Future<MediaDetailModel> getDetail(MediaModel media) async {
    if (media.mediaType == 'Anime') {
      if (media.source == 'AniList') return _anilistDetail(media);
      // Kitsu menyediakan metadata detail, tetapi tidak memiliki endpoint
      // cast/voice actor yang setara dengan AniList.
      return _kitsuDetail(media);
    }
    return _tmdbDetail(media);
  }

  Future<MediaDetailModel> _tmdbDetail(MediaModel media) async {
    if (ApiConfig.tmdbAccessToken.isEmpty) {
      throw const ApiException('TMDB Access Token belum dikonfigurasi.');
    }
    final id = media.externalId;
    if (id == null || id.isEmpty) {
      throw const ApiException('ID TMDB untuk judul ini tidak tersedia.');
    }
    final isMovie = media.mediaType == 'Film';
    final kind = isMovie ? 'movie' : 'tv';
    try {
      final response = await Future.wait([
        _tmdb.get<dynamic>('/$kind/$id', queryParameters: {
          'append_to_response': 'credits',
        }),
      ]);
      final data = ApiClient.asJsonMap(response.first.data, source: 'TMDB');
      final credits = data['credits'] as Map<String, dynamic>? ?? {};
      final castData = credits['cast'];
      final cast = <MediaCastMember>[];
      if (castData is List) {
        for (final item in castData.take(30)) {
          if (item is! Map<String, dynamic>) continue;
          final profile = item['profile_path']?.toString();
          cast.add(MediaCastMember(
            name: item['name']?.toString() ?? 'Unknown',
            role: (item['character'] ?? item['known_for_department'] ?? '').toString(),
            imageUrl: profile == null ? null : 'https://image.tmdb.org/t/p/w185$profile',
          ));
        }
      }
      final genres = (data['genres'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => e['name'].toString()).join(', ');
      final companies = (data['production_companies'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => e['name'].toString()).join(', ');
      final networks = (data['networks'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => e['name'].toString()).join(', ');
      final dateStart = (data[isMovie ? 'release_date' : 'first_air_date'] ?? '').toString();
      final dateEnd = (data['last_air_date'] ?? '').toString();
      final info = <String, String>{
        'Type': media.mediaType,
        if (data['number_of_episodes'] != null) 'Episodes': '${data['number_of_episodes']}',
        if (data['number_of_seasons'] != null) 'Seasons': '${data['number_of_seasons']}',
        if (data['status'] != null) 'Status': data['status'].toString(),
        if (dateStart.isNotEmpty) 'Aired': isMovie || dateEnd.isEmpty ? dateStart : '$dateStart – $dateEnd',
        if (data['runtime'] != null) 'Duration': '${data['runtime']} min',
        if (data['episode_run_time'] is List && (data['episode_run_time'] as List).isNotEmpty)
          'Duration': '${(data['episode_run_time'] as List).first} min per ep.',
        if (genres.isNotEmpty) 'Genres': genres,
        if (companies.isNotEmpty) 'Production Companies': companies,
        if (networks.isNotEmpty) 'Networks': networks,
        if (data['original_language'] != null) 'Original Language': data['original_language'].toString().toUpperCase(),
        if (data['adult'] != null) 'Adult': data['adult'] == true ? 'Yes' : 'No',
      };
      return MediaDetailModel(
        synopsis: data['overview']?.toString(),
        information: info,
        cast: cast,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e, source: 'TMDB');
    }
  }

  Future<MediaDetailModel> _anilistDetail(MediaModel media) async {
    final id = int.tryParse(media.externalId ?? '');
    if (id == null) throw const ApiException('ID AniList tidak valid.');
    const query = r'''query ($id: Int) { Media(id: $id, type: ANIME) {
      description(asHtml: false) format status episodes season seasonYear
      startDate { year month day } endDate { year month day }
      nextAiringEpisode { episode airingAt }
      duration source genres averageScore
      studios { nodes { name } }
      tags { name rank }
      characters(sort: [ROLE, RELEVANCE], perPage: 25) {
        edges { role node { name { full } image { large } }
          voiceActors(language: JAPANESE) { name { full } image { large } }
        }
      }
    }}''';
    try {
      final response = await _anilist.post<dynamic>('', data: {
        'query': query,
        'variables': {'id': id},
      });
      final root = ApiClient.asJsonMap(response.data, source: 'AniList');
      if (root['errors'] != null) throw const ApiException('AniList gagal mengambil detail anime.');
      final data = root['data']?['Media'] as Map<String, dynamic>?;
      if (data == null) throw const ApiException('Detail anime tidak ditemukan di AniList.');
      String date(Map<String, dynamic>? d) {
        if (d == null || d['year'] == null) return '';
        return '${d['year']}-${(d['month'] ?? 1).toString().padLeft(2, '0')}-${(d['day'] ?? 1).toString().padLeft(2, '0')}';
      }
      final studios = data['studios']?['nodes'] as List? ?? [];
      final tags = data['tags'] as List? ?? [];
      final edges = data['characters']?['edges'] as List? ?? [];
      final cast = <MediaCastMember>[];
      for (final edge in edges) {
        if (edge is! Map<String, dynamic>) continue;
        final character = edge['node'] as Map<String, dynamic>? ?? {};
        final actors = edge['voiceActors'] as List? ?? [];
        final actor = actors.isNotEmpty && actors.first is Map<String, dynamic>
            ? actors.first as Map<String, dynamic> : null;
        cast.add(MediaCastMember(
          name: character['name']?['full']?.toString() ?? 'Unknown',
          role: edge['role']?.toString() ?? 'Character',
          imageUrl: character['image']?['large']?.toString(),
          secondaryName: actor?['name']?['full']?.toString(),
          secondaryRole: actor == null ? null : 'Japanese Voice Actor',
          secondaryImageUrl: actor?['image']?['large']?.toString(),
        ));
      }
      final airing = data['nextAiringEpisode'] as Map<String, dynamic>?;
      final info = <String, String>{
        if (data['format'] != null) 'Type': data['format'].toString(),
        if (data['episodes'] != null) 'Episodes': data['episodes'].toString(),
        if (data['status'] != null) 'Status': data['status'].toString().replaceAll('_', ' '),
        if (date(data['startDate']) .isNotEmpty) 'Aired': '${date(data['startDate'])} – ${date(data['endDate']).isEmpty ? '?' : date(data['endDate'])}',
        if (data['season'] != null) 'Premiered': '${data['season']} ${data['seasonYear'] ?? ''}'.trim(),
        if (airing != null) 'Next Episode': 'Episode ${airing['episode']}',
        if (data['duration'] != null) 'Duration': '${data['duration']} min per ep.',
        if (data['source'] != null) 'Source': data['source'].toString().replaceAll('_', ' '),
        if (data['genres'] is List && (data['genres'] as List).isNotEmpty) 'Genres': (data['genres'] as List).join(', '),
        if (tags.isNotEmpty) 'Themes': tags.whereType<Map<String, dynamic>>().where((t) => (t['rank'] as num? ?? 0) >= 50).map((t) => t['name'].toString()).join(', '),
        if (studios.isNotEmpty) 'Studios': studios.whereType<Map<String, dynamic>>().map((s) => s['name'].toString()).join(', '),
      };
      return MediaDetailModel(synopsis: data['description']?.toString(), information: info, cast: cast);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, source: 'AniList');
    }
  }

  Future<MediaDetailModel> _kitsuDetail(MediaModel media) async {
    final id = media.externalId;
    if (id == null || id.isEmpty) throw const ApiException('ID Kitsu tidak tersedia.');
    try {
      final response = await _kitsu.get<dynamic>('/anime/$id');
      final root = ApiClient.asJsonMap(response.data, source: 'Kitsu');
      final a = root['data']?['attributes'] as Map<String, dynamic>? ?? {};
      final info = <String, String>{
        if (a['showType'] != null) 'Type': a['showType'].toString(),
        if (a['episodeCount'] != null) 'Episodes': a['episodeCount'].toString(),
        if (a['status'] != null) 'Status': a['status'].toString(),
        if (a['startDate'] != null) 'Aired': '${a['startDate']} – ${a['endDate'] ?? '?'}',
        if (a['episodeLength'] != null) 'Duration': '${a['episodeLength']} min per ep.',
        if (a['ageRating'] != null) 'Rating': '${a['ageRating']} ${a['ageRatingGuide'] ?? ''}'.trim(),
      };
      return MediaDetailModel(synopsis: a['synopsis']?.toString(), information: info);
    } on DioException catch (e) {
      throw ApiException.fromDio(e, source: 'Kitsu');
    }
  }

  void dispose() { _tmdb.close(); _anilist.close(); _kitsu.close(); }
}
