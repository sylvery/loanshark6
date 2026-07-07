import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/customer/customer_providers.dart';
import '../../application/loan/loan_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/messaging.dart';
import '../../widgets/app_actions.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loan_card.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerByIdProvider(customerId));
    final loanDetails = ref.watch(customerLoanDetailsProvider(customerId));
    final formatter = const CurrencyFormatter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
        actions: const [SyncButton(), AccountMenu()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/loans/new?customerId=$customerId'),
        icon: const Icon(Icons.add),
        label: const Text('Add loan'),
      ),
      body: customer.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(message: 'Error: $e'),
        data: (c) {
          if (c == null) {
            return const EmptyState(message: 'Customer not found.');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      if (c.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(c.phone!),
                      ],
                      if (c.address != null) ...[
                        const SizedBox(height: 4),
                        Text(c.address!),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: c.phone == null
                                  ? null
                                  : () => Messaging.openWhatsApp(
                                        context,
                                        c.phone!,
                                        Messaging.reminderMessage(
                                          c.name,
                                          'your loan',
                                        ),
                                      ),
                              icon: const Icon(Icons.chat),
                              label: const Text('WhatsApp'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: c.phone == null
                                  ? null
                                  : () => Messaging.openSms(
                                        context,
                                        c.phone!,
                                        Messaging.reminderMessage(
                                          c.name,
                                          'your loan',
                                        ),
                                      ),
                              icon: const Icon(Icons.sms),
                              label: const Text('SMS'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Loans', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              loanDetails.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(message: 'Error: $e'),
                data: (details) {
                  if (details.isEmpty) {
                    return const EmptyState(
                      message: 'No loans for this customer yet.',
                    );
                  }
                  return Column(
                    children: details
                        .map(
                          (d) => LoanCard(
                            loan: d.loan,
                            status: d.status,
                            outstanding: d.outstanding,
                            subtitle: c.name,
                            onTap: () => context.push('/loans/${d.loan.id}'),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
