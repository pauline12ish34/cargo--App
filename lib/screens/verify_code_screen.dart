import 'package:flutter/material.dart';
import '../constants.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

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
            const SizedBox(height: 24),
            const Text("Check your email", style: titleStyle),
            const SizedBox(height: 8),
            const Text(
              "We sent a reset link to contact@ange…rw\nEnter the 5-digit code from the email",
              style: subtitleStyle,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (_) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: inputBg,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primaryGreen),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/password-reset-confirmation');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: const Text("VERIFY CODE", style: verifyTextStyle),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Haven’t got the email yet?", style: subtitleStyle),
                SizedBox(width: 4),
                Text(
                  "Resend email",
                  style: TextStyle(
                    color: resendLinkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
