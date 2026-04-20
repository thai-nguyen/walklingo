import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/failures.dart";
import "../domain/daily_plan.dart";
import "../domain/daily_plan_repository.dart";
import "../domain/date_calendar.dart";

class FirestoreDailyPlanRepository implements DailyPlanRepository {
  FirestoreDailyPlanRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _planRef(String uid, String dateKey) {
    final id = planDocIdFromDateKey(dateKey);
    return _firestore
        .collection("users")
        .doc(uid)
        .collection("dailyPlans")
        .doc(id);
  }

  Map<String, dynamic> _normalizeFromStore(Map<String, dynamic> d) {
    final out = Map<String, dynamic>.from(d);
    final items = out["items"];
    if (items is List) {
      out["items"] = items.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final ca = m["completedAt"];
        if (ca is Timestamp) {
          m["completedAt"] = ca.millisecondsSinceEpoch;
        }
        return m;
      }).toList();
    }
    return out;
  }

  @override
  Stream<DailyPlan?> watchDailyPlan(String uid, String dateKey) {
    return _planRef(uid, dateKey).snapshots().map((s) {
      if (!s.exists || s.data() == null) return null;
      final raw = _normalizeFromStore(s.data()!);
      return DailyPlan.fromFirestore(dateKey, raw);
    });
  }

  @override
  Future<void> saveDailyPlan(String uid, DailyPlan plan) async {
    try {
      final next = plan.recalculate();
      final data = Map<String, dynamic>.from(next.toFirestore());
      data["updatedAt"] = FieldValue.serverTimestamp();
      await _planRef(uid, plan.dateKey).set(data, SetOptions(merge: true));
    } catch (e, st) {
      Error.throwWithStackTrace(
        FirestoreFailure("Không lưu kế hoạch ngày: $e"),
        st,
      );
    }
  }

  @override
  Future<void> updateTodoItemCompletion(
    String uid,
    String dateKey,
    String itemId,
    bool completed,
  ) async {
    if (!isTodayDateKey(dateKey)) {
      return;
    }
    try {
      await _firestore.runTransaction((txn) async {
        final ref = _planRef(uid, dateKey);
        final snap = await txn.get(ref);
        if (!snap.exists || snap.data() == null) return;
        final raw = _normalizeFromStore(snap.data()!);
        final plan = DailyPlan.fromFirestore(dateKey, raw);
        final items = plan.items
            .map(
              (i) => i.id == itemId
                  ? i.copyWith(
                      completed: completed,
                      completedAt: completed ? DateTime.now() : null,
                    )
                  : i,
            )
            .toList();
        final next = DailyPlan(
          dateKey: plan.dateKey,
          targets: plan.targets,
          items: items,
          percentComplete: plan.percentComplete,
          completedCount: plan.completedCount,
          totalCount: plan.totalCount,
        ).recalculate();
        final payload = Map<String, dynamic>.from(next.toFirestore());
        payload["updatedAt"] = FieldValue.serverTimestamp();
        txn.set(ref, payload);
      });
    } catch (e, st) {
      Error.throwWithStackTrace(
        FirestoreFailure("Không cập nhật mục todo: $e"),
        st,
      );
    }
  }

  @override
  Future<void> applyAutoQuotas(
    String uid,
    String dateKey, {
    required int tracksToday,
    required int stepsToday,
  }) async {
    if (!isTodayDateKey(dateKey)) return;
    try {
      await _firestore.runTransaction((txn) async {
        final ref = _planRef(uid, dateKey);
        final snap = await txn.get(ref);
        if (!snap.exists || snap.data() == null) return;
        final raw = _normalizeFromStore(snap.data()!);
        final plan = DailyPlan.fromFirestore(dateKey, raw);
        final t = plan.targets;
        var items = [...plan.items];
        items = items.map((i) {
          if (i.id == "quota_audio" &&
              !i.completed &&
              tracksToday >= t.audioTrackGoal) {
            return i.copyWith(completed: true, completedAt: DateTime.now());
          }
          if (i.id == "quota_steps" &&
              !i.completed &&
              stepsToday >= t.stepGoal) {
            return i.copyWith(completed: true, completedAt: DateTime.now());
          }
          return i;
        }).toList();
        final next = DailyPlan(
          dateKey: plan.dateKey,
          targets: plan.targets,
          items: items,
          percentComplete: plan.percentComplete,
          completedCount: plan.completedCount,
          totalCount: plan.totalCount,
        ).recalculate();
        final payload = Map<String, dynamic>.from(next.toFirestore());
        payload["updatedAt"] = FieldValue.serverTimestamp();
        txn.set(ref, payload);
      });
    } catch (_) {
      // Tránh spam lỗi khi offline
    }
  }
}
