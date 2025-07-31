import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cargo_app/screens/home.dart';

// Fake AuthProvider for testing
class FakeAuthProvider extends ChangeNotifier {
  get user => null;
  Future<void> refreshUserData() async {}
}

// Fake ProfileProvider for testing
class FakeProfileProvider extends ChangeNotifier {
  bool get isLoading => true;
}

void main() {
  testWidgets('Home screen shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FakeAuthProvider()),
          ChangeNotifierProvider(create: (_) => FakeProfileProvider()),
        ],
        child: const MaterialApp(
          home: Home(),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
