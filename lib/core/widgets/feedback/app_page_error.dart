import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';
import '../buttons/app_button.dart';

/// The generic full-page error pattern: a friendly message + Retry + a
/// safe navigation path out. [message] must always be a friendly,
/// human-readable sentence — never a raw stack trace, provider error
/// code, or SQL error surfaced to the user. Callers are responsible for
/// translating whatever they caught into that sentence before passing it
/// here; this widget won't attempt to interpret or format an exception
/// itself.
class AppPageError extends ConsumerWidget {
  final String message;
  final VoidCallback? onRetry;
  final String safeActionLabel;
  final VoidCallback onSafeAction;

  const AppPageError({
    super.key,
    required this.message,
    this.onRetry,
    this.safeActionLabel = 'Go back',
    required this.onSafeAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_dissatisfied_outlined, size: 44, color: scheme.textMuted),
            const SizedBox(height: AppSpacing.space4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(color: scheme.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space6),
            if (onRetry != null)
              AppButton.primary(label: 'Retry', onPressed: onRetry, expand: false),
            const SizedBox(height: AppSpacing.space3),
            AppButton.tertiary(label: safeActionLabel, onPressed: onSafeAction),
          ],
        ),
      ),
    );
  }
}
