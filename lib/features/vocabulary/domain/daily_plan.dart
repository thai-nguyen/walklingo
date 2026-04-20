import "daily_plan_targets.dart";
import "daily_todo_item.dart";

class DailyPlan {
  const DailyPlan({
    required this.dateKey,
    required this.targets,
    required this.items,
    required this.percentComplete,
    required this.completedCount,
    required this.totalCount,
  });

  final String dateKey;
  final DailyPlanTargets targets;
  final List<DailyTodoItem> items;
  final int percentComplete;
  final int completedCount;
  final int totalCount;

  static int computePercent(int completed, int total) {
    if (total <= 0) return 0;
    return ((completed / total) * 100).round().clamp(0, 100);
  }

  static (int completed, int total) countProgress(List<DailyTodoItem> items) {
    final total = items.length;
    final done = items.where((e) => e.completed).length;
    return (done, total);
  }

  DailyPlan recalculate() {
    final (c, t) = countProgress(items);
    final p = computePercent(c, t);
    return DailyPlan(
      dateKey: dateKey,
      targets: targets,
      items: items,
      percentComplete: p,
      completedCount: c,
      totalCount: t,
    );
  }

  Map<String, dynamic> toFirestore() => {
    "dateKey": dateKey,
    "targets": targets.toJson(),
    "items": items.map((e) => e.toJson()).toList(),
    "percentComplete": percentComplete,
    "completedCount": completedCount,
    "totalCount": totalCount,
  };

  static DailyPlan fromFirestore(String dateKey, Map<String, dynamic> d) {
    final raw = d["items"] as List<dynamic>? ?? [];
    final items = raw
        .map((e) => DailyTodoItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final plan = DailyPlan(
      dateKey: d["dateKey"] as String? ?? dateKey,
      targets: DailyPlanTargets.fromJson(
        Map<String, dynamic>.from(d["targets"] as Map? ?? {}),
      ),
      items: items,
      percentComplete: (d["percentComplete"] as num?)?.toInt() ?? 0,
      completedCount: (d["completedCount"] as num?)?.toInt() ?? 0,
      totalCount: (d["totalCount"] as num?)?.toInt() ?? 0,
    );
    return plan.recalculate();
  }
}
