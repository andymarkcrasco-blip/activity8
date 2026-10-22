import 'package:flutter/material.dart';

/// Reusable button used across screens.
/// Lesson 8 principle: Build once, reuse many times.
///
/// Used in: home_screen.dart, login_screen.dart, dashboard_screen.dart
/// and report_form_screen.dart (Activity 9).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// When true the button shows a spinner and is disabled.
  /// This is how Activity 9 prevents duplicate submissions.
  final bool isLoading;

  /// Renders the button as an outlined (secondary) action.
  final bool isOutlined;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon ?? Icons.arrow_forward);

    final labelText = isLoading ? '$label...' : label;

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: child,
              label: Text(labelText),
            )
          : FilledButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: child,
              label: Text(labelText),
            ),
    );
  }
}
