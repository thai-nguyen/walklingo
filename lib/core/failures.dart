sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class FirestoreFailure extends Failure {
  const FirestoreFailure(super.message);
}

final class AudioFailure extends Failure {
  const AudioFailure(super.message);
}

final class TrackingFailure extends Failure {
  const TrackingFailure(super.message);
}
