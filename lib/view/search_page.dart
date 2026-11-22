import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/media_model.dart';
import '../repositories/media_repository.dart';
import 'app_colors.dart';
import 'media_detail_page.dart';
import 'poster_image.dart';
import 'skeletons.dart';

/// Halaman pencarian untuk semua kategori sekaligus
/// (Film, Series, Anime, J-Drama, K-Drama).
class SearchPage extends StatefulWidget {
  final MediaRepository repository;

  const SearchPage({super.key, required this.repository});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const int _minChars = 2;
  static const int _maxPerCategory = 10;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  Timer? _debounce;
  int _requestId = 0;

  String _query = '';
  bool _loading = false;
  bool _failed = false;
  List<MediaModel> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ============================================================
  // PENCARIAN
  // ============================================================

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();

    // batalkan permintaan lama supaya hasil lamanya tidak muncul
    _requestId++;

    if (q.length < _minChars) {
      setState(() {
        _query = q;
        _loading = false;
        _failed = false;
        _results = [];
      });
      return;
    }

    setState(() {
      _query = q;
      _loading = true;
      _failed = false;
    });

    _debounce = Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  void _onSubmitted(String value) {
    final q = value.trim();
    if (q.length < _minChars) return;

    _debounce?.cancel();
    setState(() {
      _query = q;
      _loading = true;
      _failed = false;
    });
    _search(q);
  }

  void _clear() {
    _debounce?.cancel();
    _requestId++;
    _controller.clear();
    setState(() {
      _query = '';
      _loading = false;
      _failed = false;
      _results = [];
    });
    _focus.requestFocus();
  }

  /// Jalankan satu pencarian; kalau gagal, hasilnya null (bukan error).
  Future<List<MediaModel>?> _safe(
    Future<List<MediaModel>> Function() run,
  ) async {
    try {
      return await run();
    } catch (_) {
      return null;
    }
  }

  Future<void> _search(String q) async {
    final id = ++_requestId;
    final repo = widget.repository;

    final responses = await Future.wait([
      _safe(() => repo.searchMovies(q)),
      _safe(() => repo.searchSeries(q)),
      _safe(() => repo.searchAnime(q)),
      _safe(() => repo.searchJDrama(q)),
      _safe(() => repo.searchKDrama(q)),
    ]);

    // pengguna sudah mengetik hal lain / menutup halaman
    if (!mounted || id != _requestId) return;

    final failedAll = responses.every((r) => r == null);

    setState(() {
      _loading = false;
      _failed = failedAll;
      _results = failedAll
          ? []
          : _merge(
              q,
              film: responses[0] ?? const [],
              series: responses[1] ?? const [],
              anime: responses[2] ?? const [],
              jdrama: responses[3] ?? const [],
              kdrama: responses[4] ?? const [],
            );
    });
  }

  /// Gabungkan hasil semua kategori:
  /// 1. buang judul ganda (drama Korea/Jepang juga muncul di Series TMDB,
  ///    jadi label drama yang dipilih),
  /// 2. selang-seling antar kategori,
  /// 3. judul yang paling cocok dengan kata kunci ditaruh di atas.
  List<MediaModel> _merge(
    String query, {
    required List<MediaModel> film,
    required List<MediaModel> series,
    required List<MediaModel> anime,
    required List<MediaModel> jdrama,
    required List<MediaModel> kdrama,
  }) {
    // urutan prioritas saat ada judul ganda
    final priority = [film, anime, jdrama, kdrama, series];
    final seenKeys = <String>{};
    final kept = HashSet<MediaModel>.identity();

    for (final group in priority) {
      for (final item in group) {
        if (seenKeys.add(item.mediaKey)) kept.add(item);
      }
    }

    // urutan tampil: selang-seling antar kategori
    final display = [film, series, anime, jdrama, kdrama]
        .map(
          (g) => g.where(kept.contains).take(_maxPerCategory).toList(),
        )
        .toList();

    final interleaved = <MediaModel>[];
    for (int i = 0; i < _maxPerCategory; i++) {
      for (final group in display) {
        if (i < group.length) interleaved.add(group[i]);
      }
    }

    final q = query.toLowerCase();
    int score(MediaModel m) {
      final t = m.title.toLowerCase();
      if (t == q) return 0;
      if (t.startsWith(q)) return 1;
      if (t.contains(q)) return 2;
      return 3;
    }

    final indexed = [
      for (int i = 0; i < interleaved.length; i++) (i, interleaved[i]),
    ];
    indexed.sort((a, b) {
      final byScore = score(a.$2).compareTo(score(b.$2));
      return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
    });

    return indexed.map((e) => e.$2).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: true,
          textInputAction: TextInputAction.search,
          cursorColor: Colors.white,
          onChanged: _onChanged,
          onSubmitted: _onSubmitted,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Cari film, series, anime...',
            hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 16),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            TextButton(
              onPressed: _clear,
              child: const Text(
                'Hapus',
                style: TextStyle(color: AppColors.lightBlue),
              ),
            ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_query.length < _minChars) {
      return _message(
        'Ketik judul untuk mencari di semua kategori:\n'
        'Film, Series, Anime, J-Drama, dan K-Drama.',
      );
    }

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: SearchResultSkeleton(),
      );
    }

    if (_failed) {
      return _message(
        'Gagal memuat hasil pencarian.\n'
        'Periksa koneksi internet lalu coba lagi.',
      );
    }

    if (_results.isEmpty) {
      return _message('Tidak ada hasil untuk "$_query".');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      itemCount: _results.length + 1,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        color: AppColors.border,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${_results.length} hasil untuk "$_query"',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
          );
        }
        return _ResultTile(
          media: _results[index - 1],
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MediaDetailPage(media: _results[index - 1]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _message(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// ==============================================================
// SATU BARIS HASIL
// ==============================================================

class _ResultTile extends StatelessWidget {
  final MediaModel media;
  final VoidCallback onTap;

  const _ResultTile({required this.media, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final overview = (media.overview ?? '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();

    return InkWell(
      onTap: onTap,
      hoverColor: const Color(0x144A6FC3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: PosterImage(media: media, width: 56, height: 84),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.getDisplayTitle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _CategoryChip(type: media.mediaType),
                  if (overview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                        height: 1.4,
                      ),
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

class _CategoryChip extends StatelessWidget {
  final String type;

  const _CategoryChip({required this.type});

  static const Map<String, (Color, Color)> _colors = {
    'Film': (Color(0x334A6FC3), Color(0xFF9DBEFF)),
    'Series': (Color(0x33805AD5), Color(0xFFC4B5FD)),
    'Anime': (Color(0x33D53F8C), Color(0xFFF9A8D4)),
    'J-Drama': (Color(0x33DD6B20), Color(0xFFFBBF77)),
    'K-Drama': (Color(0x3338A89D), Color(0xFF81E6D9)),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) =
        _colors[type] ?? (const Color(0x338E8E93), AppColors.softText);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}