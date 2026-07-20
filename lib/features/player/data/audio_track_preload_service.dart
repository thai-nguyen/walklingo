import "dart:async";

import "package:just_audio/just_audio.dart";

/// Preloads remote track audio into just_audio's lock cache for offline playback.
class AudioTrackPreloadService {
  final Set<String> _inFlight = {};
  final Set<String> _completed = {};

  /// Best-effort preload for each unique [urls] (sequential, ignores failures).
  Future<void> preloadTracks(Iterable<String> urls) async {
    for (final url in urls.where((u) => u.isNotEmpty).toSet()) {
      if (_completed.contains(url) || _inFlight.contains(url)) continue;
      _inFlight.add(url);
      try {
        await _preloadOne(url);
        _completed.add(url);
      } catch (_) {
        // Preload is best-effort; playback still streams from network.
      } finally {
        _inFlight.remove(url);
      }
    }
  }

  Future<void> _preloadOne(String url) async {
    final uri = Uri.parse(url);
    final source = LockCachingAudioSource(uri);
    final resolved = await source.resolve();
    if (resolved is! LockCachingAudioSource) return;

    final player = AudioPlayer();
    try {
      await player.setAudioSource(source, preload: true);
      await source.downloadProgressStream
          .firstWhere((progress) => progress >= 1.0)
          .timeout(const Duration(minutes: 15));
    } finally {
      await player.dispose();
    }
  }

  /// Cached file URI when available; otherwise a streaming cache source.
  Future<AudioSource> audioSourceForUrl(String url, {dynamic tag}) async {
    final caching = LockCachingAudioSource(Uri.parse(url), tag: tag);
    final resolved = await caching.resolve();
    if (resolved is LockCachingAudioSource) return caching;
    if (tag != null && resolved is UriAudioSource) {
      return AudioSource.uri(resolved.uri, tag: tag);
    }
    return resolved;
  }
}
