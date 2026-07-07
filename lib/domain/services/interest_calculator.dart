import 'value_objects.dart';

class InterestCalculator {
  const InterestCalculator();

  int countFortnights(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    if (days <= 0) return 0;
    return (days / 14).ceil();
  }

  Money fortnightlyInterest(Money principal, double ratePerFortnightPercent) {
    return principal * (ratePerFortnightPercent / 100);
  }

  Money totalInterest(
    Money principal,
    double ratePerFortnightPercent,
    DateTime start,
    DateTime end,
  ) {
    final fortnights = countFortnights(start, end);
    return principal * (ratePerFortnightPercent / 100) * fortnights;
  }
}
