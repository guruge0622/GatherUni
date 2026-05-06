import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/firebase_service.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  Stream<User?> authStateChanges() =>
      FirebaseService.instance.authStateChanges();

  User? get currentUser => FirebaseService.instance.currentUser;

  Future<UserCredential> signInWithGoogle() =>
      FirebaseService.instance.signInWithGoogle();

  Future<void> signOut() => FirebaseService.instance.signOut();
}
