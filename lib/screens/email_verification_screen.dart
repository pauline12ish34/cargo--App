import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  @override
  void initState() {
    super.initState();
    // Send verification email automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationEmail();
    });
  }

  Future<void> _sendVerificationEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.sendEmailVerification();
  }

  Future<void> _resendVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.sendEmailVerification();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _checkVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await authProvider.checkEmailVerification();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verification status updated!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // If verified, navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF2F7FAFF),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userEmail = authProvider.user?.email ?? 'your email';
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 24, color: Colors.orange),
                ),
                const SizedBox(height: 24),
                const Text("Verify your email", style: titleStyle),
                const SizedBox(height: 8),
                Text(
                  "We sent a verification link to $userEmail\nClick the link in your email to verify your account.",
                  style: subtitleStyle,
                ),
                const SizedBox(height: 32),
                
                // Check verification button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("I'VE VERIFIED", style: buttonTextStyle),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Resend verification button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: authProvider.isLoading ? null : _resendVerification,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    child: const Text(
                      "RESEND EMAIL",
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Skip for now option
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text(
                      "Skip for now",
                      style: TextStyle(
                        color: textGray,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}