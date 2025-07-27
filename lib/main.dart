import 'package:flutter/material.dart';
import 'widgets/firebase_initializer.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/password_reset_confirmation.dart';
import 'screens/email_verification_screen.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FirebaseInitializer(
      child: MaterialApp(
        title: 'CargoLink',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/': (context) => WelcomeScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/forgot-password': (context) => const ForgetPasswordScreen(),
          '/password-reset-confirmation': (context) =>
              const PasswordResetConfirmation(),
          '/email-verification': (context) => const EmailVerificationScreen(),
          '/home': (context) => const Home(),
        },
      ),
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
