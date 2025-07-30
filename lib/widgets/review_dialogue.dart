import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:provider/provider.dart';

import 'package:cargo_app/widgets/thankyou_dialog.dart';

class ReviewDialog extends StatefulWidget {
  // final String carId;
  // final String carName;

  // const ReviewDialog({required this.carId, required this.carName, super.key});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _rating = 4.5;
  String _review = '';
  int _tip = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // insetPadding: const EdgeInsets.all(0),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            /// 🌟 Dynamic RatingBar
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              unratedColor: Colors.grey.withOpacity(0.3),
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),

            const SizedBox(height: 12),

            Text(
              _rating >= 4 ? "Excellent" : "Good",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: "Write your review",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
              onChanged: (val) => _review = val,
            ),

            const SizedBox(height: 12),
            const Text(
              "Give some tips",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Wrap(
              spacing: 10,
              children: [1, 2, 5, 10, 20].map((amount) {
                final isSelected = _tip == amount;
                return ChoiceChip(
                  label: Text(
                    '\$$amount',
                    style: const TextStyle(color: Colors.black),
                  ),
                  // selected: isSelected,
                  selected: isSelected,
                  //  _tip == amount,
                  onSelected: (_) => setState(() => _tip = amount),
                  selectedColor:
                      Colors.transparent, // Prevent default fill color
                  backgroundColor: Colors.transparent,
                  showCheckmark: false,
                  side: BorderSide(
                    color: isSelected ? Colors.green : Colors.grey.shade500,
                    width: 2,
                  ),
                );
              }).toList(),
            ),
            TextButton(
              onPressed: () {
                // Show custom amount input
              },
              child: Text(
                "Enter other amount",
                style: TextStyle(color: Colors.green.shade500),
              ),
            ),

            const SizedBox(height: 15),
            ElevatedButton.icon(
              label: const Text(
                "Submit",
                style: TextStyle(color: Color(0xffFFFFFF)),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.green,
              ),

              onPressed: () {
                // Provider.of<CarProvider>(
                //   context,
                //   listen: false,
                // ).submitReview(widget.carId, _review, _rating);
                Navigator.pop(context); // close dialog
                showDialog(
                  context: context,
                  builder: (_) => const ThankYouDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
