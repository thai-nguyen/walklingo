/// Một chapter sau khi parse RSS (LibriVox item ~ một file MP3).
class LibrivoxChapter {
  const LibrivoxChapter({
    required this.title,
    required this.audioUrl,
  });

  final String title;
  final String audioUrl;
}
