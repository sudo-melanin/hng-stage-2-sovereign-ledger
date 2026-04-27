import 'package:intl/intl.dart';
import 'package:sovereign_ledger/core/constants/app_currencies.dart';

class CurrencyFormatter {
  static String format(
    double amount, {
    required AppCurrency currency,
  }) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedNumber = formatter.format(amount);

    return '${currency.symbol}$formattedNumber';
  }
}