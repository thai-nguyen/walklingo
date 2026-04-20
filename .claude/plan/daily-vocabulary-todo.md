# Implementation Plan: Daily Vocabulary Todo, Calendar & Spaced Review

## Task Type
- [x] Frontend
- [x] Backend (Firestore + API client)
- [x] Fullstack

## Context (WalkLingo baseline)
- **Shell + GoRouter**: `lib/app/router.dart` — `StatefulShellRoute` với các tab shell; **`initialLocation` = `/today`** (tab **“Hôm nay”** — calendar + todo); các tab khác giữ `/listen`, `/player`, `/walk`, `/history`, profile.
- **State**: Riverpod; user: `auth_providers`, profile: `profile` + `firestore_user_profile_repository`.
- **Mẫu lưu trữ từng user**: `users/{uid}` (profile) — vocabulary nên theo cùng namespace hoặc subcollection.
- **API từ vựng**: [Free Dictionary API](https://dictionaryapi.dev/) — `GET https://api.dictionaryapi.dev/api/v2/entries/en/{word}` (chỉ **tiếng Anh**; từ tiếng Việt cần bước chuẩn hóa — xem Rủi ro).

## Technical Solution (tổng hợp)

### 1) Mô hình dữ liệu (Firestore)
Đề xuất (có thể tinh chỉnh sau khi chốt rule nghiệp vụ):

- **`users/{uid}/dailyPlans/{yyyyMMdd}`** — một document cho **một ngày** (timezone: local device hoặc cố định `Asia/Ho_Chi_Minh` — cần chọn một và ghi vào rule).
  - `dateKey`: string `yyyy-MM-dd`
  - `targets`: `{ newWordsCount, audioTrackGoal, stepGoal }` — **audio** đo bằng **số track/chapter đã nghe** trong ngày (không dùng phút/session).
  - `items`: array hoặc subcollection **DailyTodoItem**
    - Loại enum: `reviewOldWord | newWord | audioQuota | stepsQuota`
    - Cho từ: `wordId` / snapshot lean, `completed`, `completedAt`
  - `percentComplete`: số nguyên 0–100 (derived hoặc lưu để query nhanh)
  - `completedCount` / `totalCount`

- **`users/{uid}/vocabulary/{wordId}`** — từ đã học (lemma tiếng Anh chuẩn hóa làm id hoặc hash).
  - `lemma`, `sourceInput` (VN/EN user typed), `phonetic`, `audioUrl` (chọn một URL từ `phonetics[]`), `definitionsSummary` (text), `examples[]`, `meaningsRaw` (optional Map), `learnedAt`, `lastReviewedAt`, `nextReviewEligibleAfter` (hoặc chỉ dùng `learnedAt` + query “> 7 ngày”).

- **`users/{uid}/dailyHistory/{yyyyMMdd}`** (optional gộp vào `dailyPlans` nếu đủ field) — snapshot % hoàn thành và timestamp để calendar đọc nhẹ.

### 2) Luồng “5 từ cũ sau 1 tuần”
- Query `vocabulary` where `learnedAt <= now - 7 days` và `lastReviewedAt` null hoặc `< learnedAt + 7d`, sort, limit 5 (chiến lược **FIFO** hoặc **SRS đơn giản**).
- Khi **mở ngày mới** hoặc **bootstrap home**: merge vào todo hôm nay 5 item loại `reviewOldWord` (không trùng từ trong ngày).

### 3) Dictionary API client
- HTTP GET; parse JSON mẫu user cung cấp.
- Map sang domain: `DictionaryEntry` (word, phonetic, phonetics[], meanings[] → pick first definition + example per POS hoặc flatten).
- **Rate limit / lỗi**: retry nhẹ, cache local (Hive/`shared_preferences` optional) theo lemma.
- **404**: từ không hợp lệ → báo UI, không lưu Firestore.

### 4) Đầu vào tiếng Việt vs tiếng Anh
- Dictionary chỉ nhận **English lemma**.
- **Phương án A**: user chỉ nhập tiếng Anh (đơn giản).
- **Phương án B**: nhập tiếng Việt → gọi **dịch EN** (Google Cloud Translate, LibreTranslate self-host, hoặc heuristic từ điển offline) → lấy candidate English → user xác nhận → gọi dictionary API.
- Kế hoạch triển khai nên **tách interface** `WordNormalizeService` để đổi backend sau.

### 5) Gợi ý từ nhanh (suggestions)
- Static list theo band (A1/A2), hoặc **random từ wordlist asset** (`assets/words.json`), hoặc API từ khác; user chọn chip → append vào danh sách nhập trong ngày.

### 6) UI/UX
- **Tab “Hôm nay”** là **màn đầu sau đăng nhập** (`initialLocation`): **Calendar** (package `table_calendar` hoặc `syncfusion_flutter_calendar` nhẹ) + panel **Todo** của ngày đang chọn (mặc định **hôm nay**).
- Chọn ngày trên lịch → đọc `dailyPlans` / history → hiển thị % và danh sách mục.
- **Chỉ `dateKey == hôm nay`** mới là **chế độ tương tác**: user có thể **tick/bỏ tick** các mục **từ vựng (ôn + mới)** và nhận onboarding “tạo todo ngày” / chỉnh danh sách **cho hôm nay** (theo scope đã có).
- **Ngày cũ (`dateKey < hôm nay`)**: **hoàn toàn không tương tác** — chỉ hiển thị snapshot (%, trạng thái đã hoàn thành lúc đó): **không** checkbox bấm được (hoặc ẩn hẳn control), **không** sửa target, **không** tick/bỏ tick **từ vựng**, **không** chỉnh todo — kể cả ôn/mới (**read-only**). Audio/steps trên ngày cũ cũng chỉ là **nhãn trạng thái** đã ghi nhận (không đồng bộ walk/listen để đổi quá khứ).
- **First-open flow**: sheet/dialog “Hôm nay bạn muốn học bao nhiêu từ mới?” → nhập danh sách / chọn suggest → nút “Tạo todo ngày”.
- **Trang cá nhân / “Từ đã học”**: route mới hoặc section trong `ProfileScreen` — danh sách có search, tap xem chi tiết (IPA, audio `just_audio`/`audioplayers` preview).

### 7) Liên kết Walk + Listen quota (đã chốt: **hoàn thành tự động**)
- **Audio (track)**: đếm **số track/chapter hoàn thành** trong ngày (theo `dateKey` local) — nguồn từ **lịch sử nghe** (`listen_sessions` hoặc log tương đương: mỗi lần phát xong một chapter/book episode = +1 track theo rule đã định nghĩa). So sánh với `audioTrackGoal` trong `dailyPlans`; khi `tracksToday >= audioTrackGoal` → mục todo **audio** tự **completed** (ghi `completedAt`).
- **Bước**: đọc bước trong ngày (pedometer aggregate / delta theo ngày) — so với `stepGoal`; khi đạt ngưỡng → mục todo **steps** tự **completed**.
- **Từ vựng** (ôn + mới): **tick thủ công chỉ trong ngày hôm nay** (`dateKey == today`). Ngày cũ: **không** gửi mutation tick lên Firestore. (Tùy chọn sau: auto-complete từ khi đã “học xong” — nếu có thì **chỉ áp** cho plan **hôm nay**.)

### 8) Đánh giá phần trăm & lịch sử
- `percentComplete = round(100 * completedItems / totalItems)` với totalItems = 5 + N + **1** (audio) + **1** (steps) — hai slot audio/steps mỗi slot một boolean hoàn thành (do **tự động** khi đạt track/steps).
- Ghi `dailyHistory` khi có thay đổi (**toggle từ vựng chỉ khi plan là hôm nay**, hoặc listener cập nhật audio/steps cho **hôm nay**). **Ngày quá khứ**: documents **immutable** từ góc nhìn client — không ghi thêm toggle từ UI lịch sử.

## Implementation Steps

1. **Domain + model** — `VocabularyWord`, `DailyTodoItem`, `DailyPlan`, enums; pure Dart, test unit parse %.
2. **Dictionary client** — `dictionary_api_client.dart`; DTO khớp JSON mẫu; map failure → `AppFailure`.
3. **Firestore repositories** — `vocabulary_repository`, `daily_plan_repository`; rules: chỉ `request.auth.uid == uid`.
4. **Providers** — `todayPlanProvider`, `calendarMonthProvider`, `vocabularyListProvider`, `reviewWordsProvider` (5 từ/tuần).
5. **Onboarding nhập ngày** — dialog số từ mới + text field multi-line parse từ (split comma/newline); suggest chips.
6. **Resolve từ** — normalize → API; loading state per từ; batch với độ trễ nhỏ tránh 429.
7. **Todo UI** — checklist **chỉ bật control** khi `selectedDate == today`; ngày cũ: list **read-only** (icon trạng thái thay checkbox nếu cần); section: Old 5 | New N | Audio | Steps; progress ring.
8. **Calendar UI** — highlight ngày có dữ liệu; tap ngày cũ → panel **chỉ xem** (no `onToggle`).
9. **Profile / learned words** — list + detail sheet (play pronunciation).
10. **Wire Walk/Listen** — subscribe provider bước + **đếm track/ngày** từ listen history; cập nhật auto-complete **chỉ** cho ngày **hôm nay** (`dateKey == today`).
11. **Firestore indexes** — composite nếu query vocabulary theo ngày.
12. **QA** — offline, API fail, duplicate word same day, timezone midnight; **regression**: chọn ngày cũ không gọi write.

## Key Files (dự kiến)

| File | Operation | Description |
|------|-----------|-------------|
| `lib/app/router.dart` | Modify | Thêm branch tab **`/today`** (“Hôm nay”), đặt **`initialLocation: "/today"`** |
| `lib/features/profile/presentation/profile_screen.dart` | Modify | Link “Từ đã học”, hoặc sub-route |
| `lib/features/profile/data/firestore_user_profile_repository.dart` | Reference | Pattern CRUD Firestore hiện có |
| `lib/core/firebase_providers.dart` | Reference | Firebase instances |
| `lib/features/vocabulary/` (new) | Create | domain/data/presentation — todo, calendar, dictionary |
| `firestore.rules` | Modify | Rules cho subcollections vocabulary & dailyPlans |

## Risks and Mitigation

| Risk | Mitigation |
|------|------------|
| Dictionary API chỉ EN; input VN | `WordNormalizeService` + optional translate provider; UX xác nhận từ đích |
| Rate limit / network | Debounce, cache lemma, retry exponential |
| Timezone “ngày hôm nay” | Lưu `dateKey` theo local midnight; document behavior |
| Trùng từ trong review + new | Dedupe theo lemma khi build todo |
| Audio/steps không đồng bộ realtime | Listener Riverpod hoặc periodic refresh; hiển thị “đang cập nhật” |

## SESSION_ID (for `/ccg:execute`)
- **CODEX_SESSION**: `not_available` — external Codex analyzer không được gọi trong phiên Cursor này.
- **GEMINI_SESSION**: `not_available` — external Gemini analyzer không được gọi trong phiên Cursor này.

*Nếu workflow nội bộ yêu cầu session thật, chạy lại bước multi-model trong môi trường có `codeagent-wrapper` và điền session vào đây.*

## Đã chốt (product rules)
| Chủ đề | Quyết định |
|--------|------------|
| Audio / Steps hoàn thành | **Tự động** khi đạt chỉ tiêu (không tick tay cho hai mục này). |
| Đơn vị “audio” trong todo | **Track** (chapter/episode đã nghe — định nghĩa cụ thể khi implement đếm từ `listen_sessions`). |
| Todo ngày cũ | **Không sửa, không tương tác** — chỉ xem % / trạng thái (read-only). |
| Từ vựng ôn/mới | **Chỉ tick được trên hôm nay**; ngày cũ **không** tick / không mutation. |
| Tab mặc định | **`/today`** (“Hôm nay”) là **`initialLocation`** sau login. |

---

## Pseudocode Sketches

### Parse dictionary response (simplified)
```dart
class DictionaryMapper {
  static VocabularyWord fromJson(Map<String, dynamic> json, String lemma) {
    final phonetics = (json['phonetics'] as List?)?.cast<Map>();
    final audioUrl = phonetics?.map((p) => p['audio'] as String?).firstWhere((u) => u != null && u!.isNotEmpty, orElse: () => null);
    final meanings = json['meanings'] as List?;
    // flatten definitions + examples for display
    return VocabularyWord(
      lemma: lemma,
      phonetic: json['phonetic'] as String?,
      definitionPreview: ...,
      examplePreview: ...,
      pronunciationUrl: audioUrl,
      raw: json,
    );
  }
}
```

### Build today’s todo items
```dart
Future<DailyPlan> buildTodayPlan(uid, dateKey, targets, reviewWords, newWords) async {
  final items = <TodoItem>[
    ...reviewWords.take(5).map((w) => TodoItem.review(w)),
    ...newWords.map((w) => TodoItem.newWord(w)),
    TodoItem.audioQuota(trackTarget: targets.audioTrackGoal), // completed auto
    TodoItem.stepsQuota(stepTarget: targets.stepGoal),       // completed auto
  ];
  return DailyPlan(dateKey: dateKey, items: items, ...);
}
```

### Auto-complete audio / steps (today only)
```dart
void syncWalkListenCompletion(DailyPlan plan, {required bool isToday}) {
  if (!isToday) return; // past days: never mutate from walk/listen
  if (tracksCompletedToday >= plan.targets.audioTrackGoal) plan.markAudioDone();
  if (stepsCompletedToday >= plan.targets.stepGoal) plan.markStepsDone();
}
```

### Toggle vocabulary (today only)
```dart
Future<void> onVocabularyToggle(DailyPlan plan, String itemId, bool done) async {
  if (!plan.isToday) return; // past days: no interaction, no Firestore write
  await repository.updateWordItemCompletion(plan.dateKey, itemId, done);
}
```

---

*Plan generated without modifying production source files.*
