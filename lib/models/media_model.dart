class MediaModel {
  final String title;
  final String imageUrl;
  final String? genre;
  final int? releaseYear;

  final String? externalId;
  final String? overview;

  final double? rating;
  final int? ratingScale;
  final String? ratingSource;
  final int? voteCount;

  final List<String> genres;

  // Identitas kategori dan sumber API
  final String mediaType;
  final String source;

  MediaModel({
    required this.title,
    required this.imageUrl,
    this.genre,
    this.releaseYear,
    this.externalId,
    this.overview,
    this.rating,
    this.ratingScale,
    this.ratingSource,
    this.voteCount,
    this.genres = const [],
    this.mediaType = 'Film',
    this.source = 'TMDB',
  });

  /// Kunci unik dan stabil untuk menyimpan judul ini di database.
  ///
  /// Format: {sumber}_{jenis}_{externalId}, contoh tmdb_movie_550 atau
  /// anilist_anime_21. Jenis dipisah (movie/tv/anime) karena id TMDB untuk
  /// film dan serial bisa sama. Aman dipakai sebagai ID dokumen Firestore.
  String get mediaKey {
    final src = source.toLowerCase();
    final kind = mediaType == 'Film'
        ? 'movie'
        : mediaType == 'Anime'
        ? 'anime'
        : 'tv';

    final id = (externalId != null && externalId!.isNotEmpty)
        ? externalId!
        : _slug('$title ${releaseYear ?? ''}');

    return '${src}_${kind}_$id';
  }

  static String _slug(String input) {
    var slug = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length > 80) slug = slug.substring(0, 80);
    return slug.isEmpty ? 'unknown' : slug;
  }

  String getDisplayTitle() {
    if (releaseYear != null) {
      return '$title ($releaseYear)';
    }
    return title;
  }

  // =========================
  // TMDB
  // =========================

  factory MediaModel.fromTmdb(
    Map<String, dynamic> json, {
    required String mediaType,
  }) {
    final isMovie = mediaType == 'Film';

    final date = isMovie ? json['release_date'] : json['first_air_date'];

    final posterPath = json['poster_path'];
    final rawRating = json['vote_average'];

    return MediaModel(
      externalId: json['id']?.toString(),
      title: (isMovie ? json['title'] : json['name']) ?? 'Untitled',
      imageUrl: posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : '',
      genre: mediaType,
      mediaType: mediaType,
      source: 'TMDB',
      releaseYear: date is String && date.length >= 4
          ? int.tryParse(date.substring(0, 4))
          : null,
      overview: json['overview'] as String?,
      rating: rawRating is num ? rawRating.toDouble() : null,
      ratingScale: 10,
      ratingSource: 'TMDB',
      voteCount: json['vote_count'] is num
          ? (json['vote_count'] as num).toInt()
          : null,
    );
  }

  // =========================
  // ANILIST
  // =========================

  factory MediaModel.fromAniList(Map<String, dynamic> json) {
    final titleData = json['title'] as Map<String, dynamic>? ?? {};

    final coverData = json['coverImage'] as Map<String, dynamic>? ?? {};

    final dateData = json['startDate'] as Map<String, dynamic>? ?? {};

    final title =
        titleData['english'] ??
        titleData['romaji'] ??
        titleData['native'] ??
        'Untitled';

    final rawRating = json['averageScore'];
    final rawGenres = json['genres'];

    return MediaModel(
      externalId: json['id']?.toString(),
      title: title.toString(),
      imageUrl: (coverData['large'] ?? '').toString(),
      genre: 'Anime',
      mediaType: 'Anime',
      source: 'AniList',
      releaseYear: dateData['year'] is num
          ? (dateData['year'] as num).toInt()
          : null,
      overview: json['description'] as String?,
      rating: rawRating is num ? rawRating.toDouble() : null,
      ratingScale: 100,
      ratingSource: 'AniList',
      voteCount: _parseAniListVoteCount(json['stats']),
      genres: rawGenres is List
          ? rawGenres.map((item) => item.toString()).toList()
          : const [],
    );
  }

  // =========================
  // KITSU
  // =========================

  factory MediaModel.fromKitsu(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};

    final titles = attributes['titles'] as Map<String, dynamic>? ?? {};

    final poster = attributes['posterImage'] as Map<String, dynamic>? ?? {};

    final rawRating = attributes['averageRating'];
    final rawGenres = attributes['genres'];

    final title =
        attributes['canonicalTitle'] ??
        titles['en'] ??
        titles['en_jp'] ??
        titles['ja_jp'] ??
        'Untitled';

    final startDate = attributes['startDate'];

    return MediaModel(
      externalId: json['id']?.toString(),
      title: title.toString(),
      imageUrl: _kitsuPoster(poster),
      genre: 'Anime',
      mediaType: 'Anime',
      source: 'Kitsu',
      releaseYear: startDate is String && startDate.length >= 4
          ? int.tryParse(startDate.substring(0, 4))
          : null,
      overview: attributes['synopsis'] as String?,
      rating: rawRating is String
          ? double.tryParse(rawRating)
          : rawRating is num
          ? rawRating.toDouble()
          : null,
      ratingScale: 100,
      ratingSource: 'Kitsu',
      voteCount: _parseKitsuVoteCount(attributes['ratingFrequencies']),
      genres: rawGenres is List
          ? rawGenres
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return item['name']?.toString() ?? '';
                  }
                  return '';
                })
                .where((item) => item.isNotEmpty)
                .toList()
          : const [],
    );
  }

  /// Kitsu tidak selalu mengisi ukuran 'large', jadi dicoba beberapa ukuran.
  static String _kitsuPoster(Map<String, dynamic> poster) {
    for (final key in ['large', 'medium', 'original', 'small', 'tiny']) {
      final url = poster[key]?.toString() ?? '';
      if (url.isNotEmpty && url != 'null') {
        return url.replaceFirst('http://', 'https://');
      }
    }
    return '';
  }

  // =========================
  // TVMAZE
  // =========================

  factory MediaModel.fromTvmaze(
    Map<String, dynamic> json, {
    required String mediaType,
  }) {
    final image = json['image'] as Map<String, dynamic>? ?? {};

    final ratingData = json['rating'] as Map<String, dynamic>? ?? {};

    final rawRating = ratingData['average'];

    final premiered = json['premiered'];

    final genresData = json['genres'];

    return MediaModel(
      externalId: json['id']?.toString(),
      title: (json['name'] ?? 'Untitled').toString(),
      imageUrl: (image['original'] ?? image['medium'] ?? '').toString(),
      genre: mediaType,
      mediaType: mediaType,
      source: 'TVmaze',
      releaseYear: premiered is String && premiered.length >= 4
          ? int.tryParse(premiered.substring(0, 4))
          : null,
      overview: json['summary']?.toString(),
      rating: rawRating is num ? rawRating.toDouble() : null,
      ratingScale: 10,
      ratingSource: 'TVmaze',
      genres: genresData is List
          ? genresData.map((item) => item.toString()).toList()
          : const [],
    );
  }

  // =========================
  // FORMATTED RATING
  // =========================

  String get formattedRating {
    if (rating == null) return 'Belum ada rating';

    final value = ratingScale == 100
        ? rating!.toStringAsFixed(0)
        : rating!.toStringAsFixed(1);

    return '$value/${ratingScale ?? 10}';
  }

  static int _parseAniListVoteCount(dynamic stats) {
    if (stats is! Map<String, dynamic>) return 0;

    final distribution = stats['scoreDistribution'];

    if (distribution is! List) return 0;

    return distribution.fold<int>(0, (total, item) {
      if (item is! Map<String, dynamic>) return total;

      final amount = item['amount'];

      return total + (amount is num ? amount.toInt() : 0);
    });
  }

  static int _parseKitsuVoteCount(dynamic frequencies) {
    if (frequencies is! Map) return 0;

    return frequencies.values.fold<int>(0, (total, value) {
      final count = value is num
          ? value.toInt()
          : int.tryParse(value.toString()) ?? 0;

      return total + count;
    });
  }
}
