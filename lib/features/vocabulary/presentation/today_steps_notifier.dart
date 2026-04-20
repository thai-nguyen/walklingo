import "dart:async";
import "dart:math";

import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../tracking/presentation/step_tracking_providers.dart";
import "../domain/date_calendar.dart";

final todayStepsProvider = StateNotifierProvider<TodayStepsNotifier, int>((
  ref,
) {
  return TodayStepsNotifier(ref);
});

/// Ước lượng bước trong ngày từ pedometer: baseline khi sang ngày mới (lần đầu nhận bước).
class TodayStepsNotifier extends StateNotifier<int> {
  TodayStepsNotifier(this._ref) : super(0) {
    unawaited(_start());
  }

  final Ref _ref;
  StreamSubscription<int>? _sub;

  Future<void> _start() async {
    if (kIsWeb) return;
    final svc = _ref.read(stepTrackingServiceProvider);
    final ok = await svc.ensurePermissions();
    if (!ok) return;
    final prefs = await SharedPreferences.getInstance();
    _sub = svc.watchTotalSteps().listen((total) async {
      final today = dateKeyFromDateTime(DateTime.now());
      final storedDay = prefs.getString("wl_step_day");
      var baseline = prefs.getInt("wl_step_baseline") ?? total;
      if (storedDay != today) {
        baseline = total;
        await prefs.setString("wl_step_day", today);
        await prefs.setInt("wl_step_baseline", baseline);
      }
      state = max(0, total - baseline);
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }
}
