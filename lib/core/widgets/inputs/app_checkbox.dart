import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';

/// A checkbox with a tappable label, 44-48dp hit target.
///
/// Never wire this to an irreversible action directly (e.g. "delete on
/// check") — that's a caller-level rule this widget can't enforce, only
/// document: irreversible actions belong behind a button + confirmation
/// dialog (see overlays/app_dialog.dart), not a checkbox toggle.
class AppCheckbox extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final disabled = onChanged == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      checked: value,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.smRadius,
          onTap: disabled ? null : () => onChanged!(!value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: value,
                      onChanged: disabled ? null : (v) => onChanged!(v ?? false),
                      activeColor: scheme.primary,
                      side: BorderSide(color: scheme.border, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body.copyWith(
                        color: disabled ? scheme.disabledText : scheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A switch-style toggle with a tappable label, same hit-target/usage
/// rules as [AppCheckbox].
class AppToggle extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;

  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final disabled = onChanged == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      toggled: value,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.smRadius,
          onTap: disabled ? null : () => onChanged!(!value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body.copyWith(
                        color: disabled ? scheme.disabledText : scheme.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: value,
                    onChanged: disabled ? null : onChanged,
                    activeThumbColor: Colors.white,
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor: scheme.border,
                    inactiveThumbColor: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
