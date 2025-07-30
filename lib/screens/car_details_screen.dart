import 'package:cargo_app/widgets/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RideDetailsPage extends StatelessWidget {
  const RideDetailsPage({super.key});

  Widget buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          hintText: value,
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ride Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/truck.jpg', // Path to your SVG file
            ),

            const SizedBox(height: 10),
            const Text("Location: Kimironko", style: TextStyle(fontSize: 16)),
            const Text(
              "Price: Rwf 80k",
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            const Divider(height: 20),
            const Text(
              "Car features",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildInfoTile("Model", "GT5000"),
            buildInfoTile("Capacity", "760hp"),
            buildInfoTile("Color", "Red"),
            buildInfoTile("Gear type", "Automatic"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle bargain action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[200],
                minimumSize: const Size.fromHeight(40),
              ),
              child: const Text(
                "BARGAIN",
                style: TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => showPaymentDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "PLACE AN ORDER",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
