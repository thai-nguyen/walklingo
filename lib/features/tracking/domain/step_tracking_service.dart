/// Trừu tượng hóa nguồn đếm bước (ISP — có thể thay bằng Health Connect / fake trong test).
abstract interface class StepTrackingService {
  /// Xin quyền cần thiết trên nền tảng hiện tại.
  Future<bool> ensurePermissions();

  /// Tổng bước tích lũy từ hệ thống (theo API pedometer / health).
  Stream<int> watchTotalSteps();
}
