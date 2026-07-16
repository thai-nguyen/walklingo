import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "../../player/domain/audio_episode.dart";
import "../../player/presentation/audio_player_providers.dart";
import "../../profile/presentation/profile_providers.dart";
import "../../vocabulary/domain/daily_todo_item.dart";
import "../../vocabulary/domain/daily_todo_kind.dart";
import "../../vocabulary/presentation/daily_plan_setup_sheet.dart";
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
  String? _statusKey;
  String? _statusError;
  int? _lastTotal;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) {
      setState(() => _statusKey = "web");
      return;
    }
    final service = ref.read(stepTrackingServiceProvider);
    final ok = await service.ensurePermissions();
    if (!ok) {
      setState(() => _statusKey = "permission");
      return;
    }
    try {
      _stepSub = service.watchTotalSteps().listen(
        _onStep,
        onError: (Object e) => setState(() {
          _statusKey = "pedometer";
          _statusError = e.toString();
        }),
      );
    } catch (e) {
      setState(() {
        _statusKey = "pedometerInit";
        _statusError = e.toString();
      });
    }
  }

  void _onStep(int total) {
    setState(() {
      _lastTotal = total;
      _statusKey = null;
      _statusError = null;
    });
    final session = ref.read(activeWalkingSessionProvider);
    if (session != null) {
      final delta = session.deltaSteps(total);
      ref.read(walkStepsDeltaProvider.notifier).state = delta;
    }
  }

  Future<void> _startWalk() async {
    final plan = await ref.read(dailyPlanForSelectedDateProvider.future);
    if (plan == null) {
      await showDailyPlanSetupSheet(context, ref);
      return;
    }
    final int total = _lastTotal ?? ref.read(todayStepsProvider);
    ref.read(activeWalkingSessionProvider.notifier).state = WalkingSession(
      stepsAtStart: total,
      startedAt: DateTime.now(),
    );
    ref.read(walkStepsDeltaProvider.notifier).state = 0;
    await _startSelectedTrackForToday();
  }

  Future<void> _startSelectedTrackForToday() async {
    final l10n = AppLocalizations.of(context)!;
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
        : l10n.todayTrackFallbackTitle;

    try {
      final player = ref.read(audioPlayerServiceProvider);
      await player.loadEpisode(
        AudioEpisode(
          id: episodeId,
          title: title,
          streamUrl: url,
          sourceName: l10n.todayGoalSourceName,
          sourceUrl: url,
          order: idx,
        ),
      );
      await player.play();
      if (mounted) {
        setState(() => _statusKey = "playingTrack");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusKey = "cannotPlay";
          _statusError = e.toString();
        });
      }
    }
  }

  void _stopWalkAndSummarize() {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.walkSessionEndedTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.walkStartedAt(_fmtTime(session.startedAt))),
              Text(l10n.walkEndedAt(_fmtTime(endedAt))),
              const SizedBox(height: 8),
              Text(
                l10n.walkDuration(_fmtDuration(l10n, dur)),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.walkSessionSteps(delta),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              Text(l10n.walkEstimatedKcal(kcal.toStringAsFixed(1))),
              const SizedBox(height: 8),
              Text(
                l10n.walkDeviceTotalSteps(total),
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.closeButton),
          ),
        ],
      ),
    );
  }

  static String _fmtTime(DateTime d) =>
      "${d.hour.toString().padLeft(2, '0')}:"
      "${d.minute.toString().padLeft(2, '0')}:"
      "${d.second.toString().padLeft(2, '0')}";

  static String _fmtDuration(AppLocalizations l10n, Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return l10n.durationHoursMinutesSeconds(h, m, s);
    if (m > 0) return l10n.durationMinutesSeconds(m, s);
    return l10n.durationSecondsOnly(s);
  }

  String? _localizedStatus(AppLocalizations l10n) {
    return switch (_statusKey) {
      "web" => l10n.stepsNotSupportedWeb,
      "permission" => l10n.stepsPermissionRequired,
      "pedometer" => l10n.pedometerError(_statusError ?? ""),
      "pedometerInit" => l10n.pedometerInitFailed(_statusError ?? ""),
      "playingTrack" => l10n.playingTrackForWalk,
      "cannotPlay" => l10n.cannotPlaySelectedTrack(_statusError ?? ""),
      _ => null,
    };
  }

  @override
  void dispose() {
    unawaited(_stepSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
    final statusText = _localizedStatus(l10n);

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
                Expanded(
                  child: Text(
                    l10n.walkingTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                        l10n.todaySessionLabel,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        l10n.stepsCount(stepsToday),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        tooltip: l10n.resetTodayStepsTooltip,
                        onPressed: () async {
                          await ref
                              .read(todayStepsProvider.notifier)
                              .resetTodaySteps();
                          if (mounted) {
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                              SnackBar(content: Text(l10n.stepsResetSnack)),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh),
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
                        active ? l10n.currentSessionLabel : l10n.noSessionLabel,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        l10n.stepsCount(delta),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        l10n.kcalToday(kcal.toStringAsFixed(1)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (statusText != null) ...[
              const SizedBox(height: 8),
              Text(statusText, style: TextStyle(color: cs.error)),
            ],
            const SizedBox(height: 16),
            if (active)
              FilledButton.tonal(
                onPressed: _stopWalkAndSummarize,
                child: Text(l10n.endSessionButton),
              )
            else
              FilledButton(
                onPressed: () => _startWalk(),
                child: Text(l10n.startSessionButton),
              ),
            const SizedBox(height: 8),
            Text(
              l10n.profileForCalorieHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
