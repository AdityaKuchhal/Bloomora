import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';

/// A pale-tinted chip labeling a developmental domain. Domain color is a
/// secondary encoding only — [icon]/[label] must always carry the meaning
/// on their own, per the design system's color-independence rule.
class DomainChip extends ConsumerWidget {
  final String domain;
  final IconData? icon;

  const DomainChip({super.key, required this.domain, this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final accent = AppColors.domainColors[domain] ?? scheme.primary;

    return Semantics(
      label: domain,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: scheme.isDark ? 0.22 : 0.12),
          borderRadius: AppRadius.pillRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
            ],
            // Flexible (not a bare Text) so the label wraps instead of
            // hard-overflowing when something constrains this chip's
            // width — e.g. at large system text scale inside a Row that
            // doesn't give it unlimited space. Domain chips are still
            // meant to be short one-line labels in normal use; this is
            // the fallback for when they're not.
            Flexible(
              child: Text(
                domain,
                softWrap: true,
                style: AppTypography.caption.copyWith(
                  color: scheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A selectable filter chip. Selected = tinted primary fill + theme
/// `primary` border/text. Unselected = theme `surface` + theme `border`.
///
/// Named `AppFilterChip` (not `FilterChip`) to avoid colliding with
/// Flutter's own `material.dart` `FilterChip`.
class AppFilterChip extends ConsumerWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onChanged;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final disabled = onChanged == null;

    final fill = selected
        ? scheme.primary.withValues(alpha: scheme.isDark ? 0.24 : 0.12)
        : scheme.surface;
    final borderColor = selected ? scheme.primary : scheme.border;
    final textColor = disabled
        ? scheme.disabledText
        : (selected ? scheme.primary : scheme.textPrimary);

    return Semantics(
      button: true,
      selected: selected,
      enabled: !disabled,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.pillRadius,
            onTap: disabled ? null : () => onChanged!(!selected),
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: AppRadius.pillRadius,
                border: Border.all(color: borderColor, width: 1),
              ),
              // Row+Flexible (not a bare centered Text) so the label wraps
              // instead of hard-overflowing when constrained — same
              // reasoning as DomainChip above.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: AppTypography.label.copyWith(color: textColor),
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
