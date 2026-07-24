enum ServiceStatus {
  ongoingService,
  completed;

  String get label {
    switch (this) {
      case ServiceStatus.ongoingService:
        return 'Ongoing Service';
      case ServiceStatus.completed:
        return 'Completed';
    }
  }

  String toDb() => name;

  static ServiceStatus fromDb(String value) {
    return ServiceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ServiceStatus.ongoingService,
    );
  }
}
