import "dart:async";

import "package:flutter/widgets.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:wakelock_plus/wakelock_plus.dart";

import "../features/player/presentation/audio_player_providers.dart";
import "../features/tracking/presentation/walk_providers.dart";

/// Giữ CPU hoạt động khi đang có phiên đi bộ hoặc đang phát audio — giảm nguy cơ OS
/// đóng băng đếm bước / timer khi màn hình tắt (không đảm bảo trên mọi thiết bị).
class WalkingWakelockHost extends ConsumerStatefulWidget {
  const WalkingWakelockHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<WalkingWakelockHost> createState() =>
      _WalkingWakelockHostState();
}

class _WalkingWakelockHostState extends ConsumerState<WalkingWakelockHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWakelock());
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  Future<void> _syncWakelock() async {
    final walk = ref.read(activeWalkingSessionProvider);
    final playing =
        ref.read(isAudioPlayingProvider).valueOrNull ?? false;
    final on = walk != null || playing;
    if (on) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(activeWalkingSessionProvider, (previous, next) => _syncWakelock());
    ref.listen(isAudioPlayingProvider, (previous, next) => _syncWakelock());
    return widget.child;
  }
}
