import "package:flutter_riverpod/flutter_riverpod.dart";

import "../domain/walking_session.dart";

/// Số bước cộng dồn trong phiên đi bộ hiện tại (đồng bộ với lưu lịch sử nghe).
final walkStepsDeltaProvider = StateProvider<int>((ref) => 0);

/// Phiên đi bộ đang bật (có baseline) — dùng khi gắn với listen session.
final activeWalkingSessionProvider = StateProvider<WalkingSession?>((ref) => null);
