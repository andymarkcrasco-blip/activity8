import 'package:flutter/material.dart';

/// Reusable text field used by login, report form and future forms.
///
/// Used in: login_screen.dart (Activity 8) and
/// report_form_screen.dart (Activity 9) - shared widget in two contexts.
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  /// Number of lines for multi-line input (Activity 9 description field).
  final int maxLines;

  final String? helperText;
  final IconData? prefixIcon;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.helperText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      minLines: maxLines > 1 ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
