import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:intl/date_symbol_data_local.dart";

import "../firebase_options.dart";
import "../features/notifications/firebase_messaging_background.dart";
import "playback_background_init.dart";

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await initializeDateFormatting("vi");
  await initializeDateFormatting("en");
  await initJustAudioBackground();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
