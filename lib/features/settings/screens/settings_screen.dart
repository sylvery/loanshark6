import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/settings/settings_providers.dart';
import '../../application/providers/core_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _editDisplayName() {
    final current = ref.read(displayNameProvider);
    _nameController.text = current ?? '';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(displayNameProvider.notifier)
                  .set(_nameController.text.trim());
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final displayName = ref.watch(displayNameProvider);
    final signedIn = user != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Display name'),
            subtitle: Text(displayName ?? 'Not set'),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _editDisplayName,
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Account'),
            subtitle: Text(signedIn ? (user!.email ?? 'Signed in') : 'Signed out'),
          ),
          const Divider(height: 24),
          const Text(
            'Appearance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SegmentedButton<ThemeMode>(
              selected: {themeModeFrom(themeMode)},
              onSelectionChanged: (selected) {
                final mode = selected.first;
                ref.read(themeModeProvider.notifier).setMode(
                      mode == ThemeMode.light
                          ? 'light'
                          : mode == ThemeMode.dark
                              ? 'dark'
                              : 'system',
                    );
              },
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          const Text(
            'Preferences',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.paid_outlined),
            title: const Text('Lending & penalty'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/lending'),
          ),
          const Divider(height: 24),
          ListTile(
            leading: Icon(
              signedIn ? Icons.logout_outlined : Icons.login_outlined,
              color: signedIn ? Theme.of(context).colorScheme.error : null,
            ),
            title: Text(signedIn ? 'Sign out' : 'Sign in'),
            onTap: () {
              if (signedIn) {
                ref.read(authControllerProvider.notifier).signOut();
              } else {
                context.push('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
