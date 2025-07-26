import 'package:cargo_app/screens/onboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/verify_code_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/password_reset_confirmation.dart';
import 'screens/set_new_password_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            title: 'CargoLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
  '/splash': (context) => const SplashScreen(),
  '/': (context) => WelcomeScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/forgot-password': (context) => const ForgetPasswordScreen(),
  '/verify-code': (context) => const VerifyCodeScreen(),
  '/password-reset-confirmation': (context) => const PasswordResetConfirmation(),
  '/set-new-password': (context) => const SetNewPasswordScreen(),
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
