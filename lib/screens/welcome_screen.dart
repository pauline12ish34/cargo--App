import 'package:flutter/material.dart';
import '../constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/welcome.png", height: 250),
            const SizedBox(height: 30),
            const Text("Welcome to CargoLink", style: welcomeTitleStyle),
            const Text(
              "Fill the form to continue",
              style: welcomeSubtitleStyle,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: primaryButtonStyle,
              child: const Text("CREATE ACCOUNT",
              style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: outlineButtonStyle,
              child: const Text("LOGIN", style: TextStyle(color: appGreen)),
            ),
          ],
        ),
      ),
    );
  }
}
