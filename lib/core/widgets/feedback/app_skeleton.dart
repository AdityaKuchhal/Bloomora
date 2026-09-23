import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_motion.dart';
import '../../theme/app_radius.dart';
import '../../theme/theme_provider.dart';

/// A loading placeholder for predictable-layout content (dashboard cards,
/// catalog lists). A gentle opacity pulse — indeterminate, i.e. it
/// indicates "loading" without implying any specific % complete. It must
/// NOT be an animated fake progress bar (that implies real, measured
/// progress the app doesn't have) — this widget only ever pulses in
/// place, never fills/advances.
///
/// Respects reduce-motion: the pulse is skipped (static, at mid-opacity)
/// when [AppMotion.isReduced] is true.
class AppSkeleton extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
  });

  @override
  ConsumerState<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends ConsumerState<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final reduced = AppMotion.isReduced(context);
    final radius = widget.borderRadius ?? AppRadius.mdRadius;

    final base = scheme.isDark ? scheme.surfaceElevated : scheme.border;

    if (reduced) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base.withValues(alpha: 0.6),
          borderRadius: radius,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.4 + (_controller.value * 0.3);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: base.withValues(alpha: opacity),
            borderRadius: radius,
          ),
        );
      },
    );
  }
}
