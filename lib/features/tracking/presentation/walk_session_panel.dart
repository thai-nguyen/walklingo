import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../player/domain/audio_episode.dart";
import "../../player/presentation/audio_player_providers.dart";
import "../../profile/presentation/profile_providers.dart";
import "../../vocabulary/domain/daily_todo_item.dart";
import "../../vocabulary/domain/daily_todo_kind.dart";
import "../../vocabulary/presentation/vocabulary_providers.dart";
import "../../vocabulary/presentation/today_steps_notifier.dart";
import "../calorie_calculator.dart";
import "../domain/walking_session.dart";
import "step_tracking_providers.dart";
import "walk_providers.dart";

/// Phiên đi bộ (pedometer + start/kết thúc) — nhúng trong màn Hôm nay.
class WalkSessionPanel extends ConsumerStatefulWidget {
  const WalkSessionPanel({super.key});

  @override
  ConsumerState<WalkSessionPanel> createState() => _WalkSessionPanelState();
}

class _WalkSessionPanelState extends ConsumerState<WalkSessionPanel> {
  StreamSubscription<int>? _stepSub;
  String _status = "";
  int? _lastTotal;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) {
      setState(() => _status = "Đếm bước không hỗ trợ trên web.");
      return;
    }
    final service = ref.read(stepTrackingServiceProvider);
    final ok = await service.ensurePermissions();
    if (!ok) {
      setState(
        () => _status =
            "Cần quyền nhận biết hoạt động / chuyển động để đếm bước.",
      );
      return;
    }
    try {
      _stepSub = service.watchTotalSteps().listen(
        _onStep,
        onError: (Object e) => setState(() => _status = "Lỗi pedometer: $e"),
      );
    } catch (e) {
      setState(() => _status = "Không khởi tạo được pedometer: $e");
    }
  }

  void _onStep(int total) {
    setState(() {
      _lastTotal = total;
      _status = "";
    });
    final session = ref.read(activeWalkingSessionProvider);
    if (session != null) {
      final delta = session.deltaSteps(total);
      ref.read(walkStepsDeltaProvider.notifier).state = delta;
    }
  }

  Future<void> _startWalk() async {
    final total = _lastTotal;
    if (total == null) {
      setState(() => _status = "Đang chờ dữ liệu bước từ thiết bị…");
      return;
    }
    ref.read(activeWalkingSessionProvider.notifier).state = WalkingSession(
      stepsAtStart: total,
      startedAt: DateTime.now(),
    );
    ref.read(walkStepsDeltaProvider.notifier).state = 0;
    await _startSelectedTrackForToday();
  }

  Future<void> _startSelectedTrackForToday() async {
    final plan = ref.read(dailyPlanForSelectedDateProvider).valueOrNull;
    if (plan == null) return;

    DailyTodoItem? item;
    for (final it in plan.items) {
      if (it.kind == DailyTodoKind.audioQuota) {
        item = it;
        break;
      }
    }
    if (item == null) return;

    final trackIds = item.trackIds ?? const <String>[];
    final trackTitles = item.trackTitles ?? const <String>[];
    final trackUrls = item.trackUrls ?? const <String>[];
    if (trackUrls.isEmpty) return;

    var idx = 0;
    while (idx < trackUrls.length && trackUrls[idx].isEmpty) {
      idx += 1;
    }
    if (idx >= trackUrls.length) return;

    final url = trackUrls[idx];
    final episodeId = idx < trackIds.length
        ? trackIds[idx]
        : "track_${DateTime.now().millisecondsSinceEpoch}";
    final title = idx < trackTitles.length
        ? trackTitles[idx]
        : "Track đã chọn hôm nay";

    try {
      final player = ref.read(audioPlayerServiceProvider);
      await player.loadEpisode(
        AudioEpisode(
          id: episodeId,
          title: title,
          streamUrl: url,
          sourceName: "Mục tiêu hôm nay",
          sourceUrl: url,
          order: idx,
        ),
      );
      await player.play();
      if (mounted) {
        setState(() => _status = "Đang phát track đã chọn cho phiên đi bộ.");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = "Không phát được track đã chọn: $e");
      }
    }
  }

  void _stopWalkAndSummarize() {
    final session = ref.read(activeWalkingSessionProvider);
    final total = _lastTotal;
    ref.read(activeWalkingSessionProvider.notifier).state = null;
    ref.read(walkStepsDeltaProvider.notifier).state = 0;

    if (session == null || total == null || !mounted) return;

    final delta = session.deltaSteps(total);
    final endedAt = DateTime.now();
    final profile = ref
        .read(userProfileProvider)
        .maybeWhen(data: (p) => p, orElse: () => null);
    final kcal = estimateWalkingKcal(
      steps: delta,
      weightKg: profile?.weightKg,
      heightCm: profile?.heightCm,
    );
    final dur = endedAt.difference(session.startedAt);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Phiên đi bộ đã kết thúc"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bắt đầu: ${_fmtTime(session.startedAt)}"),
              Text("Kết thúc: ${_fmtTime(endedAt)}"),
              const SizedBox(height: 8),
              Text(
                "Thời lượng: ${_fmtDuration(dur)}",
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Bước trong phiên: $delta",
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              Text("Ước lượng: ${kcal.toStringAsFixed(1)} kcal"),
              const SizedBox(height: 8),
              Text(
                "Tổng bước thiết bị (hiện tại): $total",
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  static String _fmtTime(DateTime d) =>
      "${d.hour.toString().padLeft(2, '0')}:"
      "${d.minute.toString().padLeft(2, '0')}:"
      "${d.second.toString().padLeft(2, '0')}";

  static String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "$h giờ $m phút $s giây";
    if (m > 0) return "$m phút $s giây";
    return "$s giây";
  }

  @override
  void dispose() {
    unawaited(_stepSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delta = ref.watch(walkStepsDeltaProvider);
    final session = ref.watch(activeWalkingSessionProvider);
    final active = session != null;
    final profileAsync = ref.watch(userProfileProvider);
    final stepsToday = ref.watch(todayStepsProvider);
    final kcal = profileAsync.maybeWhen(
      data: (p) => estimateWalkingKcal(
        steps: stepsToday,
        weightKg: p?.weightKg,
        heightCm: p?.heightCm,
      ),
      orElse: () => estimateWalkingKcal(steps: stepsToday),
    );

    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.directions_walk, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  "Đi bộ",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hôm nay (theo phiên)",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        "$stepsToday bước",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active ? "Phiên hiện tại" : "Chưa có phiên",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        "$delta bước",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${kcal.toStringAsFixed(1)} kcal hôm nay",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_status, style: TextStyle(color: cs.error)),
            ],
            const SizedBox(height: 16),
            if (active)
              FilledButton.tonal(
                onPressed: _stopWalkAndSummarize,
                child: const Text("Kết thúc phiên"),
              )
            else
              FilledButton(
                onPressed: () => _startWalk(),
                child: const Text("Bắt đầu phiên"),
              ),
            const SizedBox(height: 8),
            Text(
              "Nhập cân nặng/chiều cao trong Hồ sơ để ước lượng calo chính xác hơn.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
