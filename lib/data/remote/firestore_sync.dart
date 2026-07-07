import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/value_objects.dart';
import '../../domain/ports/customer_repository.dart';
import '../../domain/ports/loan_repository.dart';
import '../../domain/ports/payment_repository.dart';

class FirestoreSyncService {
  FirestoreSyncService(
    this._firestore,
    this._customers,
    this._loans,
    this._payments,
  );

  final FirebaseFirestore _firestore;
  final CustomerRepository _customers;
  final LoanRepository _loans;
  final PaymentRepository _payments;

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
        'interestRatePerFortnightPercent': l.interestRatePerFortnightPercent,
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

  Future<void> pushNow(String uid) async {
    final customers = await _customers.getAll(ownerId: uid);
    final customerBatch = _firestore.batch();
    for (final c in customers) {
      customerBatch.set(
        _collection(uid, 'customers').doc(c.id),
        _customerToMap(c),
      );
    }
    await customerBatch.commit();

    final loans = await _loans.getAll(ownerId: uid);
    final loanBatch = _firestore.batch();
    for (final l in loans) {
      loanBatch.set(_collection(uid, 'loans').doc(l.id), _loanToMap(l));
    }
    await loanBatch.commit();

    final payments = await _payments.getAll(ownerId: uid);
    final paymentBatch = _firestore.batch();
    for (final p in payments) {
      paymentBatch.set(
        _collection(uid, 'payments').doc(p.id),
        _paymentToMap(p),
      );
    }
    await paymentBatch.commit();
  }

  Future<void> pullNow(String uid) async {
    final customerDocs = await _collection(uid, 'customers').get();
    for (final doc in customerDocs.docs) {
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

    final loanDocs = await _collection(uid, 'loans').get();
    for (final doc in loanDocs.docs) {
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
          repaymentFrequency:
              RepaymentFrequency.values[data['repaymentFrequency'] as int],
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

    final paymentDocs = await _collection(uid, 'payments').get();
    for (final doc in paymentDocs.docs) {
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
