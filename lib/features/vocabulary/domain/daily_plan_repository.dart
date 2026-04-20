import "daily_plan.dart";

abstract class DailyPlanRepository {
  Stream<DailyPlan?> watchDailyPlan(String uid, String dateKey);

  Future<void> saveDailyPlan(String uid, DailyPlan plan);

  Future<void> updateTodoItemCompletion(
    String uid,
    String dateKey,
    String itemId,
    bool completed,
  );

  /// Chỉ gọi cho [dateKey] là hôm nay — cập nhật hoàn thành audio/steps.
  Future<void> applyAutoQuotas(
    String uid,
    String dateKey, {
    required int tracksToday,
    required int stepsToday,
  });
}
