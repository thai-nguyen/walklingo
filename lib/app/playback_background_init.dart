import "playback_background_init_stub.dart"
    if (dart.library.io) "playback_background_init_io.dart" as impl;

Future<void> initJustAudioBackground() => impl.initJustAudioBackground();
