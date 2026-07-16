import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

abstract interface class AppSettingsRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);

  Future<Locale> getLocale();
  Future<void> setLocale(Locale locale);
}

class SharedPreferencesAppSettingsRepository implements AppSettingsRepository {
  SharedPreferencesAppSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = "app_theme_mode";
  static const _localeKey = "app_locale";

  @override
  Future<ThemeMode> getThemeMode() async {
    final raw = _prefs.getString(_themeModeKey);
    return switch (raw) {
      "dark" => ThemeMode.dark,
      "light" => ThemeMode.light,
      _ => ThemeMode.light,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final raw = switch (mode) {
      ThemeMode.dark => "dark",
      ThemeMode.light => "light",
      ThemeMode.system => "light",
    };
    await _prefs.setString(_themeModeKey, raw);
  }

  @override
  Future<Locale> getLocale() async {
    final raw = _prefs.getString(_localeKey);
    return switch (raw) {
      "en" => const Locale("en"),
      "vi" => const Locale("vi"),
      _ => const Locale("vi"),
    };
  }

  @override
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }
}
