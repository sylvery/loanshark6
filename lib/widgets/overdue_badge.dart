import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../domain/entities/value_objects.dart';

class OverdueBadge extends StatelessWidget {
  const OverdueBadge({super.key, required this.status});

  final LoanStatus status;

  Color _color(BuildContext context) {
    switch (status) {
      case LoanStatus.paid:
        return Colors.green;
      case LoanStatus.overdue:
        return AppTheme.danger;
      case LoanStatus.writtenOff:
        return Colors.grey;
      case LoanStatus.active:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color(context).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: _color(context), fontWeight: FontWeight.w600),
      ),
    );
  }
}
