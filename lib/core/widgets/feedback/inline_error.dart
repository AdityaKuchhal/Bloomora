import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';

/// An inline error, meant to render directly next to the component that
/// failed (a single field, a single card's data fetch — not a full page;
/// see app_page_error.dart for that).
///
/// This widget only renders a message — it never clears or rebuilds
/// sibling state, so it can't be the cause of losing already-entered user
/// data. Actual preservation of that data is the caller's state
/// management; this widget just has to stay out of the way of it.
class InlineError extends ConsumerWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: scheme.isDark ? 0.16 : 0.08),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(color: scheme.textPrimary),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.space2),
            GestureDetector(
              onTap: onRetry,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
                  child: Text(
                    'Retry',
                    style: AppTypography.label.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
