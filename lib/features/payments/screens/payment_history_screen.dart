import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/payment/payment_providers.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helpers.dart';
import '../../widgets/app_actions.dart';
import '../../widgets/empty_state.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key, required this.loanId});

  final String loanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsByLoanProvider(loanId));
    final formatter = const CurrencyFormatter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: const [SyncButton(), AccountMenu()],
      ),
      body: payments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(message: 'Error: $e'),
        data: (list) {
          final sorted = List.of(list)
            ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
          if (sorted.isEmpty) {
            return const EmptyState(message: 'No payments recorded yet.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = sorted[index];
              return Dismissible(
                key: Key(p.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async => true,
                onDismissed: (_) =>
                    ref.read(paymentActionsProvider).delete(p.id),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.payment)),
                  title: Text(formatter.format(p.amount)),
                  subtitle: Text(
                    '${DateHelpers.format(p.paidAt)}${p.note != null ? ' — ${p.note}' : ''}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
