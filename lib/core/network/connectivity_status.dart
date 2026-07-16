import "package:connectivity_plus/connectivity_plus.dart";

bool isDeviceOffline(List<ConnectivityResult> results) {
  if (results.isEmpty) return true;
  return results.every((r) => r == ConnectivityResult.none);
}

bool isDeviceOnline(List<ConnectivityResult> results) => !isDeviceOffline(results);
