import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';
import '../buttons/app_button.dart';

/// A short blocking confirmation or system-error dialog. Max 2 actions.
/// Scrim ~45% black (from [ThemeData.dialogTheme] backdrop via
/// [showDialog]'s default barrier, styled through [AppColors.scrim] here).
///
/// [barrierDismissible] defaults to `true` (tapping outside = implicit
/// cancel, which is safe for a plain confirm dialog). Callers embedding
/// unsaved input inside [content] must pass `barrierDismissible: false` —
/// "tap-outside-to-dismiss only when losing unsaved data is impossible" is
/// about that case, not about simple confirm/cancel dialogs where dismiss
/// and cancel are the same safe outcome.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
  bool barrierDismissible = true,
  VoidCallback? onConfirm,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: AppColors.scrim,
    builder: (context) => AppDialog(
      title: title,
      message: message,
      content: content,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      onConfirm: onConfirm,
    ),
  );
}

class AppDialog extends ConsumerWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback? onConfirm;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return Dialog(
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.h3.copyWith(color: scheme.textPrimary)),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.space2),
              Text(
                message!,
                style: AppTypography.body.copyWith(color: scheme.textSecondary),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: AppSpacing.space4),
              content!,
            ],
            const SizedBox(height: AppSpacing.space6),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: isDestructive
                      ? AppButton.destructive(
                          label: confirmLabel,
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            onConfirm?.call();
                          },
                        )
                      : AppButton.primary(
                          label: confirmLabel,
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            onConfirm?.call();
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
