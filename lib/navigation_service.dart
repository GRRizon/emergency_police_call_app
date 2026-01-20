import 'package:flutter/material.dart';

class NavigationService {
  // This key is the "magic wand" that allows us to navigate from anywhere
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Helper to show a SnackBar without needing 'context'
  static void showSnackBar(String message, {bool isError = false}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  // Helper to navigate without needing 'context'
  static void navigateTo(Widget page, {bool replace = false}) {
    if (replace) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );
    } else {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => page),
      );
    }
  }
}
