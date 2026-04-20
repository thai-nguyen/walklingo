import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../auth/presentation/auth_providers.dart";
import "../domain/user_profile.dart";
import "profile_providers.dart";

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  String? _gender;
  bool _seeded = false;
  bool _saving = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _save(String uid, UserProfile? current) async {
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final age = int.tryParse(_age.text.trim());
      final w = double.tryParse(_weight.text.replaceAll(",", "."));
      final h = double.tryParse(_height.text.replaceAll(",", "."));
      await ref.read(userProfileRepositoryProvider).saveProfile(
            UserProfile(
              uid: uid,
              displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
              avatarUrl: current?.avatarUrl,
              age: age,
              gender: _gender,
              weightKg: w,
              heightCm: h,
            ),
          );
      ref.invalidate(userProfileProvider);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      setState(() => _message = "Lỗi: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateChangesProvider);
    final profile = ref.watch(userProfileProvider);

    ref.listen(userProfileProvider, (prev, next) {
      next.whenData((p) {
        if (_seeded || p == null) return;
        _name.text = p.displayName ?? "";
        _age.text = p.age?.toString() ?? "";
        _weight.text = p.weightKg?.toString() ?? "";
        _height.text = p.heightCm?.toString() ?? "";
        _gender = p.gender;
        _seeded = true;
        if (mounted) setState(() {});
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa hồ sơ")),
      body: auth.when(
        data: (user) {
          if (user == null) return const Center(child: Text("Chưa đăng nhập."));
          final current = profile.valueOrNull;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: "Tên hiển thị",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _age,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Tuổi",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(_gender),
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: "Giới tính",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "male", child: Text("Nam")),
                  DropdownMenuItem(value: "female", child: Text("Nữ")),
                  DropdownMenuItem(value: "other", child: Text("Khác")),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weight,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Cân nặng (kg)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _height,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Chiều cao (cm)",
                  border: OutlineInputBorder(),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : () => _save(user.id, current),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Lưu"),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("$e")),
      ),
    );
  }
}
