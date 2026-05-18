import "learned_word.dart";

abstract class VocabularyRepository {
  Stream<List<LearnedWord>> watchWords(String uid);

  Future<List<LearnedWord>> fetchReviewCandidates(String uid, {int limit = 5});

  Future<void> upsertWord(String uid, LearnedWord word);

  Future<void> markReviewed(String uid, String lemmaId);

  /// Gỡ trạng thái đã ôn (xóa `lastReviewedAt`) khi user bỏ tick một todo ôn.
  Future<void> unmarkReviewed(String uid, String lemmaId);
}
