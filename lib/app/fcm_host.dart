import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../features/auth/presentation/auth_providers.dart";
import "../features/notifications/fcm_providers.dart";
import "scaffold_keys.dart";

class FcmHost extends ConsumerStatefulWidget {
  const FcmHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<FcmHost> createState() => _FcmHostState();
}

class _FcmHostState extends ConsumerState<FcmHost> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "Thông báo";
      final body = message.notification?.body ?? "";
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(body.isNotEmpty ? "$title · $body" : title)),
      );
    });

    ref.listenManual(authStateChangesProvider, (prev, next) {
      next.whenData((user) async {
        if (user != null) {
          await ref.read(fcmServiceProvider).syncTokenForUser(user.id);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
