import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/presentation/auth_providers.dart";
import "../../listen_history/presentation/listen_history_providers.dart";
import "../data/listen_track_counter.dart";
import "../domain/date_calendar.dart";
import "today_steps_notifier.dart";
import "vocabulary_providers.dart";

/// Đồng bộ hoàn thành audio/steps (tự động) cho **hôm nay** khi có dữ liệu nghe/bước.
class DailyQuotaSync extends ConsumerStatefulWidget {
  const DailyQuotaSync({super.key});

  @override
  ConsumerState<DailyQuotaSync> createState() => _DailyQuotaSyncState();
}

class _DailyQuotaSyncState extends ConsumerState<DailyQuotaSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _DailyQuotaSyncLogic.run(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(listenSessionsProvider, (previous, next) {
      _DailyQuotaSyncLogic.run(ref);
    });
    ref.listen(todayStepsProvider, (previous, next) {
      _DailyQuotaSyncLogic.run(ref);
    });
    return const SizedBox.shrink();
  }
}

class _DailyQuotaSyncLogic {
  static void run(WidgetRef ref) {
    final uid = ref.read(authStateChangesProvider).valueOrNull?.id;
    if (uid == null) return;
    final dk = dateKeyFromDateTime(ref.read(selectedCalendarDateProvider));
    if (!isTodayDateKey(dk)) return;
    final sessions = ref.read(listenSessionsProvider).valueOrNull ?? [];
    final day = parseDateKeyToLocalDay(dk);
    final tracks = distinctEpisodeTracksForDay(sessions, day);
    final steps = ref.read(todayStepsProvider);
    ref
        .read(dailyPlanRepositoryProvider)
        .applyAutoQuotas(uid, dk, tracksToday: tracks, stepsToday: steps);
  }
}
