import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import '../domain/entities/loan.dart';
import '../domain/entities/value_objects.dart';
import 'overdue_badge.dart';

class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.loan,
    required this.status,
    required this.outstanding,
    this.subtitle,
    this.onTap,
  });

  final Loan loan;
  final LoanStatus status;
  final Money outstanding;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = const CurrencyFormatter();
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtitle ?? 'Loan',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  OverdueBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Metric(
                    label: 'Principal',
                    value: formatter.format(loan.principal),
                  ),
                  _Metric(
                    label: 'Outstanding',
                    value: formatter.format(outstanding),
                    color: status == LoanStatus.overdue
                        ? AppTheme.danger
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
