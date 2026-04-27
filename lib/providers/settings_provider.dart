import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:sovereign_ledger/core/constants/app_currencies.dart';
import 'package:sovereign_ledger/core/constants/hive_boxes.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _currencyCodeKey = 'currency_code';

  final Box _settingsBox = Hive.box(HiveBoxes.settings);

  AppCurrency _currency = AppCurrencies.naira;

  AppCurrency get currency => _currency;

  void loadSettings() {
    final savedCode = _settingsBox.get(_currencyCodeKey, defaultValue: 'NGN');
    _currency = AppCurrencies.fromCode(savedCode);
    notifyListeners();
  }

  Future<void> updateCurrency(AppCurrency currency) async {
    _currency = currency;
    await _settingsBox.put(_currencyCodeKey, currency.code);
    notifyListeners();
  }
}