import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';

/// Deep-link-only screen: reachable with NO session (that's the point of
/// password recovery), and — per route_guards.dart's `neutral` set — never
/// auto-redirected into or out of based on session state, so forging a
/// query param after this path can't be used to jump into a guarded route.
///
/// The recovery `code` query param is Supabase's own opaque token, never a
/// user/child id — this screen only ever learns *which* user it is after
/// [GoTrueClient.exchangeCodeForSession] succeeds, never before. This is
/// the whole point of the "don't trust a raw route parameter as identity"
/// rule in FT-003.
///
/// NOTE: no native deep-link delivery exists yet in this app (no URL
/// scheme registered, no incoming-link listener) — see FT-003's report.
/// This screen is correct and ready for when that's wired up, but can't be
/// exercised end-to-end via a real emailed link today; it's exercised here
/// by opening `/reset-password?code=...` directly.
class ResetPasswordPage extends ConsumerStatefulWidget {
  final String? code;

  const ResetPasswordPage({super.key, this.code});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

enum _Stage { exchanging, invalid, ready, submitting, done }

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  _Stage _stage = _Stage.exchanging;
  String? _error;
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _exchange();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _exchange() async {
    final code = widget.code;
    if (code == null || code.isEmpty) {
      setState(() => _stage = _Stage.invalid);
      return;
    }
    try {
      await SupabaseService.auth.exchangeCodeForSession(code);
      if (mounted) setState(() => _stage = _Stage.ready);
    } catch (_) {
      if (mounted) setState(() => _stage = _Stage.invalid);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _stage = _Stage.submitting);
    try {
      await SupabaseService.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );
      // Sign out the temporary recovery session — the user must sign in
      // fresh with the new password, rather than this deep link silently
      // leaving them authenticated in the app.
      await SupabaseService.auth.signOut();
      if (mounted) setState(() => _stage = _Stage.done);
    } catch (e) {
      if (mounted) {
        setState(() {
          _stage = _Stage.ready;
          _error = 'Could not update password. Try the reset link again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: _buildBody(scheme),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppColorScheme scheme) {
    switch (_stage) {
      case _Stage.exchanging:
        return const Center(child: CircularProgressIndicator());

      case _Stage.invalid:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off, size: 44, color: scheme.textMuted),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'This reset link is invalid or has expired',
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(color: scheme.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Request a new password reset from the sign-in screen.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: scheme.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space6),
            AppButton.primary(
              label: 'Back to sign in',
              onPressed: () => context.go(AppRoutes.signIn),
              expand: false,
            ),
          ],
        );

      case _Stage.ready:
      case _Stage.submitting:
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Set a new password',
                textAlign: TextAlign.center,
                style: AppTypography.h3.copyWith(color: scheme.textPrimary),
              ),
              const SizedBox(height: AppSpacing.space5),
              AppTextField(
                label: 'New password',
                hint: 'At least 8 characters',
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                errorText: _error,
                validator: (v) => (v == null || v.length < 8)
                    ? 'Password must be at least 8 characters'
                    : null,
                controller: _passwordController,
              ),
              const SizedBox(height: AppSpacing.space5),
              AppButton.primary(
                label: 'Update password',
                isLoading: _stage == _Stage.submitting,
                onPressed: _stage == _Stage.submitting ? null : _submit,
              ),
            ],
          ),
        );

      case _Stage.done:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 44, color: scheme.primary),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Password updated',
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(color: scheme.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Sign in with your new password.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: scheme.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space6),
            AppButton.primary(
              label: 'Back to sign in',
              onPressed: () => context.go(AppRoutes.signIn),
              expand: false,
            ),
          ],
        );
    }
  }
}
