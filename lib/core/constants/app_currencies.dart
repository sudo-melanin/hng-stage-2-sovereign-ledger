class AppCurrency {
  final String code;
  final String symbol;
  final String locale;
  final String name;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.locale,
    required this.name,
  });
}

class AppCurrencies {
  static const naira = AppCurrency(
    code: 'NGN',
    symbol: '₦',
    locale: 'en_NG',
    name: 'Nigerian Naira',
  );

  static const dollar = AppCurrency(
    code: 'USD',
    symbol: r'$',
    locale: 'en_US',
    name: 'US Dollar',
  );

  static const pound = AppCurrency(
    code: 'GBP',
    symbol: '£',
    locale: 'en_GB',
    name: 'British Pound',
  );

  static const euro = AppCurrency(
    code: 'EUR',
    symbol: '€',
    locale: 'de_DE',
    name: 'Euro',
  );

  static const List<AppCurrency> supported = [
    naira,
    dollar,
    pound,
    euro,
  ];

  static AppCurrency fromCode(String code) {
    return supported.firstWhere(
      (currency) => currency.code == code,
      orElse: () => naira,
    );
  }
}