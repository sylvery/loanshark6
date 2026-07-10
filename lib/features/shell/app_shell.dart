import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/reports/report_export_provider.dart';
import '../application/reports/reports_provider.dart';
import '../widgets/app_actions.dart';
import '../widgets/global_search_anchor.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) => navigationShell.goBranch(index);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const titles = ['BookinMan', 'Customers', 'Loans', 'Reports'];
    final index = navigationShell.currentIndex;

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
        title: Text(titles[index]),
        actions: [
          const GlobalSearchAnchor(),
          if (index == 3) const _ReportExportMenu(),
          const SyncButton(),
          const AccountMenu(),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Customers',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Loans',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class _ReportExportMenu extends ConsumerWidget {
  const _ReportExportMenu();

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
