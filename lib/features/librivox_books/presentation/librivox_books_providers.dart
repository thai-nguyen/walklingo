import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase_providers.dart";
import "../data/firestore_librivox_books_repository.dart";
import "../domain/librivox_book.dart";
import "../domain/librivox_book_chapter.dart";
import "../domain/librivox_books_repository.dart";

final librivoxBooksRepositoryProvider = Provider<LibrivoxBooksRepository>((ref) {
  return FirestoreLibrivoxBooksRepository(ref.watch(firestoreProvider));
});

final librivoxBooksStreamProvider = StreamProvider<List<LibrivoxBook>>((ref) {
  return ref.watch(librivoxBooksRepositoryProvider).watchBooks();
});

/// Chi tiết một sách (document `books/{bookId}`).
final librivoxBookProvider =
    FutureProvider.family<LibrivoxBook?, String>((ref, bookId) async {
  final snap =
      await ref.watch(firestoreProvider).collection("books").doc(bookId).get();
  if (!snap.exists) return null;
  final m = snap.data()!;
  return LibrivoxBook(
    id: snap.id,
    title: (m["title"] as String?)?.trim().isNotEmpty == true
        ? m["title"] as String
        : "Untitled",
    author: (m["author"] as String?)?.trim() ?? "",
    textUrl: (m["textUrl"] as String?)?.trim() ?? "",
  );
});

final librivoxChaptersStreamProvider =
    StreamProvider.family<List<LibrivoxBookChapter>, String>((ref, bookId) {
  return ref.watch(librivoxBooksRepositoryProvider).watchChapters(bookId);
});
