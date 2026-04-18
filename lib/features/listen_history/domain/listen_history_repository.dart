import "listen_session.dart";

abstract interface class ListenHistoryRepository {
  Stream<List<ListenSession>> watchSessions(String uid, {int limit});

  Future<void> saveSession(String uid, ListenSessionDraft draft);
}
