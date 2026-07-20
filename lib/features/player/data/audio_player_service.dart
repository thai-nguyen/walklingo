import "dart:async";

import "package:audio_session/audio_session.dart";
import "package:flutter/foundation.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";

import "../../../app/playback_environment.dart";
import "../../../core/failures.dart";
import "../domain/audio_episode.dart";
import "audio_track_preload_service.dart";

class AudioPlayerService {
  AudioPlayerService({AudioTrackPreloadService? preloadService})
    : _preloadService = preloadService ?? AudioTrackPreloadService(),
      _player = AudioPlayer() {
    _configureSession();
  }

  final AudioTrackPreloadService _preloadService;

  final AudioPlayer _player;
  final currentEpisodeNotifier = ValueNotifier<AudioEpisode?>(null);

  AudioEpisode? _currentEpisode;
  DateTime? _sessionStartedAt;

  AudioEpisode? get currentEpisode => _currentEpisode;

  DateTime? get sessionStartedAt => _sessionStartedAt;

  Stream<bool> get playingStream => _player.playingStream;

  Stream<Duration?> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;
  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  Future<void> loadEpisode(AudioEpisode episode) async {
    try {
      _currentEpisode = episode;
      currentEpisodeNotifier.value = episode;
      _sessionStartedAt = DateTime.now();
      if (PlaybackEnvironment.justAudioBackgroundReady) {
        final duration = episode.durationSec != null
            ? Duration(seconds: episode.durationSec!)
            : null;
        final tag = MediaItem(
          id: episode.id,
          title: episode.title,
          artist: episode.sourceName,
          duration: duration,
          extras: {"sourceUrl": episode.sourceUrl},
        );
        final source = await _preloadService.audioSourceForUrl(
          episode.streamUrl,
          tag: tag,
        );
        await _player.setAudioSource(source);
      } else {
        final source = await _preloadService.audioSourceForUrl(
          episode.streamUrl,
        );
        await _player.setAudioSource(source);
      }
    } catch (e, st) {
      Error.throwWithStackTrace(AudioFailure("Không tải được audio: $e"), st);
    }
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() async {
    await _player.stop();
    _currentEpisode = null;
    currentEpisodeNotifier.value = null;
    _sessionStartedAt = null;
  }

  Duration get position => _player.position;

  Duration? get duration => _player.duration;

  Future<void> dispose() async {
    currentEpisodeNotifier.dispose();
    await _player.dispose();
  }
}
