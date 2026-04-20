import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "librivox_sync_notifier.dart";

/// Màn hình đồng bộ dữ liệu audiobook LibriVox → Firestore (`books` / `chapters`).
class LibrivoxSyncScreen extends ConsumerWidget {
  const LibrivoxSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(librivoxSyncNotifierProvider);
    final notifier = ref.read(librivoxSyncNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Đồng bộ LibriVox")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Tải danh sách audiobook từ LibriVox API, parse RSS và ghi vào "
              "Firestore (collection `books`, subcollection `chapters`). "
              "Tối đa 10 sách đầu; sách đã có document sẽ bị bỏ qua.\n\n"
              "Sau khi xong: mở tab Bài nghe → LibriVox → chọn sách → chọn chapter để nghe "
              "(mở Trình phát từ sách LibriVox để điều khiển).",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: ui is LibrivoxSyncLoading
                  ? null
                  : () => notifier.syncLatestData(),
              icon: ui is LibrivoxSyncLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                ui is LibrivoxSyncLoading
                    ? "Đang đồng bộ…"
                    : "Sync Latest Data",
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: _StatusPanel(state: ui)),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.state});

  final LibrivoxSyncUiState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    switch (state) {
      case LibrivoxSyncIdle():
        return Text(
          "Nhấn nút để bắt đầu.",
          style: TextStyle(color: cs.onSurfaceVariant),
        );
      case LibrivoxSyncLoading():
        return const Center(child: CircularProgressIndicator());
      case LibrivoxSyncSuccess(:final result):
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              "Hoàn tất.\n"
              "• Đã ghi: ${result.booksWritten} sách\n"
              "• Bỏ qua (đã có): ${result.booksSkippedExisting}\n"
              "• Tổng chapter ghi: ${result.totalChaptersWritten}",
              style: TextStyle(color: cs.primary),
            ),
          ),
        );
      case LibrivoxSyncError(:final message):
        return Card(
          color: cs.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              message,
              style: TextStyle(color: cs.onErrorContainer),
            ),
          ),
        );
    }
  }
}
