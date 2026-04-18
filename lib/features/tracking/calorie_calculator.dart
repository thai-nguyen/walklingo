/// Ước lượng kcal tiêu hao khi đi bộ từ số bước.
double estimateWalkingKcal({
  required int steps,
  double? weightKg,
  double? heightCm,
}) {
  if (steps <= 0) return 0;
  if (weightKg != null && weightKg > 0 && heightCm != null && heightCm > 0) {
    final strideM = heightCm * 0.414 / 100.0;
    final distKm = steps * strideM / 1000.0;
    return distKm * weightKg * 0.75;
  }
  return steps * 0.04;
}
