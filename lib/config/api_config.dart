class ApiConfig {
  ApiConfig._();

  // TMDB
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static const String tmdbAccessToken = String.fromEnvironment(
    'TMDB_ACCESS_TOKEN',
  );

  // AniList
  static const String anilistUrl = 'https://graphql.anilist.co';

  // Kitsu
  static const String kitsuBaseUrl = 'https://kitsu.io/api/edge';

  // TVmaze
  static const String tvmazeBaseUrl = 'https://api.tvmaze.com';

  static const String language = 'id-ID';

  static const Duration requestTimeout = Duration(seconds: 20);
}
