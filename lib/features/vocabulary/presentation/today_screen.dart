import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:table_calendar/table_calendar.dart";

import "../../auth/presentation/auth_providers.dart";
import "../../listen_history/presentation/listen_history_providers.dart";
import "../../tracking/presentation/walk_session_panel.dart";
import "../data/listen_track_counter.dart";
import "../domain/daily_plan.dart";
import "../domain/daily_todo_item.dart";
import "../domain/daily_todo_kind.dart";
import "../domain/date_calendar.dart";
import "daily_plan_setup_sheet.dart";
import "daily_quota_sync.dart";
import "today_steps_notifier.dart";
import "vocabulary_providers.dart";

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateChangesProvider);
    final selectedDay = ref.watch(selectedCalendarDateProvider);
    final dateKey = dateKeyFromDateTime(selectedDay);
    final planAsync = ref.watch(dailyPlanForSelectedDateProvider);
    final tracks = distinctEpisodeTracksForDay(
      ref.watch(listenSessionsProvider).valueOrNull ?? [],
      parseDateKeyToLocalDay(dateKey),
    );
    final stepsToday = ref.watch(todayStepsProvider);

    final isToday = isTodayDateKey(dateKey);
    final interactive = isToday && auth.valueOrNull != null;

    return Stack(
      children: [
        const DailyQuotaSync(),
        Scaffold(
          appBar: AppBar(
            title: const Text("Hôm nay"),
            actions: [
              IconButton(
                onPressed: () => showDailyPlanSetupSheet(context, ref),
                icon: const Icon(Icons.edit_calendar_outlined),
              ),
            ],
          ),

          body: auth.when(
            data: (user) {
              if (user == null) {
                return const Center(child: Text("Đăng nhập để dùng todo."));
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _ExpandableTodayCalendar(),
                  const SizedBox(height: 16),
                  if (isToday) const WalkSessionPanel(),
                  if (isToday) const SizedBox(height: 16),
                  planAsync.when(
                    data: (plan) {
                      if (plan == null) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              isToday
                                  ? "Chưa có todo. Nhấn «Thiết lập todo» để thêm từ và mục tiêu."
                                  : "Không có dữ liệu ngày này.",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        );
                      }
                      return _PlanBody(
                        plan: plan,
                        interactive: interactive,
                        tracksToday: tracks,
                        stepsToday: stepsToday,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text("$e"),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("$e")),
          ),
        ),
      ],
    );
  }
}

/// Lịch: mặc định cả tháng; thu gọn chỉ hiển thị **tuần** chứa ngày đang chọn.
class _ExpandableTodayCalendar extends ConsumerStatefulWidget {
  const _ExpandableTodayCalendar();

  @override
  ConsumerState<_ExpandableTodayCalendar> createState() =>
      _ExpandableTodayCalendarState();
}

class _ExpandableTodayCalendarState
    extends ConsumerState<_ExpandableTodayCalendar> {
  bool _expandedMonth = false;

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedCalendarDateProvider);
    final streak = ref.watch(completionStreakDaysProvider).valueOrNull ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Bạn đã duy trì được $streak ngày liên tục.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: _expandedMonth
                  ? "Thu gọn — chỉ tuần hiện tại"
                  : "Mở rộng — xem cả tháng",
              onPressed: () => setState(() => _expandedMonth = !_expandedMonth),
              icon: Icon(
                _expandedMonth ? Icons.unfold_less : Icons.unfold_more,
              ),
            ),
          ],
        ),
        TableCalendar<void>(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2040),
          focusedDay: selectedDay,
          calendarFormat: _expandedMonth
              ? CalendarFormat.month
              : CalendarFormat.week,
          availableCalendarFormats: const {
            CalendarFormat.month: "month",
            CalendarFormat.week: "week",
          },
          selectedDayPredicate: (d) => isSameDay(d, selectedDay),
          onDaySelected: (selected, focused) {
            ref.read(selectedCalendarDateProvider.notifier).state = DateTime(
              selected.year,
              selected.month,
              selected.day,
            );
          },
          headerStyle: const HeaderStyle(formatButtonVisible: false),
          formatAnimationDuration: const Duration(milliseconds: 280),
          calendarStyle: CalendarStyle(outsideDaysVisible: _expandedMonth),
        ),
      ],
    );
  }
}

class _PlanBody extends ConsumerWidget {
  const _PlanBody({
    required this.plan,
    required this.interactive,
    required this.tracksToday,
    required this.stepsToday,
  });

  final DailyPlan plan;
  final bool interactive;
  final int tracksToday;
  final int stepsToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "${plan.percentComplete}% hoàn thành (${plan.completedCount}/${plan.totalCount})",
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: plan.totalCount > 0
                ? plan.completedCount / plan.totalCount
                : 0,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 16),
        Text("Ôn tập", style: theme.textTheme.titleSmall),
        ...plan.items
            .where((i) => i.kind == DailyTodoKind.reviewOldWord)
            .map(
              (i) => _TodoTile(
                item: i,
                interactive: interactive,
                subtitleExtra: null,
              ),
            ),
        const SizedBox(height: 12),
        Text("Từ mới", style: theme.textTheme.titleSmall),
        ...plan.items
            .where((i) => i.kind == DailyTodoKind.newWord)
            .map(
              (i) => _TodoTile(
                item: i,
                interactive: interactive,
                subtitleExtra: null,
              ),
            ),
        const SizedBox(height: 12),
        Text("Audio & bước chân", style: theme.textTheme.titleSmall),
        ...plan.items
            .where(
              (i) =>
                  i.kind == DailyTodoKind.audioQuota ||
                  i.kind == DailyTodoKind.stepsQuota,
            )
            .map(
              (i) => _QuotaTile(
                item: i,
                plan: plan,
                tracksToday: tracksToday,
                stepsToday: stepsToday,
              ),
            ),
      ],
    );
  }
}

class _TodoTile extends ConsumerWidget {
  const _TodoTile({
    required this.item,
    required this.interactive,
    required this.subtitleExtra,
  });

  final DailyTodoItem item;
  final bool interactive;
  final String? subtitleExtra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateChangesProvider).valueOrNull?.id;
    final dk = dateKeyFromDateTime(ref.watch(selectedCalendarDateProvider));

    final trailing = interactive
        ? Checkbox(
            value: item.completed,
            onChanged: uid == null
                ? null
                : (v) async {
                    if (v == null) return;
                    await ref
                        .read(dailyPlanRepositoryProvider)
                        .updateTodoItemCompletion(uid, dk, item.id, v);
                    if (item.kind == DailyTodoKind.reviewOldWord && v) {
                      final lid = item.id.startsWith("review_")
                          ? item.id.substring("review_".length)
                          : item.lemma ?? "";
                      if (lid.isNotEmpty) {
                        await ref
                            .read(vocabularyRepositoryProvider)
                            .markReviewed(uid, lid);
                      }
                    }
                  },
          )
        : Icon(
            item.completed ? Icons.check_circle : Icons.circle_outlined,
            color: item.completed ? Colors.green : Colors.grey,
          );

    return Card(
      child: ListTile(
        title: Text(item.lemma ?? ""),
        subtitle: Text(() {
          final parts = <String>[];
          final p = item.phonetic;
          if (p != null) parts.add(p);
          final d = item.definitionPreview;
          if (d != null) {
            parts.add(d.length > 120 ? "${d.substring(0, 120)}…" : d);
          }
          final x = subtitleExtra;
          if (x != null) parts.add(x);
          return parts.join("\n");
        }()),
        isThreeLine: true,
        trailing: trailing,
      ),
    );
  }
}

class _QuotaTile extends StatelessWidget {
  const _QuotaTile({
    required this.item,
    required this.plan,
    required this.tracksToday,
    required this.stepsToday,
  });

  final DailyTodoItem item;
  final DailyPlan plan;
  final int tracksToday;
  final int stepsToday;

  @override
  Widget build(BuildContext context) {
    final t = plan.targets;
    late String subtitle;
    if (item.kind == DailyTodoKind.audioQuota) {
      subtitle =
          "Đã nghe $tracksToday / ${t.audioTrackGoal} track — tự hoàn thành khi đạt mục tiêu.";
    } else {
      subtitle =
          "Đã đi $stepsToday / ${t.stepGoal} bước — tự hoàn thành khi đạt mục tiêu.";
    }

    return Card(
      child: ListTile(
        leading: Icon(
          item.completed ? Icons.check_circle : Icons.pending_outlined,
          color: item.completed ? Colors.green : null,
        ),
        title: Text(
          item.kind == DailyTodoKind.audioQuota ? "Nghe audio" : "Đi bộ",
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
