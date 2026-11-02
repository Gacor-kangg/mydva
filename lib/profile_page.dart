import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'media_data.dart';
import 'media_detail_page.dart';
import 'media_listpage.dart';
import 'models/media_model.dart';
import 'ui_effects.dart';
import 'about_application_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFF0B0B0C);
  static const Color headerColor = Color(0xFF151516);
  static const Color panelColor = Color(0xFF151516);
  static const Color cardColor = Color(0xFF1B1B1D);
  static const Color borderColor = Color(0xFF2A2A2D);

  static const Color blue = Color(0xFF4A6FC3);
  static const Color lightBlue = Color(0xFF9DBEFF);

  static const Color green = Color(0xFF3FA35B);
  static const Color yellow = Color(0xFFD1A91A);
  static const Color red = Color(0xFF963434);
  static const Color grey = Color(0xFF666666);

  static const Color mutedText = Color(0xFF8E8E93);
  static const Color softText = Color(0xFFC8C8CC);

  // ============================================================
  // DATA STATISTIK (sementara hardcode, nanti bisa dari database)
  // ============================================================

  static const _Stats _film = _Stats(
    watching: 2,
    completed: 4,
    onHold: 1,
    dropped: 0,
    planToWatch: 0,
  );

  static const _Stats _series = _Stats(
    watching: 1,
    completed: 4,
    onHold: 2,
    dropped: 1,
    planToWatch: 5,
  );

  static const _Stats _anime = _Stats(
    watching: 0,
    completed: 5,
    onHold: 3,
    dropped: 2,
    planToWatch: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 900;

                            final sidebar = Reveal(
                              delay: const Duration(milliseconds: 120),
                              child: _buildSidebar(context),
                            );
                            final main = Reveal(
                              delay: const Duration(milliseconds: 200),
                              child: _buildMainContent(context),
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Reveal(child: _buildHero(wide)),
                                const SizedBox(height: 20),
                                if (wide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 320, child: sidebar),
                                      const SizedBox(width: 24),
                                      Expanded(child: main),
                                    ],
                                  )
                                else ...[
                                  sidebar,
                                  const SizedBox(height: 24),
                                  main,
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: headerColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // BACK TO HOMEPAGE
          _headerButton(
            text: 'Back',
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),

          const SizedBox(width: 6),

          const Text(
            'PROFILE',
            style: TextStyle(
              color: mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          _headerButton(
            text: 'About Applications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutApplicationPage(),
                ),
              );
            },
          ),
          
          _headerButton(text: 'Settings', onPressed: () {}),
          _headerButton(
            text: 'Logout',
            color: const Color(0xFFE57373),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required String text,
    required VoidCallback onPressed,
    Color color = lightBlue,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HERO (foto + nama + ringkasan angka)
  // ============================================================

  Widget _buildHero(bool wide) {
    final all = _film + _series + _anime;

    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/masha.jpg',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 120,
          height: 120,
          color: cardColor,
          alignment: Alignment.center,
          child: const Text(
            'F',
            style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Flooooooo',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Member since Nov 25, 2024',
          style: TextStyle(color: mutedText, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x223FA35B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x663FA35B)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Online',
                style: TextStyle(
                  color: Color(0xFF7FD69A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final numbers = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _heroNumber('Total', all.total),
        const SizedBox(width: 28),
        _heroNumber('Completed', all.completed),
        const SizedBox(width: 28),
        _heroNumber('Planned', all.planToWatch),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D2B4A), Color(0xFF151516)],
        ),
      ),
      child: wide
          ? Row(
              children: [
                avatar,
                const SizedBox(width: 24),
                identity,
                const Spacer(),
                numbers,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    avatar,
                    const SizedBox(width: 18),
                    Flexible(child: identity),
                  ],
                ),
                const SizedBox(height: 20),
                numbers,
              ],
            ),
    );
  }

  Widget _heroNumber(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ABOUT
        _sectionCard(
          title: 'About',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No biography yet. Write it now.',
                style: TextStyle(color: softText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'Write biography',
                    style: TextStyle(
                      color: lightBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // DETAILS
        _sectionCard(
          title: 'Details',
          child: Column(
            children: [
              _infoRow(title: 'Last Online', value: 'Now'),
              _infoRow(title: 'Joined', value: 'Nov 25, 2024'),
              _infoRow(title: 'Lists', value: '3', last: true),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // MEDIA LISTS
        _sectionCard(
          title: 'My Lists',
          child: Column(
            children: [
              _listButton(context, 'Film List', movieData.length, 'Film'),
              const SizedBox(height: 8),
              _listButton(context, 'Series List', seriesData.length, 'Series'),
              const SizedBox(height: 8),
              _listButton(context, 'Anime List', animeData.length, 'Anime'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow({
    required String title,
    required String value,
    bool last = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFF242427))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: mutedText, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: softText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listButton(
    BuildContext context,
    String text,
    int count,
    String type,
  ) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        hoverColor: const Color(0x224A6FC3),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaListPage(initialType: type),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$count titles',
                style: const TextStyle(color: lightBlue, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Statistics', 'All Media Stats'),
        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              Reveal(
                delay: const Duration(milliseconds: 300),
                child: HoverLift(
                  hoverScale: 1.015,
                  child: _statisticsCard(title: 'Film', stats: _film),
                ),
              ),
              Reveal(
                delay: const Duration(milliseconds: 400),
                child: HoverLift(
                  hoverScale: 1.015,
                  child: _statisticsCard(title: 'Series', stats: _series),
                ),
              ),
              Reveal(
                delay: const Duration(milliseconds: 500),
                child: HoverLift(
                  hoverScale: 1.015,
                  child: _statisticsCard(title: 'Anime', stats: _anime),
                ),
              ),
            ];

            if (constraints.maxWidth >= 640) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }

            return Column(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  cards[i],
                ],
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        _buildRecentActivity(context),
      ],
    );
  }

  Widget _sectionHeader(String title, String link) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: Text(
            link,
            style: const TextStyle(color: lightBlue, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS CARD
  // ============================================================

  Widget _statisticsCard({required String title, required _Stats stats}) {
    final percent = stats.total == 0
        ? 0
        : (stats.completed / stats.total * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + TOTAL
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                stats.total.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'titles',
                style: TextStyle(color: mutedText, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _progressBar(stats),

          const SizedBox(height: 8),

          Text(
            '$percent% completed',
            style: const TextStyle(color: mutedText, fontSize: 12),
          ),

          const SizedBox(height: 12),

          _statRow('Watching', stats.watching, green),
          _statRow('Completed', stats.completed, blue),
          _statRow('On-Hold', stats.onHold, yellow),
          _statRow('Dropped', stats.dropped, red),
          _statRow('Plan to Watch', stats.planToWatch, grey),
        ],
      ),
    );
  }

  Widget _progressBar(_Stats s) {
    final segments = <MapEntry<int, Color>>[
      MapEntry(s.completed, blue),
      MapEntry(s.watching, green),
      MapEntry(s.onHold, yellow),
      MapEntry(s.dropped, red),
      MapEntry(s.planToWatch, grey),
    ].where((segment) => segment.key > 0).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        width: double.infinity,
        child: ColoredBox(
          color: borderColor,
          child: segments.isEmpty
              ? null
              : TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: t,
                    child: Row(
                      children: [
                        for (final segment in segments)
                          Expanded(
                            flex: segment.key,
                            child: ColoredBox(color: segment.value),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _statRow(String title, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT ACTIVITY
  // ============================================================

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Recent Activity', 'History'),
        const SizedBox(height: 10),
        _activityItem(
          context: context,
          title: 'Oldboy',
          type: 'Film',
          status: 'Completed',
          score: '9',
          date: 'May 31, 2026',
        ),
        _activityItem(
          context: context,
          title: 'The Boys',
          type: 'Series',
          status: 'Completed',
          score: '5',
          date: 'May 13, 2026',
        ),
        _activityItem(
          context: context,
          title: 'Barakamon',
          type: 'Anime',
          status: 'Completed',
          score: '10',
          date: 'May 08, 2026',
        ),
      ],
    );
  }

  /// Cari data media berdasarkan judul supaya poster ikut data utama.
  MediaModel? _findMedia(String title) {
    final all = [...movieData, ...seriesData, ...animeData];
    for (final m in all) {
      if (m.title.toLowerCase() == title.toLowerCase()) return m;
    }
    return null;
  }

  /// Poster tanpa icon: kalau gambar kosong/gagal, tampilkan huruf awal judul.
  Widget _poster(String title) {
    const double w = 58;
    const double h = 82;

    Widget initial() => Container(
      width: w,
      height: h,
      color: const Color(0xFF26262A),
      alignment: Alignment.center,
      child: Text(
        title.isEmpty ? '?' : title[0].toUpperCase(),
        style: const TextStyle(
          color: mutedText,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final src = _findMedia(title)?.imageUrl ?? '';

    Widget image;
    if (src.isEmpty) {
      image = initial();
    } else if (src.startsWith('http')) {
      image = Image.network(
        src,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => initial(),
      );
    } else {
      image = Image.asset(
        src,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => initial(),
      );
    }

    return ClipRRect(borderRadius: BorderRadius.circular(4), child: image);
  }

  Widget _activityItem({
    required BuildContext context,
    required String title,
    required String type,
    required String status,
    required String score,
    required String date,
  }) {
    final media = _findMedia(title);

    return HoverLift(
      hoverScale: 1.01,
      onTap: media == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MediaDetailPage(media: media),
                ),
              );
            },
      child: _activityCard(
        title: title,
        type: type,
        status: status,
        score: score,
        date: date,
      ),
    );
  }

  Widget _activityCard({
    required String title,
    required String type,
    required String status,
    required String score,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _poster(title),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: lightBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$status  /  $type',
                  style: const TextStyle(color: softText, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: mutedText, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // SCORE
          Container(
            width: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  score,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'SCORE',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DATA CLASS STATISTIK
// ============================================================

class _Stats {
  final int watching;
  final int completed;
  final int onHold;
  final int dropped;
  final int planToWatch;

  const _Stats({
    required this.watching,
    required this.completed,
    required this.onHold,
    required this.dropped,
    required this.planToWatch,
  });

  int get total => watching + completed + onHold + dropped + planToWatch;

  _Stats operator +(_Stats o) => _Stats(
    watching: watching + o.watching,
    completed: completed + o.completed,
    onHold: onHold + o.onHold,
    dropped: dropped + o.dropped,
    planToWatch: planToWatch + o.planToWatch,
  );
}
