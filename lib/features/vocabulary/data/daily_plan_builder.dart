import "../domain/daily_plan.dart";
import "../domain/daily_plan_targets.dart";
import "../domain/daily_todo_item.dart";
import "../domain/daily_todo_kind.dart";
import "../domain/learned_word.dart";
import "dictionary_api_client.dart";

class SelectedTrackTarget {
  const SelectedTrackTarget({
    required this.id,
    required this.title,
    required this.audioUrl,
  });

  final String id;
  final String title;
  final String audioUrl;
}

String lemmaIdFromWord(String word) =>
    word.trim().toLowerCase().replaceAll(RegExp(r"\s+"), "_");

/// Ghép plan: tối đa 5 ôn + N từ mới + 2 quota (audio, bước).
DailyPlan buildDailyPlan({
  required String dateKey,
  required DailyPlanTargets targets,
  required List<LearnedWord> reviewCandidates,
  required List<DictionaryEntryDto> newEntries,
  required List<SelectedTrackTarget> selectedTracks,
}) {
  final items = <DailyTodoItem>[];
  final seen = <String>{};

  for (final r in reviewCandidates.take(5)) {
    if (seen.contains(r.lemmaId)) continue;
    seen.add(r.lemmaId);
    items.add(
      DailyTodoItem(
        id: "review_${r.lemmaId}",
        kind: DailyTodoKind.reviewOldWord,
        lemma: r.lemma,
        phonetic: r.phonetic,
        definitionPreview: r.definitionPreview,
      ),
    );
  }

  for (final n in newEntries) {
    final lid = lemmaIdFromWord(n.word);
    if (seen.contains(lid)) continue;
    seen.add(lid);
    items.add(
      DailyTodoItem(
        id: "new_$lid",
        kind: DailyTodoKind.newWord,
        lemma: n.word,
        phonetic: n.phonetic,
        definitionPreview: n.definitionPreview,
      ),
    );
  }

  items.add(
    DailyTodoItem(
      id: "quota_audio",
      kind: DailyTodoKind.audioQuota,
      definitionPreview: "Đã chọn ${selectedTracks.length} track để nghe hôm nay",
      trackIds: selectedTracks.map((e) => e.id).toList(),
      trackTitles: selectedTracks.map((e) => e.title).toList(),
      trackUrls: selectedTracks.map((e) => e.audioUrl).toList(),
    ),
  );
  items.add(
    const DailyTodoItem(id: "quota_steps", kind: DailyTodoKind.stepsQuota),
  );

  return DailyPlan(
    dateKey: dateKey,
    targets: targets,
    items: items,
    percentComplete: 0,
    completedCount: 0,
    totalCount: 0,
  ).recalculate();
}

LearnedWord learnedWordFromDto(DictionaryEntryDto dto, String rawInput) {
  final lid = lemmaIdFromWord(dto.word);
  return LearnedWord(
    lemmaId: lid,
    lemma: dto.word,
    sourceInput: rawInput.trim().isEmpty ? null : rawInput.trim(),
    phonetic: dto.phonetic,
    pronunciationUrl: dto.phoneticsAudioUrl,
    definitionPreview: dto.definitionPreview,
    examplePreview: dto.examplePreview,
    learnedAt: DateTime.now(),
  );
}
