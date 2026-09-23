import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_provider.dart';

enum AppIconButtonShape { rounded, circular }

/// A 48x48dp-minimum icon-only button. [semanticLabel] is required — an
/// icon alone is never an acceptable accessible label.
///
/// This widget does not add a confirmation step for destructive actions;
/// per the design system rule, no icon-only destructive action may skip a
/// confirmation dialog (see overlays/app_dialog.dart) — that's enforced by
/// the caller wiring [onPressed] to open one, not by this widget.
class AppIconButton extends ConsumerWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final AppIconButtonShape shape;
  final double iconSize;
  final Color? color;
  final Color? background;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.shape = AppIconButtonShape.rounded,
    this.iconSize = 22,
    this.color,
    this.background,
  }) : assert(iconSize >= 16 && iconSize <= 24, 'icon should be 20-24dp per spec');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final disabled = onPressed == null;
    final fg = disabled ? scheme.disabledText : (color ?? scheme.textPrimary);
    final bg = disabled ? null : background;
    final radius = shape == AppIconButtonShape.circular
        ? AppRadius.pillRadius
        : AppRadius.mdRadius;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: semanticLabel,
      child: Material(
        color: bg ?? Colors.transparent,
        shape: shape == AppIconButtonShape.circular
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: onPressed,
          customBorder: shape == AppIconButtonShape.circular
              ? const CircleBorder()
              : RoundedRectangleBorder(borderRadius: radius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Center(child: Icon(icon, size: iconSize, color: fg)),
          ),
        ),
      ),
    );
  }
}
