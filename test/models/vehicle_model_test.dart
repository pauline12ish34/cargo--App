import 'package:flutter_test/flutter_test.dart';
import 'package:cargo_app/core/models/vehicle_model.dart';
import 'package:cargo_app/core/enums/app_enums.dart';

void main() {
  group('Vehicle', () {
    test('constructor creates correct instance', () {
      final vehicle = Vehicle(
        vehicleId: 'v1',
        make: 'Toyota',
        model: 'Hiace',
        year: 2020,
        licensePlate: 'ABC123',
        type: VehicleType.van,
        capacity: VehicleCapacity.medium,
        maxWeight: 1000.0,
        registrationNumber: 'REG123',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );
      expect(vehicle.vehicleId, 'v1');
      expect(vehicle.make, 'Toyota');
      expect(vehicle.model, 'Hiace');
      expect(vehicle.year, 2020);
      expect(vehicle.licensePlate, 'ABC123');
      expect(vehicle.type, VehicleType.van);
      expect(vehicle.capacity, VehicleCapacity.medium);
      expect(vehicle.maxWeight, 1000.0);
      expect(vehicle.registrationNumber, 'REG123');
      expect(vehicle.createdAt, DateTime(2024, 1, 1));
      expect(vehicle.updatedAt, DateTime(2024, 1, 2));
      expect(vehicle.isActive, true);
    });
  });
}
