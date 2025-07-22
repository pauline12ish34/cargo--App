import 'package:flutter/material.dart';

class ButtonProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> performAction() async {
    _isLoading = true;
    notifyListeners();

    // Simulate a network request or async operation
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }
}
