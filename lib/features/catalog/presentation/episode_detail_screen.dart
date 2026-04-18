import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "../../player/presentation/audio_player_providers.dart";
import "../domain/audio_episode.dart";
import "catalog_providers.dart";

final episodeProvider = FutureProvider.family<AudioEpisode?, String>((ref, id) {
  return ref.watch(episodeCatalogRepositoryProvider).getEpisode(id);
});

class EpisodeDetailScreen extends ConsumerStatefulWidget {
  const EpisodeDetailScreen({super.key, required this.episodeId});

  final String episodeId;

  @override
  ConsumerState<EpisodeDetailScreen> createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends ConsumerState<EpisodeDetailScreen> {
  bool _loading = false;

  Future<void> _play(AudioEpisode episode) async {
    setState(() => _loading = true);
    try {
      await ref.read(audioPlayerServiceProvider).loadEpisode(episode);
      await ref.read(audioPlayerServiceProvider).play();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã tải bài — mở tab Phát")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không phát được: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSource(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(episodeProvider(widget.episodeId));
    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết bài")),
      body: async.when(
        data: (episode) {
          if (episode == null) {
            return const Center(child: Text("Không tìm thấy bài."));
          }
          final cs = Theme.of(context).colorScheme;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  episode.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (episode.description != null && episode.description!.isNotEmpty)
                  Text(episode.description!, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nguồn",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(episode.sourceName),
                        TextButton.icon(
                          onPressed: () => _openSource(episode.sourceUrl),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text("zappenglish.com"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loading ? null : () => _play(episode),
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_loading ? "Đang tải…" : "Phát trong WalkLingo"),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }
}
