import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:walklingo/features/auth/domain/app_user.dart";
import "package:walklingo/features/auth/presentation/auth_providers.dart";
import "package:walklingo/features/profile/presentation/profile_providers.dart";
import "package:walklingo/features/tracking/domain/step_tracking_service.dart";
import "package:walklingo/features/tracking/presentation/step_tracking_providers.dart";
import "package:walklingo/features/tracking/presentation/walk_providers.dart";
import "package:walklingo/features/tracking/presentation/walk_session_panel.dart";
import "package:walklingo/features/vocabulary/domain/daily_plan.dart";
import "package:walklingo/features/vocabulary/domain/daily_plan_targets.dart";
import "package:walklingo/features/vocabulary/presentation/vocabulary_providers.dart";

class _FakeStepTrackingService implements StepTrackingService {
  @override
  Future<bool> ensurePermissions() async => true;

  @override
  Stream<int> watchTotalSteps() => const Stream<int>.empty();
}

void main() {
  testWidgets(
    "Bắt đầu phiên khi chưa có todo thì mở thiết lập todo",
    (tester) async {
      SharedPreferences.setMockInitialValues(const {
        "wl_steps_today_accumulated": 0,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stepTrackingServiceProvider.overrideWith(
              (ref) => _FakeStepTrackingService(),
            ),
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(const AppUser(id: "u1")),
            ),
            dailyPlanForSelectedDateProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
            userProfileProvider.overrideWith((ref) => Future.value(null)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WalkSessionPanel(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Bắt đầu phiên"), findsOneWidget);
      await tester.tap(find.text("Bắt đầu phiên"));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WalkSessionPanel)),
      );
      final activeSession = container.read(activeWalkingSessionProvider);
      expect(activeSession, isNull);
      expect(find.text("Thiết lập hôm nay"), findsOneWidget);
    },
  );

  testWidgets(
    "Bắt đầu phiên khi đã có todo thì tạo session mới",
    (tester) async {
      SharedPreferences.setMockInitialValues(const {
        "wl_steps_today_accumulated": 0,
      });

      final now = DateTime.now();
      final dateKey =
          "${now.year.toString().padLeft(4, "0")}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";
      final plan = DailyPlan(
        dateKey: dateKey,
        targets: const DailyPlanTargets(
          newWordsCount: 1,
          audioTrackGoal: 1,
          stepGoal: 1000,
        ),
        items: const [],
        percentComplete: 0,
        completedCount: 0,
        totalCount: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stepTrackingServiceProvider.overrideWith(
              (ref) => _FakeStepTrackingService(),
            ),
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(const AppUser(id: "u1")),
            ),
            dailyPlanForSelectedDateProvider.overrideWith(
              (ref) => Stream.value(plan),
            ),
            userProfileProvider.overrideWith((ref) => Future.value(null)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WalkSessionPanel(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text("Bắt đầu phiên"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WalkSessionPanel)),
      );
      expect(container.read(activeWalkingSessionProvider), isNotNull);
    },
  );

  testWidgets(
    "Nhấn refresh sẽ reset số bước hôm nay về 0",
    (tester) async {
      final now = DateTime.now();
      final todayKey =
          "${now.year.toString().padLeft(4, "0")}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";

      SharedPreferences.setMockInitialValues({
        "wl_steps_today_day": todayKey,
        "wl_steps_today_accumulated": 123,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stepTrackingServiceProvider.overrideWith(
              (ref) => _FakeStepTrackingService(),
            ),
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(const AppUser(id: "u1")),
            ),
            dailyPlanForSelectedDateProvider.overrideWith(
              (ref) => Stream.value(
                DailyPlan(
                  dateKey: todayKey,
                  targets: const DailyPlanTargets(
                    newWordsCount: 1,
                    audioTrackGoal: 1,
                    stepGoal: 1000,
                  ),
                  items: const [],
                  percentComplete: 0,
                  completedCount: 0,
                  totalCount: 0,
                ),
              ),
            ),
            userProfileProvider.overrideWith((ref) => Future.value(null)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WalkSessionPanel(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text("123 bước"), findsOneWidget);

      await tester.tap(find.byTooltip("Reset bước hôm nay"));
      await tester.pumpAndSettle();

      expect(find.text("0 bước"), findsWidgets);
      expect(find.text("Đã reset số bước hôm nay."), findsOneWidget);
    },
  );
}

