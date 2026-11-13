import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/media_model.dart';
import '../models/my_list_entry.dart';
import '../repositories/my_list_repository.dart';

class MyListController {
  final MyListRepository _repository;

  MyListController({required MyListRepository repository})
    : _repository = repository;

  /// Memuat entry milik user untuk media ini. Null jika belum disimpan
  /// atau jika pemuatan gagal (pesan error dikembalikan lewat [onError]).
  Future<MyListEntry?> load(
    MediaModel media, {
    void Function(String message)? onError,
  }) async {
    try {
      return await _repository.getEntry(media);
    } catch (error) {
      onError?.call(_messageFor(error));
      return null;
    }
  }

  /// Mengembalikan null jika berhasil, atau pesan error.
  Future<String?> save({
    required MediaModel media,
    required String status,
    int? score,
    int progress = 0,
    int? totalEpisodes,
  }) async {
    try {
      final isFilm = media.mediaType == 'Film';
      await _repository.saveEntry(
        MyListEntry.fromMedia(
          media,
          status: status,
          score: score,
          // Film tidak punya progress episode.
          progress: isFilm ? 0 : progress,
          totalEpisodes: isFilm ? null : totalEpisodes,
        ),
      );
      return null;
    } catch (error) {
      return _messageFor(error);
    }
  }

  /// Mengembalikan null jika berhasil, atau pesan error.
  Future<String?> remove(MediaModel media) async {
    try {
      await _repository.removeEntry(media);
      return null;
    } catch (error) {
      return _messageFor(error);
    }
  }

  String _messageFor(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? 'Silakan login terlebih dahulu.';
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Tidak punya izin menyimpan. Periksa aturan Firestore.';
        case 'unavailable':
          return 'Koneksi bermasalah. Coba lagi.';
      }
    }
    return 'Terjadi kesalahan saat mengakses My List.';
  }
}
