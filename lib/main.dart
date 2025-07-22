import 'package:cargo_app/screens/onboardingScreen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Routing App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Onboarding(),
        '/onboarding': (context) => Onboarding(),
      },
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home')),
//       body: Center(
//         child: ElevatedButton(
//           child: Text('Go to Onboarding'),
//           onPressed: () {
//             Navigator.pushNamed(context, '/onboarding');
//           },
//         ),
//       ),
//     );
//   }
// }
