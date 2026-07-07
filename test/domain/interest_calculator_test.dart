import 'package:bookinman/domain/entities/value_objects.dart';
import 'package:bookinman/domain/services/interest_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InterestCalculator', () {
    final calculator = const InterestCalculator();

    test('countFortnights counts 14-day periods', () {
      final start = DateTime(2024, 1, 1);
      expect(calculator.countFortnights(start, DateTime(2024, 1, 15)), 1);
      expect(calculator.countFortnights(start, DateTime(2024, 1, 29)), 2);
      expect(calculator.countFortnights(start, start), 0);
    });

    test('fortnightlyInterest applies flat rate to principal', () {
      final interest = calculator.fortnightlyInterest(Money(1000, 'PGK'), 5);
      expect(interest.amount, closeTo(50, 0.001));
    });

    test('totalInterest is flat across fortnights', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 29);
      final interest =
          calculator.totalInterest(Money(1000, 'PGK'), 5, start, end);
      expect(interest.amount, closeTo(100, 0.001));
    });
  });
}
