import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/question_model.dart';
import '../../domain/repositories/question_repository.dart';
import '../../data/repositories/question_repository_impl.dart';

part 'questionnaire_provider.g.dart';

// Repository provider — swap implementation here (e.g. for tests)
final questionRepositoryProvider = Provider<QuestionRepository>(
  (ref) => QuestionRepositoryImpl(),
);

@riverpod
class QuestionnaireNotifier extends _$QuestionnaireNotifier {
  @override
  QuestionnaireState build() {
    return const QuestionnaireState();
  }

  void answerQuestion(String questionId, String answer) {
    final responses = Map<String, String>.from(state.responses);
    responses[questionId] = answer;
    
    state = state.copyWith(responses: responses);
  }

  Future<void> completeAssessment() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual assessment completion logic
      // This would involve:
      // 1. Calculating scores for each domain
      // 2. Running AI analysis for ADHD/ASD detection
      // 3. Saving the assessment results
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void resetQuestionnaire() {
    state = const QuestionnaireState();
  }
}

@riverpod
Future<List<QuestionModel>> questions(QuestionsRef ref, String ageGroup) async {
  final repo = ref.read(questionRepositoryProvider);
  return repo.getQuestionsForAgeGroup(ageGroup);
}

class QuestionnaireState {
  final Map<String, String> responses;
  final bool isLoading;
  final bool isCompleted;
  final String? error;

  const QuestionnaireState({
    this.responses = const {},
    this.isLoading = false,
    this.isCompleted = false,
    this.error,
  });

  QuestionnaireState copyWith({
    Map<String, String>? responses,
    bool? isLoading,
    bool? isCompleted,
    String? error,
  }) {
    return QuestionnaireState(
      responses: responses ?? this.responses,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}
