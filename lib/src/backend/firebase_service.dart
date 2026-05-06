import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  final _auth = FirebaseAuth.instance;
  final _fs = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception('Google sign-in aborted');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Common cause on Android: missing SHA-1 in Firebase Console or outdated
      // google-services.json (no oauth_client entries). Provide actionable
      // guidance in the thrown exception to help the developer fix the setup.
      final msg = StringBuffer();
      msg.writeln('Google Sign-In failed: ${e.toString()}');
      msg.writeln(
        'If you are running on Android, ensure your app SHA-1 is added in the Firebase Console for the Android app package (applicationId).',
      );
      msg.writeln(
        'Then re-download the updated google-services.json or re-run `flutterfire configure` so the OAuth client entry is present.',
      );
      msg.writeln(
        'To get your debug SHA-1 run: cd android && ./gradlew signingReport (on Windows PowerShell: .\\gradlew signingReport)',
      );
      throw Exception(msg.toString());
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // User profile in Firestore under `users/{uid}`
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _fs.collection('users').doc(uid).get();
  }

  Future<Map<String, dynamic>?> fetchUserProfileMap(String uid) async {
    final doc = await _fs.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> setUserProfile(String uid, Map<String, dynamic> data) {
    return _fs.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // Events collection: `events` with `organizerId` field
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserEvents(String uid) {
    return _fs
        .collection('events')
        .where('organizerId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> fetchUserEventsOnce(String uid) async {
    final snap = await _fs
        .collection('events')
        .where('organizerId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<DocumentReference<Map<String, dynamic>>> createEvent(
    Map<String, dynamic> data,
  ) {
    return _fs.collection('events').add(data);
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) {
    return _fs.collection('events').doc(id).update(data);
  }

  Future<void> deleteEvent(String id) {
    return _fs.collection('events').doc(id).delete();
  }

  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    final upload = await ref.putFile(file);
    return upload.ref.getDownloadURL();
  }
}
