import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/comm_slot_state.dart';
import '../../domain/models/question_model.dart';
import '../../domain/repositories/question_repository.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../../../core/router/route_guards.dart';
import '../../../../core/services/supabase_service.dart';

part 'questionnaire_provider.g.dart';

final questionRepositoryProvider = Provider<QuestionRepository>(
  (ref) => QuestionRepositoryImpl(),
);

@riverpod
class QuestionnaireNotifier extends _$QuestionnaireNotifier {
  @override
  QuestionnaireState build() => const QuestionnaireState();

  /// Score: 0 = Not yet, 1 = Sometimes, 2 = Consistently
  void answerQuestion(String questionId, int score) {
    final responses = Map<String, int>.from(state.responses);
    responses[questionId] = score;
    state = state.copyWith(responses: responses);
  }

  Future<void> completeAssessment({
    required List<QuestionModel> regularQuestions,
    required List<CommSlotState> commSlots,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final domainScores = <String, int>{};
      final domainMaxScores = <String, int>{};

      // Regular domains: sum responses
      for (final q in regularQuestions) {
        final score = state.responses[q.id] ?? 0;
        domainScores[q.domain] = (domainScores[q.domain] ?? 0) + score;
        domainMaxScores[q.domain] = (domainMaxScores[q.domain] ?? 0) + 2;
      }

      // Communication domain: average each slot's chain scores, treat as 0–2
      const commDomain = 'Communication';
      for (final slot in commSlots) {
        final slotScore = slot.averageScore.round();
        domainScores[commDomain] = (domainScores[commDomain] ?? 0) + slotScore;
        domainMaxScores[commDomain] = (domainMaxScores[commDomain] ?? 0) + 2;
      }

      final domainPercentages = <String, double>{};
      for (final domain in domainScores.keys) {
        final max = domainMaxScores[domain] ?? 1;
        domainPercentages[domain] =
            (domainScores[domain]! / max * 100).clamp(0.0, 100.0);
      }

      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
        domainScores: domainScores,
        domainPercentages: domainPercentages,
        commSlots: commSlots,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void resetQuestionnaire() => state = const QuestionnaireState();

  void syncCommSlots(List<CommSlotState> slots) {
    state = state.copyWith(commSlots: slots);
  }

  Future<String?> saveAssessment({
    required List<QuestionModel> regularQuestions,
    required List<CommSlotState> commSlots,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get child ID from Supabase
      final childResponse = await SupabaseService.client
          .from('children')
          .select('id, age_group')
          .eq('parent_id', userId)
          .single();

      final childId = childResponse['id'] as String;
      final ageGroup = childResponse['age_group'] as String;

      final now = DateTime.now().toUtc().toIso8601String();

      // STEP 1 — Create assessment record
      final assessmentResponse = await SupabaseService.client
          .from('assessments')
          .insert({
            'child_id': childId,
            'parent_id': userId,
            'age_group': ageGroup,
            'completed_at': now,
            'created_at': now,
          })
          .select()
          .single();

      final assessmentId = assessmentResponse['id'] as String;

      // STEP 2 — Save individual question responses
      final responseRows = <Map<String, dynamic>>[];

      // Regular questions
      for (final q in regularQuestions) {
        final score = state.responses[q.id] ?? 0;
        responseRows.add({
          'assessment_id': assessmentId,
          'question_id': q.id,
          'domain': q.domain,
          'score': score,
          'created_at': now,
        });
      }

      // Communication domain slots — iterate chain+scores directly
      // to save one row per answered level with the actual question ID
      for (final slot in commSlots) {
        for (int level = 0; level < slot.chain.length; level++) {
          final score = slot.scores[level];
          if (score != null) {
            responseRows.add({
              'assessment_id': assessmentId,
              'question_id': slot.chain[level].id,
              'domain': 'Communication',
              'score': score,
              'created_at': now,
            });
          }
        }
      }

      await SupabaseService.client
          .from('assessment_responses')
          .insert(responseRows);

      // STEP 3 — Save domain results
      final domainResultRows = <Map<String, dynamic>>[];

      for (final domain in state.domainScores.keys) {
        final rawScore = state.domainScores[domain] ?? 0;
        final maxScore = domain == 'Communication'
            ? commSlots.length * 2
            : regularQuestions
                    .where((q) => q.domain == domain)
                    .length *
                2;
        final percentage = state.domainPercentages[domain] ?? 0.0;
        final level = state.domainLevel(domain);

        domainResultRows.add({
          'assessment_id': assessmentId,
          'domain': domain,
          'raw_score': rawScore,
          'max_score': maxScore,
          'percentage': percentage,
          'level': level,
          'created_at': now,
        });
      }

      await SupabaseService.client
          .from('domain_results')
          .insert(domainResultRows);

      // STEP 4 — Store assessmentId in state for downstream use
      state = state.copyWith(assessmentId: assessmentId);

      // See route_guards.dart's OnboardingCompleteCache doc comment: not a
      // fix for today's flow (this user can't have been cached "complete"
      // if AssessmentStepCheck was still failing them into this screen),
      // but keeps a future retake/re-assessment flow correct too.
      ref.read(onboardingCompleteCacheProvider.notifier).invalidate(userId);

      return assessmentId;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

@riverpod
Future<List<QuestionModel>> questions(QuestionsRef ref, String ageGroup) {
  final repo = ref.read(questionRepositoryProvider);
  return repo.getQuestionsForAgeGroup(ageGroup);
}

class QuestionnaireState {
  final Map<String, int> responses;
  final Map<String, int> domainScores;
  final Map<String, double> domainPercentages;
  final bool isLoading;
  final bool isCompleted;
  final String? error;
  final String? assessmentId;
  final List<CommSlotState> commSlots;

  const QuestionnaireState({
    this.responses = const {},
    this.domainScores = const {},
    this.domainPercentages = const {},
    this.isLoading = false,
    this.isCompleted = false,
    this.error,
    this.assessmentId,
    this.commSlots = const [],
  });

  /// Skill level for a domain based on percentage
  /// < 40% → Needs Support, 40–70% → Developing, > 70% → On Track
  String domainLevel(String domain) {
    final pct = domainPercentages[domain] ?? 0;
    if (pct >= 70) return 'On Track';
    if (pct >= 40) return 'Developing';
    return 'Needs Support';
  }

  QuestionnaireState copyWith({
    Map<String, int>? responses,
    Map<String, int>? domainScores,
    Map<String, double>? domainPercentages,
    bool? isLoading,
    bool? isCompleted,
    String? error,
    String? assessmentId,
    List<CommSlotState>? commSlots,
  }) {
    return QuestionnaireState(
      responses: responses ?? this.responses,
      domainScores: domainScores ?? this.domainScores,
      domainPercentages: domainPercentages ?? this.domainPercentages,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
      assessmentId: assessmentId ?? this.assessmentId,
      commSlots: commSlots ?? this.commSlots,
    );
  }
}