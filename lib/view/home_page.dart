import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'media_detail_page.dart';
import 'media_listpage.dart';
import '../models/media_model.dart';
import '../repositories/media_repository.dart';
import '../services/anilist_service.dart';
import '../services/kitsu_service.dart';
import '../services/tmdb_service.dart';
import 'poster_image.dart';
import 'profile_page.dart';
import 'skeletons.dart';
import 'ui_effects.dart';

class _HomeSection {
  final String title;
  final List<MediaModel> items;
  final String? listType;
  final int total;
  final bool featured;
  final bool isLoading;
  final String? errorMessage;

  _HomeSection({
    required this.title,
    required this.items,
    this.listType,
    this.total = 0,
    this.featured = false,
    this.isLoading = false,
    this.errorMessage,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Data Home seluruhnya dimuat melalui API menggunakan MediaRepository.
  late final TmdbService _tmdbService;
  late final AnilistService _anilistService;
  late final KitsuService _kitsuService;
  late final MediaRepository _repository;

  final Map<String, List<MediaModel>> _homeData = {
    'Film': [],
    'Series': [],
    'Anime': [],
    'J-Drama': [],
    'K-Drama': [],
  };
  final Map<String, String?> _homeErrors = {
    'Film': null,
    'Series': null,
    'Anime': null,
    'J-Drama': null,
    'K-Drama': null,
  };
  bool _isLoading = true;

  static const Color backgroundColor = AppColors.background;
  static const Color headerColor = AppColors.panel;
  static const Color cardColor = AppColors.card;
  static const Color borderColor = AppColors.border;
  static const Color lightBlue = AppColors.lightBlue;
  static const Color mutedText = AppColors.mutedText;

  static const double _headerHeight = 62;
  static const int _popularLimit = 15;
  static const int _newestLimit = 12;
  static const int _heroCount = 5;
  static const Duration _heroInterval = Duration(seconds: 6);

  static const List<String> _sectionTitles = [
    'Rekomendasi Untukmu',
    'Series Terbaru',
    'Series Unggulan',
    'Film Populer',
    'Film Terbaru',
    'Anime Terpopuler',
    'Anime Terbaru',
    'J-Drama Terpopuler',
    'J-Drama Terbaru',
    'K-Drama Terpopuler',
    'K-Drama Terbaru',
  ];

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  late final List<String> _navTitles;
  String _activeSection = '';
  final ValueNotifier<double> _headerOpacity = ValueNotifier<double>(0);

  List<MediaModel> _heroItems = [];
  final PageController _heroController = PageController();
  Timer? _heroTimer;
  int _heroIndex = 0;

  @override
  void initState() {
    super.initState();
    _navTitles = List<String>.from(_sectionTitles);
    _tmdbService = TmdbService();
    _anilistService = AnilistService();
    _kitsuService = KitsuService();
    _repository = MediaRepository(
      tmdbService: _tmdbService,
      anilistService: _anilistService,
      kitsuService: _kitsuService,
    );
    _scrollController.addListener(_onScroll);
    _loadHomeData();
  }

  Future<List<MediaModel>> _loadCategory(
    String category,
    Future<List<MediaModel>> request,
  ) async {
    try {
      final items = await request;
      _homeErrors[category] = items.isEmpty
          ? 'Belum ada data yang dapat ditampilkan.'
          : null;
      return items;
    } catch (error) {
      _homeErrors[category] = error.toString();
      debugPrint('Gagal memuat $category: $error');
      return [];
    }
  }

  Future<void> _loadHomeData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      for (final key in _homeErrors.keys) {
        _homeErrors[key] = null;
      }
    });

    final results = await Future.wait<List<MediaModel>>([
      _loadCategory('Film', _repository.getMovies(page: 1)),
      _loadCategory('Series', _repository.getSeries(page: 1)),
      _loadCategory('Anime', _repository.getAnime(page: 1, perPage: 20)),
      _loadCategory('J-Drama', _repository.getJDrama(pages: 3)),
      _loadCategory('K-Drama', _repository.getKDrama(pages: 3)),
    ]);

    if (!mounted) return;
    setState(() {
      _homeData['Film'] = results[0];
      _homeData['Series'] = results[1];
      _homeData['Anime'] = results[2];
      _homeData['J-Drama'] = results[3];
      _homeData['K-Drama'] = results[4];
      _isLoading = false;
      _heroItems = _buildHeroItems();
      _heroIndex = 0;
    });
    if (_heroController.hasClients) _heroController.jumpToPage(0);
    _startHeroTimer();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _headerOpacity.dispose();
    _repository.dispose();
    super.dispose();
  }

  List<MediaModel> _newestFirst(List<MediaModel> items) {
    final sorted = List<MediaModel>.from(items);
    sorted.sort((a, b) => (b.releaseYear ?? 0).compareTo(a.releaseYear ?? 0));
    return sorted;
  }

  List<_HomeSection> _buildSections() {
    final movies = _homeData['Film'] ?? [];
    final series = _homeData['Series'] ?? [];
    final anime = _homeData['Anime'] ?? [];
    final jdrama = _homeData['J-Drama'] ?? [];
    final kdrama = _homeData['K-Drama'] ?? [];

    final featured = <MediaModel>[
      ...movies.take(2),
      ...series.take(2),
      ...anime.take(2),
      ...jdrama.take(1),
      ...kdrama.take(1),
    ];
    final seen = <String>{};
    final recommendations = featured
        .where((item) {
          final key = '${item.mediaType}:${item.externalId ?? item.title}'
              .toLowerCase();
          return item.imageUrl.isNotEmpty && seen.add(key);
        })
        .take(8)
        .toList();

    return [
      _HomeSection(
        title: 'Rekomendasi Untukmu',
        featured: true,
        items: recommendations,
        isLoading: _isLoading,
        errorMessage: _allCategoriesFailed
            ? 'Data rekomendasi tidak tersedia karena API gagal.'
            : null,
      ),
      _section(
        'Series Terbaru',
        _newestFirst(series).take(_newestLimit).toList(),
        'Series',
      ),
      _section('Series Unggulan', series.take(5).toList(), 'Series'),
      _section('Film Populer', movies.take(_popularLimit).toList(), 'Film'),
      _section(
        'Film Terbaru',
        _newestFirst(movies).take(_newestLimit).toList(),
        'Film',
      ),
      _section('Anime Terpopuler', anime.take(_popularLimit).toList(), 'Anime'),
      _section(
        'Anime Terbaru',
        _newestFirst(anime).take(_newestLimit).toList(),
        'Anime',
      ),
      _section(
        'J-Drama Terpopuler',
        jdrama.take(_popularLimit).toList(),
        'J-Drama',
      ),
      _section(
        'J-Drama Terbaru',
        _newestFirst(jdrama).take(_newestLimit).toList(),
        'J-Drama',
      ),
      _section(
        'K-Drama Terpopuler',
        kdrama.take(_popularLimit).toList(),
        'K-Drama',
      ),
      _section(
        'K-Drama Terbaru',
        _newestFirst(kdrama).take(_newestLimit).toList(),
        'K-Drama',
      ),
    ];
  }

  _HomeSection _section(String title, List<MediaModel> items, String type) {
    return _HomeSection(
      title: title,
      items: items,
      listType: type,
      total: (_homeData[type] ?? []).length,
      isLoading: _isLoading,
      errorMessage: _homeErrors[type],
    );
  }

  bool get _allCategoriesFailed =>
      !_isLoading && _homeData.values.every((items) => items.isEmpty);

  GlobalKey _keyFor(String title) =>
      _sectionKeys.putIfAbsent(title, () => GlobalKey());

  List<MediaModel> _buildHeroItems() {
    final candidates = <MediaModel>[
      ..._newestFirst(_homeData['Film'] ?? []),
      ..._newestFirst(_homeData['Series'] ?? []),
      ..._newestFirst(_homeData['Anime'] ?? []),
      ..._newestFirst(_homeData['J-Drama'] ?? []),
      ..._newestFirst(_homeData['K-Drama'] ?? []),
    ];
    final seen = <String>{};
    final result = <MediaModel>[];
    for (final item in candidates) {
      if (item.imageUrl.isEmpty) continue;
      final key = '${item.mediaType}:${item.externalId ?? item.title}'
          .toLowerCase();
      if (!seen.add(key)) continue;
      result.add(item);
      if (result.length >= _heroCount) break;
    }
    return result;
  }

  void _startHeroTimer() {
    _heroTimer?.cancel();
    if (_heroItems.length < 2) return;
    _heroTimer = Timer.periodic(_heroInterval, (_) {
      if (!mounted || !_heroController.hasClients) return;
      _goToHero((_heroIndex + 1) % _heroItems.length, restartTimer: false);
    });
  }

  void _goToHero(int index, {bool restartTimer = true}) {
    if (!_heroController.hasClients) return;
    _heroController.animateToPage(
      index,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
    if (restartTimer) _startHeroTimer();
  }

  double _headerTotal() => MediaQuery.of(context).padding.top + _headerHeight;

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.hasClients) {
      _headerOpacity.value = (_scrollController.offset / 140).clamp(0.0, 1.0);
    }
    _updateActiveSection();
  }

  void _scrollToSection(String title) {
    final ctx = _sectionKeys[title]?.currentContext;
    if (ctx == null || !_scrollController.hasClients) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final sectionTop = box.localToGlobal(Offset.zero).dy;
    final target = (_scrollController.offset + sectionTop - _headerTotal() - 16)
        .clamp(0.0, _scrollController.position.maxScrollExtent)
        .toDouble();
    setState(() => _activeSection = title);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void _updateActiveSection() {
    final line = _headerTotal() + 40;
    String current = '';
    for (final title in _navTitles) {
      final ctx = _sectionKeys[title]?.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= line) current = title;
    }
    if (current != _activeSection) setState(() => _activeSection = current);
  }

  void _openList(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MediaListPage(initialType: type)),
    );
  }

  void _openDetail(MediaModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MediaDetailPage(media: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_heroItems.isNotEmpty) _buildHero(),
                if (_heroItems.isEmpty && _isLoading)
                  SizedBox(
                    height: _headerTotal() + 300,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                const SizedBox(height: 26),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final section in sections) ...[
                          KeyedSubtree(
                            key: _keyFor(section.title),
                            child: _buildSectionTitle(section),
                          ),
                          const SizedBox(height: 12),
                          _buildHorizontalList(section),
                          const SizedBox(height: 28),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),
        ],
      ),
    );
  }

  // HERO
  // ============================================================

  Widget _buildHero() {
    final wide = MediaQuery.of(context).size.width >= 720;
    final contentHeight = wide ? 360.0 : 320.0;
    final totalHeight = _headerTotal() + contentHeight;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _heroController,
            itemCount: _heroItems.length,
            onPageChanged: (i) => setState(() => _heroIndex = i),
            itemBuilder: (context, index) =>
                _buildHeroSlide(_heroItems[index], wide),
          ),

          // Tombol panah (hanya di layar lebar)
          if (wide && _heroItems.length > 1) ...[
            Positioned(
              left: 14,
              top: _headerTotal() + (contentHeight - 44) / 2,
              child: _HeroArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => _goToHero(
                  (_heroIndex - 1 + _heroItems.length) % _heroItems.length,
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: _headerTotal() + (contentHeight - 44) / 2,
              child: _HeroArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => _goToHero((_heroIndex + 1) % _heroItems.length),
              ),
            ),
          ],

          // Indikator titik
          if (_heroItems.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _heroItems.length; i++)
                    GestureDetector(
                      onTap: () => _goToHero(i),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: i == _heroIndex ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: i == _heroIndex
                                  ? lightBlue
                                  : const Color(0x55FFFFFF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide(MediaModel item, bool wide) {
    final posterW = wide ? 190.0 : 108.0;
    final posterH = wide ? 285.0 : 162.0;

    final meta = [
      if (item.releaseYear != null) item.releaseYear.toString(),
      if (item.rating != null) item.formattedRating,
    ].join('  /  ');

    final overview = _cleanOverview(item.overview);
    final type = item.genre ?? '';

    final poster = HoverLift(
      hoverScale: 1.02,
      radius: 6,
      onTap: () => _openDetail(item),
      child: Container(
        width: posterW,
        height: posterH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x33FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: PosterImage(media: item, width: posterW, height: posterH),
      ),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (type.isNotEmpty) _TypeChip(label: type),
        if (type.isNotEmpty) SizedBox(height: wide ? 14 : 10),
        Text(
          item.title,
          maxLines: wide ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: wide ? 38 : 22,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            meta,
            style: const TextStyle(color: AppColors.softText, fontSize: 14),
          ),
        ],
        if (wide && overview.isNotEmpty) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              overview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.softText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
        SizedBox(height: wide ? 20 : 14),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _HeroButton(
              label: 'Lihat detail',
              filled: true,
              onTap: () => _openDetail(item),
            ),
            if (type.isNotEmpty)
              _HeroButton(
                label: 'Semua $type',
                filled: false,
                onTap: () => _openList(type),
              ),
          ],
        ),
      ],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Latar: poster yang diburamkan
        ClipRect(
          child: Transform.scale(
            scale: 1.2,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: PosterImage(
                media: item,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),

        // Gelapkan dari kiri (supaya teks terbaca)
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xEE0B0B0C), Color(0x990B0B0C)],
            ),
          ),
        ),

        // Menyatu ke warna latar halaman di bagian bawah
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Color(0x000B0B0C), backgroundColor],
            ),
          ),
        ),

        // Isi
        Padding(
          padding: EdgeInsets.fromLTRB(
            wide ? 64 : 18,
            _headerTotal() + (wide ? 24 : 14),
            wide ? 64 : 18,
            wide ? 36 : 34,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: wide
                  ? Row(
                      children: [
                        Expanded(child: text),
                        const SizedBox(width: 40),
                        poster,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        poster,
                        const SizedBox(width: 16),
                        Expanded(child: text),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Membersihkan tag HTML sederhana (deskripsi dari API kadang berisi <br>).
  String _cleanOverview(String? raw) {
    if (raw == null) return '';
    return raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ============================================================
  // HEADER / NAVBAR
  // ============================================================

  Widget _buildHeader() {
    final wide = MediaQuery.of(context).size.width >= 720;

    return ValueListenableBuilder<double>(
      valueListenable: _headerOpacity,
      builder: (context, t, _) {
        // Transparan di atas hero, makin solid saat di-scroll.
        final bgAlpha = 0.35 + 0.57 * t;
        final borderAlpha = t;

        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: headerColor.withAlpha((bgAlpha * 255).round()),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor.withAlpha((borderAlpha * 255).round()),
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: _headerHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // LOGO (klik = kembali ke atas)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _scrollToTop,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      width: 38,
                                      height: 38,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (wide) ...[
                                    const SizedBox(width: 10),
                                    const Text(
                                      'MYDVA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // LINK KE SECTION
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final title in _navTitles)
                                    _buildNavItem(title),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          _buildProfileButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(String title) {
    final active = _activeSection == title;

    return InkWell(
      onTap: () => _scrollToSection(title),
      hoverColor: const Color(0x144A6FC3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: _headerHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? lightBlue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            color: active ? Colors.white : AppColors.softText,
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Text(title),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE BUTTON
  // ============================================================

  Widget _buildProfileButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF444444)),
          ),
          child: const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/masha.jpg'),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(_HomeSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            section.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: borderColor)),
          if (section.listType != null) ...[
            const SizedBox(width: 4),
            TextButton(
              onPressed: () => _openList(section.listType!),
              child: const Text(
                'Lihat semua',
                style: TextStyle(color: lightBlue, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HORIZONTAL LIST
  // ============================================================

  Widget _buildHorizontalList(_HomeSection section) {
    final items = section.items;
    final hasSeeAll = section.listType != null;

    if (items.isEmpty && section.isLoading) {
      return PosterRowSkeleton(featured: section.featured);
    }

    if (items.isEmpty) {
      return SizedBox(
        height: section.featured ? 170 : 130,
        child: Center(
          child: section.isLoading
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        section.errorMessage ?? 'Data belum tersedia.',
                        style: const TextStyle(color: mutedText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: _loadHomeData,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ),
        ),
      );
    }

    return SizedBox(
      height: section.featured ? 340 : 262,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        itemCount: items.length + (hasSeeAll ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) return _buildSeeAllCard(section);
          return _buildMediaCard(items[index], featured: section.featured);
        },
      ),
    );
  }

  Widget _buildSeeAllCard(_HomeSection section) {
    return HoverLift(
      onTap: () => _openList(section.listType!),
      child: Container(
        width: 145,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: headerColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lihat semua',
              style: TextStyle(
                color: lightBlue,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${section.total} judul',
              style: const TextStyle(color: mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEDIA CARD
  // ============================================================

  Widget _buildMediaCard(MediaModel item, {bool featured = false}) {
    final subtitle = [
      if (item.genre != null) item.genre!,
      if (item.releaseYear != null) item.releaseYear.toString(),
    ].join('  /  ');

    final cardWidth = featured ? 190.0 : 145.0;
    final posterHeight = featured ? 255.0 : 180.0;

    return HoverLift(
      onTap: () => _openDetail(item),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: posterHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(media: item),

                  // Badge tipe (hanya untuk kartu rekomendasi, karena
                  // isinya campuran film / series / anime)
                  if (featured && item.genre != null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: _TypeChip(label: item.genre!, small: true),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 3),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: featured ? 14 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 0, 9, 8),
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: mutedText, fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _TypeChip extends StatelessWidget {
  final String label;
  final bool small;

  const _TypeChip({required this.label, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: small ? const Color(0xCC0B0B0C) : const Color(0x334A6FC3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: small ? const Color(0x33FFFFFF) : AppColors.lightBlue,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: small ? Colors.white : AppColors.lightBlue,
          fontSize: small ? 10.5 : 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Tombol di hero. [filled] = tombol utama, selain itu tombol garis tepi.
class _HeroButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeroButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: filled ? AppColors.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: filled ? AppColors.lightBlue : const Color(0x66FFFFFF),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? const Color(0xFF0B0B0C) : Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Panah kiri/kanan di hero.
class _HeroArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeroArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0x660B0B0C),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
