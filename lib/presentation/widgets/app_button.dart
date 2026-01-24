import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonType type;
  final Icon? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.type = ButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon!, const SizedBox(width: 8), Text(label)],
                )
              : Text(label),
        );
        break;
      case ButtonType.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon!, const SizedBox(width: 8), Text(label)],
                )
              : Text(label),
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon!, const SizedBox(width: 8), Text(label)],
                )
              : Text(label),
        );
        break;
      case ButtonType.danger:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          onPressed: isLoading ? null : onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon!, const SizedBox(width: 8), Text(label)],
                )
              : Text(label),
        );
        break;
    }

    if (isLoading) {
      button = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.5, child: button),
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

enum ButtonType { primary, secondary, text, danger }
