import 'package:flutter_test/flutter_test.dart';
import 'package:cargo_app/core/models/booking_model.dart';

void main() {
  group('BookingModel', () {
    test('constructor creates correct instance', () {
      final booking = BookingModel(
        id: '1',
        cargoOwnerId: 'owner1',
        pickupLocation: 'A',
        dropoffLocation: 'B',
        cargoDescription: 'Boxes',
        vehicleType: VehicleType.pickup,
        status: BookingStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(booking.id, '1');
      expect(booking.cargoOwnerId, 'owner1');
      expect(booking.pickupLocation, 'A');
      expect(booking.dropoffLocation, 'B');
      expect(booking.cargoDescription, 'Boxes');
      expect(booking.vehicleType, VehicleType.pickup);
      expect(booking.status, BookingStatus.pending);
      expect(booking.createdAt, DateTime(2024, 1, 1));
    });
  });
}
