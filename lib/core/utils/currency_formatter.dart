import 'package:intl/intl.dart';

import '../../domain/entities/value_objects.dart';

class CurrencyFormatter {
  const CurrencyFormatter();

  static final NumberFormat _pgk = NumberFormat.currency(
    locale: 'en_PG',
    name: 'PGK',
    symbol: 'K',
    decimalDigits: 2,
  );

  String format(Money money) => _pgk.format(money.amount);

  String formatAmount(double amount) => _pgk.format(amount);

  String formatCompact(double amount) {
    final compact = NumberFormat.compactCurrency(
      locale: 'en_PG',
      name: 'PGK',
      symbol: 'K',
      decimalDigits: 0,
    );
    return compact.format(amount);
  }
}
