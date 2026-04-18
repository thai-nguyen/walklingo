import "package:firebase_auth/firebase_auth.dart" as fb;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/firebase_auth_repository.dart";
import "../domain/app_user.dart";
import "../domain/auth_repository.dart";

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
