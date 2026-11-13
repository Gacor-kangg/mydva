import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/my_list_entry.dart';

/// Akses Firestore untuk My List: users/{uid}/mylist/{mediaKey}
class MyListService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  MyListService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  String _requireUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-signed-in',
        message: 'Silakan login terlebih dahulu.',
      );
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('mylist');

  /// Mengambil satu entry, atau null jika judul belum ada di My List.
  Future<MyListEntry?> get(String mediaKey) async {
    final uid = _requireUid();
    final snapshot = await _collection(uid).doc(mediaKey).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return MyListEntry.fromMap(data, id: snapshot.id);
  }

  /// Membuat atau memperbarui entry. addedAt hanya diisi saat pertama dibuat.
  Future<void> save(MyListEntry entry) async {
    final uid = _requireUid();
    final ref = _collection(uid).doc(entry.mediaKey);
    final existing = await ref.get();

    await ref.set({
      ...entry.toMap(),
      if (!existing.exists) 'addedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> remove(String mediaKey) async {
    final uid = _requireUid();
    await _collection(uid).doc(mediaKey).delete();
  }

  /// Seluruh My List user, terbaru diperbarui di atas (dipakai langkah 3-4).
  Stream<List<MyListEntry>> watchAll() {
    final uid = _requireUid();
    return _collection(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => MyListEntry.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }
}
