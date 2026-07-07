import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/providers/core_providers.dart';

class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final online = ref.watch(connectivityProvider).valueOrNull ?? false;
    final uid = user.value?.uid;

    return IconButton(
      icon: const Icon(Icons.cloud_sync_outlined),
      tooltip: uid == null ? 'Sign in to enable sync' : 'Sync now',
      onPressed: (uid == null || !online)
          ? null
          : () async {
              await ref.read(firestoreSyncProvider).pushNow(uid);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Synced to cloud.')),
                );
              }
            },
    );
  }
}

class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final signedIn = user.value != null;

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'login') {
          context.push('/login');
        } else if (value == 'logout') {
          await ref.read(authControllerProvider.notifier).signOut();
        }
      },
      itemBuilder: (_) => signedIn
          ? [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Sign out'),
              ),
            ]
          : [
              const PopupMenuItem(
                value: 'login',
                child: Text('Sign in'),
              ),
            ],
    );
  }
}
