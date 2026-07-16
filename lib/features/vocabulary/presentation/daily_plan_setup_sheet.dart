import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "../../../core/failures.dart";
import "../../auth/presentation/auth_providers.dart";
import "../../librivox_books/domain/librivox_book_chapter.dart";
import "../../librivox_books/presentation/librivox_books_providers.dart";
import "../data/daily_plan_builder.dart";
import "../data/dictionary_api_client.dart";
import "../data/word_normalize.dart";
import "../domain/daily_plan_targets.dart";
import "../domain/date_calendar.dart";
import "vocabulary_providers.dart";

Future<void> showDailyPlanSetupSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: DailyPlanSetupSheet(onClose: () => Navigator.of(ctx).pop()),
    ),
  );
}

class DailyPlanSetupSheet extends ConsumerStatefulWidget {
  const DailyPlanSetupSheet({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<DailyPlanSetupSheet> createState() =>
      _DailyPlanSetupSheetState();
}

class _DailyPlanSetupSheetState extends ConsumerState<DailyPlanSetupSheet> {
  final _stepCtl = TextEditingController(text: "5000");
  final _wordsCtl = TextEditingController();
  String? _selectedBookId;
  String? _selectedBookTitle;
  final Set<String> _selectedTrackIds = {};
  final Map<String, String> _selectedTrackTitles = {};
  final Map<String, String> _selectedTrackUrls = {};
  bool _tracksExpanded = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _stepCtl.dispose();
    _wordsCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = ref.read(authStateChangesProvider).valueOrNull?.id;
    if (uid == null) return;

    final stepGoal = int.tryParse(_stepCtl.text.trim()) ?? 3000;
    final pieces = splitWordInput(_wordsCtl.text);
    if (pieces.isEmpty) {
      setState(() => _error = l10n.errorEnterAtLeastOneWord);
      return;
    }
    if (_selectedTrackIds.isEmpty) {
      setState(() => _error = l10n.errorSelectAtLeastOneTrack);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final dict = ref.read(dictionaryApiClientProvider);
    final vocab = ref.read(vocabularyRepositoryProvider);
    final daily = ref.read(dailyPlanRepositoryProvider);

    final dtos = <DictionaryEntryDto>[];
    final raws = <String>[];
    final fails = <String>[];
    for (var i = 0; i < pieces.length; i++) {
      final raw = pieces[i];
      await Future<void>.delayed(Duration(milliseconds: i * 120));
      try {
        final dto = await dict.lookup(raw);
        dtos.add(dto);
        raws.add(raw);
      } on DictionaryFailure catch (e) {
        fails.add("$raw: $e");
      } catch (e) {
        fails.add("$raw: $e");
      }
    }

    if (dtos.isEmpty) {
      setState(() {
        _busy = false;
        _error = fails.isEmpty ? l10n.errorNoWordsLookedUp : fails.join("\n");
      });
      return;
    }

    try {
      final review = await vocab.fetchReviewCandidates(uid, limit: 5);
      final todayKey = dateKeyFromDateTime(DateTime.now());
      final targets = DailyPlanTargets(
        newWordsCount: dtos.length,
        audioTrackGoal: _selectedTrackIds.length.clamp(1, 999),
        stepGoal: stepGoal.clamp(100, 200000),
      );
      final selectedTracks = _selectedTrackIds
          .map(
            (id) => SelectedTrackTarget(
              id: id,
              title: _selectedTrackTitles[id] ?? id,
              audioUrl: _selectedTrackUrls[id] ?? "",
            ),
          )
          .where((e) => e.audioUrl.isNotEmpty)
          .toList();

      for (var i = 0; i < dtos.length; i++) {
        final w = learnedWordFromDto(dtos[i], raws[i]);
        await vocab.upsertWord(uid, w);
      }

      final plan = buildDailyPlan(
        dateKey: todayKey,
        targets: targets,
        reviewCandidates: review,
        newEntries: dtos,
        selectedTracks: selectedTracks,
        audioQuotaPreview: l10n.audioQuotaPreview(selectedTracks.length),
      );
      await daily.saveDailyPlan(uid, plan);

      if (mounted) {
        widget.onClose();
        final msg = fails.isEmpty
            ? l10n.snackbarPlanCreated
            : l10n.snackbarPlanCreatedWithSkips(fails.length);
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      setState(() => _error = l10n.genericError("$e"));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sug = ref.watch(wordSuggestionsProvider);
    final booksAsync = ref.watch(librivoxBooksStreamProvider);
    final chaptersAsync = _selectedBookId == null
        ? const AsyncValue<List<LibrivoxBookChapter>>.data([])
        : ref.watch(librivoxChaptersStreamProvider(_selectedBookId!));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.setupTodayTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.tracksSelectedCount(_selectedTrackIds.length),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _tracksExpanded = !_tracksExpanded),
                  icon: Icon(
                    _tracksExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  label: Text(_tracksExpanded ? l10n.collapse : l10n.expand),
                ),
              ],
            ),
            booksAsync.when(
              data: (books) => DropdownButtonFormField<String>(
                initialValue: _selectedBookId,
                decoration: InputDecoration(
                  labelText: l10n.selectLibrivoxBook,
                  border: const OutlineInputBorder(),
                ),
                items: books
                    .map(
                      (b) =>
                          DropdownMenuItem(value: b.id, child: Text(b.title)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  final b = books.firstWhere((e) => e.id == v);
                  setState(() {
                    _selectedBookId = v;
                    _selectedBookTitle = b.title;
                    _selectedTrackIds.clear();
                    _selectedTrackTitles.clear();
                    _selectedTrackUrls.clear();
                    _tracksExpanded = true;
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(l10n.genericError("$e")),
            ),
            if (_tracksExpanded) ...[
              const SizedBox(height: 8),
              chaptersAsync.when(
                data: (chapters) {
                  if (_selectedBookId == null) {
                    return Text(l10n.selectBookForTracks);
                  }
                  if (chapters.isEmpty) {
                    return Text(l10n.bookNoChapters);
                  }
                  return Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: chapters.length,
                      itemBuilder: (context, i) {
                        final ch = chapters[i];
                        final enabled = ch.audioUrl.isNotEmpty;
                        final key = "${_selectedBookId}_${ch.id}";
                        final selected = _selectedTrackIds.contains(key);
                        return CheckboxListTile(
                          dense: true,
                          value: selected,
                          onChanged: !enabled
                              ? null
                              : (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedTrackIds.add(key);
                                      final title = l10n.trackTitleSeparator(
                                        _selectedBookTitle ?? "",
                                        ch.title,
                                      );
                                      _selectedTrackTitles[key] = title.trim();
                                      _selectedTrackUrls[key] = ch.audioUrl;
                                    } else {
                                      _selectedTrackIds.remove(key);
                                      _selectedTrackTitles.remove(key);
                                      _selectedTrackUrls.remove(key);
                                    }
                                  });
                                },
                          title: Text(ch.title),
                          subtitle: enabled
                              ? null
                              : Text(l10n.missingAudioUrl),
                        );
                      },
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(l10n.genericError("$e")),
              ),
            ] else if (_selectedTrackIds.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selectedTrackIds
                    .map(
                      (id) => Chip(label: Text(_selectedTrackTitles[id] ?? id)),
                    )
                    .toList(),
              ),
            const SizedBox(height: 6),
            Text(
              l10n.trackGoalAutoHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stepCtl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.stepGoalLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wordsCtl,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: l10n.wordListLabel,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            sug.when(
              data: (words) => Wrap(
                spacing: 6,
                runSpacing: 6,
                children: words.take(12).map((w) {
                  return ActionChip(
                    label: Text(w),
                    onPressed: () {
                      final t = _wordsCtl.text.trim();
                      _wordsCtl.text = t.isEmpty ? w : "$t\n$w";
                      _wordsCtl.selection = TextSelection.collapsed(
                        offset: _wordsCtl.text.length,
                      );
                    },
                  );
                }).toList(),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(l10n.genericError("$e")),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.createDailyTodoButton),
            ),
          ],
        ),
      ),
    );
  }
}
