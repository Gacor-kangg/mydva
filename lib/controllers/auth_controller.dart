import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class AuthController {
  final AuthRepository _repository;

  AuthController({required AuthRepository repository})
      : _repository = repository;

  Stream<User?> authStateChanges() => _repository.authStateChanges();

  User? get currentUser => _repository.currentUser;

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _repository.signIn(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (error) {
      return _messageFor(error);
    } catch (_) {
      return 'Terjadi kesalahan. Periksa koneksi internet lalu coba lagi.';
    }
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _repository.register(
        username: username,
        email: email,
        password: password,
      );
      // Pendaftaran tidak langsung membuka Home; pengguna diminta login.
      await _repository.signOut();
      return null;
    } on FirebaseAuthException catch (error) {
      return _messageFor(error);
    } catch (_) {
      return 'Akun dibuat, tetapi profil gagal disimpan. Coba masuk kembali.';
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await _repository.signInWithGoogle();
      return null;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'popup-closed-by-user' ||
          error.code == 'cancelled-popup-request') {
        return 'Login Google dibatalkan.';
      }
      return _messageFor(error);
    } catch (_) {
      return 'Login Google gagal. Periksa koneksi dan konfigurasi Firebase.';
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return null;
    } on FirebaseAuthException catch (error) {
      return _messageFor(error);
    } catch (_) {
      return 'Link reset password gagal dikirim. Coba lagi.';
    }
  }

  Future<void> signOut() => _repository.signOut();

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba beberapa saat lagi.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan di Firebase Console.';
      case 'account-exists-with-different-credential':
        return 'Email ini sudah terhubung dengan metode login lain.';
      default:
        return error.message ?? 'Autentikasi gagal. Silakan coba lagi.';
    }
  }
}
