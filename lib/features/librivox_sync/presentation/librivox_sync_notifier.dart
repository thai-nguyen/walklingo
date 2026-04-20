import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../domain/librivox_sync_repository.dart";
import "librivox_sync_providers.dart";

/// Trạng thái UI đồng bộ LibriVox.
sealed class LibrivoxSyncUiState {
  const LibrivoxSyncUiState();

  factory LibrivoxSyncUiState.idle() = LibrivoxSyncIdle;
  factory LibrivoxSyncUiState.loading() = LibrivoxSyncLoading;
  factory LibrivoxSyncUiState.success(LibrivoxSyncResult result) =
      LibrivoxSyncSuccess;
  factory LibrivoxSyncUiState.error(String message) = LibrivoxSyncError;
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
  LibrivoxSyncError(this.message);

  final String message;
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
      state = LibrivoxSyncUiState.error(_formatError(e));
    }
  }

  void reset() {
    state = LibrivoxSyncIdle();
  }

  static String _formatError(Object e) {
    final s = e.toString();
    if (s.contains("SocketException") || s.contains("network")) {
      return "Lỗi mạng — kiểm tra kết nối và thử lại.";
    }
    if (s.contains("TimeoutException")) {
      return "Hết giờ chờ — LibriVox hoặc RSS phản hồi quá lâu.";
    }
    if (e is StateError && s.contains("signed in")) {
      return "Cần đăng nhập trước khi đồng bộ.";
    }
    return s.length > 200 ? "${s.substring(0, 200)}…" : s;
  }
}
