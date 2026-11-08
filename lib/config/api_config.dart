class ApiConfig {
  ApiConfig._();

  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static const String anilistUrl = 'https://graphql.anilist.co';

  static const String tmdbAccessToken = String.fromEnvironment(
    'TMDB_ACCESS_TOKEN',
  );

  static const String language = 'id-ID';
}
