/// Phiên đi bộ đang hoạt động — baseline bước để tính delta trong phiên.
class WalkingSession {
  const WalkingSession({
    required this.stepsAtStart,
    required this.startedAt,
  });

  final int stepsAtStart;
  final DateTime startedAt;

  int deltaSteps(int currentTotalSteps) {
    final d = currentTotalSteps - stepsAtStart;
    if (d < 0) return 0;
    return d > 1000000 ? 1000000 : d;
  }
}
