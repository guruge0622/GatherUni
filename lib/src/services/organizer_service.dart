import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/src/models/organizer_request.dart';

class OrganizerService {
  static final _col = FirebaseFirestore.instance.collection(
    'organizer_requests',
  );

  /// Submit a new organizer request. Returns the created document id.
  static Future<String> submitRequest(OrganizerRequest req) async {
    final docRef = await _col.add(req.toJson());
    return docRef.id;
  }

  /// Listen to a specific request's snapshot to get status updates (admin approval flow)
  static Stream<OrganizerRequest> watchRequest(String id) {
    return _col
        .doc(id)
        .snapshots()
        .map((snap) => OrganizerRequest.fromJson(snap.id, snap.data() ?? {}));
  }

  /// Stream requests with optional status filter and simple search on organization name or email.
  static Stream<List<OrganizerRequest>> streamRequests({
    String? status,
    String? query,
  }) {
    Query q = _col.orderBy('submittedAt', descending: true);
    if (status != null && status.isNotEmpty)
      q = q.where('status', isEqualTo: status);
    if (query != null && query.isNotEmpty) {
      // Firestore doesn't support contains; perform client-side filtering after snapshot.
      return q.snapshots().map((snap) {
        final list = snap.docs
            .map((d) => OrganizerRequest.fromJson(d.id, d.data()))
            .toList();
        final lower = query.toLowerCase();
        return list.where((r) {
          return r.organizationName.toLowerCase().contains(lower) ||
              r.email.toLowerCase().contains(lower);
        }).toList();
      });
    }
    return q.snapshots().map(
      (snap) => snap.docs
          .map((d) => OrganizerRequest.fromJson(d.id, d.data()))
          .toList(),
    );
  }

  /// Update status and optional metadata (e.g., rejection reason).
  static Future<void> updateStatus(
    String id,
    String status, {
    String? rejectionReason,
  }) async {
    final docRef = _col.doc(id);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) throw Exception('Request not found');

      final Map<String, dynamic> updateData = {
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
      };
      if (rejectionReason != null)
        updateData['rejectionReason'] = rejectionReason;

      tx.update(docRef, updateData);

      // If approved, promote the user to organizer role
      if (status == 'approved') {
        final data = snap.data() as Map<String, dynamic>?;
        final uid = data?['uid'] as String?;
        if (uid != null && uid.isNotEmpty) {
          final userRef = FirebaseFirestore.instance
              .collection('users')
              .doc(uid);
          tx.set(userRef, {'role': 'organizer'}, SetOptions(merge: true));
        }
      }
    });
  }

  /// Returns true when the current signed-in user is an organizer or admin
  static Future<bool> isOrganizer() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data == null) return false;
      final role = data['role'];
      return role == 'organizer' || role == 'admin';
    } catch (_) {
      return false;
    }
  }

  /// Returns true when the current signed-in user has role == 'admin' in /users/{uid}
  static Future<bool> isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data == null) return false;
      final role = data['role'];
      return role == 'admin';
    } catch (_) {
      return false;
    }
  }
}
