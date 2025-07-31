import 'package:flutter/material.dart';

// Colors
const Color primaryGreen = Color(0xFF008853);
const Color appGreen = Color(0xFF08914D);
const Color lightGreen = Color(0xFFC5E7DF);
const Color searchBg = Color(0xFFE1F3ED);
const Color inputBg = Color(0xFFF1F7FA);
const Color borderGray = Color(0xFFCBD5E1);
const Color textDark = Color(0xFF1E293B);
const Color textGray = Color(0xFF64748B);
const Color resendLinkBlue = Color(0xFF0E4C92);
const Color darkBg = Color(0xFF2D3748);

// Spacing
const double borderRadius = 12.0;
const double cardBorderRadius = 12.0;
const double buttonBorderRadius = 8.0;
const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
const EdgeInsets defaultMargin = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 8,
);

// Text Styles
const TextStyle titleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: textDark,
);

const TextStyle subtitleStyle = TextStyle(fontSize: 14, color: textGray);

const TextStyle buttonTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle verifyTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: textDark,
);

const TextStyle welcomeTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

const TextStyle welcomeSubtitleStyle = TextStyle(color: Colors.grey);

// Button Styles
final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: appGreen,
  minimumSize: const Size(double.infinity, 50),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(buttonBorderRadius),
  ),
);

final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
  minimumSize: const Size(double.infinity, 50),
  side: const BorderSide(color: appGreen),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(buttonBorderRadius),
  ),
);

// Container Decorations
final BoxDecoration cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(cardBorderRadius),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ],
);

final BoxDecoration searchBarDecoration = BoxDecoration(
  color: searchBg,
  borderRadius: BorderRadius.circular(cardBorderRadius),
);

final BoxDecoration vehicleCardDecoration = BoxDecoration(
  color: searchBg,
  borderRadius: BorderRadius.circular(cardBorderRadius),
  border: Border.all(color: appGreen, width: 1),
);
