import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../../l10n/app_localizations.dart";
import "../../auth/presentation/auth_providers.dart";
import "../domain/user_profile.dart";
import "profile_providers.dart";

/// Profile card and utility links shown at the top of [SettingsScreen].
class ProfileSection extends ConsumerStatefulWidget {
  const ProfileSection({super.key});

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  final _picker = ImagePicker();
  bool _uploadingAvatar = false;
  String? _message;

  Future<void> _uploadAvatar(String uid, UserProfile? current) async {
    final l10n = AppLocalizations.of(context)!;
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
      if (mounted) setState(() => _message = l10n.avatarUpdated);
    } catch (e) {
      if (mounted) {
        setState(() => _message = l10n.avatarUploadError(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  String _genderLabel(AppLocalizations l10n, String? gender) {
    switch (gender) {
      case "male":
        return l10n.genderMale;
      case "female":
        return l10n.genderFemale;
      case "other":
        return l10n.genderOther;
      default:
        return l10n.genderUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateChangesProvider);
    final profile = ref.watch(userProfileProvider);

    return auth.when(
      data: (user) {
        if (user == null) {
          return Center(child: Text(l10n.notSignedIn));
        }
        return profile.when(
          data: (p) {
            final avatarUrl = p?.avatarUrl;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.profileTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
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
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? const Icon(Icons.person, size: 44)
                                  : null,
                            ),
                            IconButton.filled(
                              tooltip: l10n.uploadAvatarTooltip,
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
                              : l10n.displayNameUnset,
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
                              label: l10n.ageLabel,
                              value: p?.age?.toString() ?? l10n.genderUnknown,
                            ),
                            _InfoChip(
                              label: l10n.genderLabel,
                              value: _genderLabel(l10n, p?.gender),
                            ),
                            _InfoChip(
                              label: l10n.weightLabel,
                              value: p?.weightKg != null
                                  ? l10n.weightKgValue(p!.weightKg.toString())
                                  : l10n.genderUnknown,
                            ),
                            _InfoChip(
                              label: l10n.heightLabel,
                              value: p?.heightCm != null
                                  ? l10n.heightCmValue(p!.heightCm.toString())
                                  : l10n.genderUnknown,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => context.push("/profile/edit"),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(l10n.editBasicInfoButton),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(_message!),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.utilitiesSection,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text(l10n.learnedWordsTitle),
                    subtitle: Text(l10n.learnedWordsSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push("/learned-words"),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.cloud_download_outlined),
                    title: Text(l10n.librivoxSyncTitle),
                    subtitle: Text(l10n.librivoxSyncSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push("/librivox-sync"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("$e")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("$e")),
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
    final l10n = AppLocalizations.of(context)!;
    return Chip(
      label: Text(l10n.infoChipFormat(label, value)),
    );
  }
}
