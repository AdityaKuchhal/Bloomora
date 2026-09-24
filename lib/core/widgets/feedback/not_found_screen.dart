import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../router/app_routes.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';
import '../buttons/app_button.dart';

/// The safe fallback for any unknown/deprecated route (wired as GoRouter's
/// `errorBuilder`) — never a crash or blank screen.
///
/// The "safe action" target is just /home or /welcome; it doesn't need to
/// duplicate the onboarding resolver's logic — navigating to /home when
/// onboarding is incomplete is itself caught and correctly redirected by
/// route_guards.dart's evaluateRedirect on that next navigation.
class NotFoundScreen extends ConsumerWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;
    final target = isAuthenticated ? AppRoutes.home : AppRoutes.welcome;
    final label = isAuthenticated ? 'Go to Home' : 'Go to Welcome';

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_off_outlined, size: 44, color: scheme.textMuted),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  "We couldn't find that page",
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(color: scheme.textPrimary),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  "It may have moved, or the link may be outdated.",
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: scheme.textSecondary),
                ),
                const SizedBox(height: AppSpacing.space6),
                AppButton.primary(
                  label: label,
                  onPressed: () => context.go(target),
                  expand: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
