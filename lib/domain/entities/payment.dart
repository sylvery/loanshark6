import 'value_objects.dart';

class Payment {
  const Payment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paidAt,
    this.note,
    this.installmentIndex,
    required this.createdAt,
  });

  final String id;
  final String loanId;
  final Money amount;
  final DateTime paidAt;
  final String? note;
  final int? installmentIndex;
  final DateTime createdAt;
}

class PaymentSummary {
  const PaymentSummary({
    required this.totalCollected,
    required this.paymentCount,
  });

  final Money totalCollected;
  final int paymentCount;
}
