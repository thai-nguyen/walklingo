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
