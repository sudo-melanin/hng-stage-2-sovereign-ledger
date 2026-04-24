import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _nairaFormatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _nairaFormatter.format(amount);
  }
}