import '../models/question_model.dart';

abstract class QuestionRepository {
  Future<List<QuestionModel>> getQuestionsForAgeGroup(String ageGroup);
  Future<QuestionModel> getQuestionById(String questionId);
  Future<List<QuestionModel>> getQuestionsForDomain(String domain, String ageGroup);
}
