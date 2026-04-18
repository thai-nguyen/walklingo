import "audio_episode.dart";

abstract interface class EpisodeCatalogRepository {
  Stream<List<AudioEpisode>> watchEpisodes();

  Future<AudioEpisode?> getEpisode(String id);
}
