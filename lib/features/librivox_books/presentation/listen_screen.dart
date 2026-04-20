import "package:flutter/material.dart";

import "librivox_books_list_tab.dart";

/// Tab điều hướng “Bài nghe”: danh mục LibriVox (`books`).
class ListenScreen extends StatelessWidget {
  const ListenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bài nghe")),
      body: const LibrivoxBooksListTab(),
    );
  }
}
