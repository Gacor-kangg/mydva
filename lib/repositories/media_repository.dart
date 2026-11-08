import '../models/media_model.dart';
import '../services/tmdb_service.dart';
import '../services/anilist_service.dart';

class MediaRepository {
  final TmdbService _tmdbService;
  final AnilistService _anilistService;

  MediaRepository({
    required TmdbService tmdbService,
    required AnilistService anilistService,
  }) : _tmdbService = tmdbService,
       _anilistService = anilistService;

  Future<List<MediaModel>> getMovies({int page = 1}) {
    return _tmdbService.getPopularMovies(page: page);
  }

  Future<List<MediaModel>> getSeries({int page = 1}) {
    return _tmdbService.getPopularSeries(page: page);
  }

  Future<List<MediaModel>> getAnime({int page = 1, int perPage = 20}) {
    return _anilistService.getTrendingAnime(page: page, perPage: perPage);
  }

  void dispose() {
    _tmdbService.dispose();
    _anilistService.dispose();
  }
}
