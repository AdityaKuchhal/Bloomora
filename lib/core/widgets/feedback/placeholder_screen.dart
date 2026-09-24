import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';
import '../buttons/app_button.dart';

/// "Coming soon" placeholder for a route whose real screen isn't built
/// yet — always includes a safe way out (never a dead end), per FT-003.
///
/// Use for routes annotated in the FT-003 route map as not-yet-built; do
/// NOT use this in place of an existing real screen (see FT-003's report
/// for which routes already have one).
class PlaceholderScreen extends ConsumerWidget {
  final String title;
  final String message;
  final String safeActionLabel;
  final String safeActionRoute;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.message = 'This part of Bloomora is still being built.',
    required this.safeActionLabel,
    required this.safeActionRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.construction_outlined, size: 44, color: scheme.textMuted),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(color: scheme.textPrimary),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: scheme.textSecondary),
                ),
                const SizedBox(height: AppSpacing.space6),
                AppButton.secondary(
                  label: safeActionLabel,
                  onPressed: () => context.go(safeActionRoute),
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
