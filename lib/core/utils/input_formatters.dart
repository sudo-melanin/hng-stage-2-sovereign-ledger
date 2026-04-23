import 'package:flutter/services.dart';

class AppInputFormatters {
  /// Allows positive numbers only, with optional decimal values.
  /// Blocks letters, minus signs, and repeated decimal points.
  static final List<TextInputFormatter> positiveDecimal = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  /// Allows whole positive numbers only.
  static final List<TextInputFormatter> positiveInteger = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Keeps names/titles readable while preventing excessive length.
  static List<TextInputFormatter> text({int maxLength = 40}) {
    return [
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  /// Keeps notes short enough for mobile display.
  static final List<TextInputFormatter> note = [
    LengthLimitingTextInputFormatter(120),
  ];
}