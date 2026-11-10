import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final AuthController _controller = AuthController(
    repository: AuthRepository(service: AuthService()),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _controller.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const LoginPage();
        }

        return snapshot.data == null ? const LoginPage() : const HomePage();
      },
    );
  }
}
