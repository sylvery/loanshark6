import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/customer/customer_providers.dart';
import '../../application/providers/core_providers.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/customer.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = ref.read(idGeneratorProvider).generate();
    final ownerId = ref.read(ownerIdProvider);
    final customer = Customer(
      id: id,
      name: _name.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      createdAt: DateTime.now(),
      ownerId: ownerId,
    );
    await ref.read(customerActionsProvider).create(customer);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Save customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
