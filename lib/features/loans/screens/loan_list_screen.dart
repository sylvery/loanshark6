import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/customer/customer_providers.dart';
import '../../application/filters.dart';
import '../../application/loan/loan_providers.dart';
import '../../domain/entities/value_objects.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loan_card.dart';

class LoanListScreen extends ConsumerStatefulWidget {
  const LoanListScreen({super.key});

  @override
  ConsumerState<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends ConsumerState<LoanListScreen> {
  final _search = TextEditingController();
  LoanStatus? _status;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(allLoanDetailsProvider);
    final customers = ref.watch(customerListProvider);

    return Scaffold(
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
          final filtered = filterLoans(list, _search.text, _status, nameById);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by customer',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _status == null,
                      onSelected: () => setState(() => _status = null),
                    ),
                    _FilterChip(
                      label: 'Active',
                      selected: _status == LoanStatus.active,
                      onSelected: () =>
                          setState(() => _status = LoanStatus.active),
                    ),
                    _FilterChip(
                      label: 'Overdue',
                      selected: _status == LoanStatus.overdue,
                      onSelected: () =>
                          setState(() => _status = LoanStatus.overdue),
                    ),
                    _FilterChip(
                      label: 'Paid',
                      selected: _status == LoanStatus.paid,
                      onSelected: () =>
                          setState(() => _status = LoanStatus.paid),
                    ),
                    _FilterChip(
                      label: 'Written off',
                      selected: _status == LoanStatus.writtenOff,
                      onSelected: () =>
                          setState(() => _status = LoanStatus.writtenOff),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        message: 'No loans match your filters.',
                        icon: Icons.account_balance_wallet_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.refresh(allLoanDetailsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final d = filtered[index];
                            final name =
                                nameById[d.loan.customerId] ?? 'Unknown';
                            return LoanCard(
                              loan: d.loan,
                              status: d.status,
                              outstanding: d.outstanding,
                              subtitle: name,
                              onTap: () =>
                                  context.push('/loans/${d.loan.id}'),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onSelected(),
        ),
      );
}
