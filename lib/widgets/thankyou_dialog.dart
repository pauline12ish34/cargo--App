import 'package:cargo_app/features/cargo_owner/screens/cargo_owner_home.dart';
import 'package:flutter/material.dart';

class ThankYouDialog extends StatelessWidget {
  const ThankYouDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 10),
          const Text("Thank you", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Thank you for your valuable feedback and tip."),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CargoOwnerHome())),

            child: const Text("Back Home"),
          )
        ]),
      ),
    );
  }
}
