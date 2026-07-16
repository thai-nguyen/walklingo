import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:walklingo/l10n/app_localizations.dart";

import "../../auth/domain/app_user.dart";
import "../../auth/presentation/auth_providers.dart";
import "../../profile/presentation/profile_providers.dart";

String? _resolveDisplayName(String? profileName, AppUser? user) {
  final trimmed = profileName?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;

  final email = user?.email?.trim();
  if (email != null && email.contains("@")) {
    return email.split("@").first;
  }
  return null;
}

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final displayName =
        _resolveDisplayName(profile?.displayName, user) ?? l10n.displayNameUnset;
    final avatarUrl = profile?.avatarUrl;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          ColoredBox(color: cs.primaryContainer),
          Positioned(
            top: -56,
            right: -56,
            child: _CornerQuarterCircle(
              size: 168,
              color: cs.primary.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            top: -24,
            right: -24,
            child: _CornerQuarterCircle(
              size: 96,
              color: cs.surface.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            bottom: -64,
            left: -64,
            child: _CornerQuarterCircle(
              size: 176,
              color: cs.primary.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -28,
            child: _CornerQuarterCircle(
              size: 104,
              color: cs.surface.withValues(alpha: 0.18),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.12),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 32,
                          color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerQuarterCircle extends StatelessWidget {
  const _CornerQuarterCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
