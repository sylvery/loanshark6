import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/reports/report_export_provider.dart';
import '../../application/reports/reports_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/app_actions.dart';
import '../../widgets/empty_state.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsProvider);
    final formatter = const CurrencyFormatter();

    ref.listen(reportExportProvider, (_, next) {
      if (next.status == ReportExportStatus.done && next.path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to ${next.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () =>
                  ref.read(reportExportProvider.notifier).open(next.path!),
            ),
          ),
        );
      } else if (next.status == ReportExportStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: const [
          _ExportMenu(),
          SyncButton(),
          AccountMenu(),
        ],
      ),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(message: 'Error: $e'),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(reportsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PortfolioCards(data: data, formatter: formatter),
              const SizedBox(height: 24),
              _TrendSection(data: data, formatter: formatter),
              const SizedBox(height: 24),
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

class _ExportMenu extends ConsumerWidget {
  const _ExportMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exporting =
        ref.watch(reportExportProvider).status == ReportExportStatus.exporting;
    final data = ref.watch(reportsProvider).valueOrNull;

    return PopupMenuButton<ReportFormat>(
      icon: exporting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_outlined),
      tooltip: 'Export report',
      enabled: data != null && !exporting,
      onSelected: (format) =>
          ref.read(reportExportProvider.notifier).export(data!, format),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: ReportFormat.csv,
          child: Text('Export as CSV'),
        ),
        PopupMenuItem(
          value: ReportFormat.pdf,
          child: Text('Export as PDF'),
        ),
      ],
    );
  }
}

class _PortfolioCards extends StatelessWidget {
  const _PortfolioCards({
    required this.data,
    required this.formatter,
  });

  final ReportsData data;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final a = data.analytics;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        StatCard(
          label: 'Disbursed',
          value: formatter.formatCompact(a.totalDisbursed.amount),
          icon: Icons.local_atm_outlined,
        ),
        StatCard(
          label: 'Outstanding',
          value: formatter.formatCompact(a.totalOutstanding.amount),
          accent: AppTheme.warning,
          icon: Icons.money_off_outlined,
        ),
        StatCard(
          label: 'Collected',
          value: formatter.formatCompact(a.totalCollected.amount),
          icon: Icons.savings_outlined,
        ),
        StatCard(
          label: 'Collection rate',
          value: '${(a.collectionRate * 100).toStringAsFixed(0)}%',
          icon: Icons.speed_outlined,
        ),
        StatCard(
          label: 'Arrears',
          value: formatter.formatCompact(a.arrearsOutstanding.amount),
          accent: AppTheme.danger,
          icon: Icons.warning_amber_outlined,
        ),
        StatCard(
          label: 'PAR30',
          value: '${(a.par30Ratio * 100).toStringAsFixed(0)}%',
          accent: AppTheme.danger,
          icon: Icons.bug_report_outlined,
        ),
      ],
    );
  }
}

class _TrendSection extends StatelessWidget {
  const _TrendSection({
    required this.data,
    required this.formatter,
  });

  final ReportsData data;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final trends = data.trends;
    final maxAmount = trends.fold<double>(
      0.0,
      (max, t) =>
          [max, t.disbursed.amount, t.collected.amount].reduce((a, b) => a > b ? a : b),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disbursement vs Collection (12 months)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: trends
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.label,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          _Bar(
                            label: 'Disbursed',
                            amount: t.disbursed.amount,
                            max: maxAmount,
                            color: AppTheme.primarySeed,
                            formatter: formatter,
                          ),
                          const SizedBox(height: 4),
                          _Bar(
                            label: 'Collected',
                            amount: t.collected.amount,
                            max: maxAmount,
                            color: AppTheme.warning,
                            formatter: formatter,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.amount,
    required this.max,
    required this.color,
    required this.formatter,
  });

  final String label;
  final double amount;
  final double max;
  final Color color;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (amount / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: fraction,
            color: color,
            backgroundColor: color.withOpacity(0.15),
            minHeight: 12,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            formatter.formatCompact(amount),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
