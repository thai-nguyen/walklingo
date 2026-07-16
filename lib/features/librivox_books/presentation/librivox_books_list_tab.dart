import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "../../../app/app_navigation_bar.dart";
import "librivox_books_providers.dart";

/// Danh sách sách LibriVox (`books`).
class LibrivoxBooksListTab extends ConsumerWidget {
  const LibrivoxBooksListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(librivoxBooksStreamProvider);

    return async.when(
      data: (books) {
        if (books.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.noBooksInFirestore,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + mainShellBottomInset(context),
          ),
          itemCount: books.length,
          itemBuilder: (context, i) {
            final b = books[i];
            return Card(
              child: ListTile(
                title: Text(b.title),
                subtitle: Text(
                  b.author.isEmpty ? l10n.librivoxAuthorFallback : b.author,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push("/book/${b.id}"),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.genericError(e.toString()))),
    );
  }
}
