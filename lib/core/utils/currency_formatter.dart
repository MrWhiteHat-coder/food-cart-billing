import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) =>
      NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount);
  static String formatWithDecimals(double amount) =>
      '₹ ${NumberFormat('#,##0.00', 'en_IN').format(amount)}';
}
