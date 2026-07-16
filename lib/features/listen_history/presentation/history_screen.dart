import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "daily_history_summary.dart";
import "listen_history_providers.dart";

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat.yMMMMd(locale);
    final sessionsAsync = ref.watch(listenSessionsProvider);
    final plansAsync = ref.watch(dailyPlansRawByDateProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyByDayTitle)),
      body: sessionsAsync.when(
        data: (sessions) {
          final plans = plansAsync.valueOrNull ?? const <String, Map<String, dynamic>>{};
          final summaries = aggregateByDay(
            sessions: sessions,
            plansByDate: plans,
          );

          if (summaries.isEmpty) {
            return Center(
              child: Text(
                l10n.noHistoryData,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: summaries.length,
            itemBuilder: (context, i) {
              final s = summaries[i];
              final day = DateTime.tryParse("${s.dateKey} 00:00:00");
              return Card(
                child: ListTile(
                  onTap: () => context.push("/history/day/${s.dateKey}"),
                  title: Text(day != null ? dateFmt.format(day) : s.dateKey),
                  subtitle: Text(
                    l10n.historyDaySummary(
                      s.learnedWords,
                      s.steps,
                      s.kcal.toStringAsFixed(1),
                      s.tracks,
                      s.percentComplete,
                      s.completedCount,
                      s.totalCount,
                    ),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError(e.toString()))),
      ),
    );
  }
}
