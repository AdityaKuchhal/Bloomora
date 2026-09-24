import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  // ── Navigation logic — untouched ──────────────────────────────────────────
  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      context.go(isAuthenticated ? AppRoutes.home : AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return Scaffold(
      backgroundColor: scheme.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => FadeTransition(
          opacity: _fade,
          child: Transform.scale(
            scale: _scale.value,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ─────────────────────────────────────────────────
                  _BloomLogo(
                    primaryColor: scheme.primary,
                    accentColor: scheme.accent,
                  ),

                  const SizedBox(height: 28),

                  // ── App name ──────────────────────────────────────────────
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: scheme.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Tagline ───────────────────────────────────────────────
                  Text(
                    'Growing Together',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: scheme.textMuted,
                      letterSpacing: 0.8,
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

// ─── Bloom logo ───────────────────────────────────────────────────────────────

/// 6-petal flower — 6 circles arranged at 60° intervals around a center dot.
/// Total bounding box: 72 × 72 px.
class _BloomLogo extends StatelessWidget {
  final Color primaryColor;
  final Color accentColor;

  const _BloomLogo({
    required this.primaryColor,
    required this.accentColor,
  });

  static const double _size       = 72.0;
  static const double _petalSize  = 22.0;
  static const double _centerSize = 18.0;
  static const double _orbitR     = 18.0; // center-to-petal distance

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 6 petals at 60° steps (starting from top, i.e. -90°)
          for (int i = 0; i < 6; i++)
            Transform.translate(
              offset: Offset(
                _orbitR * math.cos((i * 60 - 90) * math.pi / 180),
                _orbitR * math.sin((i * 60 - 90) * math.pi / 180),
              ),
              child: Container(
                width: _petalSize,
                height: _petalSize,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // Center accent dot
          Container(
            width: _centerSize,
            height: _centerSize,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}