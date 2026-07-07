import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/customer/customer_providers.dart';
import '../../application/loan/loan_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/utils/messaging.dart';
import '../../widgets/app_actions.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/overdue_badge.dart';

class LoanDetailScreen extends ConsumerWidget {
  const LoanDetailScreen({super.key, required this.loanId});

  final String loanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(loanDetailProvider(loanId));
    final formatter = const CurrencyFormatter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan'),
        actions: const [SyncButton(), AccountMenu()],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(message: 'Error: $e'),
        data: (d) {
          final loan = d.loan;
          final customer = ref.watch(customerByIdProvider(loan.customerId));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Loan summary',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          OverdueBadge(status: d.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Row(
                        label: 'Principal',
                        value: formatter.format(loan.principal),
                      ),
                      _Row(
                        label: 'Interest / fortnight',
                        value:
                            '${loan.interestRatePerFortnightPercent}%',
                      ),
                      _Row(
                        label: 'Frequency',
                        value: loan.repaymentFrequency.label,
                      ),
                      _Row(
                        label: 'Total repayable',
                        value: formatter.format(d.schedule.totalRepayable),
                      ),
                      _Row(
                        label: 'Outstanding',
                        value: formatter.format(d.outstanding),
                        accent: d.status == LoanStatus.overdue
                            ? AppTheme.danger
                            : null,
                      ),
                      _Row(
                        label: 'Start',
                        value: DateHelpers.format(loan.startDate),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/loans/$loanId/pay'),
                      icon: const Icon(Icons.payment),
                      label: const Text('Record payment'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/loans/$loanId/history'),
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                    ),
                  ),
                ],
              ),
              if (loan.writtenOff == false)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: OutlinedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Write off loan?'),
                          content: const Text(
                            'This marks the loan as written off and stops '
                            'further overdue alerts.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Write off'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref
                            .read(loanActionsProvider)
                            .writeOff(loanId, loan);
                      }
                    },
                    child: const Text('Write off'),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...d.installments.map(
                (inst) => ListTile(
                  leading: Icon(
                    inst.isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: inst.isPaid
                        ? Colors.green
                        : (inst.dueDate.isBefore(DateTime.now())
                            ? AppTheme.danger
                            : null),
                  ),
                  title: Text(formatter.format(inst.amountDue)),
                  subtitle: Text('Due ${DateHelpers.format(inst.dueDate)}'),
                  trailing: inst.isPaid
                      ? const Text('Paid')
                      : (inst.dueDate.isBefore(DateTime.now())
                          ? const Text('Overdue')
                          : null),
                ),
              ),
              if (customer.hasValue && customer.value?.phone != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Messaging.openWhatsApp(
                            context,
                            customer.value!.phone!,
                            Messaging.reminderMessage(
                              customer.value!.name,
                              formatter.format(d.outstanding),
                            ),
                          ),
                          icon: const Icon(Icons.chat),
                          label: const Text('Remind via WhatsApp'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Messaging.openSms(
                            context,
                            customer.value!.phone!,
                            Messaging.reminderMessage(
                              customer.value!.name,
                              formatter.format(d.outstanding),
                            ),
                          ),
                          icon: const Icon(Icons.sms),
                          label: const Text('Remind via SMS'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: accent),
          ),
        ],
      ),
    );
  }
}
