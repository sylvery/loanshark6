import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/customer/customer_providers.dart';
import '../../application/loan/loan_providers.dart';
import '../../widgets/app_actions.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loan_card.dart';

class LoanListScreen extends ConsumerWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(allLoanDetailsProvider);
    final customers = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        actions: const [SyncButton(), AccountMenu()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/loans/new'),
        child: const Icon(Icons.add),
      ),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(message: 'Error: $e'),
        data: (list) {
          final nameById = customers.maybeWhen(
            data: (c) => {for (final x in c) x.id: x.name},
            orElse: () => <String, String>{},
          );
          if (list.isEmpty) {
            return const EmptyState(
              message: 'No loans yet.',
              icon: Icons.account_balance_wallet_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(allLoanDetailsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = list[index];
                final name = nameById[d.loan.customerId] ?? 'Unknown';
                return LoanCard(
                  loan: d.loan,
                  status: d.status,
                  outstanding: d.outstanding,
                  subtitle: name,
                  onTap: () => context.push('/loans/${d.loan.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
