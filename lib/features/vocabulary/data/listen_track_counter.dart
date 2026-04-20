import "../../listen_history/domain/listen_session.dart";

/// Đếm **số episode/track khác nhau** đã có session kết thúc trong ngày [dayLocal].
int distinctEpisodeTracksForDay(
  List<ListenSession> sessions,
  DateTime dayLocal,
) {
  final start = DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
  final end = start.add(const Duration(days: 1));
  final ids = <String>{};
  for (final s in sessions) {
    final e = s.endedAt;
    if (!e.isBefore(start) && e.isBefore(end) && s.episodeId.isNotEmpty) {
      ids.add(s.episodeId);
    }
  }
  return ids.length;
}
