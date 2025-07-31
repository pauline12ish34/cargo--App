import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cargo_app/widgets/stats_card.dart';

void main() {
  testWidgets('StatsCard displays label and value', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StatsCard(
          title: 'Jobs',
          value: '10',
          icon: Icons.work,
          color: Colors.green,
        ),
      ),
    );
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.byIcon(Icons.work), findsOneWidget);
  });
}
