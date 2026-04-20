/// Sách đồng bộ từ LibriVox (`books/{bookId}`).
class LibrivoxBook {
  const LibrivoxBook({
    required this.id,
    required this.title,
    required this.author,
    required this.textUrl,
  });

  final String id;
  final String title;
  final String author;
  final String textUrl;
}
