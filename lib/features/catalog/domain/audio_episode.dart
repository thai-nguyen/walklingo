class AudioEpisode {
  const AudioEpisode({
    required this.id,
    required this.title,
    this.description,
    required this.streamUrl,
    this.durationSec,
    required this.sourceName,
    required this.sourceUrl,
    this.publishedAt,
    required this.order,
  });

  final String id;
  final String title;
  final String? description;
  final String streamUrl;
  final int? durationSec;
  final String sourceName;
  final String sourceUrl;
  final DateTime? publishedAt;
  final int order;
}
