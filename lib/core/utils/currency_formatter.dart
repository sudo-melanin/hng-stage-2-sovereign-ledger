import 'package:intl/intl.dart';
import 'package:sovereign_ledger/core/constants/app_currencies.dart';

class CurrencyFormatter {
  static String format(
    double amount, {
    AppCurrency currency = AppCurrencies.naira,
  }) {
    final formatter = NumberFormat.currency(
      locale: currency.locale,
      symbol: currency.symbol,
      decimalDigits: 2,
    );

    return formatter.format(amount);
  }
}