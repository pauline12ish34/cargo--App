import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cargo_app/screens/job_details_screen.dart';
import 'package:cargo_app/core/models/booking_model.dart';

void main() {
  testWidgets('JobDetailsScreen renders with booking info', (WidgetTester tester) async {
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
    await tester.pumpWidget(
      MaterialApp(
        home: JobDetailsScreen(booking: booking),
      ),
    );
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });
}
