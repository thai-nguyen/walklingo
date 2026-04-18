import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/theme/app_theme.dart";
import "fcm_host.dart";
import "router.dart";
import "scaffold_keys.dart";

class WalkLingoApp extends ConsumerWidget {
  const WalkLingoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => FcmHost(child: child ?? const SizedBox.shrink()),
    );
  }
}
