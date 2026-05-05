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
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in aborted');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
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
