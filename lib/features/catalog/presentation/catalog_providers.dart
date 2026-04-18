import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase_providers.dart";
import "../data/firestore_episode_catalog_repository.dart";
import "../domain/episode_catalog_repository.dart";

final episodeCatalogRepositoryProvider = Provider<EpisodeCatalogRepository>((ref) {
  return FirestoreEpisodeCatalogRepository(ref.watch(firestoreProvider));
});
