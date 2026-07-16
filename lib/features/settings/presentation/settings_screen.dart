import "package:firebase_auth/firebase_auth.dart" as fb;
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../app/app_navigation_bar.dart";
import "../../../core/settings/app_settings_providers.dart";
import "../../../l10n/app_localizations.dart";
import "../../auth/presentation/auth_providers.dart";
import "../../profile/presentation/profile_section.dart";
import "settings_providers.dart";

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.deleteAccountTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.deleteAccountMessage),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.deleteAccountPasswordHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.deleteAccountConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      await auth.reauthenticateWithPassword(passwordController.text);
      await ref.read(accountDeletionServiceProvider).deleteAllUserData(user.id);
      await auth.deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleteAccountSuccess)),
        );
      }
    } on fb.FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == "requires-recent-login"
          ? l10n.deleteAccountReauthRequired
          : l10n.deleteAccountError(e.message ?? e.code);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } on StateError catch (e) {
      if (!mounted) return;
      final msg = e.message == "no_email_for_reauth"
          ? l10n.noEmailForReauth
          : l10n.deleteAccountError(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountError("$e"))),
      );
    } finally {
      passwordController.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(appThemeModeProvider).valueOrNull ?? ThemeMode.light;
    final locale = ref.watch(appLocaleProvider).valueOrNull ?? const Locale("vi");
    final auth = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: auth.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.notSignedIn));
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + mainShellBottomInset(context),
            ),
            children: [
              const ProfileSection(),
              Text(l10n.appearanceSection, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: _busy
                      ? null
                      : (selection) {
                          ref
                              .read(appThemeModeProvider.notifier)
                              .setThemeMode(selection.first);
                        },
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.languageSection, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: "vi",
                      label: Text(l10n.languageVietnamese),
                    ),
                    ButtonSegment(
                      value: "en",
                      label: Text(l10n.languageEnglish),
                    ),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: _busy
                      ? null
                      : (selection) {
                          ref
                              .read(appLocaleProvider.notifier)
                              .setLocale(Locale(selection.first));
                        },
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.accountSection, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(l10n.signOutButton),
                      onTap: _busy ? null : _signOut,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        l10n.deleteAccountButton,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onTap: _busy ? null : _confirmDeleteAccount,
                    ),
                  ],
                ),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError("$e"))),
      ),
    );
  }
}
