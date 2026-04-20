import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase_providers.dart";
import "../../auth/presentation/auth_providers.dart";
import "../data/firestore_listen_history_repository.dart";
import "../domain/listen_history_repository.dart";
import "../domain/listen_session.dart";

final listenHistoryRepositoryProvider = Provider<ListenHistoryRepository>((ref) {
  return FirestoreListenHistoryRepository(ref.watch(firestoreProvider));
});

final listenSessionsProvider = StreamProvider<List<ListenSession>>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final repo = ref.watch(listenHistoryRepositoryProvider);
  return auth.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return repo.watchSessions(user.id);
    },
    loading: () => Stream.value([]),
    error: (error, stackTrace) => Stream.value([]),
  );
});

/// Dữ liệu plan theo ngày từ `users/{uid}/dailyPlans/{yyyyMMdd}`.
final dailyPlansRawByDateProvider =
    StreamProvider<Map<String, Map<String, dynamic>>>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final fs = ref.watch(firestoreProvider);
  return auth.when(
    data: (user) {
      if (user == null) return Stream.value(const {});
      return fs
          .collection("users")
          .doc(user.id)
          .collection("dailyPlans")
          .orderBy("dateKey", descending: true)
          .limit(365)
          .snapshots()
          .map((snap) {
        final out = <String, Map<String, dynamic>>{};
        for (final doc in snap.docs) {
          final d = doc.data();
          final key = d["dateKey"] as String?;
          if (key == null || key.isEmpty) continue;
          out[key] = _normalizePlanMap(d);
        }
        return out;
      });
    },
    loading: () => Stream.value(const {}),
    error: (error, stackTrace) => Stream.value(const {}),
  );
});

Map<String, dynamic> _normalizePlanMap(Map<String, dynamic> input) {
  final out = Map<String, dynamic>.from(input);
  final items = out["items"];
  if (items is List) {
    out["items"] = items.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final completedAt = m["completedAt"];
      if (completedAt is Timestamp) {
        m["completedAt"] = completedAt.millisecondsSinceEpoch;
      } else if (completedAt is DateTime) {
        m["completedAt"] = completedAt.millisecondsSinceEpoch;
      } else if (completedAt is num) {
        m["completedAt"] = completedAt.toInt();
      }
      return m;
    }).toList();
  }
  return out;
}
