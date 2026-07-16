import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "../core/network/connectivity_providers.dart";
import "scaffold_keys.dart";

class OfflineSnackbarHost extends ConsumerStatefulWidget {
  const OfflineSnackbarHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OfflineSnackbarHost> createState() =>
      _OfflineSnackbarHostState();
}

class _OfflineSnackbarHostState extends ConsumerState<OfflineSnackbarHost> {
  bool? _wasOnline;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      next.whenData((online) {
        if (_wasOnline == null) {
          _wasOnline = online;
          return;
        }
        if (_wasOnline == true && !online) {
          _showOfflineSnackBar();
        }
        _wasOnline = online;
      });
    });

    return widget.child;
  }

  void _showOfflineSnackBar() {
    final ctx = rootScaffoldMessengerKey.currentContext;
    if (ctx == null) return;
    final l10n = AppLocalizations.of(ctx)!;
    rootScaffoldMessengerKey.currentState?.clearSnackBars();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.offlineSnack)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
