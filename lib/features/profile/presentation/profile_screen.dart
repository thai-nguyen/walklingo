import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/presentation/auth_providers.dart";
import "../domain/user_profile.dart";
import "profile_providers.dart";

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  bool _saving = false;
  String? _message;
  bool _seededFromRemote = false;

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _save(String uid) async {
    setState(() {
      _saving = true;
      _message = null;
    });
    final w = double.tryParse(_weight.text.replaceAll(",", "."));
    final h = double.tryParse(_height.text.replaceAll(",", "."));
    try {
      await ref.read(userProfileRepositoryProvider).saveProfile(
            UserProfile(
              uid: uid,
              weightKg: w,
              heightCm: h,
            ),
          );
      ref.invalidate(userProfileProvider);
      setState(() => _message = "Đã lưu.");
    } catch (e) {
      setState(() => _message = "Lỗi: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _seededFromRemote = false);
    _weight.clear();
    _height.clear();
    await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProfileProvider, (prev, next) {
      next.whenData((p) {
        if (!mounted || _seededFromRemote || p == null) return;
        setState(() {
          if (_weight.text.isEmpty && p.weightKg != null) {
            _weight.text = p.weightKg!.toString();
          }
          if (_height.text.isEmpty && p.heightCm != null) {
            _height.text = p.heightCm!.toString();
          }
          _seededFromRemote = true;
        });
      });
    });

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
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    user.email ?? user.id,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Cân nặng (kg)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _height,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    onPressed: _saving ? null : () => _save(user.id),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Lưu hồ sơ"),
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
