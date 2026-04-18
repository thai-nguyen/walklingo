import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/presentation/auth_providers.dart";
import "../../catalog/domain/audio_episode.dart";
import "../../listen_history/domain/listen_session.dart";
import "../../listen_history/presentation/listen_history_providers.dart";
import "../../profile/presentation/profile_providers.dart";
import "../../tracking/calorie_calculator.dart";
import "../../tracking/presentation/walk_providers.dart"
    show walkStepsDeltaProvider, activeWalkingSessionProvider;
import "../data/audio_player_service.dart";
import "audio_player_providers.dart";

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  Future<void> _saveSession(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authStateChangesProvider).valueOrNull;
    if (auth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cần đăng nhập để lưu lịch sử.")),
      );
      return;
    }

    final player = ref.read(audioPlayerServiceProvider);
    final ep = player.currentEpisode;
    if (ep == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa có bài đang phát.")),
      );
      return;
    }

    final started = player.sessionStartedAt ?? DateTime.now();
    final ended = DateTime.now();
    final dur = player.duration ?? Duration.zero;
    final pos = player.position;
    final listenedSec = pos.inSeconds.clamp(0, dur.inSeconds > 0 ? dur.inSeconds : pos.inSeconds);

    final walkActive = ref.read(activeWalkingSessionProvider) != null;
    final stepsDelta = walkActive ? ref.read(walkStepsDeltaProvider) : null;

    final profile = await ref.read(userProfileProvider.future);
    double? kcal;
    if (walkActive && stepsDelta != null && stepsDelta > 0) {
      kcal = estimateWalkingKcal(
        steps: stepsDelta,
        weightKg: profile?.weightKg,
        heightCm: profile?.heightCm,
      );
    }

    try {
      await ref.read(listenHistoryRepositoryProvider).saveSession(
            auth.id,
            ListenSessionDraft(
              episodeId: ep.id,
              episodeTitleSnapshot: ep.title,
              streamUrlSnapshot: ep.streamUrl,
              startedAt: started,
              endedAt: ended,
              listenedSeconds: listenedSec,
              stepsDelta: walkActive ? stepsDelta : null,
              estimatedKcal: kcal,
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã lưu vào Lịch sử.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lưu thất bại: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(audioPlayerServiceProvider);
    final episode = player.currentEpisode;

    return Scaffold(
      appBar: AppBar(title: const Text("Trình phát")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: episode == null
            ? Center(
                child: Text(
                  "Chưa chọn bài.\nVào tab Bài nghe và mở một episode để phát.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _PlayerBody(episode: episode, player: player)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _saveSession(context, ref),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text("Lưu session nghe"),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PlayerBody extends StatefulWidget {
  const _PlayerBody({required this.episode, required this.player});

  final AudioEpisode episode;
  final AudioPlayerService player;

  @override
  State<_PlayerBody> createState() => _PlayerBodyState();
}

class _PlayerBodyState extends State<_PlayerBody> {
  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.episode.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.episode.sourceName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        StreamBuilder<Duration?>(
          stream: player.durationStream,
          builder: (context, snap) {
            final total = snap.data ?? Duration.zero;
            return StreamBuilder<Duration?>(
              stream: player.positionStream,
              builder: (context, posSnap) {
                final pos = posSnap.data ?? Duration.zero;
                final maxMs = total.inMilliseconds == 0 ? 1 : total.inMilliseconds;
                final v = pos.inMilliseconds / maxMs;
                return Column(
                  children: [
                    LinearProgressIndicator(value: v.clamp(0.0, 1.0)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(pos)),
                        Text(_fmt(total)),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        StreamBuilder<bool>(
          stream: player.playingStream,
          initialData: false,
          builder: (context, snap) {
            final playing = snap.data ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  iconSize: 48,
                  onPressed: () async {
                    if (playing) {
                      await player.pause();
                    } else {
                      await player.play();
                    }
                  },
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          "Nguồn: ${widget.episode.sourceUrl}",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline),
        ),
      ],
    );
  }

  static String _fmt(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    if (d.inHours > 0) {
      return "${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
    }
    return "${d.inMinutes}:${twoDigits(d.inSeconds.remainder(60))}";
  }
}
