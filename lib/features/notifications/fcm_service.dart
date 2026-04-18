import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

class FcmService {
  FcmService(this._messaging, this._firestore);

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  static const _deviceIdKey = "walklingo_device_id";

  Future<void> syncTokenForUser(String uid) async {
    try {
      if (kIsWeb) return;
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        return;
      }
      final token = await _messaging.getToken();
      if (token == null) return;

      final prefs = await SharedPreferences.getInstance();
      var deviceId = prefs.getString(_deviceIdKey);
      deviceId ??= DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_deviceIdKey, deviceId);

      await _firestore
          .collection("users")
          .doc(uid)
          .collection("devices")
          .doc(deviceId)
          .set({
        "token": token,
        "updatedAt": FieldValue.serverTimestamp(),
        "platform": defaultTargetPlatform.name,
      });

      _messaging.onTokenRefresh.listen((newToken) async {
        await _firestore
            .collection("users")
            .doc(uid)
            .collection("devices")
            .doc(deviceId)
            .set({
          "token": newToken,
          "updatedAt": FieldValue.serverTimestamp(),
          "platform": defaultTargetPlatform.name,
        });
      });
    } catch (e, st) {
      debugPrint("FCM sync failed: $e\n$st");
    }
  }
}
