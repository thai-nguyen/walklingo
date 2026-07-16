import "package:flutter/material.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "librivox_books_list_tab.dart";

/// Tab điều hướng “Bài nghe”: danh mục LibriVox (`books`).
class ListenScreen extends StatelessWidget {
  const ListenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.listenTitle)),
      body: const LibrivoxBooksListTab(),
    );
  }
}
