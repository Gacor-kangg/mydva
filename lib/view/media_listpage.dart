import 'package:flutter/material.dart';

import '../controllers/media_controller.dart';
import 'media_detail_page.dart';
import '../models/media_model.dart';
import 'poster_image.dart';
import '../repositories/media_repository.dart';
import '../services/anilist_service.dart';
import '../services/tmdb_service.dart';
import 'ui_effects.dart';
import '../services/kitsu_service.dart';

class MediaListPage extends StatefulWidget {
  final String initialType;

  const MediaListPage({super.key, this.initialType = 'Film'});

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  late final TmdbService _tmdbService;
  late final AnilistService _anilistService;
  late final MediaRepository _repository;
  late final MediaController _controller;
  late final KitsuService _kitsuService;

  @override
  void initState() {
    super.initState();

    // Inisialisasi service API.
    _tmdbService = TmdbService();
    _anilistService = AnilistService();
    _kitsuService = KitsuService();

    // Inisialisasi repository.
    _repository = MediaRepository(
      tmdbService: _tmdbService,
      anilistService: _anilistService,
      kitsuService: _kitsuService,
    );

    // Inisialisasi controller.
    _controller = MediaController(repository: _repository);

    // Mendengarkan perubahan state controller.
    _controller.addListener(_onControllerChanged);

    // Memuat kategori awal.
    _controller.loadMedia(widget.initialType);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _repository.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = _controller.filteredMedia;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),

      appBar: AppBar(
        backgroundColor: const Color(0xFF202020),
        foregroundColor: Colors.white,
        title: const Text(
          'Media List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            // SEARCH
            TextField(
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: 'Search media...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF202020),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: _controller.setSearchQuery,
            ),

            const SizedBox(height: 14),

            // DROPDOWNS
            Row(
              children: [
                // MEDIA TYPE
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_controller.selectedType),
                    initialValue: _controller.selectedType,
                    dropdownColor: const Color(0xFF202020),
                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      labelText: 'Media Type',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF202020),
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(value: 'Film', child: Text('Film')),
                      DropdownMenuItem(value: 'Series', child: Text('Series')),
                      DropdownMenuItem(value: 'Anime', child: Text('Anime')),
                      DropdownMenuItem(
                        value: 'J-Drama',
                        child: Text('J-Drama'),
                      ),
                      DropdownMenuItem(
                        value: 'K-Drama',
                        child: Text('K-Drama'),
                      ),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        _controller.loadMedia(value);
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // SORT
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_controller.selectedSort),
                    initialValue: _controller.selectedSort,
                    dropdownColor: const Color(0xFF202020),
                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF202020),
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'Popular',
                        child: Text('Popular'),
                      ),
                      DropdownMenuItem(value: 'Newest', child: Text('Newest')),
                      DropdownMenuItem(value: 'Oldest', child: Text('Oldest')),
                      DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        _controller.setSort(value);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MEDIA LIST
            Expanded(child: _buildMediaContent(mediaList)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEDIA CONTENT
  // ============================================================

  Widget _buildMediaContent(List<MediaModel> mediaList) {
    // LOADING
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF9DBEFF)),
      );
    }

    // ERROR
    if (_controller.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Colors.redAccent, size: 48),

              const SizedBox(height: 14),

              const Text(
                'Gagal Memuat Data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _controller.errorMessage ?? 'Terjadi kesalahan.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: _controller.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // EMPTY DATA
    if (mediaList.isEmpty) {
      return const Center(
        child: Text(
          'Media tidak ditemukan.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // SUCCESS
    return RefreshIndicator(
      onRefresh: _controller.refresh,
      color: const Color(0xFF9DBEFF),

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: mediaList.length,

        itemBuilder: (context, index) {
          final media = mediaList[index];

          return _mediaListItem(media);
        },
      ),
    );
  }

  // ============================================================
  // MEDIA LIST ITEM
  // ============================================================

  Widget _mediaListItem(MediaModel media) {
    return HoverLift(
      hoverScale: 1.01,

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaDetailPage(media: media),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF303030)),
        ),

        child: Row(
          children: [
            // POSTER
            ClipRRect(
              borderRadius: BorderRadius.circular(4),

              child: PosterImage(
                media: media,
                width: 65,
                height: 90,
                placeholderColor: Colors.grey.shade800,
                textColor: Colors.grey,
                textSize: 24,
              ),
            ),

            const SizedBox(width: 14),

            // INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    media.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    '${media.genre ?? _controller.selectedType} '
                    '• ${media.releaseYear ?? '-'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  if (media.rating != null) ...[
                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),

                        const SizedBox(width: 4),

                        Text(
                          '${media.formattedRating} '
                          '· ${media.ratingSource ?? ''}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
