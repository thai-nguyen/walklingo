import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/audio_player_service.dart";
import "../data/audio_track_preload_service.dart";

final audioTrackPreloadServiceProvider = Provider<AudioTrackPreloadService>(
  (ref) => AudioTrackPreloadService(),
);

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final preload = ref.watch(audioTrackPreloadServiceProvider);
  final service = AudioPlayerService(preloadService: preload);
  ref.onDispose(service.dispose);
  return service;
});

final isAudioPlayingProvider = StreamProvider<bool>((ref) {
  return ref.watch(audioPlayerServiceProvider).playingStream;
});
