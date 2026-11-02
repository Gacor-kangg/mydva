import 'package:flutter/material.dart';

import 'media_data.dart';
import 'media_detail_page.dart';
import 'media_listpage.dart';
import 'models/media_model.dart';
import 'poster_image.dart';
import 'profile_page.dart';
import 'ui_effects.dart';

class _HomeSection {
  final String title;
  final List<MediaModel> items;

  final String? listType;

  
  final int total;

  _HomeSection({
    required this.title,
    required this.items,
    this.listType,
    this.total = 0,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFF0B0B0C);
  static const Color headerColor = Color(0xFF151516);
  static const Color cardColor = Color(0xFF1B1B1D);
  static const Color borderColor = Color(0xFF2A2A2D);

  static const Color lightBlue = Color(0xFF9DBEFF);
  static const Color mutedText = Color(0xFF8E8E93);

  // ============================================================
  // PENGATURAN
  // ============================================================

  static const double _headerHeight = 62;

  
  static const int _popularLimit = 15;
  static const int _newestLimit = 12;

  // ============================================================
  // STATE
  // ============================================================

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  late final List<String> _navTitles;
  String _activeSection = '';

  @override
  void initState() {
    super.initState();
    _navTitles = _buildSections().map((s) => s.title).toList();
    _scrollController.addListener(_updateActiveSection);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateActiveSection);
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // DAFTAR SECTION
  // ============================================================

  List<_HomeSection> _buildSections() {
    return [
      _HomeSection(
        title: 'Rekomendasi Untukmu',
        items: [
          ...movieData.take(2),
          ...seriesData.take(2),
          ...animeData.take(2),
          
          _findByTitle(movieData, 'The Box'),
          _findByTitle(movieData, 'Dead Poets Society'),
          _findByTitle(seriesData, 'The Summer I Turned Pretty'),
        ],
      ),
      _HomeSection(
        title: 'Series Terbaru',
        items: sortedByNewest(seriesData).take(_newestLimit).toList(),
        listType: 'Series',
        total: seriesData.length,
      ),
      _HomeSection(
        title: 'Series Unggulan',
        items: seriesData.take(5).toList(),
        listType: 'Series',
        total: seriesData.length,
      ),
      _HomeSection(
        title: 'Film Populer',
        items: movieData.take(_popularLimit).toList(),
        listType: 'Film',
        total: movieData.length,
      ),
      _HomeSection(
        title: 'Film Terbaru',
        items: sortedByNewest(movieData).take(_newestLimit).toList(),
        listType: 'Film',
        total: movieData.length,
      ),
      _HomeSection(
        title: 'Anime Terpopuler',
        items: animeData.take(_popularLimit).toList(),
        listType: 'Anime',
        total: animeData.length,
      ),
      _HomeSection(
        title: 'Anime Terbaru',
        items: sortedByNewest(animeData).take(_newestLimit).toList(),
        listType: 'Anime',
        total: animeData.length,
      ),
    ];
  }

  /// Mengambil satu judul dari list berdasarkan nama (tidak peka huruf besar/kecil).
  MediaModel _findByTitle(List<MediaModel> list, String title) {
    return list.firstWhere(
      (m) => m.title.toLowerCase() == title.toLowerCase(),
    );
  }

  GlobalKey _keyFor(String title) {
    return _sectionKeys.putIfAbsent(title, () => GlobalKey());
  }

  // ============================================================
  // NAVBAR: SCROLL KE SECTION + PENANDA SECTION AKTIF
  // ============================================================

  double _headerTotal() {
    return MediaQuery.of(context).padding.top + _headerHeight;
  }

  void _scrollToSection(String title) {
    final ctx = _sectionKeys[title]?.currentContext;
    if (ctx == null || !_scrollController.hasClients) return;

    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final sectionTop = box.localToGlobal(Offset.zero).dy;
    final target = (_scrollController.offset +
            sectionTop -
            _headerTotal() -
            16)
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

  /// Section yang judulnya sudah lewat di bawah header dianggap aktif.
  void _updateActiveSection() {
    if (!mounted) return;

    final line = _headerTotal() + 40;
    String current = '';

    for (final title in _navTitles) {
      final ctx = _sectionKeys[title]?.currentContext;
      if (ctx == null) continue;

      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;

      if (box.localToGlobal(Offset.zero).dy <= line) {
        current = title;
      }
    }

    if (current != _activeSection) {
      setState(() => _activeSection = current);
    }
  }

  void _openList(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaListPage(initialType: type),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // ======================================================
          // ISI HALAMAN
          // ======================================================
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: _headerTotal() + 24,
              bottom: 40,
            ),
            child: Center(
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
          ),

          // ======================================================
          // HEADER (NAVBAR)
          // ======================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER / NAVBAR
  // ============================================================

  Widget _buildHeader() {
    final wide = MediaQuery.of(context).size.width >= 720;

    return Material(
      color: headerColor,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor)),
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
                              'assets/pnp.jpg',
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
                          for (final title in _navTitles) _buildNavItem(title),
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
            color: active ? Colors.white : mutedText,
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
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
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
          Text(
            section.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(height: 1, color: borderColor),
          ),
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

    return SizedBox(
      height: 262,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        itemCount: items.length + (hasSeeAll ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _buildSeeAllCard(section);
          }

          return _buildMediaCard(items[index]);
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

  Widget _buildMediaCard(MediaModel item) {
    final subtitle = [
      if (item.genre != null) item.genre!,
      if (item.releaseYear != null) item.releaseYear.toString(),
    ].join('  /  ');

    return HoverLift(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaDetailPage(media: item),
          ),
        );
      },
      child: Container(
        width: 145,
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
              height: 180,
              child: PosterImage(media: item),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 3),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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