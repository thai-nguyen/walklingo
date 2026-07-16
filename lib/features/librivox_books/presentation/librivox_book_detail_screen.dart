import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:walklingo/l10n/app_localizations.dart";

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

    final l10n = AppLocalizations.of(context)!;
    final episode = AudioEpisode(
      id: "${book.id}_${chapter.id}",
      title: l10n.trackTitleSeparator(book.title, chapter.title),
      description: book.author.isNotEmpty ? l10n.authorPrefix(book.author) : null,
      streamUrl: chapter.audioUrl,
      sourceName: l10n.librivoxTitle,
      sourceUrl: book.textUrl.isNotEmpty ? book.textUrl : "https://librivox.org/",
      order: 0,
    );

    try {
      await ref.read(audioPlayerServiceProvider).loadEpisode(episode);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chapterOpenedSnack)),
        );
        context.push("/player?autoplay=1");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cannotPlay(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bookAsync = ref.watch(librivoxBookProvider(bookId));
    final chaptersAsync = ref.watch(librivoxChaptersStreamProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.librivoxTitle)),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return Center(child: Text(l10n.bookNotFound));
          }
          return chaptersAsync.when(
            data: (chapters) {
              if (chapters.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noChaptersSyncHint,
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
                                ? Text(l10n.missingAudioUrl)
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
            error: (e, _) => Center(child: Text(l10n.chapterError(e.toString()))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError(e.toString()))),
      ),
    );
  }
}
