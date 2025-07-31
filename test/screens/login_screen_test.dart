import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cargo_app/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen has email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
      ),
    );
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
