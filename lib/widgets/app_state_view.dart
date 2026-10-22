import 'package:flutter/material.dart';

/// Reusable presentation of an asynchronous UI state response.
///
/// Used by report_form_screen.dart (Activity 9) for the
/// LOADING / SUCCESS / EMPTY / ERROR responses so every state
/// looks the same across the app.
class AppStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  /// Visual variant: loading, success, empty or error.
  final AppStateKind kind;

  /// Optional action button (for example "Retry" on error).
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.kind = AppStateKind.empty,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color color = switch (kind) {
      AppStateKind.loading => scheme.primary,
      AppStateKind.success => Colors.green.shade700,
      AppStateKind.error => scheme.error,
      AppStateKind.empty => scheme.onSurfaceVariant,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (kind == AppStateKind.loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Icon(icon, size: 40, color: color),
            ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kind of asynchronous response rendered by [AppStateView].
enum AppStateKind { loading, success, empty, error }
