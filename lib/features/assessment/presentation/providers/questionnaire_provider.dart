import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/comm_slot_state.dart';
import '../../domain/models/question_model.dart';
import '../../domain/repositories/question_repository.dart';
import '../../data/repositories/question_repository_impl.dart';

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
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void resetQuestionnaire() => state = const QuestionnaireState();
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

  const QuestionnaireState({
    this.responses = const {},
    this.domainScores = const {},
    this.domainPercentages = const {},
    this.isLoading = false,
    this.isCompleted = false,
    this.error,
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
  }) {
    return QuestionnaireState(
      responses: responses ?? this.responses,
      domainScores: domainScores ?? this.domainScores,
      domainPercentages: domainPercentages ?? this.domainPercentages,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}