import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../domain/audio_episode.dart";
import "catalog_providers.dart";

final episodesStreamProvider = StreamProvider<List<AudioEpisode>>((ref) {
  return ref.watch(episodeCatalogRepositoryProvider).watchEpisodes();
});

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(episodesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Bài nghe")),
      body: async.when(
        data: (episodes) {
          if (episodes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Chưa có episode trong Firestore.\n"
                  "Thêm collection `audio_episodes` với các field: title, streamUrl, order, sourceUrl…",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: episodes.length,
            itemBuilder: (context, i) {
              final e = episodes[i];
              return Card(
                child: ListTile(
                  title: Text(e.title),
                  subtitle: Text(
                    e.description ?? e.sourceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push("/episode/${e.id}"),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }
}
