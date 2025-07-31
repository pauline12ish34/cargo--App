import 'package:flutter/material.dart';
import '../constants.dart';

class PasswordResetConfirmation extends StatelessWidget {
  const PasswordResetConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF2F7FAFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, size: 24, color: Colors.orange),
            ),
            const SizedBox(height: 60),
            const Text('Check your email', style: titleStyle),
            const SizedBox(height: 10),
            const Text(
              'We sent a password reset link to your email address. Click the link in your email to reset your password.',
              style: subtitleStyle,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: const Text('BACK TO LOGIN', style: buttonTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
