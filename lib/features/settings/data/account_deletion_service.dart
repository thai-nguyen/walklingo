import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

class AccountDeletionService {
  AccountDeletionService(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const _subcollections = [
    "vocabulary",
    "dailyPlans",
    "listen_sessions",
    "devices",
  ];

  Future<void> deleteAllUserData(String uid) async {
    for (final name in _subcollections) {
      await _deleteCollection(
        _firestore.collection("users").doc(uid).collection(name),
      );
    }
    await _firestore.collection("users").doc(uid).delete();
    try {
      await _storage.ref().child("users/$uid/avatar.jpg").delete();
    } catch (_) {
      // Avatar may not exist.
    }
  }

  Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> col) async {
    while (true) {
      final snap = await col.limit(450).get();
      if (snap.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
