import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart" as fb;

import "../domain/librivox_chapter.dart";
import "../domain/librivox_sync_repository.dart";
import "librivox_api_client.dart";
import "rss_chapter_parser.dart";

/// Đồng bộ LibriVox → Firestore collection `books` / subcollection `chapters`.
class FirestoreLibrivoxSyncRepository implements LibrivoxSyncRepository {
  FirestoreLibrivoxSyncRepository({
    required FirebaseFirestore firestore,
    required fb.FirebaseAuth auth,
    required LibrivoxApiClient apiClient,
    required RssChapterParser rssParser,
  })  : _firestore = firestore,
        _auth = auth,
        _api = apiClient,
        _rss = rssParser;

  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;
  final LibrivoxApiClient _api;
  final RssChapterParser _rss;

  CollectionReference<Map<String, dynamic>> get _books =>
      _firestore.collection("books");

  @override
  Future<LibrivoxSyncResult> syncLatest({required int maxBooks}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError("User must be signed in to sync LibriVox data.");
    }

    final maps = await _api.fetchAudiobookMaps(limit: maxBooks);
    var skipped = 0;
    var written = 0;
    var chaptersTotal = 0;

    for (final map in maps) {
      final id = LibrivoxApiClient.extractBookId(map);
      if (id == null || id.isEmpty) {
        // ignore: avoid_print
        print("[LibrivoxSync] skip book without id");
        continue;
      }

      final bookRef = _books.doc(id);
      final existing = await bookRef.get();
      if (existing.exists) {
        // ignore: avoid_print
        print("[LibrivoxSync] skip existing book id=$id");
        skipped++;
        continue;
      }

      final title = LibrivoxApiClient.extractTitle(map);
      final author = LibrivoxApiClient.extractAuthor(map);
      final rssUrl = LibrivoxApiClient.extractUrlRss(map);
      final textUrl = LibrivoxApiClient.extractUrlTextSource(map);

      List<LibrivoxChapter> chapters;
      try {
        chapters = await _rss.fetchChapters(rssUrl);
      } catch (e, st) {
        // ignore: avoid_print
        print("[LibrivoxSync] RSS failed for book $id: $e\n$st");
        continue;
      }

      await _writeBookAndChapters(
        bookRef: bookRef,
        title: title,
        author: author,
        textUrl: textUrl,
        chapters: chapters,
      );

      written++;
      chaptersTotal += chapters.length;
    }

    return LibrivoxSyncResult(
      booksSkippedExisting: skipped,
      booksWritten: written,
      totalChaptersWritten: chaptersTotal,
    );
  }

  /// Ghi book + chapters theo chunk để không vượt giới hạn batch (500).
  Future<void> _writeBookAndChapters({
    required DocumentReference<Map<String, dynamic>> bookRef,
    required String title,
    required String author,
    required String textUrl,
    required List<LibrivoxChapter> chapters,
  }) async {
    await bookRef.set({
      "title": title,
      "author": author,
      "textUrl": textUrl,
      "createdAt": FieldValue.serverTimestamp(),
    });

    const maxOpsPerBatch = 450;
    var batch = _firestore.batch();
    var ops = 0;

    for (var i = 0; i < chapters.length; i++) {
      final ch = chapters[i];
      final chapterId = "c_${i.toString().padLeft(4, "0")}";
      final chapterRef = bookRef.collection("chapters").doc(chapterId);

      batch.set(chapterRef, {
        "title": ch.title,
        "audioUrl": ch.audioUrl,
      });
      ops++;

      if (ops >= maxOpsPerBatch) {
        await batch.commit();
        // ignore: avoid_print
        print("[LibrivoxSync] committed batch ($ops chapter ops)");
        batch = _firestore.batch();
        ops = 0;
      }
    }

    if (ops > 0) {
      await batch.commit();
    }

    // ignore: avoid_print
    print("[LibrivoxSync] wrote book ${bookRef.id} with ${chapters.length} chapters");
  }
}
