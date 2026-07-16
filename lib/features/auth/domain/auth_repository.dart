import "app_user.dart";

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> reauthenticateWithPassword(String password);

  Future<void> deleteAccount();
}
