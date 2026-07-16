import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "daily_history_summary.dart";
import "listen_history_providers.dart";

class HistoryDayDetailScreen extends ConsumerWidget {
  const HistoryDayDetailScreen({super.key, required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final timeFmt = DateFormat.Hm(locale);
    final sessionsAsync = ref.watch(listenSessionsProvider);
    final plansAsync = ref.watch(dailyPlansRawByDateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyDayDetailTitle(dateKey))),
      body: sessionsAsync.when(
        data: (sessions) {
          final plans = plansAsync.valueOrNull ?? const <String, Map<String, dynamic>>{};
          final summary = buildDailyHistorySummary(
            dateKey: dateKey,
            sessions: sessions
                .where((e) =>
                    "${e.endedAt.year.toString().padLeft(4, "0")}-${e.endedAt.month.toString().padLeft(2, "0")}-${e.endedAt.day.toString().padLeft(2, "0")}" ==
                    dateKey)
                .toList(),
            planData: plans[dateKey],
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(summary: summary),
              const SizedBox(height: 12),
              Text(
                l10n.thatDayGoals,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (summary.todoItems.isEmpty)
                Card(
                  child: ListTile(title: Text(l10n.noTodoData)),
                )
              else
                ...summary.todoItems.map((item) {
                  final done = item["completed"] as bool? ?? false;
                  final lemma = item["lemma"] as String?;
                  final kind = item["kind"] as String? ?? "";
                  final title = lemma ??
                      switch (kind) {
                        "audioQuota" => l10n.quotaAudioTitle,
                        "stepsQuota" => l10n.quotaStepsTitle,
                        "reviewOldWord" => l10n.todoKindReview,
                        _ => l10n.todoKindNewWord,
                      };
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        done ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: done ? Colors.green : null,
                      ),
                      title: Text(title),
                      subtitle: Text(kind),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              Text(
                l10n.tracksListenedSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (summary.sessions.isEmpty)
                Card(
                  child: ListTile(title: Text(l10n.noTracksListened)),
                )
              else
                ...summary.sessions.map(
                  (s) => Card(
                    child: ListTile(
                      title: Text(s.episodeTitleSnapshot),
                      subtitle: Text(
                        l10n.sessionTimeRange(
                          timeFmt.format(s.startedAt),
                          timeFmt.format(s.endedAt),
                          s.listenedSeconds ~/ 60,
                          s.listenedSeconds % 60,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError(e.toString()))),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final DailyHistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Kpi(label: l10n.kpiWordsLearned, value: "${summary.learnedWords}"),
            _Kpi(label: l10n.kpiSteps, value: "${summary.steps}"),
            _Kpi(label: l10n.kpiCalories, value: summary.kcal.toStringAsFixed(1)),
            _Kpi(label: l10n.kpiTracks, value: "${summary.tracks}"),
            _Kpi(label: l10n.kpiPercentComplete, value: "${summary.percentComplete}%"),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
