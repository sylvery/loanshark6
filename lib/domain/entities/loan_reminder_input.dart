import 'value_objects.dart';

class LoanReminderInput {
  const LoanReminderInput({
    required this.loanId,
    required this.customerName,
    required this.outstanding,
    required this.nextDueDate,
    required this.status,
  });

  final String loanId;
  final String customerName;
  final Money outstanding;
  final DateTime? nextDueDate;
  final LoanStatus status;
}
