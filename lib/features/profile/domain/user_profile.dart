class UserProfile {
  const UserProfile({
    required this.uid,
    this.displayName,
    this.weightKg,
    this.heightCm,
  });

  final String uid;
  final String? displayName;
  final double? weightKg;
  final double? heightCm;
}
