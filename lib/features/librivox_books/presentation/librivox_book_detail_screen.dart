import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../player/domain/audio_episode.dart";
import "../../player/presentation/audio_player_providers.dart";
import "../domain/librivox_book.dart";
import "../domain/librivox_book_chapter.dart";
import "librivox_books_providers.dart";

class LibrivoxBookDetailScreen extends ConsumerWidget {
  const LibrivoxBookDetailScreen({super.key, required this.bookId});

  final String bookId;

  Future<void> _playChapter(
    WidgetRef ref,
    BuildContext context,
    LibrivoxBook book,
    LibrivoxBookChapter chapter,
  ) async {
    if (chapter.audioUrl.isEmpty) return;

    final episode = AudioEpisode(
      id: "${book.id}_${chapter.id}",
      title: "${book.title} — ${chapter.title}",
      description: book.author.isNotEmpty ? "Tác giả: ${book.author}" : null,
      streamUrl: chapter.audioUrl,
      sourceName: "LibriVox",
      sourceUrl: book.textUrl.isNotEmpty ? book.textUrl : "https://librivox.org/",
      order: 0,
    );

    try {
      await ref.read(audioPlayerServiceProvider).loadEpisode(episode);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã mở chapter — sang Trình phát")),
        );
        context.push("/player?autoplay=1");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không phát được: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(librivoxBookProvider(bookId));
    final chaptersAsync = ref.watch(librivoxChaptersStreamProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text("LibriVox")),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(child: Text("Không tìm thấy sách."));
          }
          return chaptersAsync.when(
            data: (chapters) {
              if (chapters.isEmpty) {
                return Center(
                  child: Text(
                    "Chưa có chapter.\nKiểm tra đồng bộ RSS cho sách này.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (book.author.isNotEmpty)
                          Text(
                            book.author,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: chapters.length,
                      itemBuilder: (context, i) {
                        final ch = chapters[i];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.play_circle_outline),
                            title: Text(ch.title),
                            subtitle: ch.audioUrl.isEmpty
                                ? const Text("Thiếu URL audio")
                                : null,
                            onTap: ch.audioUrl.isEmpty
                                ? null
                                : () => _playChapter(ref, context, book, ch),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Lỗi chapter: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }
}
