import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/firebase_providers.dart";
import "fcm_service.dart";

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    ref.watch(firebaseMessagingProvider),
    ref.watch(firestoreProvider),
  );
});
