import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/audio_player_service.dart";

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});
