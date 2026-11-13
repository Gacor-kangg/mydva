
import '../models/media_model.dart';
import '../services/anilist_service.dart';
import '../services/api_exception.dart';
import '../services/kitsu_service.dart';
import '../services/tmdb_service.dart';

class MediaRepository {
  final TmdbService _tmdbService;
  final AnilistService _anilistService;
  final KitsuService _kitsuService;

  MediaRepository({
    required TmdbService tmdbService,
    required AnilistService anilistService,
    required KitsuService kitsuService,
  }) : _tmdbService = tmdbService,
       _anilistService = anilistService,
       _kitsuService = kitsuService;

  // =========================
  // FILM - TMDB
  // =========================

  Future<List<MediaModel>> getMovies({
    int page = 1,
  }) {
    return _tmdbService.getPopularMovies(page: page);
  }

  // =========================
  // SERIES - TMDB
  // =========================

  Future<List<MediaModel>> getSeries({
    int page = 1,
  }) {
    return _tmdbService.getPopularSeries(page: page);
  }

  // =========================
  // ANIME - ANILIST + KITSU
  // =========================

  Future<List<MediaModel>> getAnime({
    int page = 1,
    int perPage = 20,
  }) async {
    List<MediaModel> anilistResults = [];
    List<MediaModel> kitsuResults = [];

    ApiException? anilistError;
    ApiException? kitsuError;

    // Ambil data dari AniList.
    try {
      anilistResults = await _anilistService.getTrendingAnime(
        page: page,
        perPage: perPage,
      );
    } on ApiException catch (error) {
      anilistError = error;
    }

    // Ambil data tambahan dari Kitsu.
    try {
      kitsuResults = await _kitsuService.getPopularAnime(
        page: page,
        perPage: perPage,
      );
    } on ApiException catch (error) {
      kitsuError = error;
    }

    // Jika kedua API gagal, tampilkan error.
    if (anilistError != null && kitsuError != null) {
      throw ApiException(
        'AniList dan Kitsu gagal mengambil data. '
        'AniList: ${anilistError.message} '
        'Kitsu: ${kitsuError.message}',
      );
    }

    // AniList diprioritaskan, Kitsu melengkapi katalog.
    return _mergeAnime(
      anilistResults,
      kitsuResults,
    );
  }

  // =========================
  // J-DRAMA & K-DRAMA - TMDB
  // =========================
  //
  // [pages] = jumlah halaman TMDB (20 judul per halaman) yang diambil
  // sekaligus. [newest] = true untuk urutan tayang terbaru.

  Future<List<MediaModel>> getJDrama({int pages = 3, bool newest = false}) {
    return _fetchPages(
      pages,
      (page) => _tmdbService.getJDrama(
        page: page,
        sortBy: newest ? TmdbService.sortNewest : TmdbService.sortPopular,
      ),
    );
  }

  Future<List<MediaModel>> getKDrama({int pages = 3, bool newest = false}) {
    return _fetchPages(
      pages,
      (page) => _tmdbService.getKDrama(
        page: page,
        sortBy: newest ? TmdbService.sortNewest : TmdbService.sortPopular,
      ),
    );
  }

  Future<List<MediaModel>> _fetchPages(
    int pages,
    Future<List<MediaModel>> Function(int page) loader,
  ) async {
    final responses = await Future.wait(
      [for (var page = 1; page <= pages; page++) loader(page)],
    );

    final seen = <String>{};
    final result = <MediaModel>[];

    for (final media in responses.expand((list) => list)) {
      final id = media.externalId;
      if (id == null || seen.add(id)) result.add(media);
    }

    return result;
  }

  // =========================
  // SEARCH FILM & SERIES - TMDB
  // =========================

  Future<List<MediaModel>> searchMovies(String keyword) {
    return _tmdbService.searchMovies(keyword);
  }

  Future<List<MediaModel>> searchSeries(String keyword) {
    return _tmdbService.searchSeries(keyword);
  }

  // =========================
  // SEARCH ANIME
  // =========================

  Future<List<MediaModel>> searchAnime(
    String keyword,
  ) async {
    List<MediaModel> anilistResults = [];
    List<MediaModel> kitsuResults = [];

    ApiException? anilistError;
    ApiException? kitsuError;

    // Pencarian AniList akan ditambahkan
    // pada pembaruan AnilistService berikutnya.
    try {
      anilistResults = await _anilistService.searchAnime(keyword);
    } on ApiException catch (error) {
      anilistError = error;
    }

    try {
      kitsuResults = await _kitsuService.searchAnime(keyword);
    } on ApiException catch (error) {
      kitsuError = error;
    }

    if (anilistError != null && kitsuError != null) {
      throw ApiException(
        'Pencarian anime gagal. '
        'AniList: ${anilistError.message} '
        'Kitsu: ${kitsuError.message}',
      );
    }

    return _mergeAnime(
      anilistResults,
      kitsuResults,
    );
  }

  // =========================
  // SEARCH J-DRAMA
  // =========================

  Future<List<MediaModel>> searchJDrama(
    String keyword,
  ) {
    return _tmdbService.searchDrama(
      keyword: keyword,
      countryCode: TmdbService.japanCode,
      mediaType: 'J-Drama',
    );
  }

  // =========================
  // SEARCH K-DRAMA
  // =========================

  Future<List<MediaModel>> searchKDrama(
    String keyword,
  ) {
    return _tmdbService.searchDrama(
      keyword: keyword,
      countryCode: TmdbService.koreaCode,
      mediaType: 'K-Drama',
    );
  }

  // =========================
  // MERGE ANIME
  // =========================

  List<MediaModel> _mergeAnime(
    List<MediaModel> anilist,
    List<MediaModel> kitsu,
  ) {
    final result = <MediaModel>[];
    final existingTitles = <String>{};

    for (final anime in [...anilist, ...kitsu]) {
      final normalizedTitle = _normalizeTitle(anime.title);

      if (normalizedTitle.isEmpty) continue;

      if (existingTitles.add(normalizedTitle)) {
        result.add(anime);
      }
    }

    return result;
  }

  String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // =========================
  // DISPOSE
  // =========================

  void dispose() {
    _tmdbService.dispose();
    _anilistService.dispose();
    _kitsuService.dispose();
  }
}
