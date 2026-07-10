import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/dashboard/dashboard_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardProvider);
    final formatter = const CurrencyFormatter();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customers/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(message: 'Failed to load dashboard: $e'),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    label: 'Active Loans',
                    value: '${data.totalActiveLoans}',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  StatCard(
                    label: 'Outstanding',
                    value: formatter.format(data.totalOutstanding),
                    accent: AppTheme.warning,
                    icon: Icons.money_off_outlined,
                  ),
                  StatCard(
                    label: 'Overdue',
                    value: '${data.overdueCount}',
                    accent: AppTheme.danger,
                    icon: Icons.warning_amber_outlined,
                  ),
                  StatCard(
                    label: 'Collected (Mo)',
                    value: formatter.format(data.collectedThisMonth),
                    icon: Icons.savings_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.recentActivity.isEmpty)
                const EmptyState(
                  message: 'No activity yet. Add a customer and loan to begin.',
                  icon: Icons.history_outlined,
                )
              else
                ...data.recentActivity.map(
                  (item) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.payment)),
                    title: Text(item.title),
                    subtitle: Text(item.subtitle),
                    trailing: Text(formatter.format(item.amount)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
