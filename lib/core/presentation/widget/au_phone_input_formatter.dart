import 'package:flutter/services.dart';

/// Formats a local Australian phone number for entry alongside a fixed
/// `+61` prefix: digits only, capped at 10 (covers both a trunk `0` typed
/// out of habit, e.g. `0412 345 678`, and the bare 9-digit form), grouped
/// as `XXX XXX XXX`.
class AuPhoneNumberInputFormatter extends TextInputFormatter {
  static const _maxDigits = 10;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > _maxDigits) {
      digits = digits.substring(0, _maxDigits);
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
