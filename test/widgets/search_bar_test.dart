import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('SearchBar renders and accepts input', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchBar(
            hintText: 'Search...',
            onChanged: (value) {},
          ),
        ),
      ),
    );
    expect(find.byType(SearchBar), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'query');
    expect(find.text('query'), findsOneWidget);
  });
}
