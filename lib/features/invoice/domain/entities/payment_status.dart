enum PaymentStatus {
  pending,
  paid;

  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending Payment';
      case PaymentStatus.paid:
        return 'Paid';
    }
  }

  String toDb() => name;

  static PaymentStatus fromDb(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}
