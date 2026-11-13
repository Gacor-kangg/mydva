import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Informasi user yang sedang login (uid dan username).
class UserService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static const String fallbackUsername = 'Pengguna MYDVAN';

  String? get currentUid => _auth.currentUser?.uid;

  /// Username dari dokumen users/{uid}; jika tidak ada, pakai displayName
  /// Firebase Auth, lalu bagian depan email.
  Future<String> getCurrentUsername() async {
    final user = _auth.currentUser;
    if (user == null) return fallbackUsername;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final name = doc.data()?['username'];
      if (name is String && name.trim().isNotEmpty) return name.trim();
    } catch (_) {
      // Lanjut ke sumber cadangan di bawah.
    }

    final display = user.displayName;
    if (display != null && display.trim().isNotEmpty) return display.trim();

    final email = user.email;
    if (email != null && email.contains('@')) return email.split('@').first;

    return fallbackUsername;
  }
}
