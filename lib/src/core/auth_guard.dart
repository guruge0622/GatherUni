import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../src/backend/firebase_service.dart';
import '../../screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseService.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) return child;
        return const LoginScreen();
      },
    );
  }
}
