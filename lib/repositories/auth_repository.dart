import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository({required AuthService service}) : _service = service;

  Stream<User?> authStateChanges() => _service.authStateChanges();

  User? get currentUser => _service.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _service.signIn(email: email, password: password);
  }

  Future<UserCredential> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _service.register(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() => _service.signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email) =>
      _service.sendPasswordResetEmail(email);

  Future<void> signOut() => _service.signOut();
}
