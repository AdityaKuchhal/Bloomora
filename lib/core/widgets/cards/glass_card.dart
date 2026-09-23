import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_motion.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/theme_provider.dart';

/// The glass/translucent card variant — consolidated here from the old
/// `lib/core/theme/glass_components.dart` per the Frontend Spec's file
/// structure (cards/glass_card.dart). Semi-opaque [scheme.surface]
/// (>=85% opacity in light mode), 12-16px blur, MUST fall back to a fully
/// opaque surface in reduce-transparency/high-contrast/reduced-motion
/// contexts — "glass effects degrade to opaque accessible surfaces" is a
/// hard requirement (Frontend Spec color system + QA checklist), not a
/// nice-to-have.
///
/// Flutter doesn't expose a direct cross-platform "Reduce Transparency"
/// MediaQuery flag as of this SDK — [MediaQuery.highContrastOf] and
/// [AppMotion.isReduced] (disableAnimations) are used as the closest
/// available proxies, in addition to the explicit [forceOpaque] param a
/// caller (or a future accessibility setting) can drive directly.
class GlassCard extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blurStrength;
  final bool forceOpaque;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.xl,
    this.padding = const EdgeInsets.all(20),
    this.blurStrength = AppShadows.glassBlur,
    this.forceOpaque = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final radius = BorderRadius.circular(borderRadius);

    final useOpaqueFallback = forceOpaque ||
        MediaQuery.highContrastOf(context) ||
        AppMotion.isReduced(context);

    final glassSurface = scheme.surface.withValues(alpha: scheme.isDark ? 0.82 : 0.88);
    final border = scheme.isDark
        ? AppShadows.darkElevationBorder(opacity: 0.14)
        : Border.all(color: scheme.border, width: 1);

    final decoratedChild = Container(
      decoration: BoxDecoration(
        color: useOpaqueFallback ? scheme.surface : glassSurface,
        borderRadius: radius,
        border: border,
        boxShadow: AppShadows.elevation2(scheme.isDark),
      ),
      padding: padding,
      child: child,
    );

    if (useOpaqueFallback) {
      return ClipRRect(borderRadius: radius, child: decoratedChild);
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
        child: decoratedChild,
      ),
    );
  }
}
