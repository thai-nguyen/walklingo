import "daily_todo_kind.dart";

class DailyTodoItem {
  const DailyTodoItem({
    required this.id,
    required this.kind,
    this.lemma,
    this.phonetic,
    this.definitionPreview,
    this.trackIds,
    this.trackTitles,
    this.trackUrls,
    this.completed = false,
    this.completedAt,
  });

  final String id;
  final DailyTodoKind kind;
  final String? lemma;
  final String? phonetic;
  final String? definitionPreview;
  final List<String>? trackIds;
  final List<String>? trackTitles;
  final List<String>? trackUrls;
  final bool completed;
  final DateTime? completedAt;

  DailyTodoItem copyWith({bool? completed, DateTime? completedAt}) {
    return DailyTodoItem(
      id: id,
      kind: kind,
      lemma: lemma,
      phonetic: phonetic,
      definitionPreview: definitionPreview,
      trackIds: trackIds,
      trackTitles: trackTitles,
      trackUrls: trackUrls,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "kind": dailyTodoKindToJson(kind),
    if (lemma != null) "lemma": lemma,
    if (phonetic != null) "phonetic": phonetic,
    if (definitionPreview != null) "definitionPreview": definitionPreview,
    if (trackIds != null) "trackIds": trackIds,
    if (trackTitles != null) "trackTitles": trackTitles,
    if (trackUrls != null) "trackUrls": trackUrls,
    "completed": completed,
    if (completedAt != null) "completedAt": completedAt!.millisecondsSinceEpoch,
  };

  static DailyTodoItem fromJson(Map<String, dynamic> m) {
    DateTime? at;
    final ms = m["completedAt"];
    if (ms is int) at = DateTime.fromMillisecondsSinceEpoch(ms);
    if (ms is num) at = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
    return DailyTodoItem(
      id: m["id"] as String? ?? "",
      kind: dailyTodoKindFromJson(m["kind"] as String? ?? "newWord"),
      lemma: m["lemma"] as String?,
      phonetic: m["phonetic"] as String?,
      definitionPreview: m["definitionPreview"] as String?,
      trackIds: (m["trackIds"] as List?)?.map((e) => "$e").toList(),
      trackTitles: (m["trackTitles"] as List?)?.map((e) => "$e").toList(),
      trackUrls: (m["trackUrls"] as List?)?.map((e) => "$e").toList(),
      completed: m["completed"] as bool? ?? false,
      completedAt: at,
    );
  }
}
