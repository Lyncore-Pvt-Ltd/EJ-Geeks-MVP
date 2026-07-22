enum RatingOption {
  good,
  fair,
  repair,
  na,
  nc;

  String get label {
    switch (this) {
      case RatingOption.good:
        return 'Good';
      case RatingOption.fair:
        return 'Fair';
      case RatingOption.repair:
        return 'Repair';
      case RatingOption.na:
        return 'N/A';
      case RatingOption.nc:
        return 'N/C';
    }
  }

  static RatingOption? fromLabel(String? label) {
    if (label == null) return null;
    for (final option in RatingOption.values) {
      if (option.label == label) return option;
    }
    return null;
  }
}
