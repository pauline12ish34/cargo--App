import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/');
    });

    return Scaffold(
      backgroundColor: const Color(0xFFE1F3ED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash-illustration.png',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/cargolink-logo.png',
              width: 160,
              height: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
