import 'package:flutter/material.dart';

mixin ImagePickerMixin {
  void showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Profile Picture'),
          content: const Text(
            'Choose an option to update your profile picture',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickImageFromCamera(context);
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickImageFromGallery(context);
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void pickImageFromCamera(BuildContext context) {
    // TODO: Implement camera functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera functionality - Coming Soon!')),
    );
  }

  void pickImageFromGallery(BuildContext context) {
    // TODO: Implement gallery functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery functionality - Coming Soon!')),
    );
  }
}
