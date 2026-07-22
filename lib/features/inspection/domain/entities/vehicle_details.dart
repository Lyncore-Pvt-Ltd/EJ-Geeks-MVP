import 'package:equatable/equatable.dart';

class VehicleDetails extends Equatable {
  final String make;
  final String model;
  final String rego;
  final String year;
  final String odometer;
  final String vin;
  final String engineNo;

  const VehicleDetails({
    this.make = '',
    this.model = '',
    this.rego = '',
    this.year = '',
    this.odometer = '',
    this.vin = '',
    this.engineNo = '',
  });

  @override
  List<Object?> get props => [make, model, rego, year, odometer, vin, engineNo];
}
