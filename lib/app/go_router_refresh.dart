import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../features/auth/domain/app_user.dart";
import "../features/auth/presentation/auth_providers.dart";

/// Notifies [GoRouter] when [authStateChangesProvider] updates.
final goRouterRefreshProvider = Provider<GoRouterRefreshNotifier>((ref) {
  final notifier = GoRouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref) {
    _sub = _ref.listen(authStateChangesProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
  ProviderSubscription<AsyncValue<AppUser?>>? _sub;

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }
}
