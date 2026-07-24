import 'package:equatable/equatable.dart';

class VehicleDetails extends Equatable {
  final String ownerName;
  final String address;
  final String make;
  final String model;
  final String rego;
  final String year;
  final String odometer;
  final String vin;
  final String engineNo;

  const VehicleDetails({
    this.ownerName = '',
    this.address = '',
    this.make = '',
    this.model = '',
    this.rego = '',
    this.year = '',
    this.odometer = '',
    this.vin = '',
    this.engineNo = '',
  });

  @override
  List<Object?> get props => [
    ownerName,
    address,
    make,
    model,
    rego,
    year,
    odometer,
    vin,
    engineNo,
  ];
}
