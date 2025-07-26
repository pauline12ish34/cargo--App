import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupScreen extends StatelessWidget {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const SizedBox(height: 80),
            const Text(
              "Register to CargoLink",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text("Fill the form to continue",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                hintText: "Name",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                hintText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                hintText: "Phone number",
                prefixIcon: const Icon(Icons.phone_android),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: const Icon(Icons.visibility_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08914D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("SIGNUP"),
            ),
            const SizedBox(height: 20),
            const Center(child: Text("Or continue with")),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                FaIcon(FontAwesomeIcons.google, size: 24),
                SizedBox(width: 20),
                FaIcon(FontAwesomeIcons.facebook, size: 24),
                SizedBox(width: 20),
                FaIcon(FontAwesomeIcons.instagram, size: 24),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("You already have an account?"),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text("LOGIN",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
