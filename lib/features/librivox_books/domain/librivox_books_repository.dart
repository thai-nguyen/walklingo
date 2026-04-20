import "librivox_book.dart";
import "librivox_book_chapter.dart";

abstract interface class LibrivoxBooksRepository {
  Stream<List<LibrivoxBook>> watchBooks();

  Stream<List<LibrivoxBookChapter>> watchChapters(String bookId);
}
