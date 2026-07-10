import '../../domain/entities/customer.dart';
import '../../domain/entities/value_objects.dart';
import '../loan/loan_providers.dart';

List<Customer> filterCustomers(List<Customer> customers, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return customers;
  return customers
      .where(
        (c) =>
            c.name.toLowerCase().contains(q) ||
            (c.phone ?? '').toLowerCase().contains(q),
      )
      .toList();
}

List<LoanDetail> filterLoans(
  List<LoanDetail> details,
  String query,
  LoanStatus? status,
  Map<String, String> nameById,
) {
  final q = query.trim().toLowerCase();
  return details
      .where(
        (d) {
          final matchesStatus = status == null || d.status == status;
          final matchesQuery = q.isEmpty ||
              (nameById[d.loan.customerId] ?? '').toLowerCase().contains(q);
          return matchesStatus && matchesQuery;
        },
      )
      .toList();
}
