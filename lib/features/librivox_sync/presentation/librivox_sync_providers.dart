import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:http/http.dart" as http;

import "../../../core/firebase_providers.dart";
import "../../auth/presentation/auth_providers.dart";
import "../data/firestore_librivox_sync_repository.dart";
import "../data/librivox_api_client.dart";
import "../data/rss_chapter_parser.dart";
import "../domain/librivox_sync_repository.dart";

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final librivoxApiClientProvider = Provider<LibrivoxApiClient>((ref) {
  return LibrivoxApiClient(ref.watch(httpClientProvider));
});

final rssChapterParserProvider = Provider<RssChapterParser>((ref) {
  return RssChapterParser(ref.watch(httpClientProvider));
});

final librivoxSyncRepositoryProvider = Provider<LibrivoxSyncRepository>((ref) {
  return FirestoreLibrivoxSyncRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
    apiClient: ref.watch(librivoxApiClientProvider),
    rssParser: ref.watch(rssChapterParserProvider),
  );
});
