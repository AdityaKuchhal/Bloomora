import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/models/question_model.dart';
import '../../domain/models/assessment_response_model.dart';
import '../../domain/repositories/question_repository.dart';

part 'questionnaire_provider.g.dart';

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
Future<List<QuestionModel>> questions(QuestionsRef ref) async {
  // TODO: Replace with actual repository call
  return _generateSampleQuestions();
}

List<QuestionModel> _generateSampleQuestions() {
  final questions = <QuestionModel>[];
  int questionId = 1;
  
  for (int domainIndex = 0; domainIndex < AppConstants.domains.length; domainIndex++) {
    final domain = AppConstants.domains[domainIndex];
    
    for (int questionNum = 1; questionNum <= AppConstants.questionsPerDomain; questionNum++) {
      questions.add(QuestionModel(
        id: questionId.toString(),
        domain: domain,
        ageGroup: '1-2', // TODO: Get from child data
        questionNumber: questionNum,
        questionText: _getSampleQuestionText(domain, questionNum),
        options: _getSampleOptions(domain, questionNum),
        additionalInfo: questionNum == 1 ? _getDomainDescription(domain) : null,
        isRequired: true,
        weight: 1,
      ));
      questionId++;
    }
  }
  
  return questions;
}

String _getSampleQuestionText(String domain, int questionNum) {
  final questionTemplates = {
    'Fine Motor Skills': [
      'Can your child pick up small objects like Cheerios with their thumb and forefinger?',
      'Does your child try to use a spoon or fork when eating?',
      'Can your child stack 2-3 blocks on top of each other?',
      'Does your child show interest in coloring or drawing?',
      'Can your child turn pages of a book one at a time?',
    ],
    'Gross Motor Skills': [
      'Can your child walk without support?',
      'Does your child try to climb on furniture or playground equipment?',
      'Can your child kick a ball forward?',
      'Does your child enjoy running and jumping?',
      'Can your child walk up and down stairs with support?',
    ],
    'Communication': [
      'Does your child use single words to communicate?',
      'Can your child follow simple one-step instructions?',
      'Does your child point to objects they want?',
      'Can your child say "mama" or "dada" with meaning?',
      'Does your child try to imitate sounds or words?',
    ],
    'Social-Emotional': [
      'Does your child show affection to familiar people?',
      'Can your child play simple games like peek-a-boo?',
      'Does your child show interest in other children?',
      'Can your child express frustration appropriately?',
      'Does your child seek comfort when upset?',
    ],
    'Cognitive': [
      'Does your child recognize familiar people and objects?',
      'Can your child solve simple problems (like getting a toy that\'s out of reach)?',
      'Does your child show interest in cause and effect?',
      'Can your child remember where toys are hidden?',
      'Does your child show curiosity about new things?',
    ],
    'Adaptive Skills': [
      'Does your child try to feed themselves?',
      'Can your child help with simple tasks like putting toys away?',
      'Does your child show interest in dressing themselves?',
      'Can your child use a cup or bottle independently?',
      'Does your child try to help with household activities?',
    ],
    'Sensory Processing': [
      'Does your child react strongly to loud noises?',
      'Can your child tolerate different textures of food?',
      'Does your child seek or avoid certain types of touch?',
      'Can your child focus on activities for a few minutes?',
      'Does your child seem over or under-sensitive to sensory input?',
    ],
  };
  
  final domainQuestions = questionTemplates[domain] ?? [];
  if (questionNum <= domainQuestions.length) {
    return domainQuestions[questionNum - 1];
  }
  
  return 'Sample question for $domain - Question $questionNum';
}

List<String> _getSampleOptions(String domain, int questionNum) {
  return [
    'Always',
    'Often',
    'Sometimes',
    'Rarely',
    'Never',
  ];
}

String _getDomainDescription(String domain) {
  return AppConstants.domainDescriptions[domain] ?? 
         'This section assesses your child\'s $domain development.';
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
