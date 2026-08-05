import 'package:flutter/services.dart';

/// Formats currency input like a calculator: each typed digit shifts in
/// from the right as cents, so "5" -> "0.05", "50" -> "0.50", "500" -> "5.00".
/// Backspacing drops the rightmost digit the same way.
class CentsCurrencyInputFormatter extends TextInputFormatter {
  /// Caps input at 999,999,999.99 so typing can't overflow [int.parse].
  static const _maxDigits = 11;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > _maxDigits) {
      digits = digits.substring(digits.length - _maxDigits);
    }
    final cents = digits.isEmpty ? 0 : int.parse(digits);
    final formatted = (cents / 100).toStringAsFixed(2);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
