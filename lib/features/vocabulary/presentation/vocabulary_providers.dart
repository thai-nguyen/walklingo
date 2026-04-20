import "dart:convert";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase_providers.dart";
import "../../auth/presentation/auth_providers.dart";
import "../data/dictionary_api_client.dart";
import "../data/firestore_daily_plan_repository.dart";
import "../data/firestore_vocabulary_repository.dart";
import "../domain/daily_plan.dart";
import "../domain/daily_plan_repository.dart";
import "../domain/date_calendar.dart";
import "../domain/learned_word.dart";
import "../domain/vocabulary_repository.dart";

final dictionaryApiClientProvider = Provider<DictionaryApiClient>((ref) {
  final c = DictionaryApiClient();
  ref.onDispose(c.dispose);
  return c;
});

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return FirestoreVocabularyRepository(ref.watch(firestoreProvider));
});

final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) {
  return FirestoreDailyPlanRepository(ref.watch(firestoreProvider));
});

/// Ngày đang chọn trên lịch (local midnight).
final selectedCalendarDateProvider = StateProvider<DateTime>((ref) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
});

final dailyPlanForSelectedDateProvider = StreamProvider<DailyPlan?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final d = ref.watch(selectedCalendarDateProvider);
  final dateKey = dateKeyFromDateTime(d);
  return auth.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      return ref
          .watch(dailyPlanRepositoryProvider)
          .watchDailyPlan(user.id, dateKey);
    },
    loading: () => Stream.value(null),
    error: (error, stackTrace) => Stream.value(null),
  );
});

final wordSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  final raw = await rootBundle.loadString("assets/word_suggestions.json");
  final list = jsonDecode(raw) as List<dynamic>;
  return list.map((e) => "$e").toList();
});

final learnedWordsProvider = StreamProvider<List<LearnedWord>>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final repo = ref.watch(vocabularyRepositoryProvider);
  return auth.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return repo.watchWords(user.id);
    },
    loading: () => Stream.value([]),
    error: (error, stackTrace) => Stream.value([]),
  );
});

/// Số ngày liên tục đạt 100% mục tiêu (tính lùi từ hôm nay).
final completionStreakDaysProvider = StreamProvider<int>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final fs = ref.watch(firestoreProvider);
  return auth.when(
    data: (user) {
      if (user == null) return Stream.value(0);
      return fs
          .collection("users")
          .doc(user.id)
          .collection("dailyPlans")
          .orderBy("dateKey", descending: true)
          .limit(365)
          .snapshots()
          .map((snap) => _computeCompletionStreak(snap.docs));
    },
    loading: () => Stream.value(0),
    error: (error, stackTrace) => Stream.value(0),
  );
});

int _computeCompletionStreak(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final completedByDate = <String, bool>{};
  for (final doc in docs) {
    final d = doc.data();
    final key = d["dateKey"] as String?;
    if (key == null || key.isEmpty) continue;
    final percent = (d["percentComplete"] as num?)?.toInt() ?? 0;
    completedByDate[key] = percent >= 100;
  }

  var streak = 0;
  var cursor = DateTime.now();
  while (true) {
    final key = dateKeyFromDateTime(cursor);
    final done = completedByDate[key] ?? false;
    if (!done) break;
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
