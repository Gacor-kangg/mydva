import 'package:flutter/material.dart';

import '../models/my_list_entry.dart';
import '../services/my_list_service.dart';

class MyListHistoryPage extends StatelessWidget {
  final String? mediaType;
  final String pageTitle;

  const MyListHistoryPage({
    super.key,
    this.mediaType,
    required this.pageTitle,
  });

  static const Color _background = Color(0xFF0B0B0C);
  static const Color _panel = Color(0xFF151516);
  static const Color _border = Color(0xFF2A2A2D);
  static const Color _muted = Color(0xFF8E8E93);
  static const Color _blue = Color(0xFF9DBEFF);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _panel,
        foregroundColor: Colors.white,
        title: Text(pageTitle),
      ),
      body: StreamBuilder<List<MyListEntry>>(
        stream: MyListService().watchAll(),
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

          final entries = (snapshot.data ?? <MyListEntry>[]).where((entry) {
            return mediaType == null || _normalize(entry.mediaType) == mediaType;
          }).toList();

          if (entries.isEmpty) {
            return Center(
              child: Text(
                mediaType == null
                    ? 'Belum ada media di My List.'
                    : 'Belum ada ${mediaType!.toLowerCase()} di My List.',
                style: const TextStyle(color: _muted, fontSize: 15),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
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
            },
          );
        },
      ),
    );
  }
}
