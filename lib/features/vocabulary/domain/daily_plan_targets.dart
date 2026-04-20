class DailyPlanTargets {
  const DailyPlanTargets({
    required this.newWordsCount,
    required this.audioTrackGoal,
    required this.stepGoal,
  });

  final int newWordsCount;
  final int audioTrackGoal;
  final int stepGoal;

  Map<String, dynamic> toJson() => {
    "newWordsCount": newWordsCount,
    "audioTrackGoal": audioTrackGoal,
    "stepGoal": stepGoal,
  };

  static DailyPlanTargets fromJson(Map<String, dynamic>? m) {
    if (m == null) {
      return const DailyPlanTargets(
        newWordsCount: 0,
        audioTrackGoal: 1,
        stepGoal: 3000,
      );
    }
    return DailyPlanTargets(
      newWordsCount: (m["newWordsCount"] as num?)?.toInt() ?? 0,
      audioTrackGoal: (m["audioTrackGoal"] as num?)?.toInt() ?? 1,
      stepGoal: (m["stepGoal"] as num?)?.toInt() ?? 3000,
    );
  }
}
