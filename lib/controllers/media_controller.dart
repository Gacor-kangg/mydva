import 'package:flutter/foundation.dart';

import '../models/media_model.dart';
import '../repositories/media_repository.dart';
import '../services/api_exception.dart';

class MediaController extends ChangeNotifier {
  final MediaRepository _repository;

  MediaController({required MediaRepository repository})
    : _repository = repository;

  // State data
  List<MediaModel> _mediaList = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedType = 'Film';
  String _searchQuery = '';
  String _selectedSort = 'Popular';

  // Mencegah respons request lama menimpa request terbaru.
  int _requestId = 0;

  // Getter
  List<MediaModel> get mediaList => List.unmodifiable(_mediaList);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get selectedType => _selectedType;

  String get searchQuery => _searchQuery;

  String get selectedSort => _selectedSort;

  bool get hasError => _errorMessage != null;

  // Data yang sudah melalui pencarian dan sorting.
  List<MediaModel> get filteredMedia {
    final result = _mediaList.where((media) {
      return media.title.toLowerCase().contains(_searchQuery.toLowerCase());
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
        // Urutan asli dari API dipertahankan.
        break;
    }

    return result;
  }

  // Mengambil data berdasarkan jenis media.
  Future<void> loadMedia(String type) async {
    if (!['Film', 'Series', 'Anime'].contains(type)) {
      _errorMessage = 'Jenis media tidak dikenal.';
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

        default:
          result = [];
      }

      // Abaikan hasil request yang sudah tidak relevan.
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

  // Mengubah pencarian.
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  // Mengubah metode sorting.
  void setSort(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  // Memuat ulang data saat tombol refresh digunakan.
  Future<void> refresh() {
    return loadMedia(_selectedType);
  }

  @override
  void dispose() {
    _requestId++;
    super.dispose();
  }
}
