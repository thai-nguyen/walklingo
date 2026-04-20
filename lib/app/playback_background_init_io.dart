import "dart:io";

import "package:just_audio_background/just_audio_background.dart";

import "playback_environment.dart";

Future<void> initJustAudioBackground() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  await JustAudioBackground.init(
    androidNotificationChannelId: "app.walklingo.audio",
    androidNotificationChannelName: "WalkLingo audio",
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: false,
    fastForwardInterval: const Duration(seconds: 15),
    rewindInterval: const Duration(seconds: 15),
  );
  PlaybackEnvironment.justAudioBackgroundReady = true;
}
