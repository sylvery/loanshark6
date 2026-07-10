import 'package:bookinman/application/filters.dart';
import 'package:bookinman/application/loan/loan_providers.dart';
import 'package:bookinman/domain/entities/customer.dart';
import 'package:bookinman/domain/entities/loan.dart';
import 'package:bookinman/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

Customer _customer(String id, String name, [String? phone]) => Customer(
      id: id,
      name: name,
      phone: phone,
      createdAt: DateTime(2024),
    );

LoanDetail _detail(String customerId, LoanStatus status) => LoanDetail(
      loan: Loan(
        id: 'l_$customerId',
        customerId: customerId,
        principal: Money(100, 'PGK'),
        interestRatePerFortnightPercent: 5,
        repaymentFrequency: RepaymentFrequency.weekly,
        startDate: DateTime(2024),
        createdAt: DateTime(2024),
      ),
      schedule: const LoanSchedule(
        installments: [],
        totalInterest: Money.zero,
        totalRepayable: Money.zero,
      ),
      status: status,
      outstanding: Money.zero,
      penalty: Money.zero,
      payments: const [],
      installments: const [],
      allocations: const [],
    );

void main() {
  group('search & filter helpers', () {
    final customers = [
      _customer('c1', 'Alice Moke', '71234567'),
      _customer('c2', 'Bob Smith', null),
      _customer('c3', 'Alice Wong', '79876543'),
    ];

    test('filterCustomers matches by name (case-insensitive)', () {
      final result = filterCustomers(customers, 'alice');
      expect(result.map((c) => c.id), containsAll(['c1', 'c3']));
      expect(result.map((c) => c.id), isNot(contains('c2')));
    });

    test('filterCustomers matches by phone', () {
      final result = filterCustomers(customers, '9876');
      expect(result.map((c) => c.id), ['c3']);
    });

    test('filterCustomers returns all when query is blank', () {
      expect(filterCustomers(customers, '   '), hasLength(3));
    });

    final details = [
      _detail('c1', LoanStatus.active),
      _detail('c2', LoanStatus.overdue),
      _detail('c3', LoanStatus.paid),
    ];
    final nameById = {for (final c in customers) c.id: c.name};

    test('filterLoans filters by status', () {
      final result = filterLoans(details, '', LoanStatus.overdue, nameById);
      expect(result, hasLength(1));
      expect(result.first.loan.customerId, 'c2');
    });

    test('filterLoans filters by customer name query', () {
      final result = filterLoans(details, 'bob', null, nameById);
      expect(result, hasLength(1));
      expect(result.first.loan.customerId, 'c2');
    });

    test('filterLoans returns all when no filters applied', () {
      expect(filterLoans(details, '', null, nameById), hasLength(3));
    });
  });
}
