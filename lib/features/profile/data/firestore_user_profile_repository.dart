import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/user_profile.dart";
import "../domain/user_profile_repository.dart";

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection("users").doc(uid);

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _doc(uid).get();
    final data = snap.data();
    if (!snap.exists || data == null) {
      return UserProfile(uid: uid);
    }
    return UserProfile(
      uid: uid,
      displayName: data["displayName"] as String?,
      weightKg: (data["weightKg"] as num?)?.toDouble(),
      heightCm: (data["heightCm"] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _doc(profile.uid).set(
      {
        "displayName": profile.displayName,
        "weightKg": profile.weightKg,
        "heightCm": profile.heightCm,
        "updatedAt": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
