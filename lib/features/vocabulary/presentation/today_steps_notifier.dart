import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../tracking/domain/walking_session.dart";
import "../../tracking/presentation/step_tracking_providers.dart";
import "../../tracking/presentation/walk_providers.dart";
import "../domain/date_calendar.dart";

final todayStepsProvider = StateNotifierProvider<TodayStepsNotifier, int>((
  ref,
) {
  return TodayStepsNotifier(ref);
});

/// Đếm số bước chân trong ngày hôm nay:
/// 1. Chỉ tính các bước chân phát sinh trong các phiên đi bộ (WalkingSession) đã bật.
/// 2. Reset về 0 khi sang ngày mới.
/// 3. Duy trì giá trị cộng dồn từ các phiên đã kết thúc trong ngày (lưu SharedPreferences).
class TodayStepsNotifier extends StateNotifier<int> {
  TodayStepsNotifier(this._ref) : super(0) {
    unawaited(_init());
  }

  final Ref _ref;
  StreamSubscription<int>? _stepSub;
  int _accumulated = 0; // Tổng bước từ các phiên đã kết thúc hôm nay.
  int _lastTotal = 0;   // Giá trị pedometer mới nhất nhận được.

  String? _storedDay;

  Future<void> _init() async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    final today = dateKeyFromDateTime(DateTime.now());
    _storedDay = prefs.getString("wl_steps_today_day");

    // 1. Kiểm tra reset ngày mới
    if (_storedDay != today) {
      _accumulated = 0;
      _storedDay = today;
      await prefs.setString("wl_steps_today_day", today);
      await prefs.setInt("wl_steps_today_accumulated", 0);
    } else {
      _accumulated = prefs.getInt("wl_steps_today_accumulated") ?? 0;
    }

    state = _accumulated;

    // 2. Lắng nghe Pedometer
    final svc = _ref.read(stepTrackingServiceProvider);
    final ok = await svc.ensurePermissions();
    if (!ok) return;

    _stepSub = svc.watchTotalSteps().listen((total) {
      _lastTotal = total;
      _updateState();
    });

    // 3. Lắng nghe thay đổi Session để cộng dồn khi kết thúc phiên
    _ref.listen<WalkingSession?>(activeWalkingSessionProvider, (previous, next) {
      if (previous != null && next == null) {
        // Một phiên vừa kết thúc -> Cộng dồn delta vào biến tích lũy của ngày.
        final delta = previous.deltaSteps(_lastTotal);
        _accumulated += delta;
        unawaited(prefs.setInt("wl_steps_today_accumulated", _accumulated));
      }
      _updateState();
    });
  }

  void _updateState() {
    final today = dateKeyFromDateTime(DateTime.now());
    if (_storedDay != null && _storedDay != today) {
      // Sang ngày mới khi đang mở app
      _accumulated = 0;
      _storedDay = today;
      state = 0;
      // Lưu lại vào prefs (async)
      SharedPreferences.getInstance().then((prefs) {
        unawaited(prefs.setString("wl_steps_today_day", today));
        unawaited(prefs.setInt("wl_steps_today_accumulated", 0));
      });
      return;
    }

    final session = _ref.read(activeWalkingSessionProvider);
    if (session == null) {
      state = _accumulated;
    } else {
      // Nếu đang trong phiên: state = tích lũy cũ + delta phiên hiện tại.
      state = _accumulated + session.deltaSteps(_lastTotal);
    }
  }

  /// Reset thủ công số bước hôm nay về 0.
  Future<void> resetTodaySteps() async {
    final today = dateKeyFromDateTime(DateTime.now());
    _accumulated = 0;
    _storedDay = today;

    final session = _ref.read(activeWalkingSessionProvider);
    if (session == null) {
      state = 0;
    } else {
      state = session.deltaSteps(_lastTotal);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("wl_steps_today_day", today);
    await prefs.setInt("wl_steps_today_accumulated", 0);
  }

  @override
  void dispose() {
    unawaited(_stepSub?.cancel());
    super.dispose();
  }
}
