import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/domain/models/child_model.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import 'supabase_service.dart';

/// Loads the signed-in user's child into [childNotifierProvider], if one
/// exists — used right after sign-in/sign-up/verification so the app-wide
/// active-child state (which lib/core/theme/theme_provider.dart's
/// activeColorSchemeProvider already resolves the Ocean/Blossom theme from)
/// is populated for returning users, not just newly-onboarded ones.
///
/// This used to also decide *where* to navigate (`getPostLoginRoute`) —
/// that responsibility now belongs entirely to
/// lib/core/router/route_guards.dart's onboarding-step resolver, which
/// re-evaluates on every navigation rather than computing a one-shot
/// decision here. Callers should just `context.go(AppRoutes.home)` after
/// calling this and let the router redirect to the correct onboarding step
/// if one isn't finished — see auth_page.dart / email_verification_page.dart.
class NavigationService {
  static Future<void> loadActiveChildIfAny(WidgetRef ref) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      final response = await SupabaseService.client
          .from('children')
          .select()
          .eq('parent_id', userId)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return;
      applyChildRow(ref, response);
    } catch (_) {
      // Best-effort: theme/state population, not a security or navigation
      // decision — route_guards.dart's own direct queries are what actually
      // gate access, so a failure here just means the theme falls back to
      // its pre-child default rather than blocking anything.
    }
  }

  /// Parses a raw Supabase `children` row and applies it to
  /// [childNotifierProvider] — split out from [loadActiveChildIfAny] so
  /// this parsing/wiring step (the actual fix: this was never called at all
  /// for a returning sign-in before FT-003, only during fresh onboarding —
  /// see git history) is unit-testable without a live Supabase connection.
  /// See test/core/services/navigation_service_test.dart.
  static void applyChildRow(WidgetRef ref, Map<String, dynamic> response) {
    final child = ChildModel(
      id: response['id'] as String,
      parentId: response['parent_id'] as String,
      name: response['name'] as String,
      dateOfBirth: DateTime.parse(response['date_of_birth'] as String),
      gender: response['gender'] as String,
      ageGroup: response['age_group'] as String? ?? '',
      relationship: response['relationship'] as String?,
      createdAt: DateTime.parse(response['created_at'] as String),
      updatedAt: DateTime.parse(response['updated_at'] as String),
    );

    ref.read(childNotifierProvider.notifier).setChild(child);
  }
}
