import "package:cloud_firestore/cloud_firestore.dart";
import "package:uuid/uuid.dart";

import "../domain/listen_history_repository.dart";
import "../domain/listen_session.dart";

class FirestoreListenHistoryRepository implements ListenHistoryRepository {
  FirestoreListenHistoryRepository(this._firestore);

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _sessions(String uid) {
    return _firestore.collection("users").doc(uid).collection("listen_sessions");
  }

  @override
  Stream<List<ListenSession>> watchSessions(String uid, {int limit = 50}) {
    return _sessions(uid)
        .orderBy("endedAt", descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  ListenSession _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final started = (d["startedAt"] as Timestamp?)?.toDate() ?? DateTime.now();
    final ended = (d["endedAt"] as Timestamp?)?.toDate() ?? DateTime.now();
    return ListenSession(
      id: doc.id,
      episodeId: d["episodeId"] as String? ?? "",
      episodeTitleSnapshot: d["episodeTitleSnapshot"] as String? ?? "",
      streamUrlSnapshot: d["streamUrlSnapshot"] as String? ?? "",
      startedAt: started,
      endedAt: ended,
      listenedSeconds: (d["listenedSeconds"] as num?)?.toInt() ?? 0,
      stepsDelta: (d["stepsDelta"] as num?)?.toInt(),
      estimatedKcal: (d["estimatedKcal"] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> saveSession(String uid, ListenSessionDraft draft) async {
    final id = _uuid.v4();
    await _sessions(uid).doc(id).set({
      "episodeId": draft.episodeId,
      "episodeTitleSnapshot": draft.episodeTitleSnapshot,
      "streamUrlSnapshot": draft.streamUrlSnapshot,
      "startedAt": Timestamp.fromDate(draft.startedAt),
      "endedAt": Timestamp.fromDate(draft.endedAt),
      "listenedSeconds": draft.listenedSeconds,
      "stepsDelta": draft.stepsDelta,
      "estimatedKcal": draft.estimatedKcal,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
