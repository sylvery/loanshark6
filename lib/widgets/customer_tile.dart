import 'package:flutter/material.dart';

import '../domain/entities/customer.dart';

class CustomerTile extends StatelessWidget {
  const CustomerTile({
    super.key,
    required this.customer,
    this.onTap,
  });

  final Customer customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initials = customer.name.isNotEmpty
        ? customer.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        child: Text(initials),
      ),
      title: Text(customer.name),
      subtitle: customer.phone == null ? null : Text(customer.phone!),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
