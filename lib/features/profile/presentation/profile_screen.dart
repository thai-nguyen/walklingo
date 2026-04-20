import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../auth/presentation/auth_providers.dart";
import "../domain/user_profile.dart";
import "profile_providers.dart";

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _picker = ImagePicker();
  bool _uploadingAvatar = false;
  String? _message;

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  Future<void> _uploadAvatar(String uid, UserProfile? current) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;
    setState(() {
      _uploadingAvatar = true;
      _message = null;
    });
    try {
      final bytes = await picked.readAsBytes();
      final url = await ref.read(userProfileRepositoryProvider).uploadAvatar(
            uid: uid,
            bytes: bytes,
            contentType: "image/jpeg",
          );
      await ref.read(userProfileRepositoryProvider).saveProfile(
            UserProfile(
              uid: uid,
              displayName: current?.displayName,
              avatarUrl: url,
              age: current?.age,
              gender: current?.gender,
              weightKg: current?.weightKg,
              heightCm: current?.heightCm,
            ),
          );
      ref.invalidate(userProfileProvider);
      if (mounted) setState(() => _message = "Đã cập nhật avatar.");
    } catch (e) {
      if (mounted) setState(() => _message = "Upload avatar lỗi: $e");
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  String _genderLabel(String? gender) {
    switch (gender) {
      case "male":
        return "Nam";
      case "female":
        return "Nữ";
      case "other":
        return "Khác";
      default:
        return "—";
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateChangesProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ")),
      body: auth.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Chưa đăng nhập."));
          }
          return profile.when(
            data: (p) {
              final avatarUrl = p?.avatarUrl;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundImage:
                                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl == null
                                    ? const Icon(Icons.person, size: 44)
                                    : null,
                              ),
                              IconButton.filled(
                                tooltip: "Upload avatar",
                                onPressed: _uploadingAvatar
                                    ? null
                                    : () => _uploadAvatar(user.id, p),
                                icon: _uploadingAvatar
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            p?.displayName?.isNotEmpty == true
                                ? p!.displayName!
                                : "Chưa đặt tên hiển thị",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? user.id,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                label: "Tuổi",
                                value: p?.age?.toString() ?? "—",
                              ),
                              _InfoChip(
                                label: "Giới tính",
                                value: _genderLabel(p?.gender),
                              ),
                              _InfoChip(
                                label: "Cân nặng",
                                value: p?.weightKg != null
                                    ? "${p!.weightKg} kg"
                                    : "—",
                              ),
                              _InfoChip(
                                label: "Chiều cao",
                                value: p?.heightCm != null
                                    ? "${p!.heightCm} cm"
                                    : "—",
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => context.push("/profile/edit"),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text("Edit thông tin cơ bản"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 8),
                    Text(_message!),
                  ],
                  Text(
                    "Tiện ích",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.book_outlined),
                      title: const Text("Từ đã học"),
                      subtitle: const Text("Danh sách từ vựng đã lưu"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push("/learned-words"),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.cloud_download_outlined),
                      title: const Text("Đồng bộ LibriVox"),
                      subtitle: const Text(
                        "Sync Latest Data — API + RSS → Firestore `books`",
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push("/librivox-sync"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _signOut,
                    child: const Text("Đăng xuất"),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("$e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("$e")),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text("$label: $value"),
    );
  }
}
