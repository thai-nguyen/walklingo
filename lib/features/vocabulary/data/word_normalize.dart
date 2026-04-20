/// Chuẩn hóa input thành lemma tra cứu (Free Dictionary chỉ EN).
String normalizeEnglishLemma(String raw) {
  var s = raw.trim().toLowerCase();
  if (s.isEmpty) return "";
  s = s.replaceAll(RegExp(r"\s+"), " ");
  return s.replaceAll(RegExp(r"[^a-z\-\s']"), "").trim();
}

List<String> splitWordInput(String block) {
  final lines = block.split(RegExp(r"[\n,;]+"));
  final out = <String>[];
  for (final line in lines) {
    final t = line.trim();
    if (t.isNotEmpty) out.add(t);
  }
  return out;
}
