class MediaModel {
  final String title;
  final String imageUrl;
  final String? genre;
  final int? releaseYear;

  // Informasi tambahan dari API
  final String? externalId;
  final String? overview;
  final double? rating;
  final int? ratingScale;
  final String? ratingSource;
  final int? voteCount;
  final List<String> genres;

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
  });

  String getDisplayTitle() {
    if (releaseYear != null) {
      return '$title ($releaseYear)';
    }
    return title;
  }

  // Membentuk model dari respons TMDB.
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

  // Membentuk model dari respons AniList.
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
      releaseYear: dateData['year'] is num
          ? (dateData['year'] as num).toInt()
          : null,
      overview: json['description'] as String?,
      rating: rawRating is num ? rawRating.toDouble() : null,
      ratingScale: 100,
      ratingSource: 'AniList',
      genres: rawGenres is List
          ? rawGenres.map((item) => item.toString()).toList()
          : const [],
    );
  }

  String get formattedRating {
    if (rating == null) return 'Belum ada rating';

    final value = ratingScale == 100
        ? rating!.toStringAsFixed(0)
        : rating!.toStringAsFixed(1);

    return '$value/${ratingScale ?? 10}';
  }
}
