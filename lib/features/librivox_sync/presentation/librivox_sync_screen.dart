import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "librivox_sync_notifier.dart";

/// Màn hình đồng bộ dữ liệu audiobook LibriVox → Firestore (`books` / `chapters`).
class LibrivoxSyncScreen extends ConsumerWidget {
  const LibrivoxSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ui = ref.watch(librivoxSyncNotifierProvider);
    final notifier = ref.read(librivoxSyncNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.librivoxSyncTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.librivoxSyncDescription,
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
                    ? l10n.syncInProgress
                    : l10n.syncLatestData,
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

  String _errorMessage(AppLocalizations l10n, LibrivoxSyncError error) {
    return switch (error.code) {
      LibrivoxSyncErrorCode.network => l10n.syncNetworkError,
      LibrivoxSyncErrorCode.timeout => l10n.syncTimeoutError,
      LibrivoxSyncErrorCode.signInRequired => l10n.syncSignInRequired,
      _ => l10n.genericError(error.detail ?? error.code),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    switch (state) {
      case LibrivoxSyncIdle():
        return Text(
          l10n.syncPressToStart,
          style: TextStyle(color: cs.onSurfaceVariant),
        );
      case LibrivoxSyncLoading():
        return const Center(child: CircularProgressIndicator());
      case LibrivoxSyncSuccess(:final result):
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              l10n.syncSuccess(
                result.booksWritten,
                result.booksSkippedExisting,
                result.totalChaptersWritten,
              ),
              style: TextStyle(color: cs.primary),
            ),
          ),
        );
      case final LibrivoxSyncError error:
        return Card(
          color: cs.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              _errorMessage(l10n, error),
              style: TextStyle(color: cs.onErrorContainer),
            ),
          ),
        );
    }
  }
}
