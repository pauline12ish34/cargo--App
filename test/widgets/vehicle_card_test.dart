import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cargo_app/widgets/vehicle_card.dart';

void main() {
  testWidgets('VehicleCard renders with title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleCard(
          address: '123 Main St',
          details: 'Toyota Hiace',
          distance: '5km',
          status: 'Available',
        ),
      ),
    );
    expect(find.text('Address: 123 Main St'), findsOneWidget);
    expect(find.text('Toyota Hiace'), findsOneWidget);
    expect(find.text('5km'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
  });
}
