class UserProfile {
  const UserProfile({
    required this.uid,
    this.displayName,
    this.avatarUrl,
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
  });

  final String uid;
  final String? displayName;
  final String? avatarUrl;
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
}
