import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';
import '../overlays/app_bottom_sheet.dart';

/// A select/dropdown field: shows the current selection in the closed
/// field, opens a bottom sheet (app_bottom_sheet.dart) to choose from —
/// never a long wheel picker for choices that don't need one.
class AppSelectField<T> extends ConsumerWidget {
  final String? label;
  final String hint;
  final T? value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T>? onChanged;
  final String? errorText;
  final String sheetTitle;

  const AppSelectField({
    super.key,
    this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.errorText,
    required this.sheetTitle,
  });

  Future<void> _open(BuildContext context) async {
    final selected = await showAppBottomSheet<T>(
      context: context,
      builder: (context) => _OptionList<T>(
        title: sheetTitle,
        options: options,
        value: value,
        labelBuilder: labelBuilder,
      ),
    );
    if (selected != null) onChanged?.call(selected);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final hasError = errorText != null && errorText!.isNotEmpty;
    final disabled = onChanged == null;
    final displayText = value != null ? labelBuilder(value as T) : hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.label.copyWith(color: scheme.textSecondary)),
          const SizedBox(height: AppSpacing.space2),
        ],
        Semantics(
          button: true,
          enabled: !disabled,
          label: label ?? hint,
          value: displayText,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.mdRadius,
              onTap: disabled ? null : () => _open(context),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space4,
                ),
                decoration: BoxDecoration(
                  color: disabled ? scheme.disabledFill : scheme.surface,
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(
                    color: hasError ? AppColors.error : scheme.border,
                    width: hasError ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayText,
                        style: AppTypography.bodyLg.copyWith(
                          color: disabled
                              ? scheme.disabledText
                              : (value != null ? scheme.textPrimary : scheme.textMuted),
                        ),
                      ),
                    ),
                    Icon(Icons.expand_more, color: scheme.textMuted, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.space1),
          Text(errorText!, style: AppTypography.caption.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }
}

class _OptionList<T> extends ConsumerWidget {
  final String title;
  final List<T> options;
  final T? value;
  final String Function(T) labelBuilder;

  const _OptionList({
    required this.title,
    required this.options,
    required this.value,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h3.copyWith(color: scheme.textPrimary)),
        const SizedBox(height: AppSpacing.space4),
        ...options.map((option) {
          final selected = option == value;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.mdRadius,
              onTap: () => Navigator.of(context).pop(option),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space3,
                  vertical: AppSpacing.space3,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        labelBuilder(option),
                        style: AppTypography.bodyLg.copyWith(
                          color: scheme.textPrimary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (selected) Icon(Icons.check, color: scheme.primary, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
