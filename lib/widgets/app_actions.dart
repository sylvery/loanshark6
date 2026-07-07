import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/providers/core_providers.dart';
import '../../application/sync/sync_providers.dart';

class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(syncStatusProvider).valueOrNull ?? 0;
    final user = ref.watch(authUserProvider);
    final online = ref.watch(connectivityProvider).valueOrNull ?? false;
    final sync = ref.watch(syncControllerProvider);
    final signedIn = user.value != null;

    if (!signedIn) {
      return const Tooltip(
        message: 'Sign in to sync to the cloud',
        child: Icon(Icons.cloud_off_outlined),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pending > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$pending', style: const TextStyle(fontSize: 12)),
          ),
        IconButton(
          icon: sync.syncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_sync_outlined),
          tooltip: pending > 0
              ? 'Sync $pending change(s)'
              : (sync.lastSyncedAt == null
                  ? 'Sync now'
                  : 'Up to date'),
          onPressed: (online && !sync.syncing)
              ? () => ref.read(syncControllerProvider.notifier).syncNow()
              : null,
        ),
      ],
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
