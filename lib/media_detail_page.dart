import 'package:flutter/material.dart';

import 'detail_data.dart';
import 'models/media_model.dart';
import 'poster_image.dart';
import 'ui_effects.dart';


class _Review {
  final String user;
  final int? score;
  final DateTime date;
  final String text;
  final bool spoiler;
  int helpful;
  bool helpedByMe = false;
  bool expanded = false;
  bool spoilerRevealed = false;

  _Review({
    required this.user,
    required this.score,
    required this.date,
    required this.text,
    this.spoiler = false,
    this.helpful = 0,
  });
}

class _Comment {
  final String user;
  final DateTime date;
  final String text;
  final List<_Comment> replies = [];
  final TextEditingController replyController = TextEditingController();
  bool replying = false;

  _Comment({required this.user, required this.date, required this.text});
}

// ============================================================
// HALAMAN DETAIL
// ============================================================

class MediaDetailPage extends StatefulWidget {
  final MediaModel media;

  const MediaDetailPage({super.key, required this.media});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  // ----------------------------------------------------------
  // COLORS
  // ----------------------------------------------------------

  static const Color backgroundColor = Color(0xFF0B0B0C);
  static const Color panelColor = Color(0xFF151516);
  static const Color cardColor = Color(0xFF1B1B1D);
  static const Color borderColor = Color(0xFF2A2A2D);

  static const Color blue = Color(0xFF4A6FC3);
  static const Color lightBlue = Color(0xFF9DBEFF);

  static const Color mutedText = Color(0xFF8E8E93);
  static const Color softText = Color(0xFFC8C8CC);

  static const List<String> _statuses = [
    'Watching',
    'Completed',
    'On-Hold',
    'Dropped',
    'Plan to Watch',
  ];

  static const List<String> _tabLabels = [
    'Overview',
    'Cast',
    'Reviews',
    'Discussion',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // ----------------------------------------------------------
  // STATE
  // ----------------------------------------------------------

  late final MediaDetail _detail;
  late final List<int> _distribution;

  int _tab = 0;

  // My List
  String? _status;
  int? _myScore;
  int _progress = 0;
  bool _saved = false;

  // Reviews
  String _sort = 'Most Helpful';
  bool _newReviewSpoiler = false;
  final TextEditingController _reviewController = TextEditingController();
  late final List<_Review> _reviews;

  // Discussion
  final TextEditingController _commentController = TextEditingController();
  late final List<_Comment> _comments;

  String get _type => widget.media.genre ?? 'Film';
  bool get _hasProgress => _type != 'Film';

  @override
  void initState() {
    super.initState();

    _detail = detailFor(widget.media);
    _distribution = sampleDistribution(widget.media.title);

    _reviews = [
      _Review(
        user: 'Kirana',
        score: 9,
        date: DateTime(2026, 9, 28),
        text:
            'Ceritanya kuat dan bikin penasaran dari awal sampai akhir. '
            'Pengambilan gambarnya rapi, dan akting para pemerannya terasa '
            'jujur. Layak ditonton ulang karena banyak detail kecil yang '
            'baru kelihatan di tontonan kedua.',
        helpful: 24,
      ),
      _Review(
        user: 'Dimas',
        score: 7,
        date: DateTime(2026, 9, 12),
        text:
            'Bagus, tapi tempo di bagian tengah agak lambat buat saya. '
            'Ending-nya memang yang paling berkesan, jadi sabar dulu '
            'sampai akhir.',
        helpful: 11,
      ),
      _Review(
        user: 'Rafi',
        score: 10,
        date: DateTime(2026, 8, 30),
        text:
            'Twist di akhir benar-benar bikin diam sebentar. Tidak mau '
            'cerita banyak, tonton saja sendiri.',
        spoiler: true,
        helpful: 6,
      ),
    ];

    final first = _Comment(
      user: 'Alya',
      date: DateTime(2026, 10, 2),
      text: 'Ada yang tahu urutan nonton terbaik kalau mau mulai dari awal?',
    );
    first.replies.add(
      _Comment(
        user: 'Dimas',
        date: DateTime(2026, 10, 3),
        text: 'Langsung dari yang pertama saja, ceritanya sudah berdiri sendiri.',
      ),
    );

    _comments = [
      first,
      _Comment(
        user: 'Bima',
        date: DateTime(2026, 9, 20),
        text: 'Soundtrack-nya juara. Ada yang tahu judul lagu di adegan akhir?',
      ),
    ];
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _commentController.dispose();
    for (final c in _comments) {
      c.replyController.dispose();
    }
    super.dispose();
  }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------

  double get _averageScore {
    int total = 0;
    int weighted = 0;

    for (int i = 0; i < _distribution.length; i++) {
      final score = 10 - i;
      total += _distribution[i];
      weighted += _distribution[i] * score;
    }

    return total == 0 ? 0 : weighted / total;
  }

  int get _totalVotes => _distribution.fold(0, (a, b) => a + b);

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cardColor,
        duration: const Duration(seconds: 2),
        content: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

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
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 800;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Reveal(child: _buildHero(wide)),
                                const SizedBox(height: 24),
                                Reveal(
                                  delay: const Duration(milliseconds: 120),
                                  child: _buildTabBar(),
                                ),
                                const SizedBox(height: 18),
                                Reveal(
                                  delay: const Duration(milliseconds: 200),
                                  child: _buildTabContent(wide),
                                ),
                                const SizedBox(height: 40),
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


  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: panelColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.maybePop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'DETAIL',
            style: TextStyle(
              color: mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHero(bool wide) {
    final media = widget.media;

    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: PosterImage(
        media: media,
        width: 210,
        height: 300,
        textSize: 64,
      ),
    );

    final metaParts = <String>[
      if (media.releaseYear != null) media.releaseYear.toString(),
      if (_detail.duration != null) _detail.duration!,
      if (_detail.genres.isNotEmpty) _detail.genres.join(', '),
    ];

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x224A6FC3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x664A6FC3)),
          ),
          child: Text(
            _type.toUpperCase(),
            style: const TextStyle(
              color: lightBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          media.title,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (metaParts.isNotEmpty)
          Text(
            metaParts.join('  /  '),
            style: const TextStyle(color: mutedText, fontSize: 14),
          ),
        const SizedBox(height: 18),
        _buildScoreRow(),
        const SizedBox(height: 20),
        _buildMyListPanel(),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                poster,
                const SizedBox(width: 28),
                Expanded(child: info),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: poster),
                const SizedBox(height: 20),
                info,
              ],
            ),
    );
  }

  Widget _buildScoreRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _averageScore),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SCORE',
              style: TextStyle(
                color: mutedText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$_totalVotes ratings (data contoh)',
              style: const TextStyle(color: softText, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // MY LIST: status, skor, progress
  // ----------------------------------------------------------

  Widget _buildMyListPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x99101012),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('My List'),
          const SizedBox(height: 12),

          // STATUS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _statuses)
                _choiceChip(
                  label: s,
                  selected: _status == s,
                  onTap: () => setState(() {
                    _status = s;
                    _saved = false;
                  }),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // SKOR 1 - 10
          const Text(
            'Your score',
            style: TextStyle(color: mutedText, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (int i = 1; i <= 10; i++)
                _choiceChip(
                  label: '$i',
                  selected: _myScore == i,
                  minWidth: 38,
                  onTap: () => setState(() {
                    _myScore = _myScore == i ? null : i;
                    _saved = false;
                  }),
                ),
            ],
          ),

          // PROGRESS (series / anime)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topLeft,
            child: _hasProgress ? _buildProgressControl() : const SizedBox(),
          ),

          const SizedBox(height: 16),

          // SAVE
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: FilledButton(
              onPressed: () {
                if (_status == null) {
                  _showMessage('Pilih status dulu sebelum menyimpan.');
                  return;
                }
                setState(() => _saved = true);
                _showMessage(
                  'Tersimpan di My List (sementara, belum ke database).',
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: _saved ? const Color(0xFF3FA35B) : blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _saved ? 'Saved' : 'Save to My List',
                  key: ValueKey(_saved),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressControl() {
    final max = _detail.episodes;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          const Text(
            'Episodes watched',
            style: TextStyle(color: mutedText, fontSize: 12),
          ),
          const SizedBox(width: 12),
          _stepButton('-', () {
            if (_progress > 0) {
              setState(() {
                _progress--;
                _saved = false;
              });
            }
          }),
          SizedBox(
            width: 70,
            child: Center(
              child: Text(
                max == null ? '$_progress' : '$_progress / $max',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _stepButton('+', () {
            if (max == null || _progress < max) {
              setState(() {
                _progress++;
                _saved = false;
              });
            }
          }),
        ],
      ),
    );
  }

  Widget _stepButton(String text, VoidCallback onTap) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        hoverColor: const Color(0x224A6FC3),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  /// Chip pilihan dengan perubahan warna yang halus.
  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    double minWidth = 0,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      constraints: BoxConstraints(minWidth: minWidth),
      decoration: BoxDecoration(
        color: selected ? blue : cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: selected ? blue : borderColor),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          hoverColor: const Color(0x224A6FC3),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : softText,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAB BAR
  // ----------------------------------------------------------

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < _tabLabels.length; i++) _tabItem(i),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(int index) {
    final selected = _tab == index;

    String label = _tabLabels[index];
    if (index == 2) label = '$label (${_reviews.length})';
    if (index == 3) label = '$label (${_comments.length})';

    return InkWell(
      onTap: () => setState(() => _tab = index),
      hoverColor: const Color(0x114A6FC3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? lightBlue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            color: selected ? Colors.white : mutedText,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAB CONTENT (berganti dengan fade)
  // ----------------------------------------------------------

  Widget _buildTabContent(bool wide) {
    final Widget content;

    switch (_tab) {
      case 0:
        content = _buildOverview(wide);
        break;
      case 1:
        content = _buildCast();
        break;
      case 2:
        content = _buildReviews();
        break;
      default:
        content = _buildDiscussion();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey(_tab),
        width: double.infinity,
        child: content,
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: mutedText,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _avatar(String name, {double size = 38}) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF26262A),
        shape: BoxShape.circle,
      ),
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
          color: lightBlue,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAB 1: OVERVIEW
  // ----------------------------------------------------------

  Widget _buildOverview(bool wide) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Type', _type),
      if (widget.media.releaseYear != null)
        MapEntry('Year', widget.media.releaseYear.toString()),
      if (_detail.duration != null) MapEntry('Duration', _detail.duration!),
      if (_detail.credit != null) MapEntry(_detail.creditLabel, _detail.credit!),
      if (_detail.genres.isNotEmpty)
        MapEntry('Genres', _detail.genres.join(', ')),
    ];

    final information = _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Information'),
          const SizedBox(height: 10),
          for (int i = 0; i < rows.length; i++)
            _infoRow(rows[i].key, rows[i].value, last: i == rows.length - 1),
        ],
      ),
    );

    final distribution = _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Rating distribution'),
          const SizedBox(height: 14),
          for (int i = 0; i < _distribution.length; i++)
            _distributionRow(10 - i, _distribution[i]),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Synopsis'),
              const SizedBox(height: 10),
              Text(
                _detail.synopsis,
                style: const TextStyle(
                  color: softText,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: information),
              const SizedBox(width: 16),
              Expanded(child: distribution),
            ],
          )
        else ...[
          information,
          const SizedBox(height: 16),
          distribution,
        ],
      ],
    );
  }

  Widget _infoRow(String title, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFF242427))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(color: mutedText, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: softText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _distributionRow(int score, int count) {
    final maxCount = _distribution.reduce((a, b) => a > b ? a : b);
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;
    final mine = _myScore == score;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$score',
              style: TextStyle(
                color: mine ? lightBlue : mutedText,
                fontSize: 13,
                fontWeight: mine ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                width: double.infinity,
                child: ColoredBox(
                  color: borderColor,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: fraction),
                    duration: Duration(milliseconds: 600 + (10 - score) * 60),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: ColoredBox(color: mine ? lightBlue : blue),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(color: mutedText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // TAB 2: CAST
  // ----------------------------------------------------------

  Widget _buildCast() {
    if (_detail.cast.isEmpty) {
      return _card(
        child: const Text(
          'Data cast belum tersedia untuk judul ini.',
          style: TextStyle(color: mutedText, fontSize: 14),
        ),
      );
    }

    if (_type == 'Anime') {
      return Column(
        children: [
          for (final member in _detail.cast) _animeCastRow(member),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final member in _detail.cast)
          SizedBox(
            width: 250,
            child: HoverLift(
              hoverScale: 1.02,
              child: _card(
                child: Row(
                  children: [
                    _avatar(member.name, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            member.role,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Gaya MyAnimeList: karakter di kiri, voice actor di kanan.
  Widget _animeCastRow(CastMember member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HoverLift(
        hoverScale: 1.01,
        child: _card(
          child: Row(
            children: [
              _avatar(member.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      member.role,
                      style: const TextStyle(color: mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      member.voiceActor ?? '-',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: lightBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      member.language ?? '',
                      style: const TextStyle(color: mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _avatar(member.voiceActor ?? '?', size: 44),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAB 3: REVIEWS
  // ----------------------------------------------------------

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: mutedText, fontSize: 14),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.all(14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: blue),
      ),
    );
  }

  Widget _buildReviews() {
    final sorted = List<_Review>.from(_reviews);
    if (_sort == 'Most Helpful') {
      sorted.sort((a, b) => b.helpful.compareTo(a.helpful));
    } else {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TULIS REVIEW
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Write a review'),
              const SizedBox(height: 12),
              TextField(
                controller: _reviewController,
                maxLines: 4,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration('Tulis review kamu di sini...'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _choiceChip(
                    label: 'Contains spoiler',
                    selected: _newReviewSpoiler,
                    onTap: () =>
                        setState(() => _newReviewSpoiler = !_newReviewSpoiler),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _postReview,
                    style: FilledButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Post Review',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // URUTAN
        Row(
          children: [
            const Text(
              'Sort by',
              style: TextStyle(color: mutedText, fontSize: 13),
            ),
            const SizedBox(width: 10),
            for (final option in const ['Most Helpful', 'Newest']) ...[
              _choiceChip(
                label: option,
                selected: _sort == option,
                onTap: () => setState(() => _sort = option),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),

        const SizedBox(height: 14),

        for (final review in sorted)
          Reveal(
            key: ObjectKey(review),
            child: _reviewCard(review),
          ),
      ],
    );
  }

  void _postReview() {
    final text = _reviewController.text.trim();

    if (text.isEmpty) {
      _showMessage('Review tidak boleh kosong.');
      return;
    }

    setState(() {
      _reviews.insert(
        0,
        _Review(
          user: 'Flooooooo',
          score: _myScore,
          date: DateTime.now(),
          text: text,
          spoiler: _newReviewSpoiler,
        ),
      );
      _reviewController.clear();
      _newReviewSpoiler = false;
      _sort = 'Newest';
    });
  }

  Widget _reviewCard(_Review r) {
    final long = r.text.length > 220;
    final hidden = r.spoiler && !r.spoilerRevealed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _avatar(r.user),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.user,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(r.date),
                        style: const TextStyle(color: mutedText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (r.score != null)
                  Container(
                    width: 46,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      '${r.score}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ISI REVIEW (spoiler disembunyikan dulu)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topLeft,
              child: hidden
                  ? Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Review ini mengandung spoiler.',
                            style: TextStyle(color: mutedText, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => r.spoilerRevealed = true),
                          child: const Text(
                            'Show',
                            style: TextStyle(color: lightBlue),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.text,
                          maxLines: r.expanded ? null : 4,
                          overflow: r.expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: softText,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                        if (long)
                          TextButton(
                            onPressed: () =>
                                setState(() => r.expanded = !r.expanded),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 30),
                            ),
                            child: Text(
                              r.expanded ? 'Show less' : 'Read more',
                              style: const TextStyle(color: lightBlue),
                            ),
                          ),
                      ],
                    ),
            ),

            const SizedBox(height: 8),

            // HELPFUL
            TextButton(
              onPressed: () {
                setState(() {
                  r.helpedByMe = !r.helpedByMe;
                  r.helpful += r.helpedByMe ? 1 : -1;
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: r.helpedByMe ? lightBlue : mutedText,
                  fontSize: 13,
                  fontWeight: r.helpedByMe ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text('Helpful (${r.helpful})'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAB 4: DISCUSSION
  // ----------------------------------------------------------

  Widget _buildDiscussion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Start a discussion'),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 3,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration('Tulis komentar atau pertanyaan...'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _postComment,
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final comment in _comments)
          Reveal(
            key: ObjectKey(comment),
            child: _commentCard(comment),
          ),
      ],
    );
  }

  void _postComment() {
    final text = _commentController.text.trim();

    if (text.isEmpty) {
      _showMessage('Komentar tidak boleh kosong.');
      return;
    }

    setState(() {
      _comments.insert(
        0,
        _Comment(user: 'Flooooooo', date: DateTime.now(), text: text),
      );
      _commentController.clear();
    });
  }

  Widget _commentCard(_Comment c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _commentBody(c),

            // BALASAN (indent dengan garis di kiri)
            if (c.replies.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 18, top: 10),
                padding: const EdgeInsets.only(left: 14),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: borderColor, width: 2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final reply in c.replies)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _commentBody(reply, small: true),
                      ),
                  ],
                ),
              ),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => c.replying = !c.replying),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
                child: Text(
                  c.replying ? 'Cancel' : 'Reply',
                  style: const TextStyle(color: lightBlue, fontSize: 13),
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topLeft,
              child: c.replying
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: c.replyController,
                              cursorColor: Colors.white,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: _inputDecoration('Tulis balasan...'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => _postReply(c),
                            style: FilledButton.styleFrom(
                              backgroundColor: blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  void _postReply(_Comment parent) {
    final text = parent.replyController.text.trim();

    if (text.isEmpty) {
      _showMessage('Balasan tidak boleh kosong.');
      return;
    }

    setState(() {
      parent.replies.add(
        _Comment(user: 'Flooooooo', date: DateTime.now(), text: text),
      );
      parent.replyController.clear();
      parent.replying = false;
    });
  }

  Widget _commentBody(_Comment c, {bool small = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(c.user, size: small ? 30 : 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    c.user,
                    style: TextStyle(
                      fontSize: small ? 14 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatDate(c.date),
                    style: const TextStyle(color: mutedText, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                c.text,
                style: const TextStyle(
                  color: softText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
