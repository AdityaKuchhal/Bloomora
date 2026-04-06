import '../services/supabase_service.dart';

class NavigationService {

  /// Determines the correct post-login route by querying Supabase.
  ///
  /// [onGenderDetected] is an optional callback invoked with the child's gender
  /// string ('boy' or 'girl') once the child profile is loaded. Use this to
  /// apply the gender theme from the call site, avoiding Ref/WidgetRef coupling.
  static Future<String> getPostLoginRoute({
    void Function(String gender)? onGenderDetected,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return '/parent-signup';

      // STEP 1 — Fetch child profile from Supabase
      final childResponse = await SupabaseService.client
          .from('children')
          .select()
          .eq('parent_id', userId)
          .maybeSingle();

      // No child profile
      if (childResponse == null) return '/child-profile';

      // STEP 2 — Notify caller of gender so it can apply the theme
      final gender = (childResponse['gender'] as String? ?? 'boy').toLowerCase();
      onGenderDetected?.call(gender == 'girl' ? 'girl' : 'boy');

      final childId = childResponse['id'] as String;

      // STEP 3 — Fetch assessment status
      final assessmentResponse = await SupabaseService.client
          .from('assessments')
          .select()
          .eq('child_id', childId)
          .eq('status', 'completed')
          .maybeSingle();

      // No completed assessment
      if (assessmentResponse == null) return '/questionnaire';

      final assessmentId = assessmentResponse['id'] as String;

      // STEP 4 — Check if priority selection is done
      // Table may not exist yet — fall through to dashboard on any error
      try {
        final priorityResponse = await SupabaseService.client
            .from('priority_selections')
            .select()
            .eq('assessment_id', assessmentId)
            .maybeSingle();

        if (priorityResponse == null) return '/priority-selection';

        return '/dashboard';
      } catch (_) {
        return '/dashboard';
      }

    } catch (e) {
      // On any error, safe fallback
      return '/child-profile';
    }
  }
}