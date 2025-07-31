import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cargo_app/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows images', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
    expect(find.byType(Image), findsNWidgets(2));
  });
}
