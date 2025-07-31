import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

mixin ImagePickerMixin {
  final ImagePicker _picker = ImagePicker();

  void showImagePickerDialog(BuildContext context, {Function(File)? onImageSelected}) {
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
                pickImageFromCamera(context, onImageSelected: onImageSelected);
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickImageFromGallery(context, onImageSelected: onImageSelected);
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

  void showDocumentPickerDialog(BuildContext context, String documentType, {Function(File)? onDocumentSelected}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload $documentType'),
          content: Text('Choose how to upload your $documentType'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickImageFromCamera(context, onImageSelected: onDocumentSelected);
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickImageFromGallery(context, onImageSelected: onDocumentSelected);
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickDocumentFromFiles(context, onDocumentSelected: onDocumentSelected);
              },
              child: const Text('Files'),
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

  Future<void> pickImageFromCamera(BuildContext context, {Function(File)? onImageSelected}) async {
    try {
      // Request camera permission
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission.isDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required to take photos')),
          );
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && onImageSelected != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  Future<void> pickImageFromGallery(BuildContext context, {Function(File)? onImageSelected}) async {
    try {
      // Request photo permission
      final photoPermission = await Permission.photos.request();
      if (photoPermission.isDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo access permission is required')),
          );
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && onImageSelected != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  Future<void> pickDocumentFromFiles(BuildContext context, {Function(File)? onDocumentSelected}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (onDocumentSelected != null) {
          onDocumentSelected(file);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting document: $e')),
        );
      }
    }
  }
}
