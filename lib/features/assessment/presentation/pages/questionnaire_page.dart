import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphism_app_bar.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/progress_indicator.dart';
import '../providers/questionnaire_provider.dart';

class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < AppConstants.totalQuestions - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeQuestionnaire();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/email-verification');
    }
  }

  void _onAnswerSelected(String answer) {
    final ageGroup =
        ref.read(childNotifierProvider)?.ageGroup ?? '1-2';
    final questionsList = ref.read(questionsProvider(ageGroup)).when(
          data: (questions) => questions,
          loading: () => <dynamic>[],
          error: (_, __) => <dynamic>[],
        );

    if (questionsList.isNotEmpty &&
        _currentQuestionIndex < questionsList.length) {
      ref
          .read(questionnaireNotifierProvider.notifier)
          .answerQuestion(questionsList[_currentQuestionIndex].id, answer);

      // Auto-advance to next question after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    }
  }

  Future<void> _completeQuestionnaire() async {
    try {
      await ref
          .read(questionnaireNotifierProvider.notifier)
          .completeAssessment();

      if (mounted) {
        context.go('/priority-selection');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing assessment: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireState = ref.watch(questionnaireNotifierProvider);
    final ageGroup = ref.watch(childNotifierProvider)?.ageGroup ?? '1-2';
    final questions = ref.watch(questionsProvider(ageGroup));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: GlassmorphismAppBar(
        title: 'Assessment',
        showAppName: false,
        leading: GestureDetector(
          onTap: _previousQuestion,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF000000),
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.all(24),
            child: Consumer(
              builder: (context, ref, child) {
                final childData = ref.watch(childNotifierProvider);
                final ageGroup = childData?.ageGroup ?? '1-2';
                return CustomProgressIndicator(
                  currentQuestion: _currentQuestionIndex + 1,
                  totalQuestions: AppConstants.totalQuestions,
                  currentDomain: 'Age Group: $ageGroup years',
                );
              },
            ),
          ),

          // Questions
          Expanded(
            child: questions.when(
              data: (questionsList) {
                if (questionsList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentQuestionIndex = index;
                    });
                  },
                  itemCount: questionsList.length,
                  itemBuilder: (context, index) {
                    final question = questionsList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                      ),
                      child: QuestionCard(
                        question: question,
                        questionNumber: index + 1,
                        onAnswerSelected: _onAnswerSelected,
                        selectedAnswer:
                            questionnaireState.responses[question.id],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading questions',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(questionsProvider(ageGroup));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
