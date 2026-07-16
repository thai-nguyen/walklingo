import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:walklingo/features/auth/domain/app_user.dart";
import "package:walklingo/features/listen_history/domain/listen_session.dart";
import "package:walklingo/features/profile/presentation/profile_providers.dart";
import "package:walklingo/features/vocabulary/domain/daily_plan.dart";
import "package:walklingo/features/vocabulary/domain/daily_plan_repository.dart";
import "package:walklingo/features/vocabulary/domain/daily_plan_targets.dart";
import "package:walklingo/features/vocabulary/domain/daily_todo_item.dart";
import "package:walklingo/features/vocabulary/domain/daily_todo_kind.dart";
import "package:walklingo/features/vocabulary/domain/learned_word.dart";
import "package:walklingo/features/vocabulary/domain/vocabulary_repository.dart";
import "package:walklingo/features/vocabulary/presentation/today_screen.dart";
import "package:walklingo/features/vocabulary/presentation/vocabulary_providers.dart";
import "package:walklingo/features/auth/presentation/auth_providers.dart";
import "package:walklingo/features/listen_history/presentation/listen_history_providers.dart";
import "package:walklingo/features/tracking/domain/step_tracking_service.dart";
import "package:walklingo/features/tracking/presentation/step_tracking_providers.dart";

import "l10n_test_helper.dart";

class FakeDailyPlanRepository implements DailyPlanRepository {
  FakeDailyPlanRepository();

  final updateTodoItemCompletionCalls = <(
    String uid,
    String dateKey,
    String itemId,
    bool completed,
  )>[];

  final applyAutoQuotasCalls = <(
    String uid,
    String dateKey,
    int tracksToday,
    int stepsToday,
  )>[];

  @override
  Stream<DailyPlan?> watchDailyPlan(String uid, String dateKey) =>
      Stream.value(null);

  @override
  Future<void> saveDailyPlan(String uid, DailyPlan plan) async {}

  @override
  Future<void> updateTodoItemCompletion(
    String uid,
    String dateKey,
    String itemId,
    bool completed,
  ) async {
    updateTodoItemCompletionCalls.add((uid, dateKey, itemId, completed));
  }

  @override
  Future<void> applyAutoQuotas(
    String uid,
    String dateKey, {
    required int tracksToday,
    required int stepsToday,
  }) async {
    applyAutoQuotasCalls.add((uid, dateKey, tracksToday, stepsToday));
  }
}

class FakeVocabularyRepository implements VocabularyRepository {
  FakeVocabularyRepository();

  final markReviewedCalls = <(String uid, String lemmaId)>[];
  final unmarkReviewedCalls = <(String uid, String lemmaId)>[];

  @override
  Stream<List<LearnedWord>> watchWords(String uid) => Stream.value([]);

  @override
  Future<List<LearnedWord>> fetchReviewCandidates(String uid,
          {int limit = 5}) async =>
      [];

  @override
  Future<void> upsertWord(String uid, LearnedWord word) async {}

  @override
  Future<void> markReviewed(String uid, String lemmaId) async {
    markReviewedCalls.add((uid, lemmaId));
  }

  @override
  Future<void> unmarkReviewed(String uid, String lemmaId) async {
    unmarkReviewedCalls.add((uid, lemmaId));
  }
}

void main() {
  testWidgets(
    "TodayScreen: bỏ tick reviewOldWord phải gọi unmarkReviewed",
    (tester) async {
      // Cao hơn mặc định (~600px) để Checkbox không bị đẩy khỏi viewport test.
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() async {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({
        "wl_steps_today_day": DateTime.now()
            .toString()
            .split(" ")[0], // placeholder, sẽ được TodayStepsNotifier reset
      });

      final uid = "u_123";
      final user = AppUser(id: uid);

      final selected = DateTime.now();
      final selectedDay = DateTime(selected.year, selected.month, selected.day);

      final lemmaId = "test_word";
      final todo = DailyTodoItem(
        id: "review_$lemmaId",
        kind: DailyTodoKind.reviewOldWord,
        lemma: "test word",
        completed: true,
      );

      final dateKey = "${selectedDay.year.toString().padLeft(4, "0")}-${selectedDay.month.toString().padLeft(2, "0")}-${selectedDay.day.toString().padLeft(2, "0")}";

      final plan = DailyPlan(
        dateKey: dateKey,
        targets: const DailyPlanTargets(
          newWordsCount: 0,
          audioTrackGoal: 1,
          stepGoal: 1000,
        ),
        items: [todo],
        percentComplete: 0,
        completedCount: 0,
        totalCount: 0,
      ).recalculate();

      final fakeDaily = FakeDailyPlanRepository();
      final fakeVocab = FakeVocabularyRepository();

      final listenedSessionsStream =
          Stream<List<ListenSession>>.value(const <ListenSession>[]);

      await tester.pumpWidget(
        wrapWithL10n(
          const TodayScreen(),
          overrides: [
            authStateChangesProvider.overrideWith((ref) => Stream.value(user)),
            selectedCalendarDateProvider.overrideWith((ref) => selectedDay),
            dailyPlanForSelectedDateProvider
                .overrideWith((ref) => Stream.value(plan)),
            completionStreakDaysProvider.overrideWith((ref) => Stream.value(0)),
            listenSessionsProvider.overrideWith(
              (ref) => listenedSessionsStream,
            ),
            dailyPlanRepositoryProvider.overrideWithValue(fakeDaily),
            vocabularyRepositoryProvider.overrideWithValue(fakeVocab),
            stepTrackingServiceProvider.overrideWith(
              (ref) => _FakeStepTrackingService(),
            ),
            userProfileProvider.overrideWith((ref) => Future.value(null)),
          ],
        ),
      );

      // Chờ Riverpod/StreamProvider settle để UI render nhánh có todo checkbox.
      await tester.pumpAndSettle();

      // Trạng thái ban đầu: todo đang completed=true,
      // tap checkbox sẽ chuyển v=false.
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      expect(fakeDaily.updateTodoItemCompletionCalls, hasLength(1));
      expect(fakeDaily.updateTodoItemCompletionCalls.single.$4, isFalse);
      expect(fakeDaily.updateTodoItemCompletionCalls.single.$3, "review_$lemmaId");

      // RED expectation: TodayScreen hiện tại chưa gọi unmarkReviewed.
      expect(fakeVocab.unmarkReviewedCalls, hasLength(1));
      expect(fakeVocab.unmarkReviewedCalls.single, (uid, lemmaId));
    },
  );
}

class _FakeStepTrackingService implements StepTrackingService {
  @override
  Future<bool> ensurePermissions() async => false;

  @override
  Stream<int> watchTotalSteps() => const Stream.empty();
}

