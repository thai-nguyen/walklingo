import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "app/bootstrap.dart";
import "app/walk_lingo_app.dart";

Future<void> main() async {
  await bootstrap();
  runApp(const ProviderScope(child: WalkLingoApp()));
}
