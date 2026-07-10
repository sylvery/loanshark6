import 'package:isar/isar.dart';

import '../../domain/entities/payment.dart';
import '../../domain/entities/value_objects.dart';

part 'payment_model.g.dart';

@Collection()
class PaymentModel {
  PaymentModel();

  @Id()
  int id;

  late String uuid;
  late String loanId;
  late double amount;
  late String currency;
  late int paidAt;
  String? note;
  int? installmentIndex;
  late int createdAt;

  Payment toDomain() => Payment(
        id: uuid,
        loanId: loanId,
        amount: Money(amount, currency),
        paidAt: DateTime.fromMillisecondsSinceEpoch(paidAt),
        note: note,
        installmentIndex: installmentIndex,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      );

  static PaymentModel fromDomain(Payment payment) => PaymentModel()
    ..uuid = payment.id
    ..loanId = payment.loanId
    ..amount = payment.amount.amount
    ..currency = payment.amount.currencyCode
    ..paidAt = payment.paidAt.millisecondsSinceEpoch
    ..note = payment.note
    ..installmentIndex = payment.installmentIndex
    ..createdAt = payment.createdAt.millisecondsSinceEpoch;
}
