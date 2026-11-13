import 'package:cloud_firestore/cloud_firestore.dart';

import 'media_model.dart';

/// Status tontonan yang dipakai di My List.
class MyListStatus {
  MyListStatus._();

  static const String watching = 'Watching';
  static const String completed = 'Completed';
  static const String onHold = 'On-Hold';
  static const String dropped = 'Dropped';
  static const String planToWatch = 'Plan to Watch';

  static const List<String> all = [
    watching,
    completed,
    onHold,
    dropped,
    planToWatch,
  ];
}

/// Satu judul di My List milik satu user.
///
/// Disimpan di: users/{uid}/mylist/{mediaKey}
class MyListEntry {
  final String mediaKey;
  final String? externalId;
  final String source;
  final String mediaType;
  final String title;
  final String imageUrl;
  final int? releaseYear;

  final String status;
  final int? score; // 1-10, null = belum diberi skor
  final int progress; // episode yang sudah ditonton (Film selalu 0)
  final int? totalEpisodes;

  final DateTime? addedAt;
  final DateTime? updatedAt;

  const MyListEntry({
    required this.mediaKey,
    required this.source,
    required this.mediaType,
    required this.title,
    required this.imageUrl,
    required this.status,
    this.externalId,
    this.releaseYear,
    this.score,
    this.progress = 0,
    this.totalEpisodes,
    this.addedAt,
    this.updatedAt,
  });

  /// Membuat entry baru dari media yang sedang dibuka.
  factory MyListEntry.fromMedia(
    MediaModel media, {
    required String status,
    int? score,
    int progress = 0,
    int? totalEpisodes,
  }) {
    return MyListEntry(
      mediaKey: media.mediaKey,
      externalId: media.externalId,
      source: media.source,
      mediaType: media.mediaType,
      title: media.title,
      imageUrl: media.imageUrl,
      releaseYear: media.releaseYear,
      status: status,
      score: score,
      progress: progress,
      totalEpisodes: totalEpisodes,
    );
  }

  factory MyListEntry.fromMap(Map<String, dynamic> data, {String? id}) {
    return MyListEntry(
      mediaKey: (data['mediaKey'] ?? id ?? '').toString(),
      externalId: data['externalId']?.toString(),
      source: (data['source'] ?? '').toString(),
      mediaType: (data['mediaType'] ?? 'Film').toString(),
      title: (data['title'] ?? 'Untitled').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      releaseYear: (data['releaseYear'] as num?)?.toInt(),
      status: (data['status'] ?? MyListStatus.planToWatch).toString(),
      score: (data['score'] as num?)?.toInt(),
      progress: (data['progress'] as num?)?.toInt() ?? 0,
      totalEpisodes: (data['totalEpisodes'] as num?)?.toInt(),
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Data yang ditulis ke Firestore. addedAt/updatedAt diisi oleh service.
  Map<String, dynamic> toMap() {
    return {
      'mediaKey': mediaKey,
      'externalId': externalId,
      'source': source,
      'mediaType': mediaType,
      'title': title,
      'imageUrl': imageUrl,
      'releaseYear': releaseYear,
      'status': status,
      'score': score,
      'progress': progress,
      'totalEpisodes': totalEpisodes,
    };
  }
}
