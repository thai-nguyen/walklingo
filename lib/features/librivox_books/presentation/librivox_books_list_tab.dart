import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "librivox_books_providers.dart";

/// Danh sách sách LibriVox (`books`).
class LibrivoxBooksListTab extends ConsumerWidget {
  const LibrivoxBooksListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(librivoxBooksStreamProvider);

    return async.when(
      data: (books) {
        if (books.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                "Chưa có sách trong Firestore.\n"
                "Hồ sơ → Đồng bộ LibriVox → Sync Latest Data.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, i) {
            final b = books[i];
            return Card(
              child: ListTile(
                title: Text(b.title),
                subtitle: Text(
                  b.author.isEmpty ? "LibriVox" : b.author,
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
      error: (e, _) => Center(child: Text("Lỗi: $e")),
    );
  }
}
