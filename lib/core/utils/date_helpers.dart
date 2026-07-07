import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final DateFormat _iso = DateFormat('yyyy-MM-dd');

  static String format(DateTime date) => _date.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String iso(DateTime date) => _iso.format(date);

  static bool isOverdue(DateTime dueDate, DateTime now) =>
      dueDate.isBefore(DateTime(now.year, now.month, now.day));

  static int daysUntil(DateTime dueDate, DateTime now) =>
      dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
