/// Ngày theo lịch local; `dateKey` = `yyyy-MM-dd`, id Firestore = `yyyyMMdd`.
String dateKeyFromDateTime(DateTime d) {
  final l = DateTime(d.year, d.month, d.day);
  final y = l.year.toString().padLeft(4, "0");
  final m = l.month.toString().padLeft(2, "0");
  final day = l.day.toString().padLeft(2, "0");
  return "$y-$m-$day";
}

String planDocIdFromDateKey(String dateKey) => dateKey.replaceAll("-", "");

DateTime parseDateKeyToLocalDay(String dateKey) {
  final parts = dateKey.split("-");
  if (parts.length != 3) return DateTime.now();
  final y = int.tryParse(parts[0]) ?? DateTime.now().year;
  final m = int.tryParse(parts[1]) ?? 1;
  final d = int.tryParse(parts[2]) ?? 1;
  return DateTime(y, m, d);
}

bool isTodayDateKey(String dateKey) =>
    dateKeyFromDateTime(DateTime.now()) == dateKey;
