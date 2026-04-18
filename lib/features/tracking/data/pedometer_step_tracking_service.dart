import "dart:io" show Platform;

import "package:flutter/foundation.dart";
import "package:pedometer/pedometer.dart";
import "package:permission_handler/permission_handler.dart";

import "../domain/step_tracking_service.dart";

class PedometerStepTrackingService implements StepTrackingService {
  @override
  Future<bool> ensurePermissions() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      return (await Permission.activityRecognition.request()).isGranted;
    }
    if (Platform.isIOS) {
      final motion = await Permission.sensors.request();
      return motion.isGranted;
    }
    return true;
  }

  @override
  Stream<int> watchTotalSteps() {
    return Pedometer.stepCountStream.map((StepCount e) => e.steps);
  }
}
