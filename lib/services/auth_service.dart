import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Akun berhasil dibuat, tetapi data pengguna tidak ditemukan.',
      );
    }

    await user.updateDisplayName(username.trim());
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'username': username.trim(),
      'email': email.trim(),
      'photoUrl': user.photoURL,
      'provider': 'password',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..setCustomParameters({'prompt': 'select_account'});

    final credential = await _auth.signInWithPopup(provider);
    final user = credential.user;

    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();
      await userDoc.set({
        'uid': user.uid,
        'username': user.displayName ?? 'Pengguna MYDVAN',
        'email': user.email,
        'photoUrl': user.photoURL,
        'provider': 'google',
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();
}
