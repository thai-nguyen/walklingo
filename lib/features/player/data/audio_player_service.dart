import "package:audio_session/audio_session.dart";
import "package:just_audio/just_audio.dart";

import "../../catalog/domain/audio_episode.dart";
import "../../../core/failures.dart";

class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer() {
    _configureSession();
  }

  final AudioPlayer _player;

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
      _sessionStartedAt = DateTime.now();
      await _player.setUrl(episode.streamUrl);
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
    _sessionStartedAt = null;
  }

  Duration get position => _player.position;

  Duration? get duration => _player.duration;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
