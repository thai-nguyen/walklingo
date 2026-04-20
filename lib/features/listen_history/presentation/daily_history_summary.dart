import "../../vocabulary/domain/date_calendar.dart";
import "../domain/listen_session.dart";

class DailyHistorySummary {
  const DailyHistorySummary({
    required this.dateKey,
    required this.learnedWords,
    required this.steps,
    required this.kcal,
    required this.tracks,
    required this.percentComplete,
    required this.completedCount,
    required this.totalCount,
    required this.sessions,
    required this.todoItems,
  });

  final String dateKey;
  final int learnedWords;
  final int steps;
  final double kcal;
  final int tracks;
  final int percentComplete;
  final int completedCount;
  final int totalCount;
  final List<ListenSession> sessions;
  final List<Map<String, dynamic>> todoItems;
}

DailyHistorySummary buildDailyHistorySummary({
  required String dateKey,
  required List<ListenSession> sessions,
  required Map<String, dynamic>? planData,
}) {
  final plan = planData ?? const <String, dynamic>{};
  final items =
      ((plan["items"] as List?) ?? const []).whereType<Map>().map((e) {
    return Map<String, dynamic>.from(e);
  }).toList();
  final learnedWords = items
      .where((e) => e["kind"] == "newWord" && (e["completed"] as bool? ?? false))
      .length;
  final steps = sessions
      .map((e) => e.stepsDelta ?? 0)
      .fold<int>(0, (prev, n) => prev + n);
  final kcal = sessions
      .map((e) => e.estimatedKcal ?? 0)
      .fold<double>(0, (prev, n) => prev + n);
  final tracks = sessions.map((e) => e.episodeId).toSet().length;
  final percentComplete = (plan["percentComplete"] as num?)?.toInt() ?? 0;
  final completedCount = (plan["completedCount"] as num?)?.toInt() ?? 0;
  final totalCount = (plan["totalCount"] as num?)?.toInt() ?? 0;

  return DailyHistorySummary(
    dateKey: dateKey,
    learnedWords: learnedWords,
    steps: steps,
    kcal: kcal,
    tracks: tracks,
    percentComplete: percentComplete,
    completedCount: completedCount,
    totalCount: totalCount,
    sessions: sessions,
    todoItems: items,
  );
}

List<DailyHistorySummary> aggregateByDay({
  required List<ListenSession> sessions,
  required Map<String, Map<String, dynamic>> plansByDate,
}) {
  final byDate = <String, List<ListenSession>>{};
  for (final s in sessions) {
    final key = dateKeyFromDateTime(s.endedAt);
    byDate.putIfAbsent(key, () => []).add(s);
  }

  final allKeys = <String>{...byDate.keys, ...plansByDate.keys}.toList()
    ..sort((a, b) => b.compareTo(a));

  return allKeys
      .map(
        (key) => buildDailyHistorySummary(
          dateKey: key,
          sessions: byDate[key] ?? const [],
          planData: plansByDate[key],
        ),
      )
      .toList();
}
