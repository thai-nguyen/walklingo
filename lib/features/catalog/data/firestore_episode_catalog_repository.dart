import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/audio_episode.dart";
import "../domain/episode_catalog_repository.dart";

class FirestoreEpisodeCatalogRepository implements EpisodeCatalogRepository {
  FirestoreEpisodeCatalogRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection("audio_episodes");

  @override
  Stream<List<AudioEpisode>> watchEpisodes() {
    return _col.orderBy("order").snapshots().map((snap) {
      return snap.docs.map(_fromDoc).whereType<AudioEpisode>().toList();
    });
  }

  @override
  Future<AudioEpisode?> getEpisode(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  AudioEpisode? _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;
    final streamUrl = data["streamUrl"] as String?;
    final title = data["title"] as String?;
    if (streamUrl == null || streamUrl.isEmpty || title == null) return null;

    DateTime? publishedAt;
    final ts = data["publishedAt"];
    if (ts is Timestamp) publishedAt = ts.toDate();

    return AudioEpisode(
      id: doc.id,
      title: title,
      description: data["description"] as String?,
      streamUrl: streamUrl,
      durationSec: (data["durationSec"] as num?)?.toInt(),
      sourceName: data["sourceName"] as String? ?? "Zapp! English",
      sourceUrl: data["sourceUrl"] as String? ?? "https://zappenglish.com/",
      publishedAt: publishedAt,
      order: (data["order"] as num?)?.toInt() ?? 0,
    );
  }
}
