class LearnedWord {
  const LearnedWord({
    required this.lemmaId,
    required this.lemma,
    this.sourceInput,
    this.phonetic,
    this.pronunciationUrl,
    this.definitionPreview,
    this.examplePreview,
    required this.learnedAt,
    this.lastReviewedAt,
  });

  final String lemmaId;
  final String lemma;
  final String? sourceInput;
  final String? phonetic;
  final String? pronunciationUrl;
  final String? definitionPreview;
  final String? examplePreview;
  final DateTime learnedAt;
  final DateTime? lastReviewedAt;

  Map<String, dynamic> toFirestore() => {
    "lemma": lemma,
    if (sourceInput != null) "sourceInput": sourceInput,
    if (phonetic != null) "phonetic": phonetic,
    if (pronunciationUrl != null) "pronunciationUrl": pronunciationUrl,
    if (definitionPreview != null) "definitionPreview": definitionPreview,
    if (examplePreview != null) "examplePreview": examplePreview,
    "learnedAt": learnedAt.millisecondsSinceEpoch,
    if (lastReviewedAt != null)
      "lastReviewedAt": lastReviewedAt!.millisecondsSinceEpoch,
  };
}
