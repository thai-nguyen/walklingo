import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase_providers.dart";
import "../data/account_deletion_service.dart";

final accountDeletionServiceProvider = Provider<AccountDeletionService>((ref) {
  return AccountDeletionService(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});
