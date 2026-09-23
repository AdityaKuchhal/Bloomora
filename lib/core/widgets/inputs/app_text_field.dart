import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';

/// A text field: minimum 56dp height (grows for large text scale, never
/// clips), radius-md(12), theme `surface` fill, 1px theme `border`. Focus
/// ring is a fixed 2px `#2563EB` across all four palettes (accessibility
/// consistency, not palette-adaptive — see AppColors.focusRing).
///
/// - [label] renders persistently above the field (not placeholder-only)
///   — use [hint] for in-field placeholder text if you also want one.
/// - [helperText]/[errorText]: helper-text layout space is reserved
///   whenever either is non-null-capable for this field (pass
///   `reserveHelperSpace: true` when the field expects validation), so an
///   error appearing later doesn't jump the layout.
/// - [errorText] switches the border/text to the semantic `error` token.
///   The field never clears [controller]'s text on error — user input is
///   always preserved.
/// - Pass [focusNode] and call `.requestFocus()` on it externally to focus
///   this field first on submit if it's the first invalid one — this
///   widget doesn't know about sibling fields, so "focus the first
///   invalid field" is the caller's form-level responsibility to trigger.
/// - Password fields: set [obscureText] and provide [autofillHints]
///   (e.g. `[AutofillHints.password]`) — never disable paste/autofill.
class AppTextField extends ConsumerStatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool reserveHelperSpace;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final bool enabled;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.reserveHelperSpace = false,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.autofillHints,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  ConsumerState<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends ConsumerState<AppTextField> {
  late bool _obscured = widget.obscureText;
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final borderColor = hasError
        ? AppColors.error
        : (_focused ? AppColors.focusRing : scheme.border);
    final borderWidth = _focused || hasError ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.label.copyWith(color: scheme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space2),
        ],
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            color: widget.enabled ? scheme.surface : scheme.disabledFill,
            borderRadius: AppRadius.mdRadius,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            enabled: widget.enabled,
            obscureText: _obscured,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            autofillHints: widget.autofillHints,
            style: AppTypography.bodyLg.copyWith(
              color: widget.enabled ? scheme.textPrimary : scheme.disabledText,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodyLg.copyWith(color: scheme.textMuted),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: scheme.textMuted, size: 20)
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      icon: Icon(
                        _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: scheme.textMuted,
                        size: 20,
                      ),
                      tooltip: _obscured ? 'Show password' : 'Hide password',
                    )
                  : (hasError
                      ? Icon(Icons.error_outline, color: AppColors.error, size: 20)
                      : null),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space4,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              // Errors are rendered by this widget's own helper/error row
              // below, not Flutter's default error text, so spacing stays
              // consistent with [reserveHelperSpace].
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
        if (hasError || widget.helperText != null || widget.reserveHelperSpace) ...[
          const SizedBox(height: AppSpacing.space1),
          SizedBox(
            height: 18,
            child: hasError
                ? Text(
                    widget.errorText!,
                    style: AppTypography.caption.copyWith(color: AppColors.error),
                  )
                : (widget.helperText != null
                    ? Text(
                        widget.helperText!,
                        style: AppTypography.caption.copyWith(color: scheme.textMuted),
                      )
                    : null),
          ),
        ],
      ],
    );
  }
}
