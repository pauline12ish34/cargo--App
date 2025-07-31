import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cargo_app/screens/signup_screen.dart';

void main() {
  testWidgets('SignupScreen has input fields and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignupScreen(),
      ),
    );
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.text('CREATE ACCOUNT'), findsNothing); // Button text is in WelcomeScreen
  });
}
