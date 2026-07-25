String trimmedAmount(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String formatAud(double value) => 'A\$${trimmedAmount(value)}';
