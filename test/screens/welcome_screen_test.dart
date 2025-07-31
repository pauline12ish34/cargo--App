import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cargo_app/screens/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen has welcome text and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );
    expect(find.text('Welcome to CargoLink'), findsOneWidget);
    expect(find.text('Fill the form to continue'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
  });
}
