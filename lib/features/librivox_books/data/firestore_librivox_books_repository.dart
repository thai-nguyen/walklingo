import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/librivox_book.dart";
import "../domain/librivox_book_chapter.dart";
import "../domain/librivox_books_repository.dart";

class FirestoreLibrivoxBooksRepository implements LibrivoxBooksRepository {
  FirestoreLibrivoxBooksRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _books =>
      _firestore.collection("books");

  @override
  Stream<List<LibrivoxBook>> watchBooks() {
    return _books.snapshots().map((snap) {
      final list = snap.docs.map(_bookFromDoc).toList();
      list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return list;
    });
  }

  LibrivoxBook _bookFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data();
    return LibrivoxBook(
      id: doc.id,
      title: (m["title"] as String?)?.trim().isNotEmpty == true
          ? m["title"] as String
          : "Untitled",
      author: (m["author"] as String?)?.trim() ?? "",
      textUrl: (m["textUrl"] as String?)?.trim() ?? "",
    );
  }

  @override
  Stream<List<LibrivoxBookChapter>> watchChapters(String bookId) {
    return _books
        .doc(bookId)
        .collection("chapters")
        .orderBy(FieldPath.documentId)
        .snapshots()
        .map((snap) => snap.docs.map(_chapterFromDoc).toList());
  }

  LibrivoxBookChapter _chapterFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data();
    return LibrivoxBookChapter(
      id: doc.id,
      title: (m["title"] as String?)?.trim().isNotEmpty == true
          ? m["title"] as String
          : doc.id,
      audioUrl: (m["audioUrl"] as String?)?.trim() ?? "",
    );
  }
}
