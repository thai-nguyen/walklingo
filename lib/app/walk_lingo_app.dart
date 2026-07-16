import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_localizations/flutter_localizations.dart";

import "../core/settings/app_settings_providers.dart";
import "../core/theme/app_theme.dart";
import "../l10n/app_localizations.dart";
import "fcm_host.dart";
import "offline_snackbar_host.dart";
import "router.dart";
import "scaffold_keys.dart";
import "walking_wakelock_host.dart";

class WalkLingoApp extends ConsumerWidget {
  const WalkLingoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider).valueOrNull ?? ThemeMode.light;
    final locale = ref.watch(appLocaleProvider).valueOrNull ?? const Locale("vi");

    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => OfflineSnackbarHost(
        child: WalkingWakelockHost(
          child: FcmHost(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
