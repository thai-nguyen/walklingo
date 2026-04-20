import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";

import "../../listen_history/presentation/daily_history_summary.dart";
import "../../listen_history/presentation/listen_history_providers.dart";

enum ProgressPeriod { day, week, month }

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  ProgressPeriod _period = ProgressPeriod.day;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(listenSessionsProvider);
    final plansAsync = ref.watch(dailyPlansRawByDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tiến độ"),
        actions: [
          TextButton.icon(
            onPressed: () => context.push("/history"),
            icon: const Icon(Icons.history),
            label: const Text("Lịch sử"),
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          final plans =
              plansAsync.valueOrNull ?? const <String, Map<String, dynamic>>{};
          final dayData = aggregateByDay(sessions: sessions, plansByDate: plans);
          if (dayData.isEmpty) {
            return Center(
              child: Text(
                "Chưa có dữ liệu để vẽ biểu đồ tiến độ.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final grouped = _groupByPeriod(dayData, _period);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<ProgressPeriod>(
                segments: const [
                  ButtonSegment(value: ProgressPeriod.day, label: Text("Ngày")),
                  ButtonSegment(
                    value: ProgressPeriod.week,
                    label: Text("Tuần"),
                  ),
                  ButtonSegment(
                    value: ProgressPeriod.month,
                    label: Text("Tháng"),
                  ),
                ],
                selected: {_period},
                onSelectionChanged: (v) => setState(() => _period = v.first),
              ),
              const SizedBox(height: 16),
              _MetricChartCard(
                title: "Số từ đã học",
                values: grouped.map((e) => e.learnedWords.toDouble()).toList(),
                labels: grouped.map((e) => e.label).toList(),
                color: Colors.blue,
              ),
              _MetricChartCard(
                title: "Số track đã nghe",
                values: grouped.map((e) => e.tracks.toDouble()).toList(),
                labels: grouped.map((e) => e.label).toList(),
                color: Colors.deepPurple,
              ),
              _MetricChartCard(
                title: "Số bước chân",
                values: grouped.map((e) => e.steps.toDouble()).toList(),
                labels: grouped.map((e) => e.label).toList(),
                color: Colors.green,
              ),
              _MetricChartCard(
                title: "Số kcal",
                values: grouped.map((e) => e.kcal).toList(),
                labels: grouped.map((e) => e.label).toList(),
                color: Colors.orange,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }
}

class _MetricChartCard extends StatelessWidget {
  const _MetricChartCard({
    required this.title,
    required this.values,
    required this.labels,
    required this.color,
  });

  final String title;
  final List<double> values;
  final List<String> labels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final points = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      points.add(FlSpot(i.toDouble(), values[i]));
    }
    final maxY = values.isEmpty ? 1.0 : (values.reduce((a, b) => a > b ? a : b) * 1.15 + 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  lineTouchData: LineTouchData(enabled: true),
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (labels.length / 4).clamp(1, 10).toDouble(),
                        getTitlesWidget: (value, meta) {
                          final i = value.round();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[i],
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedMetric {
  const _GroupedMetric({
    required this.sortKey,
    required this.label,
    required this.learnedWords,
    required this.tracks,
    required this.steps,
    required this.kcal,
  });

  final int sortKey;
  final String label;
  final int learnedWords;
  final int tracks;
  final int steps;
  final double kcal;
}

List<_GroupedMetric> _groupByPeriod(
  List<DailyHistorySummary> dayData,
  ProgressPeriod period,
) {
  final map = <String, _GroupedMetric>{};
  for (final d in dayData) {
    final day = DateTime.parse("${d.dateKey} 00:00:00");
    final (key, sortKey) = switch (period) {
      ProgressPeriod.day => (
          DateFormat("dd/MM").format(day),
          day.millisecondsSinceEpoch,
        ),
      ProgressPeriod.week => _weekKey(day),
      ProgressPeriod.month => (
          DateFormat("MM/yyyy").format(day),
          DateTime(day.year, day.month, 1).millisecondsSinceEpoch,
        ),
    };
    final prev = map[key];
    map[key] = _GroupedMetric(
      sortKey: sortKey,
      label: key,
      learnedWords: (prev?.learnedWords ?? 0) + d.learnedWords,
      tracks: (prev?.tracks ?? 0) + d.tracks,
      steps: (prev?.steps ?? 0) + d.steps,
      kcal: (prev?.kcal ?? 0) + d.kcal,
    );
  }
  final list = map.values.toList();
  list.sort((a, b) => a.sortKey.compareTo(b.sortKey));
  return list;
}

(String, int) _weekKey(DateTime d) {
  final monday = d.subtract(Duration(days: d.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  final f = DateFormat("dd/MM");
  return (
    "${f.format(monday)}-${f.format(sunday)}",
    monday.millisecondsSinceEpoch,
  );
}
