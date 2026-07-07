class Money implements Comparable<Money> {
  const Money(this.amount, this.currencyCode);

  final double amount;
  final String currencyCode;

  static const Money zero = Money(0, 'PGK');

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(amount + other.amount, currencyCode);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(amount - other.amount, currencyCode);
  }

  Money operator *(num factor) => Money(amount * factor, currencyCode);

  Money operator -() => Money(-amount, currencyCode);

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return amount > other.amount;
  }

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return amount < other.amount;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return amount >= other.amount;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return amount <= other.amount;
  }

  void _assertSameCurrency(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError(
        'Currency mismatch: $currencyCode vs ${other.currencyCode}',
      );
    }
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return amount.compareTo(other.amount);
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.currencyCode == currencyCode &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(amount, currencyCode);
}

enum RepaymentFrequency { weekly, biWeekly, monthly }

extension RepaymentFrequencyX on RepaymentFrequency {
  String get label {
    switch (this) {
      case RepaymentFrequency.weekly:
        return 'Weekly';
      case RepaymentFrequency.biWeekly:
        return 'Bi-weekly';
      case RepaymentFrequency.monthly:
        return 'Monthly';
    }
  }

  int get days {
    switch (this) {
      case RepaymentFrequency.weekly:
        return 7;
      case RepaymentFrequency.biWeekly:
        return 14;
      case RepaymentFrequency.monthly:
        return 30;
    }
  }
}

enum LoanStatus { active, paid, overdue, writtenOff }

extension LoanStatusX on LoanStatus {
  String get label {
    switch (this) {
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.paid:
        return 'Paid';
      case LoanStatus.overdue:
        return 'Overdue';
      case LoanStatus.writtenOff:
        return 'Written Off';
    }
  }

  bool get isOpen => this == LoanStatus.active || this == LoanStatus.overdue;
}

class LoanTerms {
  const LoanTerms({
    required this.principal,
    required this.interestRatePerFortnightPercent,
    required this.repaymentFrequency,
    required this.startDate,
    required this.endDate,
  });

  final Money principal;
  final double interestRatePerFortnightPercent;
  final RepaymentFrequency repaymentFrequency;
  final DateTime startDate;
  final DateTime endDate;
}
