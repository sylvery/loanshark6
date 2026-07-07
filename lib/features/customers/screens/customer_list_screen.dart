import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/customer/customer_providers.dart';
import '../../widgets/app_actions.dart';
import '../../widgets/customer_tile.dart';
import '../../widgets/empty_state.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: const [SyncButton(), AccountMenu()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customers/new'),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search customers',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: customers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(message: 'Error: $e'),
              data: (list) {
                final query = _search.text.toLowerCase();
                final filtered = query.isEmpty
                    ? list
                    : list
                        .where((c) => c.name.toLowerCase().contains(query))
                        .toList();
                if (filtered.isEmpty) {
                  return const EmptyState(
                    message: 'No customers found.',
                    icon: Icons.people_outline,
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final customer = filtered[index];
                    return Dismissible(
                      key: Key(customer.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return true;
                      },
                      onDismissed: (_) =>
                          ref.read(customerActionsProvider).delete(customer.id),
                      child: CustomerTile(
                        customer: customer,
                        onTap: () =>
                            context.push('/customers/${customer.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
