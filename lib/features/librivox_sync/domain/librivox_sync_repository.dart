/// Đồng bộ sách LibriVox vào Firestore (`books`, `chapters`).
abstract interface class LibrivoxSyncRepository {
  /// Đồng bộ tối đa [maxBooks] đầu tiên từ API; bỏ qua sách đã có document.
  Future<LibrivoxSyncResult> syncLatest({required int maxBooks});
}

class LibrivoxSyncResult {
  const LibrivoxSyncResult({
    required this.booksSkippedExisting,
    required this.booksWritten,
    required this.totalChaptersWritten,
  });

  final int booksSkippedExisting;
  final int booksWritten;
  final int totalChaptersWritten;
}
