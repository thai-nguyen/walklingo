import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "app/bootstrap.dart";
import "app/walk_lingo_app.dart";
import "core/settings/app_settings_providers.dart";

Future<void> main() async {
  await bootstrap();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const WalkLingoApp(),
    ),
  );
}
