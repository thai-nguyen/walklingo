import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../domain/librivox_sync_repository.dart";
import "librivox_sync_providers.dart";

/// Error codes for [LibrivoxSyncError] — localized in [LibrivoxSyncScreen].
abstract final class LibrivoxSyncErrorCode {
  static const network = "network";
  static const timeout = "timeout";
  static const signInRequired = "signInRequired";
  static const generic = "generic";
}

/// Trạng thái UI đồng bộ LibriVox.
sealed class LibrivoxSyncUiState {
  const LibrivoxSyncUiState();

  factory LibrivoxSyncUiState.idle() = LibrivoxSyncIdle;
  factory LibrivoxSyncUiState.loading() = LibrivoxSyncLoading;
  factory LibrivoxSyncUiState.success(LibrivoxSyncResult result) =
      LibrivoxSyncSuccess;
  factory LibrivoxSyncUiState.error(String code, {String? detail}) =
      LibrivoxSyncError;
}

final class LibrivoxSyncIdle extends LibrivoxSyncUiState {
  LibrivoxSyncIdle();
}

final class LibrivoxSyncLoading extends LibrivoxSyncUiState {
  LibrivoxSyncLoading();
}

final class LibrivoxSyncSuccess extends LibrivoxSyncUiState {
  LibrivoxSyncSuccess(this.result);

  final LibrivoxSyncResult result;
}

final class LibrivoxSyncError extends LibrivoxSyncUiState {
  LibrivoxSyncError(this.code, {this.detail});

  final String code;
  final String? detail;
}

final librivoxSyncNotifierProvider =
    NotifierProvider<LibrivoxSyncNotifier, LibrivoxSyncUiState>(
  LibrivoxSyncNotifier.new,
);

class LibrivoxSyncNotifier extends Notifier<LibrivoxSyncUiState> {
  static const _maxBooks = 10;

  @override
  LibrivoxSyncUiState build() => LibrivoxSyncIdle();

  Future<void> syncLatestData() async {
    state = LibrivoxSyncLoading();
    try {
      final repo = ref.read(librivoxSyncRepositoryProvider);
      final result = await repo.syncLatest(maxBooks: _maxBooks);
      state = LibrivoxSyncUiState.success(result);
    } catch (e, st) {
      debugPrint("[LibrivoxSync] failed: $e\n$st");
      final (code, detail) = _classifyError(e);
      state = LibrivoxSyncUiState.error(code, detail: detail);
    }
  }

  void reset() {
    state = LibrivoxSyncIdle();
  }

  static (String code, String? detail) _classifyError(Object e) {
    final s = e.toString();
    if (s.contains("SocketException") || s.contains("network")) {
      return (LibrivoxSyncErrorCode.network, null);
    }
    if (s.contains("TimeoutException")) {
      return (LibrivoxSyncErrorCode.timeout, null);
    }
    if (e is StateError && s.contains("signed in")) {
      return (LibrivoxSyncErrorCode.signInRequired, null);
    }
    final detail = s.length > 200 ? "${s.substring(0, 200)}…" : s;
    return (LibrivoxSyncErrorCode.generic, detail);
  }
}
