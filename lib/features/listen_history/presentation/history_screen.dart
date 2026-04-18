import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "listen_history_providers.dart";

final _dateFmt = DateFormat.yMMMd().add_Hm();

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(listenSessionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử nghe")),
      body: async.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                "Chưa có session nào.\nMở tab Phát và lưu sau khi nghe.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final s = sessions[i];
              return Card(
                child: ListTile(
                  title: Text(s.episodeTitleSnapshot),
                  subtitle: Text(
                    "${_dateFmt.format(s.endedAt)} · "
                    "${s.listenedSeconds ~/ 60} phút "
                    "${s.listenedSeconds % 60} giây"
                    "${s.stepsDelta != null ? ' · ${s.stepsDelta} bước' : ''}"
                    "${s.estimatedKcal != null ? ' · ${s.estimatedKcal!.toStringAsFixed(0)} kcal' : ''}",
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }
}
