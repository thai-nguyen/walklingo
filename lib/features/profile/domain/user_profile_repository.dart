import "user_profile.dart";

abstract interface class UserProfileRepository {
  Future<UserProfile?> getProfile(String uid);

  Future<void> saveProfile(UserProfile profile);

  Future<String> uploadAvatar({
    required String uid,
    required List<int> bytes,
    required String contentType,
  });
}
