import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/my_list_entry.dart';
import '../services/my_list_service.dart';

class ScoreDistributionPage extends StatefulWidget {
  const ScoreDistributionPage({super.key});

  @override
  State<ScoreDistributionPage> createState() => _ScoreDistributionPageState();
}

class _ScoreDistributionPageState extends State<ScoreDistributionPage> {
  static const Color _background = Color(0xFF0B0B0C);
  static const Color _panel = Color(0xFF151516);
  static const Color _card = Color(0xFF1B1B1D);
  static const Color _border = Color(0xFF2A2A2D);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _soft = Color(0xFFC8C8CC);
  static const Color _lightBlue = Color(0xFF9DBEFF);
  static const Color _selected = Color(0xFF3A3A3D);

  // Warna sama dengan kartu statistik di profile page.
  static const Map<String, Color> _statusColors = {
    MyListStatus.completed: Color(0xFF4A6FC3),
    MyListStatus.watching: Color(0xFF3FA35B),
    MyListStatus.onHold: Color(0xFFD1A91A),
    MyListStatus.dropped: Color(0xFF963434),
    MyListStatus.planToWatch: Color(0xFF666666),
  };

  static const List<String> _types = [
    'All',
    'Film',
    'Series',
    'J-Drama',
    'K-Drama',
    'Anime',
  ];

  final Stream<List<MyListEntry>> _stream = MyListService().watchAll();

  String _type = 'All';
  String? _status; 
  String _normalize(String type) {
    final value = type.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (value == 'film' || value == 'movie') return 'Film';
    if (value == 'anime') return 'Anime';
    if (value == 'jdrama') return 'J-Drama';
    if (value == 'kdrama') return 'K-Drama';
    if (value == 'series' || value == 'tv') return 'Series';
    return type;
  }

  _Distribution _compute(List<MyListEntry> all) {
    final filtered = all.where((e) {
      if (_type != 'All' && _normalize(e.mediaType) != _type) return false;
      if (_status != null && e.status != _status) return false;
      return true;
    });

    final byScore = <int, Map<String, int>>{
      for (var s = 1; s <= 10; s++) s: <String, int>{},
    };

    var total = 0;
    var unscored = 0;
    var sum = 0;
    var sumSquares = 0;

    for (final entry in filtered) {
      final score = entry.score;
      if (score == null || score < 1 || score > 10) {
        unscored++;
        continue;
      }
      final bucket = byScore[score]!;
      bucket[entry.status] = (bucket[entry.status] ?? 0) + 1;
      total++;
      sum += score;
      sumSquares += score * score;
    }

    final mean = total == 0 ? 0.0 : sum / total;
    // Standar deviasi populasi (sama seperti angka di MyAnimeList).
    final variance =
        total == 0 ? 0.0 : math.max(0.0, sumSquares / total - mean * mean);

    return _Distribution(
      byScore: byScore,
      total: total,
      mean: mean,
      stdDev: math.sqrt(variance),
      unscored: unscored,
    );
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
        surfaceTintColor: Colors.transparent,
        title: const Text('All Media Stats'),
      ),
      body: StreamBuilder<List<MyListEntry>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat My List: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final distribution = _compute(snapshot.data ?? const []);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeTabs(),
                    const SizedBox(height: 22),
                    _buildBody(distribution),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeTabs() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in _types)
          _pill(
            label: type,
            selected: _type == type,
            onTap: () => setState(() => _type = type),
          ),
      ],
    );
  }

  Widget _buildBody(_Distribution distribution) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chart = _buildChart(distribution);
        final filters = _buildFilters();

        if (constraints.maxWidth >= 760) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: chart),
              const SizedBox(width: 28),
              SizedBox(width: 260, child: filters),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            filters,
            const SizedBox(height: 24),
            chart,
          ],
        );
      },
    );
  }

  // ============================================================
  // GRAFIK
  // ============================================================

  Widget _buildChart(_Distribution d) {
    final maxCount = d.maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Score Distribution',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 20),
        for (var score = 10; score >= 1; score--) _scoreRow(d, score, maxCount),
        if (d.total == 0)
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text(
              'Belum ada judul yang diberi skor untuk filter ini. '
              'Beri skor lewat halaman detail judul.',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ),
        const SizedBox(height: 4),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 14),
        _buildSummary(d),
        if (d.unscored > 0)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '${d.unscored} judul belum diberi skor (tidak dihitung).',
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _scoreRow(_Distribution d, int score, int maxCount) {
    final count = d.countAt(score);
    final percent = d.total == 0 ? 0 : (count / d.total * 100).round();
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;

    final segments = <MapEntry<String, int>>[
      for (final status in _statusColors.keys)
        if ((d.byScore[score]![status] ?? 0) > 0)
          MapEntry(status, d.byScore[score]![status]!),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$score',
              style: const TextStyle(color: _soft, fontSize: 16),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: fraction),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    final width = value <= 0
                        ? 0.0
                        : math.max(8.0, constraints.maxWidth * value);

                    Widget bar = SizedBox(
                      width: width,
                      height: 28,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final segment in segments)
                              Expanded(
                                flex: segment.value,
                                child: ColoredBox(
                                  color: _statusColors[segment.key]!,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );

                    if (segments.isNotEmpty) {
                      bar = Tooltip(
                        message: segments
                            .map((s) => '${s.key}: ${s.value}')
                            .join('\n'),
                        child: bar,
                      );
                    }

                    return Align(alignment: Alignment.centerLeft, child: bar);
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 36,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(color: _soft, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '($percent%)',
              textAlign: TextAlign.right,
              style: const TextStyle(color: _soft, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(_Distribution d) {
    Widget item(String label, String value) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: _muted, fontSize: 14),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: _soft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 32,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        children: [
          item('Mean Score', d.total == 0 ? '-' : d.mean.toStringAsFixed(1)),
          item('Std Dev', d.total == 0 ? '-' : d.stdDev.toStringAsFixed(2)),
          item('Total Scores', '${d.total}'),
        ],
      ),
    );
  }

  // ============================================================
  // PANEL FILTER
  // ============================================================

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_alt, size: 18, color: _soft),
              SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  color: _soft,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                label: 'All',
                selected: _status == null,
                onTap: () => setState(() => _status = null),
              ),
              for (final status in MyListStatus.all)
                _pill(
                  label: status,
                  selected: _status == status,
                  dotColor: _statusColors[status],
                  onTap: () => setState(() => _status = status),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KOMPONEN KECIL
  // ============================================================

 
  Widget _pill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? dotColor,
  }) {
    return Material(
      color: selected ? _selected : _card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: selected ? _lightBlue : _border),
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
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
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
}

// ==============================================================
// DATA HASIL HITUNG
// ==============================================================

class _Distribution {
  
  final Map<int, Map<String, int>> byScore;
  final int total;
  final double mean;
  final double stdDev;
  final int unscored;

  const _Distribution({
    required this.byScore,
    required this.total,
    required this.mean,
    required this.stdDev,
    required this.unscored,
  });

  int countAt(int score) =>
      byScore[score]!.values.fold<int>(0, (a, b) => a + b);

  int get maxCount {
    var max = 0;
    for (var s = 1; s <= 10; s++) {
      final c = countAt(s);
      if (c > max) max = c;
    }
    return max;
  }
}
