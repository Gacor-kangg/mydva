import 'package:flutter/material.dart';

import '../models/my_list_entry.dart';
import '../services/my_list_service.dart';

enum _SortOption {
  newest('Terbaru'),
  oldest('Terlama'),
  titleAz('A-Z'),
  ratingHigh('Rating tertinggi (10 → 1)'),
  ratingLow('Rating terendah (1 → 10)');

  const _SortOption(this.label);
  final String label;
}

class MyListHistoryPage extends StatefulWidget {
  final String? mediaType;
  final String pageTitle;

  const MyListHistoryPage({
    super.key,
    this.mediaType,
    required this.pageTitle,
  });

  @override
  State<MyListHistoryPage> createState() => _MyListHistoryPageState();
}

class _MyListHistoryPageState extends State<MyListHistoryPage> {
  static const Color _background = Color(0xFF0B0B0C);
  static const Color _panel = Color(0xFF151516);
  static const Color _border = Color(0xFF2A2A2D);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _soft = Color(0xFFC8C8CC);
  static const Color _blue = Color(0xFF9DBEFF);
  static const Color _accent = Color(0xFF4A6FC3);
  static const Color _selected = Color(0xFF3A3A3D);

  static const Map<String, Color> _statusColors = {
    MyListStatus.watching: Color(0xFF3FA35B),
    MyListStatus.completed: Color(0xFF4A6FC3),
    MyListStatus.onHold: Color(0xFFD1A91A),
    MyListStatus.dropped: Color(0xFF963434),
    MyListStatus.planToWatch: Color(0xFF666666),
  };

  final Stream<List<MyListEntry>> _stream = MyListService().watchAll();

  _SortOption _sort = _SortOption.newest;
  final Set<String> _statuses = {};
  final Set<int> _scores = {};
  DateTimeRange? _range;

  int get _activeFilterCount =>
      (_statuses.isNotEmpty ? 1 : 0) +
      (_scores.isNotEmpty ? 1 : 0) +
      (_range != null ? 1 : 0);

  String _normalize(String type) {
    final value = type.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (value == 'film' || value == 'movie') return 'Film';
    if (value == 'anime') return 'Anime';
    if (value == 'jdrama') return 'J-Drama';
    if (value == 'kdrama') return 'K-Drama';
    if (value == 'series' || value == 'tv') return 'Series';
    return type;
  }

  String _date(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ============================================================
  // FILTER + SORT
  // ============================================================

  List<MyListEntry> _apply(List<MyListEntry> source) {
    final result = source.where((entry) {
      if (_statuses.isNotEmpty && !_statuses.contains(entry.status)) {
        return false;
      }

      if (_scores.isNotEmpty &&
          (entry.score == null || !_scores.contains(entry.score))) {
        return false;
      }

      final range = _range;
      if (range != null) {
        final added = entry.addedAt;
        if (added == null) return false;
        final day = DateTime(added.year, added.month, added.day);
        if (day.isBefore(range.start) || day.isAfter(range.end)) return false;
      }

      return true;
    }).toList();

    result.sort(_compare);
    return result;
  }

  int _compare(MyListEntry a, MyListEntry b) {
    final int result;

    switch (_sort) {
      case _SortOption.newest:
        result = _compareDates(a.addedAt, b.addedAt, newestFirst: true);
      case _SortOption.oldest:
        result = _compareDates(a.addedAt, b.addedAt, newestFirst: false);
      case _SortOption.titleAz:
        result = 0;
      case _SortOption.ratingHigh:
        result = _compareScores(a.score, b.score, highFirst: true);
      case _SortOption.ratingLow:
        result = _compareScores(a.score, b.score, highFirst: false);
    }

    if (result != 0) return result;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  int _compareDates(DateTime? a, DateTime? b, {required bool newestFirst}) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return newestFirst ? b.compareTo(a) : a.compareTo(b);
  }

  int _compareScores(int? a, int? b, {required bool highFirst}) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return highFirst ? b.compareTo(a) : a.compareTo(b);
  }

  void _resetFilters() {
    setState(() {
      _statuses.clear();
      _scores.clear();
      _range = null;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _panel,
        foregroundColor: Colors.white,
        title: Text(widget.pageTitle),
      ),
      body: StreamBuilder<List<MyListEntry>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat My List: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final type = widget.mediaType;
          final all = (snapshot.data ?? <MyListEntry>[]).where((entry) {
            return type == null || _normalize(entry.mediaType) == type;
          }).toList();

          if (all.isEmpty) {
            return Center(
              child: Text(
                type == null
                    ? 'Belum ada media di My List.'
                    : 'Belum ada ${type.toLowerCase()} di My List.',
                style: const TextStyle(color: _muted, fontSize: 15),
              ),
            );
          }

          final shown = _apply(all);

          return Column(
            children: [
              _buildToolbar(shown.length, all.length),
              Expanded(
                child: shown.isEmpty
                    ? _buildNoMatch()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: shown.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _buildItem(shown[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // TOOLBAR (SORT + FILTER)
  // ============================================================

  Widget _buildToolbar(int shown, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<_SortOption>(
                tooltip: 'Urutkan',
                color: _panel,
                offset: const Offset(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: _border),
                ),
                onSelected: (option) => setState(() => _sort = option),
                itemBuilder: (context) => [
                  for (final option in _SortOption.values)
                    PopupMenuItem<_SortOption>(
                      value: option,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: option == _sort
                                ? const Icon(Icons.check, size: 16, color: _blue)
                                : null,
                          ),
                          Text(
                            option.label,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                ],
                child: _toolButton(Icons.sort, 'Urutkan: ${_sort.label}'),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _openFilterSheet,
                child: _toolButton(
                  Icons.filter_alt_outlined,
                  'Filter',
                  badge: _activeFilterCount,
                ),
              ),
              Text(
                '$shown dari $total judul',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
          if (_activeFilterCount > 0) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(),
          ],
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, String label, {int badge = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
        color: _panel,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _soft),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          if (badge > 0) ...[
            const SizedBox(width: 8),
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final scores = _scores.toList()..sort();
    final range = _range;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final status in _statuses)
          _activeChip(status, () => setState(() => _statuses.remove(status))),
        for (final score in scores)
          _activeChip('Rating $score', () => setState(() => _scores.remove(score))),
        if (range != null)
          _activeChip(
            '${_date(range.start)} – ${_date(range.end)}',
            () => setState(() => _range = null),
          ),
        TextButton(
          onPressed: _resetFilters,
          style: TextButton.styleFrom(
            foregroundColor: _blue,
            minimumSize: const Size(0, 30),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text('Reset', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _activeChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4, right: 4),
      decoration: BoxDecoration(
        color: _selected,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 2),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.close, size: 14, color: _soft),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatch() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tidak ada judul yang cocok dengan filter.',
            style: TextStyle(color: _muted, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _resetFilters,
            style: TextButton.styleFrom(foregroundColor: _blue),
            child: const Text('Reset filter'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM SHEET FILTER
  // ============================================================

  Future<void> _openFilterSheet() async {
    final statuses = {..._statuses};
    final scores = {..._scores};
    DateTimeRange? range = _range;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            final current = range;

            Future<void> pickRange() async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: sheetContext,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year, now.month, now.day),
                initialDateRange: current,
                builder: (context, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: _accent,
                      onPrimary: Colors.white,
                      surface: _panel,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setSheet(() => range = picked);
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Filter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setSheet(() {
                            statuses.clear();
                            scores.clear();
                            range = null;
                          }),
                          style: TextButton.styleFrom(foregroundColor: _blue),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),

                    _sectionLabel('Tanggal ditambahkan'),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickRange,
                            icon: const Icon(Icons.date_range, size: 18),
                            label: Text(
                              current == null
                                  ? 'Pilih rentang tanggal'
                                  : '${_date(current.start)} – ${_date(current.end)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: _border),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        if (current != null)
                          IconButton(
                            tooltip: 'Hapus tanggal',
                            onPressed: () => setSheet(() => range = null),
                            icon: const Icon(Icons.close, size: 18, color: _muted),
                          ),
                      ],
                    ),

                    _sectionLabel('Status'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final status in MyListStatus.all)
                          _pill(
                            label: status,
                            selected: statuses.contains(status),
                            dotColor: _statusColors[status],
                            onTap: () => setSheet(() {
                              if (!statuses.remove(status)) statuses.add(status);
                            }),
                          ),
                      ],
                    ),

                    _sectionLabel('Rating'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var score = 1; score <= 10; score++)
                          _pill(
                            label: '$score',
                            selected: scores.contains(score),
                            onTap: () => setSheet(() {
                              if (!scores.remove(score)) scores.add(score);
                            }),
                          ),
                      ],
                    ),

                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _statuses
                              ..clear()
                              ..addAll(statuses);
                            _scores
                              ..clear()
                              ..addAll(scores);
                            _range = range;
                          });
                          Navigator.pop(sheetContext);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Terapkan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: _muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? dotColor,
  }) {
    return Material(
      color: selected ? _selected : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: selected ? _blue : _border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _soft,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ITEM LIST
  // ============================================================

  Widget _buildItem(MyListEntry entry) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: entry.imageUrl.isEmpty
                ? Container(
                    width: 64,
                    height: 90,
                    color: _border,
                    alignment: Alignment.center,
                    child: const Icon(Icons.movie, color: _muted),
                  )
                : Image.network(
                    entry.imageUrl,
                    width: 64,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 90,
                      color: _border,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: _muted),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _blue, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('${entry.mediaType}${entry.releaseYear == null ? '' : ' • ${entry.releaseYear}'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 5),
                Text('Status: ${entry.status}',
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Ditambahkan: ${_date(entry.addedAt)}',
                    style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(entry.score?.toString() ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              const Text('SCORE', style: TextStyle(color: _muted, fontSize: 9, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }
}
