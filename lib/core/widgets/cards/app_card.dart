import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/theme_provider.dart';

/// The standard (non-glass) card: theme `surface`, 1px theme `border`,
/// radius-lg(16), 16-20dp padding, optional shadow-1.
///
/// For the translucent/blurred variant, see glass_card.dart. Feature-
/// specific card variants (ActivityCard, DomainResultCard, ...) are out of
/// scope here — their data shapes aren't finalized yet; build on top of
/// this generic card once they are.
class AppCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool elevated;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.elevated = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);

    final decoration = BoxDecoration(
      color: scheme.surface,
      borderRadius: AppRadius.lgRadius,
      border: Border.all(
        color: scheme.isDark
            ? AppShadows.darkElevationBorder().top.color
            : scheme.border,
        width: 1,
      ),
      boxShadow: elevated ? AppShadows.elevation1(scheme.isDark) : null,
    );

    final content = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.lgRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}
