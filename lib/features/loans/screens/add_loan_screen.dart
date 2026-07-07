import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/customer/customer_providers.dart';
import '../../application/loan/loan_providers.dart';
import '../../application/providers/core_providers.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/value_objects.dart';

class AddLoanScreen extends ConsumerStatefulWidget {
  const AddLoanScreen({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends ConsumerState<AddLoanScreen> {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  RepaymentFrequency _frequency = RepaymentFrequency.weekly;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.customerId;
  }

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) return;

    final loan = Loan(
      id: ref.read(idGeneratorProvider).generate(),
      customerId: _selectedCustomerId!,
      principal: Money(
        double.tryParse(_principal.text) ?? 0,
        'PGK',
      ),
      interestRatePerFortnightPercent: double.tryParse(_rate.text) ?? 0,
      repaymentFrequency: _frequency,
      startDate: _startDate,
      endDate: _endDate,
      createdAt: DateTime.now(),
      ownerId: ref.read(ownerIdProvider),
    );
    await ref.read(loanActionsProvider).createLoan(loan);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Loan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (widget.customerId == null)
                customers.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (list) => DropdownButtonFormField<String>(
                    value: _selectedCustomerId,
                    decoration:
                        const InputDecoration(labelText: 'Customer'),
                    items: list
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCustomerId = v),
                    validator: (v) => v == null ? 'Select a customer' : null,
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _principal,
                decoration: const InputDecoration(labelText: 'Principal (PGK)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    double.tryParse(v ?? '') != null && (double.tryParse(v!)!) > 0
                        ? null
                        : 'Enter an amount',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rate,
                decoration: const InputDecoration(
                  labelText: 'Interest per fortnight (%)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    double.tryParse(v ?? '') != null ? null : 'Enter a rate',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RepaymentFrequency>(
                value: _frequency,
                decoration: const InputDecoration(labelText: 'Repayment'),
                items: RepaymentFrequency.values
                    .map(
                      (f) => DropdownMenuItem(value: f, child: Text(f.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _frequency = v!),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start date'),
                subtitle: Text(DateHelpers.format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End date'),
                subtitle: Text(DateHelpers.format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(false),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Create loan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
