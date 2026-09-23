import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';

/// A short confirmation snackbar (3-5s), with an optional action (e.g.
/// "Undo"). Reads the active [AppColorScheme] via the ambient
/// [ProviderScope] at the [context]'s position — no BuildContext-less
/// styling hacks.
void showAppSnackbar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
}) {
  final container = ProviderScope.containerOf(context);
  final scheme = container.read(activeColorSchemeProvider);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : scheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        content: Text(
          message,
          style: AppTypography.body.copyWith(
            color: isError ? Colors.white : scheme.textPrimary,
          ),
        ),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: isError ? Colors.white : scheme.primary,
                onPressed: onAction,
              )
            : null,
      ),
    );
}
