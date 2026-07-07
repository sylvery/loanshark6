import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/entities/value_objects.dart';
import '../../domain/ports/customer_repository.dart';
import '../../domain/ports/loan_repository.dart';
import '../../domain/ports/payment_repository.dart';
import '../../domain/ports/sync_queue_repository.dart';
import '../../domain/services/sync_policy.dart';

class FirestoreSyncService {
  FirestoreSyncService(
    this._firestore,
    this._customers,
    this._loans,
    this._payments,
    this._queue,
    this._policy,
  );

  final FirebaseFirestore _firestore;
  final CustomerRepository _customers;
  final LoanRepository _loans;
  final PaymentRepository _payments;
  final SyncQueueRepository _queue;
  final SyncPolicy _policy;

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String name,
  ) =>
      _firestore.collection('users').doc(uid).collection(name);

  Map<String, dynamic> _customerToMap(Customer c) => {
        'name': c.name,
        'phone': c.phone,
        'address': c.address,
        'notes': c.notes,
        'createdAt': c.createdAt.toIso8601String(),
      };

  Map<String, dynamic> _loanToMap(Loan l) => {
        'customerId': l.customerId,
        'principalAmount': l.principal.amount,
        'principalCurrency': l.principal.currencyCode,
        'interestRatePerFortnightPercent':
            l.interestRatePerFortnightPercent,
        'repaymentFrequency': l.repaymentFrequency.index,
        'startDate': l.startDate.toIso8601String(),
        'endDate': l.endDate?.toIso8601String(),
        'createdAt': l.createdAt.toIso8601String(),
        'writtenOff': l.writtenOff,
      };

  Map<String, dynamic> _paymentToMap(Payment p) => {
        'loanId': p.loanId,
        'amount': p.amount.amount,
        'currency': p.amount.currencyCode,
        'paidAt': p.paidAt.toIso8601String(),
        'note': p.note,
        'installmentIndex': p.installmentIndex,
        'createdAt': p.createdAt.toIso8601String(),
      };

  String _collectionNameFor(String entity) {
    switch (entity) {
      case 'customer':
        return 'customers';
      case 'loan':
        return 'loans';
      case 'payment':
        return 'payments';
      default:
        throw ArgumentError('Unknown sync entity: $entity');
    }
  }

  Future<Map<String, dynamic>> _currentEntityMap(
    String entity,
    String id,
  ) async {
    switch (entity) {
      case 'customer':
        final c = await _customers.getById(id);
        return c == null ? {} : _customerToMap(c);
      case 'loan':
        final l = await _loans.getById(id);
        return l == null ? {} : _loanToMap(l);
      case 'payment':
        final p = await _payments.getById(id);
        return p == null ? {} : _paymentToMap(p);
      default:
        return {};
    }
  }

  Future<void> pushNow(String uid) async {
    final pending = _policy.pushOrder(await _queue.pending());
    for (final op in pending) {
      final ref = _collection(uid, _collectionNameFor(op.entity)).doc(op.entityId);
      if (op.type == SyncOperationType.delete) {
        await ref.delete();
      } else {
        final data = await _currentEntityMap(op.entity, op.entityId);
        if (data.isNotEmpty) await ref.set(data);
      }
      await _queue.markApplied(op.id);
    }
    await _queue.clearApplied();
  }

  Future<void> pullNow(String uid) async {
    final pending = await _queue.pending();

    final customerDocs = await _collection(uid, 'customers').get();
    final loanDocs = await _collection(uid, 'loans').get();
    final paymentDocs = await _collection(uid, 'payments').get();

    final remoteIds = <String>{
      ...customerDocs.docs.map((d) => d.id),
      ...loanDocs.docs.map((d) => d.id),
      ...paymentDocs.docs.map((d) => d.id),
    };

    final adoptable = _policy.adoptableRemoteIds(remoteIds, pending);

    for (final doc in customerDocs.docs) {
      if (!adoptable.contains(doc.id)) continue;
      final data = doc.data();
      await _customers.create(
        Customer(
          id: doc.id,
          name: data['name'] as String,
          phone: data['phone'] as String?,
          address: data['address'] as String?,
          notes: data['notes'] as String?,
          createdAt: DateTime.parse(data['createdAt'] as String),
          ownerId: uid,
        ),
      );
    }

    for (final doc in loanDocs.docs) {
      if (!adoptable.contains(doc.id)) continue;
      final data = doc.data();
      await _loans.create(
        Loan(
          id: doc.id,
          customerId: data['customerId'] as String,
          principal: Money(
            (data['principalAmount'] as num).toDouble(),
            data['principalCurrency'] as String,
          ),
          interestRatePerFortnightPercent:
              (data['interestRatePerFortnightPercent'] as num).toDouble(),
          repaymentFrequency: RepaymentFrequency.values[data['repaymentFrequency'] as int],
          startDate: DateTime.parse(data['startDate'] as String),
          endDate: data['endDate'] == null
              ? null
              : DateTime.parse(data['endDate'] as String),
          createdAt: DateTime.parse(data['createdAt'] as String),
          ownerId: uid,
          writtenOff: data['writtenOff'] as bool? ?? false,
        ),
      );
    }

    for (final doc in paymentDocs.docs) {
      if (!adoptable.contains(doc.id)) continue;
      final data = doc.data();
      await _payments.create(
        Payment(
          id: doc.id,
          loanId: data['loanId'] as String,
          amount: Money(
            (data['amount'] as num).toDouble(),
            data['currency'] as String,
          ),
          paidAt: DateTime.parse(data['paidAt'] as String),
          note: data['note'] as String?,
          installmentIndex: data['installmentIndex'] as int?,
          createdAt: DateTime.parse(data['createdAt'] as String),
        ),
      );
    }
  }
}
