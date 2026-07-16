import "package:firebase_auth/firebase_auth.dart" as fb;

import "../domain/app_user.dart";
import "../domain/auth_repository.dart";

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final fb.FirebaseAuth _auth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  AppUser? _mapUser(fb.User? u) {
    if (u == null) return null;
    return AppUser(id: u.uid, email: u.email, displayName: u.displayName);
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final u = cred.user;
    if (u == null) {
      throw StateError("signIn succeeded without user");
    }
    return _mapUser(u)!;
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final u = cred.user;
    if (u == null) {
      throw StateError("register succeeded without user");
    }
    return _mapUser(u)!;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw StateError("no_email_for_reauth");
    }
    final credential = fb.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError("not_signed_in");
    }
    await user.delete();
  }
}
