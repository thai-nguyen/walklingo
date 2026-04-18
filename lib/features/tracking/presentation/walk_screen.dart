import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../profile/presentation/profile_providers.dart";
import "../calorie_calculator.dart";
import "../domain/walking_session.dart";
import "step_tracking_providers.dart";
import "walk_providers.dart";

class WalkScreen extends ConsumerStatefulWidget {
  const WalkScreen({super.key});

  @override
  ConsumerState<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends ConsumerState<WalkScreen> {
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
      setState(() => _status = "Cần quyền nhận biết hoạt động / chuyển động để đếm bước.");
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

  void _startWalk() {
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
  }

  void _stopWalk() {
    ref.read(activeWalkingSessionProvider.notifier).state = null;
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delta = ref.watch(walkStepsDeltaProvider);
    final session = ref.watch(activeWalkingSessionProvider);
    final active = session != null;
    final profileAsync = ref.watch(userProfileProvider);

    final kcal = profileAsync.maybeWhen(
      data: (p) => estimateWalkingKcal(
        steps: delta,
        weightKg: p?.weightKg,
        heightCm: p?.heightCm,
      ),
      orElse: () => estimateWalkingKcal(steps: delta),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Đi bộ")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hôm nay (tổng thiết bị)",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${_lastTotal ?? "—"} bước",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phiên hiện tại",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$delta bước",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      "${kcal.toStringAsFixed(1)} kcal (ước lượng)",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_status, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const Spacer(),
            if (active)
              FilledButton.tonal(
                onPressed: _stopWalk,
                child: const Text("Kết thúc phiên đi bộ"),
              )
            else
              FilledButton(
                onPressed: _startWalk,
                child: const Text("Bắt đầu phiên đi bộ"),
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
