import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';

/// Buttons get their own 14dp corner radius — distinct from the
/// radius-*(AppRadius) scale on purpose (Frontend Spec component section
/// gives buttons a radius separate from the general scale).
const double _kButtonRadius = 14;

/// Minimum visual height for Primary/Secondary/Destructive fills.
/// Tertiary is visually shorter (it's low-emphasis) but still meets the
/// 48x48dp tap target via [_kMinTapTarget] padding below its content.
const double _kButtonHeight = 52;

/// Hard floor for tappable area, independent of visual size — every
/// variant, including Tertiary, must hit this.
const double _kMinTapTarget = 48;

enum AppButtonVariant { primary, secondary, tertiary, destructive, destructiveOutline }

/// A button following the Frontend Spec's Primary/Secondary/Tertiary/
/// Destructive system. Always theme-resolved — never pass a raw [Color].
///
/// - Disabled: pass `onPressed: null`. Visually unambiguous (dedicated
///   disabled fill/text pair) — but *why* it's disabled is a caller-level
///   concern (e.g. helper text nearby), not something this widget infers.
/// - Loading: pass `isLoading: true`. The label stays laid out (invisibly)
///   so button width/height never shifts when a spinner replaces the
///   leading icon.
/// - Tap target: every variant reserves >=48x48dp hit area even where the
///   visual fill is shorter (Tertiary) — never only the rendered pixels.
/// - Text scaling: the button grows vertically rather than clip at large
///   system text scale (no fixed height locks — see [_kButtonHeight] used
///   as a *minimum*, not a fixed constraint).
class AppButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  const AppButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool expand = true,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.primary,
          isLoading: isLoading,
          icon: icon,
          expand: expand,
        );

  const AppButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool expand = true,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.secondary,
          isLoading: isLoading,
          icon: icon,
          expand: expand,
        );

  const AppButton.tertiary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool expand = false,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.tertiary,
          isLoading: isLoading,
          icon: icon,
          expand: expand,
        );

  /// [outline] = error-outline variant (severity: lower). Solid fill by
  /// default — for delete/sign-out-irreversible flows only.
  const AppButton.destructive({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool expand = true,
    bool outline = false,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: outline
              ? AppButtonVariant.destructiveOutline
              : AppButtonVariant.destructive,
          isLoading: isLoading,
          icon: icon,
          expand: expand,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final disabled = onPressed == null || isLoading;

    return _ButtonShell(
      label: label,
      onPressed: disabled ? null : onPressed,
      isLoading: isLoading,
      icon: icon,
      expand: expand,
      disabled: disabled,
      scheme: scheme,
      variant: variant,
    );
  }
}

class _ButtonShell extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;
  final bool disabled;
  final AppColorScheme scheme;
  final AppButtonVariant variant;

  const _ButtonShell({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    required this.expand,
    required this.disabled,
    required this.scheme,
    required this.variant,
  });

  @override
  State<_ButtonShell> createState() => _ButtonShellState();
}

class _ButtonShellState extends State<_ButtonShell> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.disabled) return;
    setState(() => _pressed = v);
  }

  ({Color fill, Color text, Color? border}) _colors() {
    final scheme = widget.scheme;
    if (widget.disabled) {
      return (fill: scheme.disabledFill, text: scheme.disabledText, border: null);
    }
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return (
          fill: _pressed ? scheme.primaryStrong : scheme.primary,
          text: Colors.white,
          border: null,
        );
      case AppButtonVariant.secondary:
        return (fill: scheme.surface, text: scheme.textPrimary, border: scheme.border);
      case AppButtonVariant.tertiary:
        return (fill: Colors.transparent, text: scheme.primary, border: null);
      case AppButtonVariant.destructive:
        return (fill: AppColors.error, text: Colors.white, border: null);
      case AppButtonVariant.destructiveOutline:
        return (fill: Colors.transparent, text: AppColors.error, border: AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    final isTertiary = widget.variant == AppButtonVariant.tertiary;

    final content = Stack(
      alignment: Alignment.center,
      children: [
        // Always laid out (possibly invisible) so loading never shifts size.
        Opacity(
          opacity: widget.isLoading ? 0 : 1,
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: colors.text),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: AppTypography.button.copyWith(color: colors.text),
                ),
              ),
            ],
          ),
        ),
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(colors.text),
            ),
          ),
      ],
    );

    return Semantics(
      button: true,
      enabled: !widget.disabled,
      label: widget.label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: _kMinTapTarget, minHeight: _kMinTapTarget),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            borderRadius: BorderRadius.circular(_kButtonRadius),
            child: AnimatedContainer(
              duration: AppMotion.standard,
              curve: AppMotion.standardCurve,
              constraints: BoxConstraints(minHeight: isTertiary ? _kMinTapTarget : _kButtonHeight),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isTertiary ? 12 : 8,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.fill,
                borderRadius: BorderRadius.circular(_kButtonRadius),
                border: colors.border != null ? Border.all(color: colors.border!, width: 1) : null,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
