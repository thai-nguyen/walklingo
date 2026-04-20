/// Chapter trong `books/{bookId}/chapters/{chapterId}`.
class LibrivoxBookChapter {
  const LibrivoxBookChapter({
    required this.id,
    required this.title,
    required this.audioUrl,
  });

  final String id;
  final String title;
  final String audioUrl;
}
