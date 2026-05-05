import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState {
  AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _init() async {
    state = state.copyWith(status: AuthStatus.loading);
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel.fromMap(
            doc.data()!..putIfAbsent('uid', () => user.uid),
          ),
        );
        return;
      }
    }
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? degree,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(displayName);
      final user = UserModel(
        uid: cred.user!.uid,
        email: cred.user!.email,
        displayName: displayName,
        degree: degree,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(user.uid).set(user.toMap());
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on fb.FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _mapAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      final user = doc.exists
          ? UserModel.fromMap(
              doc.data()!..putIfAbsent('uid', () => cred.user!.uid),
            )
          : UserModel(uid: cred.user!.uid, email: cred.user!.email);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on fb.FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _mapAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Google sign-in cancelled',
        );
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      final docRef = _db.collection('users').doc(cred.user!.uid);
      final doc = await docRef.get();
      final user = UserModel(
        uid: cred.user!.uid,
        email: cred.user!.email,
        displayName: cred.user!.displayName,
        photoUrl: cred.user!.photoURL,
        createdAt: DateTime.now(),
      );
      if (!doc.exists) await docRef.set(user.toMap());
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on fb.FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _mapAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      state = state.copyWith(error: _mapAuthError(e));
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  String _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'email-already-in-use':
        return 'The email is already registered.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'Invalid authentication credential.';
      default:
        return e.message ?? 'Authentication error: ${e.code}';
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
