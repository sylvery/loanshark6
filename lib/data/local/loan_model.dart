import 'package:isar/isar.dart';

import '../../domain/entities/loan.dart';
import '../../domain/entities/value_objects.dart';

part 'loan_model.g.dart';

@Collection()
class LoanModel {
  LoanModel();

  @Id()
  late Id id;

  late String customerId;
  late double principalAmount;
  late String principalCurrency;
  late double interestRatePerFortnightPercent;
  late int repaymentFrequency;
  late int startDate;
  int? endDate;
  late int createdAt;
  String? ownerId;
  late bool writtenOff;

  Loan toDomain() => Loan(
        id: id,
        customerId: customerId,
        principal: Money(principalAmount, principalCurrency),
        interestRatePerFortnightPercent: interestRatePerFortnightPercent,
        repaymentFrequency: RepaymentFrequency.values[repaymentFrequency],
        startDate: DateTime.fromMillisecondsSinceEpoch(startDate),
        endDate: endDate == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(endDate!),
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
        ownerId: ownerId,
        writtenOff: writtenOff,
      );

  static LoanModel fromDomain(Loan loan) => LoanModel()
    ..id = loan.id
    ..customerId = loan.customerId
    ..principalAmount = loan.principal.amount
    ..principalCurrency = loan.principal.currencyCode
    ..interestRatePerFortnightPercent = loan.interestRatePerFortnightPercent
    ..repaymentFrequency = loan.repaymentFrequency.index
    ..startDate = loan.startDate.millisecondsSinceEpoch
    ..endDate = loan.endDate?.millisecondsSinceEpoch
    ..createdAt = loan.createdAt.millisecondsSinceEpoch
    ..ownerId = loan.ownerId
    ..writtenOff = loan.writtenOff;
}
