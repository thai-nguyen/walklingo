import "package:firebase_messaging/firebase_messaging.dart";

@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Xử lý nền tối thiểu — có thể log hoặc sync local.
}
