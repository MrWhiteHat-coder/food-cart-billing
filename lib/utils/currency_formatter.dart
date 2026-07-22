import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _format = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double amount) => _format.format(amount);
  static String formatWithDecimals(double amount) {
    final f = NumberFormat('#,##0.00', 'en_IN');
    return '₹ ${f.format(amount)}';
  }
}