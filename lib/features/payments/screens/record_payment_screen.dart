import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/payment/payment_providers.dart';
import '../../application/providers/core_providers.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/value_objects.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final payment = Payment(
      id: ref.read(idGeneratorProvider).generate(),
      loanId: widget.loanId,
      amount: Money(double.tryParse(_amount.text) ?? 0, 'PGK'),
      paidAt: DateTime.now(),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      createdAt: DateTime.now(),
    );
    await ref.read(paymentActionsProvider).record(payment);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amount,
                decoration: const InputDecoration(labelText: 'Amount (PGK)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    double.tryParse(v ?? '') != null &&
                            (double.tryParse(v!)!) > 0
                        ? null
                        : 'Enter an amount',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Save payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
