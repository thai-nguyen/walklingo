import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/failures.dart";
import "../domain/learned_word.dart";
import "../domain/vocabulary_repository.dart";

class FirestoreVocabularyRepository implements VocabularyRepository {
  FirestoreVocabularyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection("users").doc(uid).collection("vocabulary");

  @override
  Stream<List<LearnedWord>> watchWords(String uid) {
    return _col(uid)
        .orderBy("learnedAt", descending: true)
        .limit(500)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  LearnedWord _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return LearnedWord(
      lemmaId: doc.id,
      lemma: d["lemma"] as String? ?? doc.id,
      sourceInput: d["sourceInput"] as String?,
      phonetic: d["phonetic"] as String?,
      pronunciationUrl: d["pronunciationUrl"] as String?,
      definitionPreview: d["definitionPreview"] as String?,
      examplePreview: d["examplePreview"] as String?,
      learnedAt: _readTime(d["learnedAt"]),
      lastReviewedAt: d["lastReviewedAt"] != null
          ? _readTime(d["lastReviewedAt"])
          : null,
    );
  }

  DateTime _readTime(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    return DateTime.now();
  }

  @override
  Future<List<LearnedWord>> fetchReviewCandidates(
    String uid, {
    int limit = 5,
  }) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final snap = await _col(uid)
        .where("learnedAt", isLessThan: Timestamp.fromDate(cutoff))
        .orderBy("learnedAt")
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> upsertWord(String uid, LearnedWord word) async {
    await _col(uid).doc(word.lemmaId).set({
      "lemma": word.lemma,
      if (word.sourceInput != null) "sourceInput": word.sourceInput,
      if (word.phonetic != null) "phonetic": word.phonetic,
      if (word.pronunciationUrl != null)
        "pronunciationUrl": word.pronunciationUrl,
      if (word.definitionPreview != null)
        "definitionPreview": word.definitionPreview,
      if (word.examplePreview != null) "examplePreview": word.examplePreview,
      "learnedAt": Timestamp.fromDate(word.learnedAt),
      if (word.lastReviewedAt != null)
        "lastReviewedAt": Timestamp.fromDate(word.lastReviewedAt!),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markReviewed(String uid, String lemmaId) async {
    try {
      await _col(uid).doc(lemmaId).update({
        "lastReviewedAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      Error.throwWithStackTrace(
        FirestoreFailure("Không cập nhật ôn tập: $e"),
        st,
      );
    }
  }
}
