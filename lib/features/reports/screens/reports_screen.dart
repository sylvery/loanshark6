import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/reports/reports_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/app_actions.dart';
import '../../widgets/empty_state.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);
    final formatter = const CurrencyFormatter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: const [SyncButton(), AccountMenu()],
      ),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(message: 'Error: $e'),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(reportsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Collections (6 months)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: data.monthlyCollections
                        .map(
                          (m) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(m.label),
                                Text(formatter.format(m.amount)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Overdue loans',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (data.overdueLoans.isEmpty)
                const EmptyState(
                  message: 'No overdue loans. Well done!',
                  icon: Icons.check_circle_outline,
                )
              else
                ...data.overdueLoans.map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber,
                          color: AppTheme.danger),
                      title: Text(item.customerName),
                      subtitle: item.phone == null
                          ? const Text('Outstanding')
                          : Text(item.phone!),
                      trailing: Text(
                        formatter.format(item.outstanding),
                        style: const TextStyle(color: AppTheme.danger),
                      ),
                      onTap: () => context.push('/loans/${item.loanId}'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
