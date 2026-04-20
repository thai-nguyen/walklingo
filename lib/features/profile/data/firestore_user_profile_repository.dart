import "dart:typed_data";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

import "../domain/user_profile.dart";
import "../domain/user_profile_repository.dart";

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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
      avatarUrl: data["avatarUrl"] as String?,
      age: (data["age"] as num?)?.toInt(),
      gender: data["gender"] as String?,
      weightKg: (data["weightKg"] as num?)?.toDouble(),
      heightCm: (data["heightCm"] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _doc(profile.uid).set(
      {
        "displayName": profile.displayName,
        "avatarUrl": profile.avatarUrl,
        "age": profile.age,
        "gender": profile.gender,
        "weightKg": profile.weightKg,
        "heightCm": profile.heightCm,
        "updatedAt": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<String> uploadAvatar({
    required String uid,
    required List<int> bytes,
    required String contentType,
  }) async {
    final ref = _storage.ref().child("users/$uid/avatar.jpg");
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
  }
}
