import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "connectivity_status.dart";

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(connectivityProvider).whenData(isDeviceOnline);
});
