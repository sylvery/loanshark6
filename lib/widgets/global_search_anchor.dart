import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/customer/customer_providers.dart';
import '../application/loan/loan_providers.dart';
import '../domain/entities/value_objects.dart';

class GlobalSearchAnchor extends ConsumerWidget {
  const GlobalSearchAnchor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchAnchor(
      builder: (context, controller) => IconButton(
        tooltip: 'Search',
        icon: const Icon(Icons.search),
        onPressed: () => controller.openView(),
      ),
      suggestionsBuilder: (context, controller) async {
        final query = controller.text.trim().toLowerCase();
        if (query.isEmpty) {
          return const [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Search customers and loans by name or phone.'),
            ),
          ];
        }

        final customers = await ref.read(customerListProvider.stream).first;
        final details = await ref.read(allLoanDetailsProvider.future);
        final nameById = {for (final c in customers) c.id: c.name};

        final matchedCustomers = customers
            .where(
              (c) =>
                  c.name.toLowerCase().contains(query) ||
                  (c.phone ?? '').toLowerCase().contains(query),
            )
            .take(5)
            .toList();
        final matchedLoans = details
            .where(
              (d) =>
                  (nameById[d.loan.customerId] ?? '').toLowerCase().contains(
                        query,
                      ),
            )
            .take(5)
            .toList();

        if (matchedCustomers.isEmpty && matchedLoans.isEmpty) {
          return const [ListTile(title: Text('No results'))];
        }

        return [
          if (matchedCustomers.isNotEmpty) ...[
            const _SectionTitle('Customers'),
            for (final c in matchedCustomers)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(c.name),
                subtitle: c.phone == null ? null : Text(c.phone!),
                onTap: () {
                  controller.closeView(c.name);
                  context.push('/customers/${c.id}');
                },
              ),
          ],
          if (matchedLoans.isNotEmpty) ...[
            const _SectionTitle('Loans'),
            for (final d in matchedLoans)
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(nameById[d.loan.customerId] ?? 'Unknown'),
                subtitle: Text(d.status.label),
                onTap: () {
                  controller.closeView(nameById[d.loan.customerId] ?? '');
                  context.push('/loans/${d.loan.id}');
                },
              ),
          ],
        ];
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      );
}
