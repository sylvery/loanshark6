import 'value_objects.dart';

class Loan {
  const Loan({
    required this.id,
    required this.customerId,
    required this.principal,
    required this.interestRatePerFortnightPercent,
    required this.repaymentFrequency,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    this.ownerId,
    this.writtenOff = false,
  });

  final String id;
  final String customerId;
  final Money principal;
  final double interestRatePerFortnightPercent;
  final RepaymentFrequency repaymentFrequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final String? ownerId;
  final bool writtenOff;

  LoanTerms get terms => LoanTerms(
        principal: principal,
        interestRatePerFortnightPercent: interestRatePerFortnightPercent,
        repaymentFrequency: repaymentFrequency,
        startDate: startDate,
        endDate: endDate ?? startDate.add(const Duration(days: 365)),
      );

  Loan copyWith({
    String? customerId,
    Money? principal,
    double? interestRatePerFortnightPercent,
    RepaymentFrequency? repaymentFrequency,
    DateTime? startDate,
    DateTime? endDate,
    bool? writtenOff,
  }) {
    return Loan(
      id: id,
      customerId: customerId ?? this.customerId,
      principal: principal ?? this.principal,
      interestRatePerFortnightPercent:
          interestRatePerFortnightPercent ?? this.interestRatePerFortnightPercent,
      repaymentFrequency: repaymentFrequency ?? this.repaymentFrequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt,
      ownerId: ownerId,
      writtenOff: writtenOff ?? this.writtenOff,
    );
  }
}

class ScheduledInstallment {
  const ScheduledInstallment({
    required this.index,
    required this.dueDate,
    required this.amountDue,
    required this.principalComponent,
    required this.interestComponent,
    this.isPaid = false,
  });

  final int index;
  final DateTime dueDate;
  final Money amountDue;
  final Money principalComponent;
  final Money interestComponent;
  final bool isPaid;

  ScheduledInstallment markPaid() => ScheduledInstallment(
        index: index,
        dueDate: dueDate,
        amountDue: amountDue,
        principalComponent: principalComponent,
        interestComponent: interestComponent,
        isPaid: true,
      );
}

class LoanSchedule {
  const LoanSchedule({
    required this.installments,
    required this.totalInterest,
    required this.totalRepayable,
  });

  final List<ScheduledInstallment> installments;
  final Money totalInterest;
  final Money totalRepayable;
}
