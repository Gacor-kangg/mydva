  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  import '../controllers/media_feedback_controller.dart';
  import '../controllers/media_detail_controller.dart';
  import '../models/media_detail_model.dart';
  import '../repositories/media_feedback_repository.dart';
  import '../services/media_feedback_service.dart';

  import 'detail_data.dart';
  import '../controllers/my_list_controller.dart';
  import '../models/media_model.dart';
  import '../repositories/my_list_repository.dart';
  import '../repositories/user_repository.dart';
  import '../services/my_list_service.dart';
  import '../services/user_service.dart';
  import 'poster_image.dart';
  import 'ui_effects.dart';

  class _Review {
    final String id, uid, user, text;
    final int? score;
    final DateTime date;
    final bool spoiler;
    final int helpful;
    final bool helpedByMe;
    bool expanded = false, spoilerRevealed = false;
    _Review({
      required this.id,
      required this.uid,
      required this.user,
      required this.text,
      required this.score,
      required this.date,
      required this.spoiler,
      required this.helpful,
      required this.helpedByMe,
    });
  }

  class _Comment {
    final String id, uid, user, text;
    final DateTime date;
    final String? parentDiscussionId;

    _Comment({
      required this.id,
      required this.uid,
      required this.user,
      required this.text,
      required this.date,
      this.parentDiscussionId,
    });
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
    final TextEditingController _replyController =
      TextEditingController();
    String? _replyingDiscussionId;
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

    // static const List<String> _months = [
    //   'Jan',
    //   'Feb',
    //   'Mar',
    //   'Apr',
    //   'May',
    //   'Jun',
    //   'Jul',
    //   'Aug',
    //   'Sep',
    //   'Oct',
    //   'Nov',
    //   'Dec',
    // ];

    // ----------------------------------------------------------
    // STATE
    // ----------------------------------------------------------

    late final MediaDetail _detail; // fallback untuk progress My List
    final MediaDetailController _detailController = MediaDetailController();
    MediaDetailModel? _apiDetail;
    bool _detailLoading = true;
    String? _detailError;
    int _tab = 0;

    // My List
    String? _status;
    int? _myScore;
    int _progress = 0;
    bool _saved = false;
    bool _inList = false; // sudah tersimpan di database
    bool _loadingList = true; // sedang memuat My List dari database
    bool _saving = false; // sedang menyimpan/menghapus

    final MyListController _myListController = MyListController(
      repository: MyListRepository(service: MyListService()),
    );
    final UserRepository _userRepository = UserRepository(service: UserService());
    String _username = UserService.fallbackUsername;

    // Reviews
    String _sort = 'Most Helpful';
    bool _newReviewSpoiler = false;
    final TextEditingController _reviewController = TextEditingController();
    // Feedback disimpan permanen di Cloud Firestore.
    final TextEditingController _commentController = TextEditingController();
    final MediaFeedbackController _feedback = MediaFeedbackController(
      repository: MediaFeedbackRepository(service: MediaFeedbackService()),
    );
    bool _feedbackBusy = false;
    String? get _uid => FirebaseAuth.instance.currentUser?.uid;

    String get _type => widget.media.genre ?? 'Film';
    bool get _hasProgress => _type != 'Film';

    @override
    void initState() {
      super.initState();

      _detail = detailFor(widget.media);
      _loadApiDetail();
      _loadMyList();
      _loadUsername();
    }

    Future<void> _loadApiDetail() async {
      try {
        final result = await _detailController.load(widget.media);
        if (!mounted) return;
        setState(() { _apiDetail = result; _detailLoading = false; _detailError = null; });
      } catch (e) {
        if (!mounted) return;
        setState(() { _detailLoading = false; _detailError = e.toString(); });
      }
    }

    // ----------------------------------------------------------
    // DATABASE: My List dan username
    // ----------------------------------------------------------

    void _showMessage(String message) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    String _formatDate(DateTime date) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hari ini';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      }

      return '${date.day}/${date.month}/${date.year}';
    }

    Future<void> _loadMyList() async {
      final entry = await _myListController.load(
        widget.media,
        onError: (message) {
          if (mounted) _showMessage(message);
        },
      );

      if (!mounted) return;

      setState(() {
        _loadingList = false;
        if (entry != null) {
          _inList = true;
          _saved = true;
          _status = _statuses.contains(entry.status) ? entry.status : null;
          _myScore = entry.score;
          _progress = entry.progress;
        }
      });
    }

    Future<void> _loadUsername() async {
      final name = await _userRepository.getCurrentUsername();
      if (!mounted) return;
      setState(() => _username = name);
    }

    Future<void> _saveToMyList() async {
      final status = _status;

      if (status == null) {
        _showMessage('Pilih status dulu sebelum menyimpan.');
        return;
      }

      final uid = _uid;

      if (uid == null) {
        _showMessage('Silakan login terlebih dahulu.');
        return;
      }

      setState(() => _saving = true);

      final error = await _myListController.save(
        media: widget.media,
        status: status,
        score: _myScore,
        progress: _progress,
        totalEpisodes: _detail.episodes,
      );

      if (!mounted) return;

      if (error != null) {
        setState(() => _saving = false);
        _showMessage(error);
        return;
      }

      try {
        await _feedback.updateMyReviewScore(
          mediaKey: widget.media.mediaKey,
          uid: uid,
          score: _myScore,
        );
        await _feedback.setMyRating(
          mediaKey: widget.media.mediaKey,
          uid: uid,
          score: _myScore,
        );

        if (!mounted) return;

        setState(() {
          _saving = false;
          _saved = true;
          _inList = true;
        });

        _showMessage('My List dan skor review berhasil diperbarui.');
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _saving = false;
          _saved = true;
          _inList = true;
        });

        _showMessage(
          'My List tersimpan, tetapi skor review gagal diperbarui: $e',
        );
      }
    }

    Future<void> _removeFromMyList() async {
      setState(() => _saving = true);

      final error = await _myListController.remove(widget.media);

      if (!mounted) return;

      setState(() {
        _saving = false;
        if (error == null) {
          _inList = false;
          _saved = false;
          _status = null;
          _myScore = null;
          _progress = 0;
        }
      });
      _showMessage(error ?? 'Dihapus dari My List.');
    }

    @override
    void dispose() {
      _reviewController.dispose();
      _commentController.dispose();
      _replyController.dispose();
      _detailController.dispose();

      super.dispose();
    }

    // ----------------------------------------------------------
    // HELPERS
    // ----------------------------------------------------------
    
    double? get _apiScore {
      final rating = widget.media.rating;

      if (rating == null) return null;

      final scale = widget.media.ratingScale ?? 10;

      return (scale == 100 ? rating / 10 : rating).clamp(0.0, 10.0);
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
        child: PosterImage(media: media, width: 210, height: 300, textSize: 64),
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
      final score = _apiScore;
      final source = widget.media.ratingSource ?? 'API';
      final votes = widget.media.voteCount ?? 0;

      final formattedVotes = votes.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );

      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            score != null ? '${score.toStringAsFixed(1)}/10' : '-',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$formattedVotes ratings',
                  style: const TextStyle(
                    color: softText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
                onPressed: (_loadingList || _saving) ? null : _saveToMyList,
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
                    _saving
                        ? 'Saving...'
                        : (_saved ? 'Saved' : 'Save to My List'),
                    key: ValueKey(_saving ? 'saving' : _saved),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            if (_inList) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : _removeFromMyList,
                child: const Text(
                  'Remove from My List',
                  style: TextStyle(color: Color(0xFFE57373)),
                ),
              ),
            ],
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
            children: [for (int i = 0; i < _tabLabels.length; i++) _tabItem(i)],
          ),
        ),
      );
    }

    Widget _tabItem(int index) {
      final selected = _tab == index;

      String label = _tabLabels[index];

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
      final detail = _apiDetail;
      final synopsis = (detail?.synopsis?.trim().isNotEmpty == true)
          ? detail!.synopsis!.replaceAll(RegExp(r'<[^>]*>'), '').trim()
          : (widget.media.overview?.trim().isNotEmpty == true
              ? widget.media.overview!.trim() : 'Sinopsis belum tersedia.');
      final rows = detail?.information.entries.toList() ?? <MapEntry<String, String>>[];
      if (rows.isEmpty) {
        rows.add(MapEntry('Type', _type));
        if (widget.media.releaseYear != null) {
          rows.add(MapEntry('Year', widget.media.releaseYear.toString()));
        }
        if (widget.media.genres.isNotEmpty) {
          rows.add(MapEntry('Genres', widget.media.genres.join(', ')));
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Synopsis'), const SizedBox(height: 10),
            Text(synopsis, style: const TextStyle(color: softText, fontSize: 15, height: 1.6)),
          ])),
          const SizedBox(height: 16),
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [_label('Information'), const Spacer(),
              if (_detailLoading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            ]),
            if (_detailError != null && rows.isEmpty) ...[
              const SizedBox(height: 10),
              Text('Informasi detail belum dapat dimuat. ${_detailError!}', style: const TextStyle(color: mutedText, fontSize: 13)),
              const SizedBox(height: 8),
              TextButton(onPressed: () { setState(() => _detailLoading = true); _loadApiDetail(); }, child: const Text('Coba lagi')),
            ] else ...[
              const SizedBox(height: 10),
              for (int i = 0; i < rows.length; i++)
                _infoRow(rows[i].key, rows[i].value, last: i == rows.length - 1),
            ],
          ])),
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

    // ----------------------------------------------------------
    // TAB 2: CAST
    // ----------------------------------------------------------

    Widget _buildCast() {
      final cast = _apiDetail?.cast ?? const <MediaCastMember>[];
      if (_detailLoading && cast.isEmpty) {
        return _card(child: const Center(child: Padding(
          padding: EdgeInsets.all(18), child: CircularProgressIndicator(),
        )));
      }
      if (cast.isEmpty) {
        return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Data cast belum tersedia dari sumber API untuk judul ini.', style: TextStyle(color: mutedText, fontSize: 14)),
          if (_detailError != null) ...[
            const SizedBox(height: 8), Text(_detailError!, style: const TextStyle(color: mutedText, fontSize: 12)),
            TextButton(onPressed: () { setState(() => _detailLoading = true); _loadApiDetail(); }, child: const Text('Coba lagi')),
          ],
        ]));
      }
      return Column(children: [
        for (final member in cast) Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _card(child: Row(children: [
            _castImage(member.imageUrl, member.name), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(member.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3), Text(member.role, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: mutedText, fontSize: 13)),
            ])),
            if (member.secondaryName != null) ...[
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(member.secondaryName!, textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: lightBlue, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(member.secondaryRole ?? 'Voice Actor', style: const TextStyle(color: mutedText, fontSize: 12)),
              ])),
              const SizedBox(width: 8), _castImage(member.secondaryImageUrl, member.secondaryName!),
            ],
          ])),
        ),
      ]);
    }

    Widget _castImage(String? url, String name) {
      return ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(
        width: 48, height: 58,
        child: url != null && url.isNotEmpty
            ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatar(name, size: 48))
            : _avatar(name, size: 48),
      ));
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
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _feedback.reviews(widget.media.mediaKey),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _feedbackError(snapshot.error.toString());
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final reviews = snapshot.data!.docs.map((doc) {
            final d = doc.data();
            final voters = List<String>.from(d['helpfulBy'] ?? const []);
            final ts = d['createdAt'];
            return _Review(
              id: doc.id,
              uid: '${d['uid'] ?? ''}',
              user: '${d['username'] ?? 'Pengguna'}',
              text: '${d['text'] ?? ''}',
              score: (d['score'] as num?)?.toInt(),
              date: ts is Timestamp ? ts.toDate() : DateTime.now(),
              spoiler: d['spoiler'] == true,
              helpful: voters.length,
              helpedByMe: _uid != null && voters.contains(_uid),
            );
          }).toList();
          if (_sort == 'Most Helpful')
            reviews.sort((a, b) => b.helpful.compareTo(a.helpful));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      decoration: _inputDecoration(
                        'Tulis review kamu di sini...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _choiceChip(
                          label: 'Contains spoiler',
                          selected: _newReviewSpoiler,
                          onTap: () => setState(
                            () => _newReviewSpoiler = !_newReviewSpoiler,
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _feedbackBusy ? null : _postReview,
                          style: FilledButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Post Review'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
              if (reviews.isEmpty)
                _emptyFeedback(
                  'Belum ada review. Jadilah yang pertama memberikan review.',
                ),
              for (final review in reviews)
                Reveal(key: ValueKey(review.id), child: _reviewCard(review)),
            ],
          );
        },
      );
    }

    Future<void> _postReview() async {
      final text = _reviewController.text.trim();
      final user = FirebaseAuth.instance.currentUser;
      if (text.isEmpty) {
        _showMessage('Review tidak boleh kosong.');
        return;
      }
      if (user == null) {
        _showMessage('Silakan login terlebih dahulu.');
        return;
      }
      setState(() => _feedbackBusy = true);
      try {
        await _feedback.addReview(
          mediaKey: widget.media.mediaKey,
          uid: user.uid,
          username: _username,
          text: text,
          spoiler: _newReviewSpoiler,
          score: _myScore,
        );
        _reviewController.clear();
        if (mounted) setState(() => _newReviewSpoiler = false);
        if (mounted) _showMessage('Review berhasil dipublikasikan.');
      } catch (e) {
        if (mounted) _showMessage('Gagal menyimpan review: $e');
      } finally {
        if (mounted) setState(() => _feedbackBusy = false);
      }
    }

    Future<String?> _editTextDialog({
      required String title,
      required String initialText,
    }) async {
      final controller = TextEditingController(text: initialText);
      final result = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: panelColor,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 8,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Tulis perubahan...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              style: FilledButton.styleFrom(backgroundColor: blue),
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (result != null && result.trim().isEmpty) {
        _showMessage('Isi tidak boleh kosong.');
        return null;
      }
      return result;
    }

    Future<bool> _confirmFeedbackDelete(String label) async =>
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: panelColor,
            title: const Text(
              'Hapus konfirmasi',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Yakin ingin menghapus $label?',
              style: const TextStyle(color: softText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    Widget _ownerMenu({
      required VoidCallback onEdit,
      required VoidCallback onDelete,
    }) => PopupMenuButton<String>(
      tooltip: 'Kelola',
      color: cardColor,
      icon: const Icon(Icons.more_vert, color: mutedText, size: 20),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Hapus')),
      ],
    );

    Future<void> _editReview(_Review review) async {
      final text = await _editTextDialog(
        title: 'Edit review',
        initialText: review.text,
      );
      if (text == null || !mounted) return;
      try {
        await _feedback.updateReview(
          mediaKey: widget.media.mediaKey,
          reviewId: review.id,
          text: text,
          spoiler: review.spoiler,
          score: review.score,
        );
        if (mounted) _showMessage('Review berhasil diperbarui.');
      } catch (e) {
        if (mounted) _showMessage('Gagal mengedit review: $e');
      }
    }

    Future<void> _deleteReview(_Review review) async {
      if (!await _confirmFeedbackDelete('review ini') || !mounted) return;
      try {
        await _feedback.deleteReview(
          mediaKey: widget.media.mediaKey,
          reviewId: review.id,
        );
        if (mounted) _showMessage('Review berhasil dihapus.');
      } catch (e) {
        if (mounted) _showMessage('Gagal menghapus review: $e');
      }
    }

    Future<void> _editComment(_Comment comment) async {
      final text = await _editTextDialog(
        title: comment.parentDiscussionId == null
            ? 'Edit diskusi'
            : 'Edit balasan',
        initialText: comment.text,
      );
      if (text == null || !mounted) return;
      try {
        if (comment.parentDiscussionId == null) {
          await _feedback.updateDiscussion(
            mediaKey: widget.media.mediaKey,
            discussionId: comment.id,
            text: text,
          );
        } else {
          await _feedback.updateReply(
            mediaKey: widget.media.mediaKey,
            discussionId: comment.parentDiscussionId!,
            replyId: comment.id,
            text: text,
          );
        }
        if (mounted) _showMessage('Berhasil diperbarui.');
      } catch (e) {
        if (mounted) _showMessage('Gagal mengedit: $e');
      }
    }

    Future<void> _deleteComment(_Comment comment) async {
      final isReply = comment.parentDiscussionId != null;
      if (!await _confirmFeedbackDelete(
            isReply ? 'balasan ini' : 'diskusi ini',
          ) ||
          !mounted)
        return;
      try {
        if (isReply) {
          await _feedback.deleteReply(
            mediaKey: widget.media.mediaKey,
            discussionId: comment.parentDiscussionId!,
            replyId: comment.id,
          );
        } else {
          await _feedback.deleteDiscussion(
            mediaKey: widget.media.mediaKey,
            discussionId: comment.id,
          );
        }
        if (mounted)
          _showMessage(
            isReply
                ? 'Balasan berhasil dihapus.'
                : 'Diskusi dan balasannya berhasil dihapus.',
          );
      } catch (e) {
        if (mounted) _showMessage('Gagal menghapus: $e');
      }
    }

    Widget _feedbackError(String e) => Padding(
      padding: const EdgeInsets.all(18),
      child: Text(
        'Gagal memuat data: $e',
        style: const TextStyle(color: Colors.redAccent),
      ),
    );
    Widget _emptyFeedback(String t) => Padding(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Text(
          t,
          textAlign: TextAlign.center,
          style: const TextStyle(color: mutedText),
        ),
      ),
    );

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
                  if (r.uid == _uid) ...[
                    const SizedBox(width: 4),
                    _ownerMenu(
                      onEdit: () => _editReview(r),
                      onDelete: () => _deleteReview(r),
                    ),
                  ],
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
                onPressed: () async {
                  final uid = _uid;
                  if (uid == null) {
                    _showMessage('Silakan login terlebih dahulu.');
                    return;
                  }
                  try {
                    await _feedback.toggleHelpful(
                      mediaKey: widget.media.mediaKey,
                      reviewId: r.id,
                      uid: uid,
                    );
                  } catch (e) {
                    _showMessage('Gagal memperbarui Helpful: $e');
                  }
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


    Future<void> _postReply(_Comment c) async {
      final text = _replyController.text.trim();
      final user = FirebaseAuth.instance.currentUser;

      if (text.isEmpty) {
        _showMessage('Balasan tidak boleh kosong.');
        return;
      }

      if (user == null) {
        _showMessage('Silakan login terlebih dahulu.');
        return;
      }

      try {
        await _feedback.addReply(
          mediaKey: widget.media.mediaKey,
          discussionId: c.id,
          uid: user.uid,
          username: _username,
          text: text,
        );

        if (!mounted) return;

        setState(() {
          _replyController.clear();
          _replyingDiscussionId = null;
        });

        _showMessage('Balasan berhasil dikirim.');
      } catch (e) {
        if (mounted) {
          _showMessage('Gagal menyimpan balasan: $e');
        }
      }
    }

    // ----------------------------------------------------------
    // TAB 4: DISCUSSION
    // ----------------------------------------------------------

    Widget _buildDiscussion() {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _feedback.discussions(widget.media.mediaKey),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _feedbackError(snapshot.error.toString());
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final comments = snapshot.data!.docs.map((doc) {
            final d = doc.data();
            final ts = d['createdAt'];
            return _Comment(
              id: doc.id,
              uid: '${d['uid'] ?? ''}',
              user: '${d['username'] ?? 'Pengguna'}',
              text: '${d['text'] ?? ''}',
              date: ts is Timestamp ? ts.toDate() : DateTime.now(),
            );
          }).toList();
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
                      decoration: _inputDecoration(
                        'Tulis komentar atau pertanyaan...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _feedbackBusy ? null : _postComment,
                        style: FilledButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (comments.isEmpty)
                _emptyFeedback('Belum ada diskusi. Mulai percakapan pertama!'),
              for (final c in comments)
                Reveal(key: ValueKey(c.id), child: _commentCard(c)),
            ],
          );
        },
      );
    }

    Future<void> _postComment() async {
      final text = _commentController.text.trim();
      final user = FirebaseAuth.instance.currentUser;
      if (text.isEmpty) {
        _showMessage('Komentar tidak boleh kosong.');
        return;
      }
      if (user == null) {
        _showMessage('Silakan login terlebih dahulu.');
        return;
      }
      setState(() => _feedbackBusy = true);
      try {
        await _feedback.addDiscussion(
          mediaKey: widget.media.mediaKey,
          uid: user.uid,
          username: _username,
          text: text,
        );
        _commentController.clear();
        if (mounted) _showMessage('Diskusi berhasil dipublikasikan.');
      } catch (e) {
        if (mounted) _showMessage('Gagal menyimpan diskusi: $e');
      } finally {
        if (mounted) setState(() => _feedbackBusy = false);
      }
    }
    
    Widget _commentCard(_Comment c) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _commentBody(c),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _feedback.replies(widget.media.mediaKey, c.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.only(left: 18, top: 10),
                  padding: const EdgeInsets.only(left: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: borderColor, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final doc in snapshot.data!.docs)
                        Builder(
                          builder: (_) {
                            final d = doc.data();
                            final ts = d['createdAt'];

                            final reply = _Comment(
                              id: doc.id,
                              uid: '${d['uid'] ?? ''}',
                              user: '${d['username'] ?? 'Pengguna'}',
                              text: '${d['text'] ?? ''}',
                              date: ts is Timestamp
                                  ? ts.toDate()
                                  : DateTime.now(),
                              parentDiscussionId: c.id,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _commentBody(reply, small: true),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (_replyingDiscussionId == c.id) {
                      _replyingDiscussionId = null;
                    } else {
                      _replyingDiscussionId = c.id;
                    }
                    _replyController.clear();
                  });
                },
                child: Text(
                  _replyingDiscussionId == c.id ? 'Cancel' : 'Reply',
                  style: const TextStyle(
                    color: lightBlue,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            if (_replyingDiscussionId == c.id)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Tulis balasan...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _postReply(c),
                    style: FilledButton.styleFrom(backgroundColor: blue),
                    child: const Text('Send'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );


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
                    const Spacer(),
                    if (c.uid == _uid)
                      _ownerMenu(
                        onEdit: () => _editComment(c),
                        onDelete: () => _deleteComment(c),
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
