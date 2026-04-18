import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/pedometer_step_tracking_service.dart";
import "../domain/step_tracking_service.dart";

final stepTrackingServiceProvider = Provider<StepTrackingService>((ref) {
  return PedometerStepTrackingService();
});
