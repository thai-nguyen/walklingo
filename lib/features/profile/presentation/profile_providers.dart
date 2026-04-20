import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase_providers.dart";
import "../../auth/presentation/auth_providers.dart";
import "../data/firestore_user_profile_repository.dart";
import "../domain/user_profile.dart";
import "../domain/user_profile_repository.dart";

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return FirestoreUserProfileRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(userProfileRepositoryProvider).getProfile(user.id);
    },
    loading: () async => null,
    error: (error, stackTrace) async => null,
  );
});
