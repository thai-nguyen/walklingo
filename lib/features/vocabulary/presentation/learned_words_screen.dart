import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:just_audio/just_audio.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "../../auth/presentation/auth_providers.dart";
import "../domain/learned_word.dart";
import "vocabulary_providers.dart";

class LearnedWordsScreen extends ConsumerWidget {
  const LearnedWordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateChangesProvider);
    final wordsAsync = ref.watch(learnedWordsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.learnedWordsTitle)),
      body: auth.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.signInToView));
          }
          return wordsAsync.when(
            data: (words) {
              if (words.isEmpty) {
                return Center(child: Text(l10n.noWordsSaved));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: words.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final w = words[i];
                  return Card(
                    child: ListTile(
                      title: Text(w.lemma),
                      subtitle: Text(
                        [
                          if (w.phonetic != null) w.phonetic!,
                          if (w.definitionPreview != null) w.definitionPreview!,
                        ].join("\n"),
                      ),
                      isThreeLine: true,
                      trailing: w.pronunciationUrl != null
                          ? IconButton(
                              tooltip: l10n.pronunciationTooltip,
                              icon: const Icon(Icons.volume_up_outlined),
                              onPressed: () async {
                                final player = AudioPlayer();
                                try {
                                  await player.setUrl(w.pronunciationUrl!);
                                  await player.play();
                                } finally {
                                  await player.dispose();
                                }
                              },
                            )
                          : null,
                      onTap: () => openLearnedWordDetail(context, w),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.genericError("$e"))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError("$e"))),
      ),
    );
  }

  void openLearnedWordDetail(BuildContext context, LearnedWord w) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(w.lemma, style: Theme.of(ctx).textTheme.headlineSmall),
              if (w.phonetic != null) Text(w.phonetic!),
              const SizedBox(height: 12),
              if (w.definitionPreview != null) Text(w.definitionPreview!),
              if (w.examplePreview != null) ...[
                const SizedBox(height: 8),
                Text(l10n.exampleLabel(w.examplePreview!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
