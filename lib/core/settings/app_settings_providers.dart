import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "app_settings_repository.dart";

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("SharedPreferences must be overridden in main()");
});

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return SharedPreferencesAppSettingsRepository(
    ref.watch(sharedPreferencesProvider),
  );
});

final appThemeModeProvider =
    AsyncNotifierProvider<AppThemeModeNotifier, ThemeMode>(
  AppThemeModeNotifier.new,
);

class AppThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() {
    return ref.watch(appSettingsRepositoryProvider).getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(appSettingsRepositoryProvider).setThemeMode(mode);
    state = AsyncData(mode);
  }
}

final appLocaleProvider = AsyncNotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class AppLocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() {
    return ref.watch(appSettingsRepositoryProvider).getLocale();
  }

  Future<void> setLocale(Locale locale) async {
    await ref.read(appSettingsRepositoryProvider).setLocale(locale);
    state = AsyncData(locale);
  }
}
