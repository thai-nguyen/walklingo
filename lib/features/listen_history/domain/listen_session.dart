class ListenSession {
  const ListenSession({
    required this.id,
    required this.episodeId,
    required this.episodeTitleSnapshot,
    required this.streamUrlSnapshot,
    required this.startedAt,
    required this.endedAt,
    required this.listenedSeconds,
    this.stepsDelta,
    this.estimatedKcal,
  });

  final String id;
  final String episodeId;
  final String episodeTitleSnapshot;
  final String streamUrlSnapshot;
  final DateTime startedAt;
  final DateTime endedAt;
  final int listenedSeconds;
  final int? stepsDelta;
  final double? estimatedKcal;
}

class ListenSessionDraft {
  const ListenSessionDraft({
    required this.episodeId,
    required this.episodeTitleSnapshot,
    required this.streamUrlSnapshot,
    required this.startedAt,
    required this.endedAt,
    required this.listenedSeconds,
    this.stepsDelta,
    this.estimatedKcal,
  });

  final String episodeId;
  final String episodeTitleSnapshot;
  final String streamUrlSnapshot;
  final DateTime startedAt;
  final DateTime endedAt;
  final int listenedSeconds;
  final int? stepsDelta;
  final double? estimatedKcal;
}
