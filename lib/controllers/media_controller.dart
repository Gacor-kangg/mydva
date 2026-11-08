import 'package:flutter/foundation.dart';

import '../models/media_model.dart';
import '../repositories/media_repository.dart';
import '../services/api_exception.dart';
import 'dart:async';

class MediaController extends ChangeNotifier {
  final MediaRepository _repository;

  MediaController({required MediaRepository repository})
    : _repository = repository;

  static const List<String> mediaTypes = [
    'Film',
    'Series',
    'Anime',
    'J-Drama',
    'K-Drama',
  ];

  List<MediaModel> _mediaList = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedType = 'Film';
  String _searchQuery = '';
  String _selectedSort = 'Popular';

  int _requestId = 0;
  Timer? _searchDebounce;

  List<MediaModel> get mediaList => List.unmodifiable(_mediaList);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get selectedType => _selectedType;

  String get searchQuery => _searchQuery;

  String get selectedSort => _selectedSort;

  bool get hasError => _errorMessage != null;

  List<MediaModel> get filteredMedia {
    final query = _searchQuery.toLowerCase();

    final result = _mediaList.where((media) {
      return media.title.toLowerCase().contains(query);
    }).toList();

    switch (_selectedSort) {
      case 'A-Z':
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;

      case 'Newest':
        result.sort(
          (a, b) => (b.releaseYear ?? 0).compareTo(a.releaseYear ?? 0),
        );
        break;

      case 'Oldest':
        result.sort(
          (a, b) => (a.releaseYear ?? 0).compareTo(b.releaseYear ?? 0),
        );
        break;

      case 'Popular':
      default:
        result.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }

    return result;
  }

  Future<void> loadMedia(String type) async {
    _searchDebounce?.cancel();
    if (!mediaTypes.contains(type)) {
      _errorMessage = 'Jenis media tidak dikenal.';
      _mediaList = [];
      notifyListeners();
      return;
    }

    _selectedType = type;

    final currentRequest = ++_requestId;

    _isLoading = true;
    _errorMessage = null;
    _mediaList = [];

    notifyListeners();

    try {
      late final List<MediaModel> result;

      switch (type) {
        case 'Film':
          result = await _repository.getMovies();
          break;

        case 'Series':
          result = await _repository.getSeries();
          break;

        case 'Anime':
          result = await _repository.getAnime();
          break;

        case 'J-Drama':
          result = await _repository.getJDrama();
          break;

        case 'K-Drama':
          result = await _repository.getKDrama();
          break;

        default:
          result = [];
      }

      if (currentRequest != _requestId) return;

      _mediaList = result;
      _errorMessage = null;
    } on ApiException catch (error) {
      if (currentRequest != _requestId) return;

      _mediaList = [];
      _errorMessage = error.message;
    } catch (error) {
      if (currentRequest != _requestId) return;

      _mediaList = [];
      _errorMessage = 'Terjadi kesalahan: $error';
    } finally {
      if (currentRequest == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();

    _searchDebounce?.cancel();

    if (_searchQuery.isEmpty) {
      loadMedia(_selectedType);
      return;
    }

    // Film dan Series sementara tetap difilter dari data yang sudah dimuat.
    if (_selectedType == 'Film' || _selectedType == 'Series') {
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _searchMediaFromApi(_searchQuery),
    );
  }

  Future<void> _searchMediaFromApi(String keyword) async {
    final currentRequest = ++_requestId;

    _isLoading = true;
    _errorMessage = null;
    _mediaList = [];

    notifyListeners();

    try {
      late final List<MediaModel> result;

      switch (_selectedType) {
        case 'Anime':
          result = await _repository.searchAnime(keyword);
          break;

        case 'J-Drama':
          result = await _repository.searchJDrama(keyword);
          break;

        case 'K-Drama':
          result = await _repository.searchKDrama(keyword);
          break;

        default:
          result = [];
      }

      if (currentRequest != _requestId) return;

      _mediaList = result;
    } on ApiException catch (error) {
      if (currentRequest != _requestId) return;

      _mediaList = [];
      _errorMessage = error.message;
    } catch (error) {
      if (currentRequest != _requestId) return;

      _mediaList = [];
      _errorMessage = 'Terjadi kesalahan saat mencari: $error';
    } finally {
      if (currentRequest == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }


  void setSort(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  Future<void> refresh() {
    return loadMedia(_selectedType);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _requestId++;
    super.dispose();
  }
}
